from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_runtime import (
    prime_command_predicate,
    prompt_runtime_contract_snapshot,
)
from reta_mojo.prompt_runtime_catalog import prompt_runtime_contract


def test_prime_command_predicate() raises:
    assert_equal(prime_command_predicate(-1), 0)
    assert_equal(prime_command_predicate(0), 0)
    assert_equal(prime_command_predicate(1), 0)
    assert_equal(prime_command_predicate(2), 1)
    assert_equal(prime_command_predicate(3), 1)
    assert_equal(prime_command_predicate(4), 3)
    assert_equal(prime_command_predicate(9), 3)
    assert_equal(prime_command_predicate(29), 1)


def test_deutsch_runtime_contract() raises:
    var contract = prompt_runtime_contract("deutsch")
    assert_equal(contract.language, "deutsch")
    assert_equal(contract.normal_prefix, ">")
    assert_equal(contract.store_prefix, "was speichern>")
    assert_equal(contract.delete_prefix, "was löschen>")
    assert_equal(contract.program.class_name, "PromptProgramView")
    assert_equal(contract.program.main_parameter_names[0], "zeilen")
    assert_equal(contract.program.main_parameter_indices[3], 3)
    assert_equal(contract.program.main_parameter_indices[4], -1)
    assert_equal(contract.program.para_n_data_matrix_len, 432)
    assert_equal(contract.program.para_dict_len, 4155)
    assert_equal(contract.program.data_dict_sizes[0], 556)
    assert_equal(contract.program.combination_reverse_len, 46)
    assert_equal(contract.program.combination_reverse2_len, 51)
    assert_equal(contract.program.simple_command_columns_len, 556)
    assert_equal(contract.vocabulary.commands_len, 386)
    assert_true(contract.wahl15_valid)
    assert_equal(len(contract.wahl15_missing_values), 0)


def test_english_runtime_contract() raises:
    var contract = prompt_runtime_contract("en")
    assert_equal(contract.language, "english")
    assert_equal(contract.normal_prefix, ">")
    assert_equal(contract.store_prefix, "save what>")
    assert_equal(contract.delete_prefix, "delete what>")
    assert_equal(contract.program.main_parameter_names[0], "lines")
    assert_equal(contract.program.main_parameter_names[3], "output")
    assert_equal(contract.program.para_dict_len, 2671)
    assert_equal(contract.program.combination_reverse_len, 35)
    assert_equal(contract.program.combination_reverse2_len, 41)
    assert_equal(contract.vocabulary.commands_len, 367)
    assert_true(contract.wahl15_valid)


def test_five_language_contracts_and_fallback() raises:
    assert_equal(prompt_runtime_contract("vietnamese").language, "vietnamese")
    assert_equal(prompt_runtime_contract("chinese").language, "chinese")
    assert_equal(prompt_runtime_contract("korean").language, "korean")
    assert_equal(prompt_runtime_contract("unknown").language, "deutsch")


def test_runtime_contract_snapshot() raises:
    var snapshot = prompt_runtime_contract_snapshot(
        prompt_runtime_contract("deutsch")
    )
    assert_equal(len(snapshot), 13)
    assert_equal(snapshot[0], "language=deutsch")
    assert_equal(snapshot[3], "para_dict=4155")
    assert_equal(snapshot[8], "normal_prefix=>")
    assert_equal(snapshot[9], "store_prefix=was speichern>")
    assert_equal(snapshot[11], "wahl15_valid=1")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
