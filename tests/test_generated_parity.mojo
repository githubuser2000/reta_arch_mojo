"""Generated against the Python reference; do not edit by hand."""
from std.collections import List, Set
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.number_theory import *
from reta_mojo.row_ranges import range_to_numbers

def _csv(values: List[Int]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += String(values[index])
    return result^

def _assert_set(actual: Set[Int], expected: List[Int]) raises:
    assert_equal(len(actual), len(expected))
    for index in range(len(expected)):
        assert_true(expected[index] in actual)

def test_prime_creativity_reference_vector() raises:
    var expected = [0, 0, 1, 1, 3, 1, 2, 1, 3, 3, 2, 1, 2, 1, 2, 2, 3, 1, 2, 1, 2, 2, 2, 1, 2, 3, 2, 3, 2, 1, 2, 1, 3, 2, 2, 2, 3, 1, 2, 2, 2, 1, 2, 1, 2, 2, 2, 1, 2, 3, 2, 2, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2, 2, 3, 2, 2, 1, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 1, 2, 3, 2, 1, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 3, 1, 2, 1, 2, 2, 2, 1, 2, 1, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 1, 3, 2, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 3, 2, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 1, 2, 2, 2, 1, 2, 3, 2, 2, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 2, 2, 3, 1, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 1, 2, 3, 2, 1, 2, 1, 2, 2, 2, 1, 2, 2, 2, 2, 2, 1, 2, 1, 2, 3, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 3]
    for value in range(len(expected)):
        assert_equal(prime_creativity(value), expected[value])

def test_prime_factor_reference_vectors() raises:
    var numbers = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 97, 100, 127, 128, 255, 256, 1024]
    var expected = ["2", "3", "2,2", "5", "2,3", "7", "2,2,2", "3,3", "2,5", "11", "2,2,3", "13", "2,7", "3,5", "2,2,2,2", "17", "2,3,3", "19", "2,2,5", "3,7", "2,11", "23", "2,2,2,3", "5,5", "2,13", "3,3,3", "2,2,7", "29", "2,3,5", "31", "2,2,2,2,2", "3,11", "2,17", "5,7", "2,2,3,3", "37", "2,19", "3,13", "2,2,2,5", "41", "2,3,7", "43", "2,2,11", "3,3,5", "2,23", "47", "2,2,2,2,3", "7,7", "2,5,5", "3,17", "2,2,13", "53", "2,3,3,3", "5,11", "2,2,2,7", "3,19", "2,29", "59", "2,2,3,5", "61", "2,31", "3,3,7", "2,2,2,2,2,2", "5,13", "2,3,11", "67", "2,2,17", "3,23", "2,5,7", "71", "2,2,2,3,3", "73", "2,37", "3,5,5", "2,2,19", "7,11", "2,3,13", "79", "2,2,2,2,5", "97", "2,2,5,5", "127", "2,2,2,2,2,2,2", "3,5,17", "2,2,2,2,2,2,2,2", "2,2,2,2,2,2,2,2,2,2"]
    for index in range(len(numbers)):
        assert_equal(_csv(prime_factors(numbers[index])), expected[index])

def test_divisor_reference_vectors() raises:
    var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 64, 81, 97, 100]
    var expected = ["1", "1,2", "1,3", "1,2,4", "1,5", "1,2,3,6", "1,7", "1,2,4,8", "1,3,9", "1,2,5,10", "1,11", "1,2,3,4,6,12", "1,13", "1,2,7,14", "1,3,5,15", "1,2,4,8,16", "1,17", "1,2,3,6,9,18", "1,19", "1,2,4,5,10,20", "1,3,7,21", "1,2,11,22", "1,23", "1,2,3,4,6,8,12,24", "1,5,25", "1,2,13,26", "1,3,9,27", "1,2,4,7,14,28", "1,29", "1,2,3,5,6,10,15,30", "1,31", "1,2,4,8,16,32", "1,3,11,33", "1,2,17,34", "1,5,7,35", "1,2,3,4,6,9,12,18,36", "1,37", "1,2,19,38", "1,3,13,39", "1,2,4,5,8,10,20,40", "1,2,4,8,16,32,64", "1,3,9,27,81", "1,97", "1,2,4,5,10,20,25,50,100"]
    for index in range(len(numbers)):
        assert_equal(_csv(divisors(numbers[index])), expected[index])

def test_prime_cross_reference_vectors() raises:
    var cross = [False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True, False, True, False, False, False, True]
    var inner = [False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True]
    var outer = [False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False, False, True, False, False, False, False]
    for value in range(len(cross)):
        assert_equal(prime_cross_candidate(value), cross[value])
        assert_equal(prime_cross_inner_candidate(value), inner[value])
        assert_equal(prime_cross_outer_candidate(value), outer[value])

def test_row_range_reference_vectors() raises:
    _assert_set(range_to_numbers("1-9", False, 30), [1, 2, 3, 4, 5, 6, 7, 8, 9])
    _assert_set(range_to_numbers("1-9,-3", False, 30), [1, 2, 4, 5, 6, 7, 8, 9])
    _assert_set(range_to_numbers("2-4+1", False, 30), [1, 2, 3, 4, 5])
    _assert_set(range_to_numbers("v2-3", False, 25), [2, 3, 4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22, 24])
    _assert_set(range_to_numbers("2-3", True, 25), [2, 3, 4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22, 24])
    _assert_set(range_to_numbers("{1,2,5,8}", False, 30), [1, 2, 5, 8])
    _assert_set(range_to_numbers("{1,2,5,8},-{2,8}", False, 30), [1, 5])
    _assert_set(range_to_numbers("1,3,5-7", False, 30), [1, 3, 5, 6, 7])
    _assert_set(range_to_numbers("4+1+2", False, 30), [2, 3, 5, 6])
    _assert_set(range_to_numbers("v5", False, 40), [5, 10, 15, 20, 25, 30, 35, 40])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
