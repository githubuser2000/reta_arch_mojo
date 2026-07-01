from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.integer_expressions import *


def _assert_values(result: IntegerCollectionResult, expected: List[Int]) raises:
    assert_true(result.valid)
    assert_equal(len(result.values), len(expected))
    for value in expected:
        assert_true(value in result.values)


def test_integer_arithmetic() raises:
    assert_equal(evaluate_integer_expression("2*3+1").value, 7)
    assert_equal(evaluate_integer_expression("-(2+3)*4").value, -20)
    assert_equal(evaluate_integer_expression("-3//2").value, -2)
    assert_equal(evaluate_integer_expression("-3%2").value, 1)
    assert_equal(evaluate_integer_expression("2**5").value, 32)
    assert_false(evaluate_integer_expression("1/2").valid)
    assert_false(evaluate_integer_expression("unknown+1").valid)
    assert_false(evaluate_integer_expression("9223372036854775808").valid)
    assert_false(evaluate_integer_expression("9223372036854775807+1").valid)
    assert_false(evaluate_integer_expression("3037000500*3037000500").valid)
    assert_false(evaluate_integer_expression("2**63").valid)


def test_collection_displays() raises:
    _assert_values(parse_integer_collection("{1,2,-3}"), [1, 2, -3])
    _assert_values(parse_integer_collection("[2*3]"), [6])
    _assert_values(parse_integer_collection("(1)"), [1])
    _assert_values(parse_integer_collection("(1,)"), [1])
    _assert_values(parse_integer_collection("[]"), [])


def test_documented_comprehensions() raises:
    _assert_values(
        parse_integer_collection("{n*2+1 for n in range(3)}"),
        [1, 3, 5],
    )
    _assert_values(
        parse_integer_collection("{2*n for n in range(2,5)}"),
        [4, 6, 8],
    )
    _assert_values(
        parse_integer_collection("[3*n for n in range(2)]"),
        [0, 3],
    )
    _assert_values(
        parse_integer_collection("[n+1 for n in range (3)]"),
        [1, 2, 3],
    )


def test_python_range_and_integer_semantics() raises:
    _assert_values(
        parse_integer_collection("[n for n in range(5,0,-2)]"),
        [1, 3, 5],
    )
    _assert_values(
        parse_integer_collection("[n//2 for n in range(-3,4)]"),
        [-2, -1, 0, 1],
    )
    _assert_values(
        parse_integer_collection("[n%3 for n in range(-3,4)]"),
        [0, 1, 2],
    )
    _assert_values(
        parse_integer_collection("[2**n for n in range(5)]"),
        [1, 2, 4, 8, 16],
    )


def test_unsafe_or_not_owned_python_is_rejected() raises:
    assert_false(parse_integer_collection("[1/2]").valid)
    assert_false(
        parse_integer_collection(
            "[__import__('os').system('true')]"
        ).valid
    )
    assert_false(
        parse_integer_collection("[n for n in range(3) if n]").valid
    )
    assert_false(
        parse_integer_collection(
            "[n+m for n in range(2) for m in range(2)]"
        ).valid
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
