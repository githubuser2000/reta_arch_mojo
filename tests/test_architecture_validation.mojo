from reta_mojo.architecture_validation import (
    architecture_validation_check_index,
    architecture_validation_layer_check_count,
    architecture_validation_layer_index,
    architecture_validation_runtime_consistency_passed,
    architecture_validation_snapshot_passed,
    bootstrap_architecture_validation,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_validation()
    assert_true(bundle.stage == 41, "stage")
    assert_true(len(bundle.checks) == 51, "check count")
    assert_true(len(bundle.layers) == 17, "layer count")
    assert_true(bundle.summary.status == "passed", "summary status")
    assert_true(bundle.summary.checked_items == 3448, "checked item count")
    assert_true(architecture_validation_snapshot_passed(bundle), "snapshot validation")
    assert_true(architecture_validation_runtime_consistency_passed(bundle), "runtime consistency")
    assert_true(architecture_validation_check_index(bundle, "CategoryFunctorReferenceCheck") >= 0, "known check")
    assert_true(architecture_validation_check_index(bundle, "ActivationTransactionCoverageCheck") >= 0, "activation check")
    assert_true(architecture_validation_layer_index(bundle, "CategoryTheoryBundle") >= 0, "known layer")
    assert_true(architecture_validation_layer_check_count(bundle, "ArchitectureActivationBundle") == 4, "activation layer check count")
    assert_true(architecture_validation_check_index(bundle, "missing") == -1, "missing check")
    assert_true(architecture_validation_layer_index(bundle, "missing") == -1, "missing layer")
    print("architecture validation tests: 13/13")
