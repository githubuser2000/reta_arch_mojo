from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PROBE = ROOT / "target" / "test-bin" / "prompt-external-commands-probe"


def _native(mode: str, line: str) -> subprocess.CompletedProcess[str]:
    assert PROBE.is_file(), f"missing native probe: {PROBE}"
    return subprocess.run(
        [str(PROBE), mode, line],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env={**os.environ, "RETA_PYTHON": sys.executable},
        check=False,
    )


def _reference(function: str, line: str) -> subprocess.CompletedProcess[str]:
    code = (
        "import sys; sys.path.insert(0, 'python_reference'); "
        "import mojo_bridge; "
        f"raise SystemExit(mojo_bridge.{function}(sys.argv[1]))"
    )
    return subprocess.run(
        [sys.executable, "-c", code, line],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def _native_bytes(
    mode: str, line: str, *, extra_env: dict[str, str] | None = None
) -> subprocess.CompletedProcess[bytes]:
    assert PROBE.is_file(), f"missing native probe: {PROBE}"
    return subprocess.run(
        [str(PROBE), mode, line],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env={
            **os.environ,
            "RETA_PYTHON": sys.executable,
            **(extra_env or {}),
        },
        check=False,
    )


def _reference_bytes(
    function: str, line: str, *, extra_env: dict[str, str] | None = None
) -> subprocess.CompletedProcess[bytes]:
    code = (
        "import sys; sys.path.insert(0, 'python_reference'); "
        "import mojo_bridge; "
        f"raise SystemExit(mojo_bridge.{function}(sys.argv[1]))"
    )
    return subprocess.run(
        [sys.executable, "-c", code, line],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env={**os.environ, **(extra_env or {})},
        check=False,
    )


def test_shell_command_matches_reference_bytes() -> None:
    line = "shell /usr/bin/printf '%s|%s\\n' 'alpha beta' 'ä λ'"
    native = _native("shell", line)
    reference = _reference("run_shell_prompt_line", line)
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )


def test_python_command_matches_reference_unicode() -> None:
    line = 'python print("ä λ", 2 + 3)'
    native = _native("python", line)
    reference = _reference("run_python_prompt_line", line)
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )


def test_math_command_matches_reference() -> None:
    line = "math sum([1, 2, 3]) * 7"
    native = _native("math", line)
    reference = _reference("run_math_prompt_line", line)
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )


def test_shell_preserves_trailing_whitespace_bytes() -> None:
    line = "shell /usr/bin/printf 'tail  \n\n'"
    native = _native_bytes("shell", line)
    reference = _reference_bytes("run_shell_prompt_line", line)
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )
    assert native.stdout == b"tail  \n\n"


def test_shell_preserves_non_utf8_stdout() -> None:
    line = (
        "shell "
        + sys.executable
        + " -c 'import sys;sys.stdout.buffer.write(bytes([0,1,255]))'"
    )
    native = _native_bytes("shell", line)
    reference = _reference_bytes("run_shell_prompt_line", line)
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )
    assert native.stdout == bytes([0, 1, 255])


def test_shell_inherits_environment_exactly() -> None:
    line = "shell /usr/bin/printenv RETA_EXTERNAL_SENTINEL"
    extra_env = {"RETA_EXTERNAL_SENTINEL": "environment-ä-λ"}
    native = _native_bytes("shell", line, extra_env=extra_env)
    reference = _reference_bytes(
        "run_shell_prompt_line", line, extra_env=extra_env
    )
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )
    assert native.stdout == "environment-ä-λ\n".encode()


def test_python_preserves_stderr_bytes() -> None:
    line = (
        "python import sys;"
        "sys.stderr.buffer.write(bytes([101,114,114,58,0,255]))"
    )
    native = _native_bytes("python", line)
    reference = _reference_bytes("run_python_prompt_line", line)
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )
    assert native.stderr == bytes([101, 114, 114, 58, 0, 255])
