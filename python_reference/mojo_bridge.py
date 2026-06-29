"""Compatibility bridge used by the incremental Mojo port.

The bridge is intentionally tiny: it only converts an argument list and calls
the untouched Python reference Program. Native Mojo commands never enter this
module.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import Iterable

REFERENCE_ROOT = Path(__file__).resolve().parent


def run_reta(arguments: Iterable[str]) -> int:
    argv = [str(value) for value in arguments]
    if not argv:
        argv = [str(REFERENCE_ROOT / "reta.py")]
    elif argv[0] in {"reta", "reta.py"}:
        argv[0] = str(REFERENCE_ROOT / "reta.py")

    root = str(REFERENCE_ROOT)
    libs = str(REFERENCE_ROOT / "libs")
    if root not in sys.path:
        sys.path.insert(0, root)
    if libs not in sys.path:
        sys.path.insert(0, libs)

    old_cwd = Path.cwd()
    old_argv = sys.argv
    try:
        os.chdir(REFERENCE_ROOT)
        sys.argv = argv
        from reta import Program

        Program(argv)
        return 0
    finally:
        sys.argv = old_argv
        os.chdir(old_cwd)


def run_reta_encoded(encoded: str) -> int:
    """Run reta from a unit-separator-delimited Mojo argument string."""
    return run_reta(str(encoded).split("\x1f"))


def run_reta_subprocess_encoded(encoded: str) -> int:
    """Run the Python reference in a child process to isolate CPython globals."""
    import subprocess

    argv = str(encoded).split("\x1f")
    command = [sys.executable, str(REFERENCE_ROOT / "reta.py"), *argv[1:]]
    completed = subprocess.run(command, cwd=REFERENCE_ROOT, check=False)
    return int(completed.returncode)

# --- Native Mojo prompt operating-system boundary -------------------------
# Prompt state and dispatch live in Mojo. These helpers are deliberately
# limited to services the Mojo standard library does not yet provide with the
# same terminal ergonomics: readline/history and child-process creation.

_PROMPT_READLINE_INITIALIZED = False
_PROMPT_HISTORY_FILE: Path | None = None
_PROMPT_COMPLETION_WORDS: tuple[str, ...] = ()
_PROMPT_COMPLETION_MATCHES: tuple[str, ...] = ()
_PROMPT_COMPLETION_PROCESS = None
_PROMPT_COMPLETION_LANGUAGE = ""


def _close_prompt_completion_process() -> None:
    global _PROMPT_COMPLETION_PROCESS, _PROMPT_COMPLETION_LANGUAGE
    process = _PROMPT_COMPLETION_PROCESS
    _PROMPT_COMPLETION_PROCESS = None
    _PROMPT_COMPLETION_LANGUAGE = ""
    if process is None:
        return
    try:
        if process.stdin is not None:
            process.stdin.close()
        process.terminate()
        process.wait(timeout=1)
    except Exception:
        try:
            process.kill()
        except Exception:
            pass


def _prompt_completion_process(language: str):
    global _PROMPT_COMPLETION_PROCESS, _PROMPT_COMPLETION_LANGUAGE
    import subprocess

    normalized = str(language or "deutsch")
    process = _PROMPT_COMPLETION_PROCESS
    if (
        process is not None
        and process.poll() is None
        and _PROMPT_COMPLETION_LANGUAGE == normalized
    ):
        return process
    _close_prompt_completion_process()
    project_root = REFERENCE_ROOT.parent
    executable = project_root / "target" / "bin" / "reta-prompt-complete"
    if not executable.is_file():
        return None
    try:
        process = subprocess.Popen(
            [str(executable), normalized, str(project_root / "assets")],
            cwd=project_root,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            encoding="utf-8",
            bufsize=1,
        )
    except OSError:
        return None
    _PROMPT_COMPLETION_PROCESS = process
    _PROMPT_COMPLETION_LANGUAGE = normalized
    return process


def _native_prompt_completion(line: str, language: str) -> tuple[str, ...] | None:
    process = _prompt_completion_process(language)
    if process is None or process.stdin is None or process.stdout is None:
        return None
    try:
        process.stdin.write(str(line).replace("\r", " ").replace("\n", " ") + "\n")
        process.stdin.flush()
        count_line = process.stdout.readline()
        if not count_line:
            raise BrokenPipeError("native completion worker closed its output")
        count = int(count_line.strip())
        values = []
        for _ in range(count):
            value = process.stdout.readline()
            if value == "":
                raise BrokenPipeError("native completion worker ended mid-response")
            values.append(value.rstrip("\r\n"))
        return tuple(values)
    except (BrokenPipeError, OSError, ValueError):
        _close_prompt_completion_process()
        return None


def _configure_prompt_readline(
    *,
    vi_mode: bool,
    history_file: str,
    language: str,
    completion_words: Iterable[str],
) -> object | None:
    global _PROMPT_READLINE_INITIALIZED, _PROMPT_HISTORY_FILE
    global _PROMPT_COMPLETION_WORDS, _PROMPT_COMPLETION_MATCHES
    try:
        import readline
    except (ImportError, ModuleNotFoundError):
        return None

    path = Path(history_file).expanduser()
    _PROMPT_COMPLETION_WORDS = tuple(dict.fromkeys(str(word) for word in completion_words if str(word)))

    readline.parse_and_bind("set editing-mode vi" if vi_mode else "set editing-mode emacs")
    readline.parse_and_bind("tab: complete")

    def complete(text: str, state: int) -> str | None:
        global _PROMPT_COMPLETION_MATCHES
        if state == 0:
            native = _native_prompt_completion(readline.get_line_buffer(), language)
            if native is None:
                native = tuple(
                    word for word in _PROMPT_COMPLETION_WORDS if word.startswith(text)
                )
            _PROMPT_COMPLETION_MATCHES = native
        return (
            _PROMPT_COMPLETION_MATCHES[state]
            if state < len(_PROMPT_COMPLETION_MATCHES)
            else None
        )

    readline.set_completer(complete)
    readline.set_completer_delims(" \t\n=,")

    if not _PROMPT_READLINE_INITIALIZED or _PROMPT_HISTORY_FILE != path:
        try:
            readline.read_history_file(path)
        except FileNotFoundError:
            pass
        except OSError:
            pass
        _PROMPT_READLINE_INITIALIZED = True
        _PROMPT_HISTORY_FILE = path
    return readline


import atexit as _prompt_atexit
_prompt_atexit.register(_close_prompt_completion_process)


def read_prompt_line_encoded(encoded: str) -> str:
    """Read one interactive line and return control sentinels for EOF/interrupt.

    Fields: prompt, history-enabled flag, vi-mode flag, history path, then
    completion words; fields are separated by the ASCII unit separator.
    """
    fields = str(encoded).split("\x1f")
    prompt = fields[0] if fields else "> "
    history_enabled = len(fields) > 1 and fields[1] == "1"
    vi_mode = len(fields) > 2 and fields[2] == "1"
    history_file = fields[3] if len(fields) > 3 else str(Path.home() / ".ReTaPromptHistory")
    language = fields[4] if len(fields) > 4 else "deutsch"
    completion_words = fields[5:]
    readline = _configure_prompt_readline(
        vi_mode=vi_mode,
        history_file=history_file,
        language=language,
        completion_words=completion_words,
    )
    try:
        line = input(prompt)
    except EOFError:
        return "\x04"
    except KeyboardInterrupt:
        print()
        return "\x03"

    if readline is not None and history_enabled and line.strip():
        try:
            # input() normally adds the line to in-memory history. Persist the
            # current state; duplicates are retained to match prompt-toolkit.
            readline.write_history_file(Path(history_file).expanduser())
        except OSError:
            pass
    elif readline is not None and not history_enabled and line.strip():
        # GNU readline may have inserted the line despite disabled logging.
        try:
            readline.remove_history_item(readline.get_current_history_length() - 1)
        except (ValueError, IndexError):
            pass
    return line





def run_reta_prompt_subprocess_encoded(encoded: str) -> int:
    """Run one still-unported prompt command in an isolated Python process."""
    import subprocess

    argv = str(encoded).split("\x1f") if str(encoded) else []
    command = [sys.executable, str(REFERENCE_ROOT / "retaPrompt.py"), *argv]
    completed = subprocess.run(command, cwd=REFERENCE_ROOT, check=False)
    return int(completed.returncode)


def run_shell_line(line: str) -> int:
    import shlex
    import subprocess

    argv = shlex.split(str(line))
    if not argv:
        return 0
    return int(subprocess.run(argv, cwd=REFERENCE_ROOT, check=False).returncode)


def run_python_code(code: str) -> int:
    import subprocess

    return int(
        subprocess.run(
            [sys.executable, "-c", str(code)],
            cwd=REFERENCE_ROOT,
            check=False,
        ).returncode
    )


def run_math_expression(expression: str) -> int:
    import subprocess

    return int(
        subprocess.run(
            [sys.executable, "-c", "print(" + str(expression) + ")"],
            cwd=REFERENCE_ROOT,
            check=False,
        ).returncode
    )



def run_reta_line(line: str) -> int:
    """Execute a raw `reta ...` prompt line with shell-like quoting."""
    import shlex
    import subprocess

    argv = shlex.split(str(line))
    if argv and argv[0] == "reta":
        argv = argv[1:]
    command = [sys.executable, str(REFERENCE_ROOT / "reta.py"), *argv]
    return int(subprocess.run(command, cwd=REFERENCE_ROOT, check=False).returncode)


def run_reta_prompt_line_encoded(encoded: str) -> int:
    """Execute a prompt line with profile flags and shell-like tokenization.

    The payload uses an ASCII record separator between profile flags and the raw
    line; profile flags themselves use the unit separator.
    """
    import shlex
    import subprocess

    flags_encoded, separator, raw_line = str(encoded).partition("\x1e")
    flags = [item for item in flags_encoded.split("\x1f") if item]
    words = shlex.split(raw_line) if separator else []
    command = [sys.executable, str(REFERENCE_ROOT / "retaPrompt.py"), *flags, *words]
    return int(subprocess.run(command, cwd=REFERENCE_ROOT, check=False).returncode)


def run_shell_prompt_line(line: str) -> int:
    _command, _space, payload = str(line).partition(" ")
    return run_shell_line(payload)


def run_python_prompt_line(line: str) -> int:
    _command, _space, payload = str(line).partition(" ")
    return run_python_code(payload)


def run_math_prompt_line(line: str) -> int:
    _command, _space, payload = str(line).partition(" ")
    return run_math_expression(payload)

# --- HTML generator operating-system boundary -----------------------------
# The hierarchy renderer and orchestration live in Mojo.  These helpers only
# provide subprocess execution and byte-preserving file streaming while the
# large reta table pipeline is still behind the compatibility boundary.


def generate_html_document(native_hierarchy_html: str, language: str = "") -> int:
    """Generate ``middle.alx`` and stream the complete historical HTML page.

    ``RETA_GENERATE_HTML_MIDDLE_FILE`` is an integration-test seam: when set,
    its bytes are copied to ``middle.alx`` instead of invoking the full table
    pipeline.  Normal users never need this variable.
    """
    import shutil
    import subprocess

    project_root = REFERENCE_ROOT.parent
    middle_path = project_root / "middle.alx"
    override = os.environ.get("RETA_GENERATE_HTML_MIDDLE_FILE", "")
    if override:
        shutil.copyfile(Path(override), middle_path)
    else:
        command = [
            sys.executable,
            str(REFERENCE_ROOT / "reta.py"),
            "-spalten",
            "--alles",
            "--breite=0",
            "-ausgabe",
            "--art=html",
            "--onetable",
            "--nocolor",
        ]
        if language:
            command.append(f"-language={language}")
        row_limit = os.environ.get("RETA_GENERATE_HTML_ROWS", "").strip()
        if row_limit:
            command.extend(["-zeilen", f"--vorhervonausschnitt={row_limit}"])
        with middle_path.open("wb") as middle_file:
            completed = subprocess.run(
                command,
                cwd=REFERENCE_ROOT,
                stdout=middle_file,
                check=False,
            )
        if completed.returncode != 0:
            raise RuntimeError(
                f"reta HTML generation failed with exit code {completed.returncode}"
            )

    output = sys.stdout.buffer
    assets_root = project_root / "assets" / "html"
    for name in ("head1.alx", "religionen.js", "head2.alx"):
        output.write((assets_root / name).read_bytes())
    output.write(middle_path.read_bytes())
    output.write(str(native_hierarchy_html).encode("utf-8"))
    output.write((assets_root / "footer.alx").read_bytes())
    output.flush()
    return 0
