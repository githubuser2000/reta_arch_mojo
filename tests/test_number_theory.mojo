from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.number_theory import *


def test_prime_factors() raises:
    var factors = prime_factors(360)
    assert_equal(len(factors), 6)
    assert_equal(factors[0], 2)
    assert_equal(factors[1], 2)
    assert_equal(factors[2], 2)
    assert_equal(factors[3], 3)
    assert_equal(factors[4], 3)
    assert_equal(factors[5], 5)


def test_divisors() raises:
    var values = divisors(36)
    assert_equal(len(values), 9)
    assert_equal(values[0], 1)
    assert_equal(values[8], 36)


def test_prime_repeat() raises:
    var grouped = prime_repeat(prime_factors(72))
    assert_equal(len(grouped), 2)
    assert_equal(grouped[0].first, 2)
    assert_equal(grouped[0].second, 3)
    assert_equal(grouped[1].first, 3)
    assert_equal(grouped[1].second, 2)


def test_prime_creativity() raises:
    assert_equal(prime_creativity(0), 0)
    assert_equal(prime_creativity(7), 1)
    assert_equal(prime_creativity(8), 3)
    assert_equal(prime_creativity(12), 2)
    assert_equal(prime_creativity(36), 3)


def test_prime_cross() raises:
    assert_true(prime_cross_candidate(29))
    assert_true(prime_cross_inner_candidate(29))
    assert_false(prime_cross_outer_candidate(29))


def test_moon_number() raises:
    var result = moon_number(64)
    assert_equal(len(result[0]), 3)
    assert_equal(result[0][0], 8)
    assert_equal(result[1][0], 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
