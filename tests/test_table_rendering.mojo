from std.testing import assert_equal, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.table_rendering import *


def test_numbering_and_csv() raises:
    var table = parse_semicolon_csv("H1;H2\na  b;x\nc;y\n")
    var numbered = add_numbering_columns(table, [0, 1, 2])
    assert_equal(render_csv_table(numbered), "; ;H1;H2\n1;1 ;a b;x\n1;2 ;c;y\n")


def test_markdown_and_emacs_headers() raises:
    var table = parse_semicolon_csv("A;B\n1;2\n")
    assert_equal(render_markdown_table(table), "|A |B |\n|:--:|:--:|\n|1|2 |\n")
    assert_equal(render_emacs_table(table), "|A |B |\n|----+----|\n|1|2 |\n")


def test_bbcode_legacy_spacing_and_counting_color() raises:
    var table = parse_semicolon_csv("; ;H1;H2\n1;1;a;b\n2;2;c;d\n")
    assert_equal(
        render_bbcode_table(table, [0, 1, 2]),
        "[table]\n"
        + "[tr=\"background-color:#ff2222;color:#002222;\"]"
        + "[td=\"background-color:#ffffff;color:#000000\"] [/td]"
        + "[td=\"\"] [/td][td=\"\"]H1[/td] [td=\"\"]H2[/td] [/tr]\n"
        + "[tr=\"background-color:#555500;color:#aaaaff;\"]"
        + "[td=\"background-color:#ffffff;color:#000000\"]1[/td]"
        + "[td=\"\"]1 [/td][td=\"\"]a[/td] [td=\"\"]b[/td] [/tr]\n"
        + "[tr=\"background-color:#66ff66;color:#000000;\"]"
        + "[td=\"background-color:#000000;color:#ffffff\"]2[/td]"
        + "[td=\"\"]2 [/td][td=\"\"]c[/td] [td=\"\"]d[/td] [/tr]\n"
        + "[/table]\n",
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
