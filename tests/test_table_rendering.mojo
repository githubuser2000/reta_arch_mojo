from std.testing import assert_equal, assert_false, assert_true, TestSuite
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


def test_shell_nocolor_omits_ansi_sequences() raises:
    var table = parse_semicolon_csv("; ;H1\n1;1;a\n")
    var rendered = render_shell_table_with_width_reference(
        table, table, [0, 1], True, 80, False
    )
    assert_false("\x1b[" in rendered)
    assert_true("H1" in rendered)
    assert_true("a" in rendered)


def test_shell_counting_group_marker_is_visible() raises:
    var table = parse_semicolon_csv("; ;H\n1;3;three\n2;5;five\n")
    var rendered = render_shell_table_with_width_reference(
        table, table, [0, 3, 5], True, 80, False
    )
    assert_true(" 3 three" in rendered)
    assert_true("█5 five" in rendered)


def test_shell_numbering_width_honors_requested_upper_maximum() raises:
    var table = parse_semicolon_csv("; ;H\n1;1;a\n")
    assert_equal(
        render_shell_table_with_width_reference(
            table, table, [0, 1], True, 80, False, 1025
        ),
        "      H \n    1 a \n",
    )


def test_shell_width_uses_prepared_fragments() raises:
    var table = parse_semicolon_csv("; ;H\n1;1;aaaa bbbb cccc\n")
    assert_equal(
        render_shell_table_with_width_reference(
            table, table, [0, 1], True, 10, False
        ),
        "   H         \n 1 aaaa bbbb \n   cccc      \n",
    )


def test_shell_wrap_preserves_internal_space_runs_at_boundary() raises:
    var value = (
        "gegen 6 |  Darin kann sich die 15 am Besten hineinversetzen. "
        + "| pro 5 |  Darin kann sich die 15 am Besten hineinversetzen."
    )
    var table = parse_semicolon_csv("; ;H\n1;15;" + value + "\n")
    var rendered = render_shell_table_with_width_reference(
        table, table, [0, 15], True, 0, False
    )
    assert_true(
        " 15 gegen 6 |  Darin kann sich die 15 am Besten "
        + "hineinversetzen. | pro 5 | "
        in rendered
    )
    assert_true(
        "\n    Darin kann sich die 15 am Besten hineinversetzen."
        in rendered
    )
    assert_false("\n    |  Darin kann sich die 15" in rendered)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
