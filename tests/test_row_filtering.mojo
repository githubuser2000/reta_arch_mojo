from std.testing import assert_equal, assert_true, TestSuite
from std.collections import List, Set
from reta_mojo.row_filtering import *


def all_rows(highest: Int) -> Set[Int]:
    var result = Set[Int]()
    for value in range(highest + 1): result.add(value)
    return result^


def test_absolute_and_divisors() raises:
    var result = filter_original_lines(default_row_filter_config(20), all_rows(20), ["_a_8", "_w_"])
    assert_true(2 in result); assert_true(4 in result); assert_true(8 in result)


def test_time_and_multiples() raises:
    var result = filter_original_lines(default_row_filter_config(30), all_rows(30), ["_b_3", "<"])
    assert_equal(sorted_row_numbers(result), [3, 6, 9])


def test_celestial_and_ordinary_multiple() raises:
    var result = filter_original_lines(default_row_filter_config(30), all_rows(30), ["all", "planet", "3v"])
    assert_equal(sorted_row_numbers(result), [6, 12, 18, 24, 30])


def test_powers_and_positions() raises:
    var result = filter_original_lines(default_row_filter_config(100), all_rows(100), ["all", "_^_2", "_z_2-4"])
    assert_equal(sorted_row_numbers(result), [4, 8, 16])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
