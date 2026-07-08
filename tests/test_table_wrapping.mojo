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


def test_wrap_result_uses_hard_chunks_without_backend_dependency() raises:
    var runtime = default_text_wrap_runtime()
    var no_wrap = wrap_cell_text("abc", 3, runtime)
    assert_false(no_wrap.wrapped)
    assert_equal(len(no_wrap.parts), 0)

    var requested = wrap_cell_text("abcdef", 3, runtime)
    assert_true(requested.wrapped)
    assert_equal(len(requested.parts), 2)
    assert_equal(requested.parts[0], "abc")
    assert_equal(requested.parts[1], "def")

    runtime.has_fill = True
    var native = wrap_cell_text("abc def", 3, runtime)
    assert_true(native.wrapped)
    assert_equal(len(native.parts), 3)
    assert_equal(native.parts[0], "abc")
    assert_equal(native.parts[1], " de")
    assert_equal(native.parts[2], "f")


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


def test_complete_runtime_surface_and_snapshot() raises:
    var state = TextWrapRuntimeState(default_text_wrap_runtime())
    set_shell_rows_amount(state, 96)
    assert_equal(get_shell_rows_amount(state), 96)
    set_wrapping_type(state, WRAP_NOHYPHEN)
    assert_equal(get_wrapping_type(state), WRAP_NOHYPHEN)

    var snapshot = text_wrap_runtime_snapshot(state.runtime)
    assert_equal(snapshot.class_name, "TextWrapRuntime")
    assert_equal(snapshot.shell_rows_amount, 96)
    assert_equal(snapshot.wrapping_type_name, "nohyphen")


def test_alxwrap_and_chunks_are_unicode_safe() raises:
    var runtime = TextWrapRuntime(80, False, False, True, WRAP_PYHYPHEN)
    var parts = alxwrap("größer漢字", 3, runtime)
    assert_equal(len(parts), 3)
    assert_equal(parts[0], "grö")
    assert_equal(parts[1], "ßer")
    assert_equal(parts[2], "漢字")

    var direct = chunks("🙂🙂a", 2)
    assert_equal(len(direct), 2)
    assert_equal(direct[0], "🙂🙂")
    assert_equal(direct[1], "a")


def test_bundle_bootstrap_and_width_morphism() raises:
    var bundle = bootstrap_table_wrapping(True, WRAP_PYHYPHEN, 80)
    var wrapped = bundle.wrap_text("abcdef", 3)
    assert_true(wrapped.wrapped)
    assert_equal(len(wrapped.parts), 2)
    assert_equal(wrapped.parts[1], "def")

    var widths: List[Int] = [10, 20]
    assert_equal(bundle.width_for_row(2, widths, 21, 2), 20)
    var snapshot = bundle.snapshot()
    assert_equal(snapshot.class_name, "TableWrappingBundle")
    assert_equal(len(snapshot.morphisms), 4)
    assert_equal(snapshot.legacy_owner, "libs.lib4tables_prepare.Prepare")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
