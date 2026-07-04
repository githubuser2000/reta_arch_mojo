from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.architecture_refactor_contracts import *


def test_exact_historical_contract_inventory() raises:
    var contracts = load_architecture_refactor_contracts()
    var snapshot = architecture_refactor_contract_snapshot(contracts)
    assert_true(architecture_refactor_contracts_valid(contracts))
    assert_equal(snapshot.contracts, 70)
    assert_equal(snapshot.assertions, 1060)
    assert_equal(snapshot.categories, 18)
    assert_equal(snapshot.native_tests, 64)
    assert_equal(snapshot.architecture_contracts, 12)
    assert_equal(snapshot.table_contracts, 12)
    assert_equal(snapshot.prompt_contracts, 7)


def test_reference_order_and_terminal_contracts_are_preserved() raises:
    var contracts = load_architecture_refactor_contracts()
    assert_equal(contracts[0].ordinal, 1)
    assert_equal(contracts[0].python_test, "test_schema_is_explicit")
    assert_equal(contracts[69].ordinal, 70)
    assert_equal(
        contracts[69].python_test, "test_known_pair_lookup_still_resolves"
    )
    assert_equal(contracts[69].native_owner, "parameter_semantics.mojo")


def test_representative_distributed_owners_are_explicit() raises:
    var contracts = load_architecture_refactor_contracts()
    var prompt_index = architecture_refactor_contract_index(
        contracts, "test_prompt_execution_layer_is_explicit"
    )
    var persistence_index = architecture_refactor_contract_index(
        contracts, "test_persistence_layer_is_explicit_and_roundtrips_sections"
    )
    var architecture_index = architecture_refactor_contract_index(
        contracts, "test_architecture_activation_layer_is_explicit"
    )
    assert_true(prompt_index >= 0)
    assert_true(persistence_index >= 0)
    assert_true(architecture_index >= 0)
    assert_equal(
        contracts[prompt_index].native_test,
        "tests/test_prompt_execution.mojo",
    )
    assert_equal(
        contracts[persistence_index].native_test,
        "tests/test_persistence.mojo",
    )
    assert_equal(
        contracts[architecture_index].native_test,
        "tests/test_architecture_activation.mojo",
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
