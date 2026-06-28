from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.row_ranges import *


def _contains_all(values: Set[Int], expected: List[Int]) raises:
    assert_equal(len(values), len(expected))
    for index in range(len(expected)):
        assert_true(expected[index] in values)


def test_token_validation() raises:
    assert_true(is_integer_range_token("1-9"))
    assert_true(is_integer_range_token("v2-4+1+3"))
    assert_true(is_integer_range_token("-5"))
    assert_false(is_integer_range_token("1/a"))
    assert_true(is_fraction_range_token("1/2-3/4+5/6"))


def test_explicit_sets() raises:
    var parsed = parse_explicit_int_set("{1, 2, -3}")
    assert_true(parsed.valid)
    _contains_all(parsed.values, [1, 2, -3])
    assert_false(parse_explicit_int_set("{1, x}").valid)
    # Security difference from Python eval: expressions are rejected.
    assert_false(parse_explicit_int_set("{1, 1+1}").valid)


def test_simple_range() raises:
    _contains_all(range_to_numbers("1-5"), [1, 2, 3, 4, 5])


def test_subtractive_range() raises:
    _contains_all(range_to_numbers("1-8,-3-5"), [1, 2, 6, 7, 8])


def test_around_offsets() raises:
    _contains_all(range_to_numbers("5+1"), [4, 6])


def test_multiple_prefix() raises:
    var values = range_to_numbers("v3", max_value=12)
    _contains_all(values, [3, 6, 9, 12])


def test_top_level_comma_split() raises:
    var parts = split_top_level_commas("1-3,{5,6},8")
    assert_equal(len(parts), 3)
    assert_equal(parts[1], "{5,6}")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
