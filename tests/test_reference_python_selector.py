from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SELECTOR = ROOT / "scripts" / "select_reference_python.sh"


def _fake_interpreter(directory: Path, name: str) -> Path:
    path = directory / name
    path.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    path.chmod(0o755)
    return path


def _select(tmp_path: Path, **environment: str) -> subprocess.CompletedProcess[str]:
    env = {
        "PATH": str(tmp_path),
        "RETA_PROJECT_ROOT": str(tmp_path / "project"),
        **environment,
    }
    return subprocess.run(
        ["/bin/sh", str(SELECTOR)],
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def test_prefers_pypy3_over_python3(tmp_path: Path) -> None:
    pypy = _fake_interpreter(tmp_path, "pypy3")
    _fake_interpreter(tmp_path, "python3")
    result = _select(tmp_path)
    assert result.returncode == 0, result.stderr
    assert Path(result.stdout.strip()) == pypy


def test_explicit_reference_interpreter_has_highest_priority(tmp_path: Path) -> None:
    explicit = _fake_interpreter(tmp_path, "reference-python")
    _fake_interpreter(tmp_path, "pypy3")
    result = _select(tmp_path, RETA_REFERENCE_PYTHON=str(explicit))
    assert result.returncode == 0, result.stderr
    assert Path(result.stdout.strip()) == explicit


def test_historical_reta_python_is_supported(tmp_path: Path) -> None:
    explicit = _fake_interpreter(tmp_path, "legacy-python")
    result = _select(tmp_path, RETA_PYTHON="legacy-python")
    assert result.returncode == 0, result.stderr
    assert Path(result.stdout.strip()) == explicit


def test_invalid_explicit_interpreter_fails_instead_of_silently_switching(tmp_path: Path) -> None:
    _fake_interpreter(tmp_path, "pypy3")
    result = _select(tmp_path, RETA_REFERENCE_PYTHON="missing-python")
    assert result.returncode == 127
    assert "nicht ausführbar" in result.stderr


def test_venv_is_only_last_resort(tmp_path: Path) -> None:
    venv_python = tmp_path / "project" / ".venv" / "bin" / "python"
    venv_python.parent.mkdir(parents=True)
    venv_python.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    venv_python.chmod(0o755)
    result = _select(tmp_path)
    assert result.returncode == 0, result.stderr
    assert Path(result.stdout.strip()) == venv_python
