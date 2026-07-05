from std.testing import assert_equal, assert_true, TestSuite
from std.sys.info import CompilationTarget
from reta_mojo.terminal_geometry import (
    automatic_cell_width,
    compound_clear_line_count,
    effective_cell_width,
    terminal_columns,
    terminal_rows,
    terminal_geometry_backend,
)


def test_automatic_width_reserves_seven_columns() raises:
    assert_equal(automatic_cell_width(80), 73)
    assert_equal(automatic_cell_width(120), 113)
    assert_equal(automatic_cell_width(200), 193)
    assert_equal(automatic_cell_width(4), 1)


def test_effective_width_matches_legacy_clamp() raises:
    assert_equal(effective_cell_width(0, 80), 73)
    assert_equal(effective_cell_width(0, 200), 193)
    assert_equal(effective_cell_width(40, 80), 40)
    assert_equal(effective_cell_width(100, 80), 73)


def test_terminal_columns_has_positive_fallback() raises:
    assert_true(terminal_columns() > 0)


def test_terminal_rows_has_positive_fallback() raises:
    assert_true(terminal_rows() > 0)


def test_compound_clear_uses_rows_plus_one() raises:
    assert_equal(compound_clear_line_count(24), 25)
    assert_equal(compound_clear_line_count(1), 2)
    assert_equal(compound_clear_line_count(0), 2)


def test_backend_matches_compilation_target() raises:
    if CompilationTarget.is_linux():
        assert_equal(terminal_geometry_backend(), "linux-ioctl")
    elif CompilationTarget.is_macos():
        assert_equal(terminal_geometry_backend(), "darwin-ioctl")
    else:
        assert_equal(terminal_geometry_backend(), "environment-fallback")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
