from reta_mojo.architecture_activation import (
    activation_gate_index,
    activation_move_index,
    activation_rollback_index,
    activation_runtime_validation_passed,
    activation_snapshot_validation_passed,
    activation_transaction_index,
    activation_unit_index,
    activation_wave_unit_count,
    activation_window_index,
    bootstrap_architecture_activation,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_activation()
    assert_true(len(bundle.windows) == 7, "window count")
    assert_true(len(bundle.units) == 34, "unit count")
    assert_true(len(bundle.gates) == 34, "gate count")
    assert_true(len(bundle.rollbacks) == 34, "rollback count")
    assert_true(len(bundle.transactions) == 7, "transaction count")
    assert_true(len(bundle.validation.checks) == 6, "check count")
    assert_true(activation_snapshot_validation_passed(bundle), "snapshot validation")
    assert_true(activation_runtime_validation_passed(bundle), "runtime cross validation")
    assert_true(activation_window_index(bundle, "ACT36-WINDOW-M0") >= 0, "known window")
    assert_true(activation_unit_index(bundle, "ACT36-REH35-MOVE-MIG34-01") >= 0, "known unit")
    assert_true(activation_move_index(bundle, "REH35-MOVE-MIG34-01") >= 0, "known move")
    assert_true(activation_gate_index(bundle, "ACT36-GATE-MIG34-01") >= 0, "known gate")
    assert_true(activation_rollback_index(bundle, "ACT36-REH35-MOVE-MIG34-01") >= 0, "known rollback")
    assert_true(activation_transaction_index(bundle, "ACT36-TX-M0") >= 0, "known transaction")
    assert_true(activation_wave_unit_count(bundle, "M0") == 16, "wave M0 unit count")
    assert_true(activation_unit_index(bundle, "missing") == -1, "missing unit")
    print("architecture activation tests: 16/16")
