from std.testing import assert_equal, assert_true, TestSuite
from std.collections import Set
from reta_mojo.row_filtering import *

def _initial() -> Set[Int]:
    var values = Set[Int]()
    for value in range(104):
        values.add(value)
    return values^

def test_python_reference_vectors() raises:
    var config = RowFilterConfig(100, 60, True)
    # ka
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["ka"])), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 64, 81, 100])
    # all
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["all"])), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 64, 81, 100])
    # absolute
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_1-9"])), [1, 2, 3, 4, 5, 6, 7, 8, 9])
    # absolute_exclusion
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_1-9,-3"])), [1, 2, 4, 5, 6, 7, 8, 9])
    # absolute_divisors
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_12", "_w_"])), [2, 3, 4, 6, 12])
    # relative_multiples
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_b_3"])), [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60])
    # relative_exclusion
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_b_2-4,-3"])), [2, 4, 8, 10, 14, 16, 20, 22, 26, 28, 32, 34, 38, 40, 44, 46, 50, 52, 56, 58])
    # time_past
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["<"])), [1, 2, 3, 4, 5, 6, 7, 8, 9])
    # time_present
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["="])), [10])
    # time_future
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), [">"])), [11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 64, 81, 100])
    # absolute_time
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_1-20", ">"])), [11, 12, 13, 14, 15, 16, 17, 18, 19, 20])
    # counting_one
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_n_1"])), [1, 2, 3, 4])
    # counting_two
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_n_2"])), [5, 6, 7, 8, 9])
    # counting_one_to_three
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_n_1-3"])), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
    # outside_first
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["aussenerste"])), [1, 7, 13, 19, 31, 37, 43])
    # inside_first
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["innenerste"])), [5, 11, 17, 23, 29, 41, 47, 53, 59])
    # outside_all
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["aussenalle"])), [1, 7, 13, 14, 19, 21, 26, 28, 31, 35, 37, 38, 39, 42, 43, 49, 52, 56, 57])
    # inside_all
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["innenalle"])), [5, 10, 11, 15, 17, 20, 22, 23, 25, 29, 30, 33, 34, 35, 40, 41, 44, 45, 46, 47, 50, 51, 53, 55, 58, 59, 60, 100])
    # moon
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["mond"])), [4, 8, 9, 16, 25, 27, 32, 36, 49, 64, 81, 100])
    # sun
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["sonne"])), [1, 2, 3, 5, 6, 7, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24, 26, 28, 29, 30, 31, 33, 34, 35, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60])
    # planet
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["planet"])), [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 64, 100])
    # black_sun
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["schwarzesonne"])), [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 81])
    # sun_with_moon_part
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["SonneMitMondanteil"])), [12, 18, 20, 24, 28, 40, 44, 45, 48, 50, 52, 54, 56, 60])
    # prime_multiple_two
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["2p"])), [2, 4, 6, 10, 14, 22, 26, 34, 38, 46, 58])
    # prime_multiple_two_three
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["2p", "3p"])), [2, 3, 4, 6, 9, 10, 14, 15, 21, 22, 26, 33, 34, 38, 39, 46, 51, 57, 58])
    # power_two
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_^_2"])), [2, 4, 8, 16, 32, 64])
    # power_two_three
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_^_2-3"])), [2, 3, 4, 8, 9, 16, 27, 32, 64, 81])
    # multiple_three
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["3v"])), [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54, 57, 60, 81])
    # multiple_three_five
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["3v", "5v"])), [3, 5, 6, 9, 10, 12, 15, 18, 20, 21, 24, 25, 27, 30, 33, 35, 36, 39, 40, 42, 45, 48, 50, 51, 54, 55, 57, 60, 81, 100])
    # invert_absolute
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_2,4,6", "_i_"])), [1, 3, 5, 7])
    # position_absolute
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_2-20", "_z_2-4"])), [3, 4, 5])
    # position_multiple
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_2-20", "_y_2"])), [3, 5, 7, 9, 11, 13, 15, 17, 19])
    # combo_planet_multiple
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_1-50", "planet", "3v"])), [6, 12, 18, 24, 30, 36, 42, 48])
    # combo_all_moon_prime
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["all", "mond", "2p"])), [4])
    # combo_relative_time
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_b_2", "<"])), [2, 4, 6, 8])
    # combo_type_position
    assert_equal(sorted_row_numbers(filter_original_lines(config, _initial(), ["_a_1-100", "aussenalle", "_z_1-5"])), [1, 7, 13, 14, 19])


def test_explicit_upper_maximum_can_keep_non_moon_rows_above_default_short_limit() raises:
    var initial = Set[Int]()
    for value in range(1, 1026):
        initial.add(value)
    var selected = filter_original_lines(
        RowFilterConfig(1025, 1025, True), initial, ["_a_256,768"]
    )
    assert_true(256 in selected)
    assert_true(768 in selected)


def test_default_short_limit_matches_python_163_rows() raises:
    var initial = Set[Int]()
    for value in range(1, 1025):
        initial.add(value)
    var selected = filter_original_lines(
        default_row_filter_config(1024), initial, ["_a_163,164"]
    )
    assert_true(163 in selected)
    assert_true(164 not in selected)

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
