from reta_mojo.architecture_migration import (
    bootstrap_architecture_migration,
    migration_first_owner_step_index,
    migration_gate_binding_index,
    migration_invariant_index,
    migration_owner_step_count,
    migration_snapshot_validation_passed,
    migration_step_index,
    migration_wave_index,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_migration()
    assert_true(len(bundle.waves) == 7, "migration wave count")
    assert_true(len(bundle.steps) == 34, "migration step count")
    assert_true(len(bundle.gate_bindings) == 34, "gate binding count")
    assert_true(len(bundle.invariants) == 7, "migration invariant count")
    assert_true(len(bundle.validation.checks) == 5, "migration check count")
    assert_true(migration_snapshot_validation_passed(bundle), "migration validation")
    assert_true(migration_wave_index(bundle, "M3") >= 0, "known wave")
    assert_true(migration_step_index(bundle, "MIG34-03") >= 0, "known step")
    assert_true(migration_gate_binding_index(bundle, "MIG34-03") >= 0, "known binding")
    assert_true(migration_invariant_index(bundle, "M3") >= 0, "known invariant")
    assert_true(migration_owner_step_count(bundle, "reta.py") == 1, "owner step count")
    assert_true(migration_first_owner_step_index(bundle, "reta.py") >= 0, "owner first step")
    assert_true(migration_wave_index(bundle, "missing") == -1, "missing wave")
    print("architecture migration tests: 13/13")
