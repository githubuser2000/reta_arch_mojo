from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.terminal_geometry import (
    automatic_cell_width,
    effective_cell_width,
    terminal_columns,
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


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
