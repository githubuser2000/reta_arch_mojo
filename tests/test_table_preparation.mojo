from std.testing import assert_equal, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.row_filtering import RowFilterConfig
from reta_mojo.table_preparation import *


def test_header_is_always_present() raises:
    var table = parse_semicolon_csv("h\na\nb\nc\n")
    var result = select_display_lines(
        RowFilterConfig(3, 3, True), table, ["_a_2-3"], List[String]()
    )
    assert_equal(result.rows, [0, 2, 3])
    assert_equal(select_display_table(table, result).rows[1][0], "b")


def test_negative_filter_is_subtracted() raises:
    var table = parse_semicolon_csv("h\na\nb\nc\nd\n")
    var result = select_display_lines(
        RowFilterConfig(4, 4, True), table, ["_a_1-4"], ["_a_2,4"]
    )
    assert_equal(result.rows, [0, 1, 3])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
