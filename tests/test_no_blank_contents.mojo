from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.table_rendering import (
    render_html_table_with_context,
    render_table_with_width_reference,
)


def test_no_blank_contents_filters_short_visible_fragments() raises:
    var table = parse_semicolon_csv(
        "; ;Heading\n"
        + "1;1;real\n"
        + "1;2;?\n"
        + "1;3;X\n"
        + "1;4;ä\n"
        + "2;5;ok\n"
    )
    var rows = [0, 1, 2, 3, 4, 5]
    assert_equal(
        render_table_with_width_reference(
            table, table, rows, "csv", 0, True, True, 0, False, True
        ),
        ";  ;Heading\n1;1 ;real\n2;5 ;ok\n",
    )


def test_emacs_inserts_prime_power_separators_after_filtering() raises:
    var table = parse_semicolon_csv(
        "; ;Heading\n"
        + "1;1;one\n"
        + "1;4;four\n"
        + "2;5;?\n"
        + "2;8;eight\n"
        + "3;9;nine\n"
    )
    var rendered = render_table_with_width_reference(
        table,
        table,
        [0, 1, 4, 5, 8, 9],
        "emacs",
        0,
        True,
        True,
        0,
        False,
        True,
    )
    assert_false("|2|5 |? |" in rendered)
    assert_equal(rendered.count("|----+----+----|"), 4)
    assert_true("|1|4 |four |\n|----+----+----|" in rendered)
    assert_true("|2|8 |eight |\n|----+----+----|" in rendered)
    assert_true("|3|9 |nine |\n|----+----+----|" in rendered)


def test_no_blank_contents_is_page_and_visual_line_local() raises:
    var table = parse_semicolon_csv(
        "; ;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;"
        + "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB;"
        + "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC\n"
        + "1;1;?;valid;?\n"
    )
    var rows = [0, 1]
    var bbcode = render_table_with_width_reference(
        table,
        table,
        rows,
        "bbcode",
        40,
        True,
        True,
        0,
        False,
        True,
    )
    assert_equal(bbcode.count("[table]"), 3)
    assert_equal(bbcode.count("background-color:#555500"), 1)

    var html = render_html_table_with_context(
        table,
        table,
        rows,
        [0, 1, 2],
        "german",
        True,
        40,
        False,
        True,
    )
    assert_equal(html.count("<table border=0"), 3)
    assert_equal(html.count("background-color:#555500"), 1)

    var wrapped = parse_semicolon_csv(
        "; ;Heading\n1;1;alpha ?\n"
    )
    var wrapped_bbcode = render_table_with_width_reference(
        wrapped,
        wrapped,
        [0, 1],
        "bbcode",
        5,
        True,
        True,
        0,
        True,
        True,
    )
    assert_equal(wrapped_bbcode.count("background-color:#555500"), 1)
    assert_false("[td=\"\"]?" in wrapped_bbcode)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
