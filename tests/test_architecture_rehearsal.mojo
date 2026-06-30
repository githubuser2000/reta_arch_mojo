from reta_mojo.architecture_rehearsal import (
    bootstrap_architecture_rehearsal,
    rehearsal_cover_index,
    rehearsal_gate_index,
    rehearsal_move_index,
    rehearsal_open_set_index,
    rehearsal_runtime_validation_passed,
    rehearsal_snapshot_validation_passed,
    rehearsal_step_index,
    rehearsal_wave_move_count,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_rehearsal()
    assert_true(len(bundle.open_sets) == 7, "open set count")
    assert_true(len(bundle.moves) == 34, "move count")
    assert_true(len(bundle.gate_rehearsals) == 34, "gate rehearsal count")
    assert_true(len(bundle.covers) == 7, "cover count")
    assert_true(len(bundle.validation.checks) == 5, "check count")
    assert_true(rehearsal_snapshot_validation_passed(bundle), "snapshot validation")
    assert_true(rehearsal_runtime_validation_passed(bundle), "runtime cross validation")
    assert_true(rehearsal_open_set_index(bundle, "REH35-OPEN-M0") >= 0, "known open set")
    assert_true(rehearsal_move_index(bundle, "REH35-MOVE-MIG34-01") >= 0, "known move")
    assert_true(rehearsal_step_index(bundle, "MIG34-01") >= 0, "known step")
    assert_true(rehearsal_gate_index(bundle, "REH35-GATE-MIG34-01") >= 0, "known gate")
    assert_true(rehearsal_cover_index(bundle, "REH35-COVER-M0") >= 0, "known cover")
    assert_true(rehearsal_wave_move_count(bundle, "M0") == 16, "wave M0 move count")
    assert_true(rehearsal_move_index(bundle, "missing") == -1, "missing move")
    print("architecture rehearsal tests: 14/14")
