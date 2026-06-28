from std.collections import Dict, List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.arithmetic import *


def test_factor_pairs() raises:
    var pairs = factor_pairs(36)
    assert_equal(len(pairs), 5)
    assert_equal(pairs[0].first, 18)
    assert_equal(pairs[0].second, 2)
    assert_equal(pairs[4].first, 36)
    assert_equal(pairs[4].second, 1)


def test_prime_factors_modulo() raises:
    var values = prime_factors(58, modulo=True)
    assert_equal(len(values), 2)
    assert_equal(values[0], 2)
    assert_equal(values[1], 5)


def test_prime_repeat_labels() raises:
    var labels = prime_repeat_labels([2, 2, 2, 3, 3, 5])
    assert_equal(len(labels), 3)
    assert_equal(labels[0], "2^3")
    assert_equal(labels[1], "3^2")
    assert_equal(labels[2], "5")


def test_has_digit() raises:
    assert_true(has_digit("abc9def"))
    assert_false(has_digit("abcdef"))


def test_divisor_range() raises:
    var result = divisor_range("6,10")
    assert_true(2 in result[1])
    assert_true(3 in result[1])
    assert_true(5 in result[1])
    assert_true(6 in result[1])
    assert_true(10 in result[1])
    assert_false(1 in result[1])


def test_modulo_lines() raises:
    var lines = modulo_table_lines([5])
    assert_equal(len(lines), 24)
    assert_equal(lines[0], "5 % 2 = 1 Gegenteil, 1 Gegenteil")


def test_invert_dict() raises:
    var source = Dict[String, List[String]]()
    source["a"] = ["1", "2"]
    source["b"] = ["2", "3"]
    var inverted = invert_int_value_dict(source)
    assert_equal(len(inverted[2]), 2)
    assert_equal(inverted[2][0], "a")
    assert_equal(inverted[2][1], "b")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
