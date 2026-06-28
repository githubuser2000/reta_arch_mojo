from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.universal import *


def test_normalize_column_buckets() raises:
    var source = [
        make_bucket(0, 0, [1, 2, 3, 4]),
        make_bucket(0, 1, [10, 11]),
        make_bucket(1, 0, [2, 4, 9]),
        make_bucket(1, 1, [11]),
    ]
    var result = normalize_column_buckets(source)
    assert_equal(len(result), 2)
    assert_true(1 in result[0].values)
    assert_true(3 in result[0].values)
    assert_false(2 in result[0].values)
    assert_false(4 in result[0].values)
    assert_true(10 in result[1].values)
    assert_false(11 in result[1].values)


def test_input_is_not_mutated() raises:
    var source = [make_bucket(0, 0, [1, 2]), make_bucket(1, 0, [2])]
    var _ = normalize_column_buckets(source)
    assert_true(2 in source[0].values)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
