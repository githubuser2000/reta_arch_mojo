from reta_mojo.architecture_impact import (
    bootstrap_architecture_impact,
    impact_contract_index,
    impact_snapshot_validation_passed,
    impact_source_index,
    migration_candidate_index,
    regression_gate_index,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_impact()
    assert_true(len(bundle.impact_sources) == 34, "impact source count")
    assert_true(len(bundle.impact_contracts) == 34, "impact contract count")
    assert_true(len(bundle.regression_gates) == 10, "regression gate count")
    assert_true(len(bundle.migration_candidates) == 34, "migration candidate count")
    assert_true(len(bundle.validation.checks) == 5, "impact check count")
    assert_true(impact_snapshot_validation_passed(bundle), "impact validation")
    assert_true(impact_source_index(bundle, "reta.py") >= 0, "known impact source")
    assert_true(impact_contract_index(bundle, "reta.py") >= 0, "known impact contract")
    assert_true(regression_gate_index(bundle, "CommandParityGate") >= 0, "known gate")
    assert_true(migration_candidate_index(bundle, "Stage33Guard::reta.py") >= 0, "known candidate")
    assert_true(impact_source_index(bundle, "missing") == -1, "missing impact source")
    print("architecture impact tests: 11/11")
