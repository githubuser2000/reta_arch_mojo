from std.testing import assert_equal, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.table_rendering import *


def test_numbering_and_csv() raises:
    var table = parse_semicolon_csv("H1;H2\na  b;x\nc;y\n")
    var numbered = add_numbering_columns(table, [0, 1, 2])
    assert_equal(render_csv_table(numbered), "; ;H1;H21;1 ;a b;x1;2 ;c;y")


def test_markdown_and_emacs_headers() raises:
    var table = parse_semicolon_csv("A;B\n1;2\n")
    assert_equal(render_markdown_table(table), "|A |B ||:--:|:--:||1|2 |")
    assert_equal(render_emacs_table(table), "|A |B ||----+----||1|2 |")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
