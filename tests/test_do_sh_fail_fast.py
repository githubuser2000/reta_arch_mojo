from __future__ import annotations

import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DO_SH = ROOT / "do.sh"


def _write_executable(path: Path, body: str) -> None:
    path.write_text("#!/usr/bin/env sh\nset -u\n" + body, encoding="utf-8")
    path.chmod(0o755)


def _fake_project(tmp_path: Path, *, failing_step: str) -> Path:
    project = tmp_path / "project"
    scripts = project / "scripts"
    fake_bin = project / "fake-bin"
    scripts.mkdir(parents=True)
    fake_bin.mkdir()
    (project / "do.sh").write_text(DO_SH.read_text(encoding="utf-8"), encoding="utf-8")
    (project / "do.sh").chmod(0o755)

    steps = (
        "build-all.sh",
        "test_current_stage.sh",
        "build-and-test-shared-diagnostics.sh",
        "test_all.sh",
    )
    for name in steps:
        status = 23 if name == failing_step else 0
        _write_executable(
            scripts / name,
            f'printf "%s\\n" "{name}" >> "$TRACE_FILE"\n'
            f'printf "%s\\n" "diagnostic from {name}" >&2\n'
            f"exit {status}\n",
        )

    _write_executable(
        fake_bin / "git",
        'printf "%s\\n" "git $*" >> "$TRACE_FILE"\nexit 0\n',
    )
    return project


def _run(project: Path, trace: Path) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env["TRACE_FILE"] = str(trace)
    env["PATH"] = str(project / "fake-bin") + os.pathsep + env["PATH"]
    return subprocess.run(
        [str(project / "do.sh"), "test-commit"],
        cwd=project,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def test_do_sh_does_not_change_to_its_own_directory() -> None:
    source = DO_SH.read_text(encoding="utf-8")
    assert 'dirname -- "$0"' not in source
    assert 'cd "$ROOT"' not in source
    assert "aktueller Verzeichniswechsel" not in source
    assert "kein automatischer Verzeichniswechsel" in source
    assert "scripts/test_current_stage.sh" in source


def test_failed_full_build_preserves_diagnostic_and_skips_every_later_step(
    tmp_path: Path,
) -> None:
    trace = tmp_path / "trace"
    project = _fake_project(tmp_path, failing_step="build-all.sh")
    result = _run(project, trace)
    assert result.returncode == 23
    assert "diagnostic from build-all.sh" in result.stderr
    assert trace.read_text(encoding="utf-8").splitlines() == ["build-all.sh"]
    assert "nicht ausgeführt" in result.stderr


def test_failed_current_stage_skips_shared_test_all_and_commit(tmp_path: Path) -> None:
    trace = tmp_path / "trace"
    project = _fake_project(tmp_path, failing_step="test_current_stage.sh")
    result = _run(project, trace)
    assert result.returncode == 23
    assert "diagnostic from test_current_stage.sh" in result.stderr
    assert trace.read_text(encoding="utf-8").splitlines() == [
        "build-all.sh",
        "test_current_stage.sh",
    ]


def test_failed_shared_build_skips_test_all_and_commit(tmp_path: Path) -> None:
    trace = tmp_path / "trace"
    project = _fake_project(
        tmp_path, failing_step="build-and-test-shared-diagnostics.sh"
    )
    result = _run(project, trace)
    assert result.returncode == 23
    assert "diagnostic from build-and-test-shared-diagnostics.sh" in result.stderr
    assert trace.read_text(encoding="utf-8").splitlines() == [
        "build-all.sh",
        "test_current_stage.sh",
        "build-and-test-shared-diagnostics.sh",
    ]


def test_failed_test_all_skips_commit(tmp_path: Path) -> None:
    trace = tmp_path / "trace"
    project = _fake_project(tmp_path, failing_step="test_all.sh")
    result = _run(project, trace)
    assert result.returncode == 23
    assert "diagnostic from test_all.sh" in result.stderr
    assert trace.read_text(encoding="utf-8").splitlines() == [
        "build-all.sh",
        "test_current_stage.sh",
        "build-and-test-shared-diagnostics.sh",
        "test_all.sh",
    ]


def test_all_green_steps_reach_git_commit(tmp_path: Path) -> None:
    trace = tmp_path / "trace"
    project = _fake_project(tmp_path, failing_step="")
    result = _run(project, trace)
    assert result.returncode == 0
    assert trace.read_text(encoding="utf-8").splitlines() == [
        "build-all.sh",
        "test_current_stage.sh",
        "build-and-test-shared-diagnostics.sh",
        "test_all.sh",
        "git add -A",
        "git commit -m test-commit",
    ]
