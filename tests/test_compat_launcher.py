from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
_configured_binary = Path(
    os.environ.get(
        "RETA_COMPAT_BINARY",
        ROOT / "target" / "test-bin" / "reta-mojo-compat-bin",
    )
)
BINARY = (ROOT / _configured_binary).resolve() if not _configured_binary.is_absolute() else _configured_binary


def _run_compat(
    arguments: list[str],
    *,
    cwd: Path = ROOT,
    python: str | None = None,
    extra_env: dict[str, str] | None = None,
) -> subprocess.CompletedProcess[bytes]:
    assert BINARY.is_file(), f"missing compatibility binary: {BINARY}"
    return subprocess.run(
        [str(BINARY), *arguments],
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        env={
            **os.environ,
            "RETA_PYTHON": python or sys.executable,
            **(extra_env or {}),
        },
        check=False,
    )


def test_compat_launcher_preserves_typed_argv_streams_and_exit_status(
    tmp_path: Path,
) -> None:
    reference = tmp_path / "python_reference"
    reference.mkdir()
    (reference / "reta.py").write_text(
        "import os, sys\n"
        "sys.stdout.buffer.write(os.getcwd().encode('utf-8') + b'\\n')\n"
        "sys.stdout.buffer.write(b'\\0'.join(a.encode('utf-8') for a in sys.argv))\n"
        "sys.stderr.buffer.write(bytes([101, 114, 114, 58, 0, 255]))\n"
        "raise SystemExit(37)\n",
        encoding="utf-8",
    )

    result = _run_compat(
        ["--name=alpha beta", "", "ä λ", "quote'and\"double"],
        cwd=tmp_path,
    )

    expected_arguments = [
        "reta.py",
        "--name=alpha beta",
        "",
        "ä λ",
        "quote'and\"double",
    ]
    expected_stdout = str(reference).encode() + b"\n" + b"\0".join(
        value.encode() for value in expected_arguments
    )
    assert (result.returncode, result.stdout, result.stderr) == (
        37,
        expected_stdout,
        bytes([101, 114, 114, 58, 0, 255]),
    )



def test_supported_historical_cli_runs_without_python_child() -> None:
    arguments = [
        "-zeilen",
        "--vorhervonausschnitt=1-2",
        "-spalten",
        "--religionen=sternpolygon",
        "-ausgabe",
        "--art=shell",
        "--breite=40",
    ]
    native = _run_compat(arguments, python="/definitely/not/available")
    reference = subprocess.run(
        [sys.executable, "reta.py", *arguments],
        cwd=ROOT / "python_reference",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )

def test_compat_launcher_matches_reference_table_bytes() -> None:
    arguments = [
        "-zeilen",
        "--vorhervonausschnitt=1-2",
        "-spalten",
        "--religionen=sternpolygon",
        "--breite=40",
    ]
    native = _run_compat(arguments)
    reference = subprocess.run(
        [sys.executable, "reta.py", *arguments],
        cwd=ROOT / "python_reference",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )



def _write_fake_python(path: Path, status: int) -> None:
    path.write_text(
        "#!/usr/bin/env python3\n"
        "import os, sys\n"
        "sys.stdout.buffer.write(os.getcwd().encode('utf-8') + b'\\n')\n"
        "sys.stdout.buffer.write(b'\\0'.join(a.encode('utf-8') for a in sys.argv[1:]))\n"
        f"raise SystemExit({status})\n",
        encoding="utf-8",
    )
    path.chmod(0o755)


def test_shell_onetable_runs_without_python_child() -> None:
    arguments = [
        "-zeilen",
        "--vorhervonausschnitt=1-3",
        "-spalten",
        "--religionen=sternpolygon",
        "-ausgabe",
        "--art=shell",
        "--breite=12",
        "--nocolor",
        "--onetable",
    ]
    native = _run_compat(arguments, python="/definitely/not/available")
    reference = subprocess.run(
        [sys.executable, "reta.py", *arguments],
        cwd=ROOT / "python_reference",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert (native.returncode, native.stdout, native.stderr) == (
        reference.returncode,
        reference.stdout,
        reference.stderr,
    )


def test_markup_onetable_remains_atomic_python_fallback(tmp_path: Path) -> None:
    fake_python = tmp_path / "fake-python"
    _write_fake_python(fake_python, 23)
    arguments = [
        "-zeilen",
        "--vorhervonausschnitt=1-2",
        "-spalten",
        "--religionen=sternpolygon",
        "-ausgabe",
        "--art=html",
        "--onetable",
    ]
    result = _run_compat(arguments, python=str(fake_python))
    expected = (ROOT / "python_reference").as_posix().encode() + b"\n" + b"\0".join(
        value.encode() for value in ["reta.py", *arguments]
    )
    assert (result.returncode, result.stdout, result.stderr) == (23, expected, b"")


def test_empty_cli_remains_on_complete_reference_surface(tmp_path: Path) -> None:
    fake_python = tmp_path / "fake-python"
    _write_fake_python(fake_python, 19)
    result = _run_compat([], python=str(fake_python))
    expected = (ROOT / "python_reference").as_posix().encode() + b"\nreta.py"
    assert (result.returncode, result.stdout, result.stderr) == (19, expected, b"")


def test_force_reference_override_keeps_full_legacy_surface(tmp_path: Path) -> None:
    fake_python = tmp_path / "fake-python"
    _write_fake_python(fake_python, 17)
    arguments = [
        "-zeilen",
        "--vorhervonausschnitt=1-2",
        "-spalten",
        "--religionen=sternpolygon",
        "-ausgabe",
        "--art=csv",
    ]
    result = _run_compat(
        arguments,
        python=str(fake_python),
        extra_env={"RETA_FORCE_REFERENCE": "1"},
    )
    expected = (ROOT / "python_reference").as_posix().encode() + b"\n" + b"\0".join(
        value.encode() for value in ["reta.py", *arguments]
    )
    assert (result.returncode, result.stdout, result.stderr) == (17, expected, b"")

def test_compat_source_contains_no_embedded_python() -> None:
    source = (ROOT / "src" / "compat_main.mojo").read_text(encoding="utf-8")
    adapter = (
        ROOT / "src" / "reta_mojo" / "prompt_external_commands.mojo"
    ).read_text(encoding="utf-8")
    assert "from std.python import" not in source
    assert "PythonObject" not in source
    assert "native_reta_tokens_supported(" in source
    assert 'getenv("RETA_FORCE_REFERENCE", "") == "1"' in source
    assert "run_native_reta(arguments, _REFERENCE_CSV)" in source
    assert "run_reta_arguments_native(arguments)" in source
    assert 'external_call["exit", NoneType]' in source
    assert "def run_reta_arguments_native(" in adapter


def test_compat_shell_launcher_preserves_project_interpreter() -> None:
    source = (ROOT / "bin" / "reta-mojo-compat").read_text(encoding="utf-8")
    assert '[ -z "${RETA_PYTHON-}" ]' in source
    assert '[ -x "$ROOT/.venv/bin/python" ]' in source
    assert 'RETA_PYTHON="$ROOT/.venv/bin/python"' in source
    assert "export RETA_PYTHON" in source
