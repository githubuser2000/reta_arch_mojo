from reta_mojo.architecture_progress import (
    architecture_progress_runtime_consistency_passed,
    architecture_progress_snapshot_consistent,
    architecture_progress_step_index,
    architecture_progress_surface_index,
    architecture_progress_wave_index,
    architecture_progress_work_index,
    bootstrap_architecture_progress,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_progress()
    assert_true(bundle.stage == 42, "stage")
    assert_true(len(bundle.surfaces) == 30, "surface count")
    assert_true(len(bundle.step_progress) == 34, "step count")
    assert_true(len(bundle.wave_progress) == 7, "wave count")
    assert_true(len(bundle.outstanding_work) == 1, "outstanding count")
    assert_true(len(bundle.validation.checks) == 3, "check count")
    assert_true(bundle.validation.status == "attention", "intentional attention status")
    assert_true(architecture_progress_snapshot_consistent(bundle), "snapshot consistency")
    assert_true(architecture_progress_runtime_consistency_passed(bundle), "runtime consistency")
    assert_true(architecture_progress_surface_index(bundle, "reta.py") >= 0, "known surface")
    assert_true(architecture_progress_step_index(bundle, "MIG34-34") >= 0, "known step")
    assert_true(architecture_progress_wave_index(bundle, "M0") >= 0, "known wave")
    assert_true(architecture_progress_work_index(bundle, "WIP42-01") >= 0, "known work item")
    assert_true(architecture_progress_surface_index(bundle, "missing") == -1, "missing surface")
    assert_true(architecture_progress_step_index(bundle, "missing") == -1, "missing step")
    assert_true(architecture_progress_wave_index(bundle, "missing") == -1, "missing wave")
    print("architecture progress tests: 16/16")
