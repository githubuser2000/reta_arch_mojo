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


def _configure_prompt_readline(
    *,
    vi_mode: bool,
    history_file: str,
    completion_words: Iterable[str],
) -> object | None:
    global _PROMPT_READLINE_INITIALIZED, _PROMPT_HISTORY_FILE, _PROMPT_COMPLETION_WORDS
    try:
        import readline
    except (ImportError, ModuleNotFoundError):
        return None

    path = Path(history_file).expanduser()
    _PROMPT_COMPLETION_WORDS = tuple(dict.fromkeys(str(word) for word in completion_words if str(word)))

    readline.parse_and_bind("set editing-mode vi" if vi_mode else "set editing-mode emacs")
    readline.parse_and_bind("tab: complete")

    def complete(text: str, state: int) -> str | None:
        matches = [word for word in _PROMPT_COMPLETION_WORDS if word.startswith(text)]
        return matches[state] if state < len(matches) else None

    readline.set_completer(complete)
    readline.set_completer_delims(" \t\n")

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
    completion_words = fields[4:]
    readline = _configure_prompt_readline(
        vi_mode=vi_mode,
        history_file=history_file,
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


def clear_terminal() -> int:
    import subprocess

    return int(subprocess.run(["clear"], check=False).returncode)


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
