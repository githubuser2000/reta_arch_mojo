from std.testing import assert_equal, TestSuite
from reta_mojo.csv_table import *


def test_semicolon_quotes_and_embedded_newline() raises:
    var table = parse_semicolon_csv("a;\"b;c\";d\n1;\"x\nq\";\"z\"\"w\"\n")
    assert_equal(len(table.rows), 2)
    assert_equal(table.maximum_columns, 3)
    assert_equal(table.rows[0][1], "b;c")
    assert_equal(table.rows[1][1], "x\nq")
    assert_equal(table.rows[1][2], "z\"w")



def test_quotes_inside_unquoted_json_cell_are_literal() raises:
    var table = parse_semicolon_csv(
        'id;wrapped\n1;|{"":"plain","html":"<b>한글 中文 Việt</b>"}|\n'
    )
    assert_equal(len(table.rows), 2)
    assert_equal(table.rows[1][1], '|{"":"plain","html":"<b>한글 中文 Việt</b>"}|')


def test_full_reference_csv_shape() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    assert_equal(len(table.rows), 1025)
    assert_equal(table.maximum_columns, 746)
    assert_equal(table_cell_count(table), 764650)


def test_ordered_column_selection() raises:
    var table = parse_semicolon_csv("a;b;c\n1;2;3\n")
    var selected = select_columns(table, [3, 1])
    assert_equal(selected.rows[0][0], "c")
    assert_equal(selected.rows[0][1], "a")
    assert_equal(selected.rows[1][0], "3")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
