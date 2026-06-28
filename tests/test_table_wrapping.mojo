from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.table_wrapping import *


def test_unicode_safe_hard_chunks() raises:
    var chunks = hard_chunks("äöü漢字", 2)
    assert_equal(len(chunks), 3)
    assert_equal(chunks[0], "äö")
    assert_equal(chunks[1], "ü漢")
    assert_equal(chunks[2], "字")


def test_split_more_only_when_one_value_is_too_long() raises:
    var short_values: List[String] = ["ab", "cd"]
    var unchanged = split_more_if_not_small(short_values, 2)
    assert_equal(len(unchanged), 2)
    assert_equal(unchanged[1], "cd")

    var mixed: List[String] = ["abcde", "xy"]
    var split = split_more_if_not_small(mixed, 2)
    assert_equal(len(split), 4)
    assert_equal(split[0], "ab")
    assert_equal(split[1], "cd")
    assert_equal(split[2], "e")
    assert_equal(split[3], "xy")


def test_wrap_result_matches_minimal_python_fallback() raises:
    var runtime = default_text_wrap_runtime()
    var no_wrap = wrap_cell_text("abc", 3, runtime)
    assert_false(no_wrap.wrapped)
    assert_equal(len(no_wrap.parts), 0)

    var requested = wrap_cell_text("abcdef", 3, runtime)
    assert_true(requested.wrapped)
    assert_equal(len(requested.parts), 1)
    assert_equal(requested.parts[0], "abcdef")

    runtime.has_fill = True
    var native = wrap_cell_text("abcdef", 3, runtime)
    assert_true(native.wrapped)
    assert_equal(len(native.parts), 2)
    assert_equal(native.parts[0], "abc")
    assert_equal(native.parts[1], "def")


def test_width_for_row_matches_architecture_formula() raises:
    var widths: List[Int] = [10, 20, 30]
    assert_equal(width_for_row(80, 3, widths, 21, 1), 10)
    assert_equal(width_for_row(80, 3, widths, 21, 3), 30)
    assert_equal(width_for_row(80, 5, widths, 21, 1, 2), 21)
    assert_equal(width_for_row(0, 3, widths, 21, 1), 0)
    assert_equal(width_for_row(80, 3, List[Int](), 21, 1), 21)


def test_width_clamping_matches_tables_setters() raises:
    assert_equal(clamp_table_width(21, 80, False), 21)
    assert_equal(clamp_table_width(100, 80, False), 73)
    assert_equal(clamp_table_width(0, 80, False), 73)
    assert_equal(clamp_table_width(0, 80, True), 0)
    assert_equal(clamp_column_width(100, 80), 73)
    assert_equal(clamp_column_width(21, 0), 21)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
