from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "tools/run_check_group.py"
RELEASE = ROOT / "scripts/release_check.sh"
ARCH_WRAPPER = ROOT / "scripts/check_architecture_diagnostics.sh"
STAGE12C = ROOT / "scripts/test_stage12c.sh"


def test_check_group_manifests_are_valid_and_commands_exist() -> None:
    manifests = (
        ROOT / "scripts/architecture_diagnostic_checks.tsv",
        ROOT / "scripts/release_catalog_checks.tsv",
        ROOT / "scripts/release_runtime_parity_checks.tsv",
        ROOT / "scripts/stage12c_rendering_parity_checks.tsv",
    )
    for manifest in manifests:
        lines = manifest.read_text(encoding="utf-8").splitlines()
        assert lines[0] == "class\ttitle\tcommand\targs..."
        assert len(lines) > 1
        for raw in lines[1:]:
            execution_class, title, command, *args = raw.split("\t")
            assert execution_class in {"parallel", "serial", "exclusive"}
            assert title
            target = ROOT / command
            assert target.is_file(), (manifest, target, args)
            assert os.access(target, os.X_OK), target


def test_release_check_uses_bounded_groups_and_parallel_test_runner() -> None:
    source = RELEASE.read_text(encoding="utf-8")
    assert "RETA_RELEASE_CHECK_JOBS" in source
    assert "tools/run_check_group.py" in source
    assert "architecture_diagnostic_checks.tsv" in source
    assert "release_catalog_checks.tsv" in source
    assert "release_runtime_parity_checks.tsv" in source
    assert '"$ROOT/scripts/test_all.sh" --run-jobs "$CHECK_JOBS"' in source
    assert "check_build_layout.sh" in source
    assert "check_install_layout.sh" in source
    assert source.index("check_build_layout.sh") < source.index("check_install_layout.sh")


def test_stage12c_parallelizes_only_stateless_rendering_parity_group() -> None:
    source = STAGE12C.read_text(encoding="utf-8")
    manifest = (ROOT / "scripts/stage12c_rendering_parity_checks.tsv").read_text(
        encoding="utf-8"
    )
    assert "stage12c_rendering_parity_checks.tsv" in source
    for forbidden in (
        "check_native_prompt_input.sh",
        "check_prompt_external_commands.sh",
        "check_prompt_terminal_parity.sh",
        "check_completion_word.sh",
        "check_install_layout.sh",
        "check_resource_paths.sh",
        "check_no_blank_contents.sh",
    ):
        assert forbidden not in manifest
        assert forbidden in source


def test_architecture_thread_probe_is_an_exclusive_barrier() -> None:
    manifest = (ROOT / "scripts/architecture_diagnostic_checks.tsv").read_text(
        encoding="utf-8"
    )
    row = next(line for line in manifest.splitlines() if "check_execution_network_parity.sh" in line)
    assert row.startswith("exclusive\t")
    wrapper = ARCH_WRAPPER.read_text(encoding="utf-8")
    assert "RETA_CHECK_JOBS" in wrapper
    assert "RETA_CHECK_CHILD_WORKERS" in wrapper


def test_generic_runner_bounds_parallel_processes_and_preserves_log_order(tmp_path: Path) -> None:
    worker = tmp_path / "worker.py"
    worker.write_text(
        """
from __future__ import annotations
import fcntl
from pathlib import Path
import sys
import time

state = Path(sys.argv[1])
name = sys.argv[2]
state.parent.mkdir(parents=True, exist_ok=True)
state.touch(exist_ok=True)
with state.open('r+', encoding='utf-8') as handle:
    fcntl.flock(handle, fcntl.LOCK_EX)
    fields = handle.read().strip().split(',')
    active = int(fields[0]) if fields and fields[0] else 0
    maximum = int(fields[1]) if len(fields) > 1 else 0
    active += 1
    maximum = max(maximum, active)
    handle.seek(0); handle.truncate(); handle.write(f'{active},{maximum}')
    handle.flush()
    fcntl.flock(handle, fcntl.LOCK_UN)
time.sleep(0.15)
with state.open('r+', encoding='utf-8') as handle:
    fcntl.flock(handle, fcntl.LOCK_EX)
    active, maximum = map(int, handle.read().strip().split(','))
    active -= 1
    handle.seek(0); handle.truncate(); handle.write(f'{active},{maximum}')
    handle.flush()
    fcntl.flock(handle, fcntl.LOCK_UN)
print(name)
""".lstrip(),
        encoding="utf-8",
    )
    state = tmp_path / "state.txt"
    manifest = tmp_path / "checks.tsv"
    rows = ["class\ttitle\tcommand\targs..."]
    for name in ("first", "second", "third"):
        rows.append(
            "\t".join(("parallel", name, sys.executable, str(worker), str(state), name))
        )
    manifest.write_text("\n".join(rows) + "\n", encoding="utf-8")

    completed = subprocess.run(
        [
            sys.executable,
            str(RUNNER),
            "--manifest",
            str(manifest),
            "--root",
            str(ROOT),
            "--jobs",
            "2",
        ],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=True,
    )
    active, maximum = map(int, state.read_text(encoding="utf-8").split(","))
    assert active == 0
    assert maximum == 2
    assert completed.stdout.index("== first ==") < completed.stdout.index("== second ==")
    assert completed.stdout.index("== second ==") < completed.stdout.index("== third ==")


def test_release_and_architecture_dry_runs_do_not_require_binaries() -> None:
    release = subprocess.run(
        [str(RELEASE), "--dry-run", "--jobs", "3", "--", "-j", "8"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=True,
    )
    assert "[parallel]" in release.stdout
    assert "test_all.sh --run-jobs 3" in release.stdout
    architecture = subprocess.run(
        [str(ARCH_WRAPPER), "--dry-run", "--jobs", "3"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=True,
    )
    assert "Kohärenz- und Trace-Parität" in architecture.stdout
    assert "Architektur- und Diagnoseprüfungen erfolgreich: JA" in architecture.stdout
