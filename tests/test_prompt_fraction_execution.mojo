from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_fraction_execution import *


def _assert_group(result: PromptFractionParse, index: Int, expected: String) raises:
    assert_equal("|".join(result.groups[index]), expected)


def test_simple_fraction() raises:
    var parsed = parse_prompt_fraction("1/2")
    assert_true(parsed.valid)
    assert_equal(len(parsed.groups), 3)
    _assert_group(parsed, 0, "")
    _assert_group(parsed, 1, "1|2")
    _assert_group(parsed, 2, "")
    var ranged = create_prompt_fraction_range(parsed.groups)
    assert_true(ranged.valid)
    assert_equal(len(ranged.values), 1)
    assert_equal(ranged.values[0], 1)
    assert_equal(ranged.suffix, "2")


def test_text_around_fraction() raises:
    var parsed = parse_prompt_fraction("abc1/2def")
    assert_true(parsed.valid)
    _assert_group(parsed, 0, "abc")
    _assert_group(parsed, 1, "1|2")
    _assert_group(parsed, 2, "def")
    var ranged = create_prompt_fraction_range(parsed.groups)
    assert_equal(ranged.values[0], 1)
    assert_equal(ranged.suffix, "abc2def")


def test_plus_fraction_range() raises:
    var parsed = parse_prompt_fraction("1/2+3/4")
    assert_true(parsed.valid)
    assert_equal(len(parsed.groups), 5)
    _assert_group(parsed, 2, "+")
    var ranged = create_prompt_fraction_range(parsed.groups)
    assert_equal(len(ranged.values), 2)
    assert_equal(ranged.values[0], 4)
    assert_equal(ranged.values[1], -2)
    assert_equal(ranged.suffix, "2+4")


def test_minus_fraction_range() raises:
    var parsed = parse_prompt_fraction("2/3-5/7")
    assert_true(parsed.valid)
    var ranged = create_prompt_fraction_range(parsed.groups)
    assert_equal(len(ranged.values), 4)
    assert_equal(ranged.values[0], 2)
    assert_equal(ranged.values[3], 5)
    assert_equal(ranged.suffix, "3-7")


def test_non_operator_text_between_fractions() raises:
    var parsed = parse_prompt_fraction("2/3x4/5")
    assert_true(parsed.valid)
    var ranged = create_prompt_fraction_range(parsed.groups)
    assert_equal(len(ranged.values), 1)
    assert_equal(ranged.values[0], 2)
    assert_equal(ranged.suffix, "3x5")


def test_invalid_fraction_forms() raises:
    assert_false(parse_prompt_fraction("1abc/2def").valid)
    assert_false(parse_prompt_fraction("1/2/3").valid)
    assert_false(parse_prompt_fraction("2/3+4").valid)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()


def test_fraction_axis_helpers() raises:
    var equal = equal_fraction_axes([1, 2, 3, 8], [2, 3, 4, 8])
    assert_equal("|".join(equal), "2|3|8")
    var whole = whole_fraction_axes([2, 3, 8], [4, 6, 8])
    assert_equal("|".join(whole.whole), "2|3|2|4|1")
    assert_equal("|".join(whole.reciprocal_whole), "2|1")


def test_add_fraction_value_helper() raises:
    var first = add_prompt_fraction_value(False, 8, 4, [], [], [])
    assert_true(first.has_integer)
    assert_equal("|".join(first.all_tokens), "2")
    assert_equal("|".join(first.integer_tokens), "2")
    var second = add_prompt_fraction_value(
        first.has_integer, 2, 8, first.reciprocal_integers, first.all_tokens, first.integer_tokens
    )
    assert_equal("|".join(second.all_tokens), "2|1/4")
    assert_equal("|".join(second.reciprocal_integers), "4")
