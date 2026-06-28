from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.schema_catalog import bootstrap_reta_schema
from reta_mojo.parameter_semantics import *
from schema_parity_constants import *


def _hash_field(value: Int, text: String) -> Int:
    var result = value
    for byte in text.bytes():
        result = (
            result * 257 + Int(byte) + 1
        ) % PYTHON_SCHEMA_FINGERPRINT_MODULUS
    return (result * 257 + 257) % PYTHON_SCHEMA_FINGERPRINT_MODULUS


def _hash_two(first: String, second: String) -> Int:
    var value = _hash_field(17, first)
    return _hash_field(value, second)


def _hash_three(first: String, second: String, third: String) -> Int:
    var value = _hash_field(17, first)
    value = _hash_field(value, second)
    return _hash_field(value, third)


def _add_fingerprint(mut total: Int, mut squares: Int, value: Int) -> None:
    total = (total + value) % PYTHON_SCHEMA_FINGERPRINT_MODULUS
    squares = (
        squares + (value * value) % PYTHON_SCHEMA_FINGERPRINT_MODULUS
    ) % PYTHON_SCHEMA_FINGERPRINT_MODULUS


def test_real_schema_matches_python_parameter_semantics() raises:
    var schema = bootstrap_reta_schema()
    var sheaf = build_parameter_semantics(schema)

    assert_equal(len(schema.parameters_main), 33)
    assert_equal(len(schema.parameter_entries), 431)
    assert_equal(len(schema.tag_names), 7)
    assert_equal(len(sheaf.main_alias_groups), 33)
    assert_equal(len(sheaf.main_aliases), EXPECTED_MAIN_ALIAS_COUNT)
    assert_equal(len(sheaf.parameter_alias_groups), EXPECTED_PAIR_COUNT)
    assert_equal(len(sheaf.pair_to_columns), EXPECTED_PAIR_COUNT)

    var main_total = 0
    var main_squares = 0
    for index in range(len(sheaf.main_aliases)):
        var value = _hash_two(
            sheaf.main_aliases[index].source_alias,
            sheaf.main_aliases[index].canonical,
        )
        _add_fingerprint(main_total, main_squares, value)
    assert_equal(main_total, EXPECTED_MAIN_ALIAS_SUM)
    assert_equal(main_squares, EXPECTED_MAIN_ALIAS_SQUARE_SUM)

    var parameter_count = 0
    var parameter_total = 0
    var parameter_squares = 0
    for group_index in range(len(sheaf.parameter_alias_groups)):
        var group = sheaf.parameter_alias_groups[group_index].copy()
        for alias_index in range(len(group.aliases)):
            var value = _hash_three(
                group.main_canonical,
                group.aliases[alias_index],
                group.parameter_canonical,
            )
            parameter_count += 1
            _add_fingerprint(parameter_total, parameter_squares, value)
    assert_equal(parameter_count, EXPECTED_PARAMETER_ALIAS_COUNT)
    assert_equal(parameter_total, EXPECTED_PARAMETER_ALIAS_SUM)
    assert_equal(parameter_squares, EXPECTED_PARAMETER_ALIAS_SQUARE_SUM)

    var pair_total = 0
    var pair_squares = 0
    for pair_index in range(len(sheaf.pair_to_columns)):
        var pair = sheaf.pair_to_columns[pair_index].copy()
        var value = _hash_field(17, pair.main_canonical)
        value = _hash_field(value, pair.parameter_canonical)
        for column_index in range(len(pair.columns)):
            value = _hash_field(value, String(pair.columns[column_index]))
        _add_fingerprint(pair_total, pair_squares, value)
    assert_equal(pair_total, EXPECTED_PAIR_SUM)
    assert_equal(pair_squares, EXPECTED_PAIR_SQUARE_SUM)


def test_known_reta_aliases_resolve_natively() raises:
    var sheaf = build_parameter_semantics(bootstrap_reta_schema())
    assert_equal(resolve_main_alias(sheaf, "religionen"), "Religionen")
    assert_equal(resolve_main_alias(sheaf, "menschliches"), "Menschliches")
    assert_equal(
        resolve_parameter_alias(sheaf, "religionen", "sternpolygon"),
        "Sternpolygon",
    )
    var columns = column_numbers_for_pair(sheaf, "religionen", "sternpolygon")
    assert_true(len(columns) > 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
