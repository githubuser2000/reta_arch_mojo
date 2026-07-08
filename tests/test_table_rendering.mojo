from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.table_rendering import *


def test_numbering_and_csv() raises:
    var table = parse_semicolon_csv("H1;H2\na  b;x\nc;y\n")
    var numbered = add_numbering_columns(table, [0, 1, 2])
    assert_equal(render_csv_table(numbered), "; ;H1;H2\n1;1 ;a b;x\n1;2 ;c;y\n")
    assert_equal(
        render_csv_table(table, False),
        ";;H1;H2\n;;a b;x\n;;c;y\n",
    )


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
        "   H          \n 1 aaaa bbbb  \n   cccc       \n",
    )


def test_shell_wrap_preserves_internal_space_runs_at_boundary() raises:
    var value = (
        "gegen 6 |  Darin kann sich die 15 am Besten hineinversetzen. "
        + "| pro 5 |  Darin kann sich die 15 am Besten hineinversetzen."
    )
    var table = parse_semicolon_csv("; ;H\n1;15;" + value + "\n")
    var rendered = render_shell_table_with_width_reference(
        table, table, [0, 15], True, 0, False,
        terminal_columns_override=80,
    )
    assert_true(
        " 15 gegen 6 |  Darin kann sich die 15 am Besten "
        + "hineinversetzen. | pro 5 |  D"
        in rendered
    )
    assert_true(
        "\n    arin kann sich die 15 am Besten hineinversetzen."
        in rendered
    )
    assert_false("\n    Darin kann sich die 15" in rendered)



def test_shell_one_table_disables_horizontal_paging() raises:
    var table = parse_semicolon_csv(
        "; ;AAAAAAAAAAAA;BBBBBBBBBBBB;CCCCCCCCCCCC;DDDDDDDDDDDD;EEEEEEEEEEEE;FFFFFFFFFFFF;GGGGGGGGGGGG\n"
        + "1;1;a;b;c;d;e;f;g\n"
    )
    var paged = render_shell_table_with_width_reference(
        table, table, [0, 1], True, 12, False,
        terminal_columns_override=80,
    )
    var single = render_shell_table_with_width_reference(
        table, table, [0, 1], True, 12, False, 0, True
    )
    assert_true("AAAAAAAAAAAA BBBBBBBBBBBB" in paged)
    assert_false("AAAAAAAAAAAA BBBBBBBBBBBB CCCCCCCCCCCC DDDDDDDDDDDD EEEEEEEEEEEE FFFFFFFFFFFF GGGGGGGGGGGG" in paged)
    assert_true("AAAAAAAAAAAA BBBBBBBBBBBB CCCCCCCCCCCC DDDDDDDDDDDD EEEEEEEEEEEE FFFFFFFFFFFF GGGGGGGGGGGG" in single)


def test_shell_one_table_zero_width_never_wraps() raises:
    var table = parse_semicolon_csv(
        "; ;H\n"
        + "1;1;ein sehr langer Zellinhalt mit mehreren Woertern\n"
    )
    var rendered = render_shell_table_with_width_reference(
        table, table, [0, 1], True, 0, False, 0, True
    )
    assert_true(
        " 1 ein sehr langer Zellinhalt mit mehreren Woertern \n"
        in rendered
    )
    assert_false("\n   mit mehreren Woertern" in rendered)



def test_bbcode_one_table_disables_horizontal_paging() raises:
    var table = parse_semicolon_csv(
        "; ;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;"
        + "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB;"
        + "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC\n"
        + "1;1;a;b;c\n"
    )
    var paged = render_bbcode_table(table, [0, 1], True, 40)
    var single = render_bbcode_table(table, [0, 1], True, 40, True)
    assert_true(paged.count("[table]") > 1)
    assert_equal(single.count("[table]"), 1)
    assert_true(
        "[td=\"\"]AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA[/td] "
        + "[td=\"\"]BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB[/td] "
        in single
    )

def test_markup_wrap_uses_hard_column_chunks_inside_words() raises:
    var table = parse_semicolon_csv(
        "; ;Heading\n"
        + "1;1;(gefährliche Wildkatzen-Außerirdische)\n"
    )
    var bbcode = render_bbcode_table(table, [0, 1], True, 21, True)
    assert_true("[td=\"\"](gefährliche Wildkatz[/td]" in bbcode)
    assert_true("[td=\"\"]en-Außerirdische) [/td]" in bbcode)
    assert_false("[td=\"\"]Wildkatzen- [/td]" in bbcode)

    var html = render_html_table_with_context(
        table, table, [0, 1], [0], "german", True, 21, True
    )
    assert_true("> (gefährliche Wildkatz </td>" in html)
    assert_true("> en-Außerirdische) </td>" in html)
    assert_false("> Wildkatzen- </td>" in html)


def test_shell_missing_continuation_fragment_uses_rest_color() raises:
    var table = parse_semicolon_csv(
        "; ;A;B\n"
        + "1;5;kurz;eins zwei drei vier fünf sechs\n"
    )
    var rendered = render_shell_table_with_width_reference(
        table, table, [0, 5], True, 10, True
    )
    assert_true(
        "\x1b[40m\x1b[37m    \x1b[0m\x1b[0m " in rendered
    )
    assert_false(
        "\x1b[43m\x1b[30m    \x1b[0m\x1b[0m " in rendered
    )



def test_explicit_column_widths_wrap_data_columns_independently() raises:
    var table = parse_semicolon_csv(
        "; ;A;B;C\n"
        + "1;1;abcdef;ghijklmnop;qrstuv\n"
    )
    var widths = [3, 5]

    var shell = render_shell_table_with_width_reference(
        table, table, [0, 1], True, 8, False, 0, True, False, widths
    )
    assert_true("abc ghijk qrstuv" in shell)
    assert_true("def lmnop" in shell)

    var bbcode = render_bbcode_table(
        table, [0, 1], True, 8, True, False, widths
    )
    assert_true("[td=\"\"]abc[/td]" in bbcode)
    assert_true("[td=\"\"]def[/td]" in bbcode)
    assert_true("[td=\"\"]ghijk[/td]" in bbcode)
    assert_true("[td=\"\"]lmnop[/td]" in bbcode)

    var html = render_html_table_with_context(
        table, table, [0, 1], [0, 1, 2], "german",
        True, 8, True, False, widths
    )
    assert_true("> abc </td>" in html)
    assert_true("> def </td>" in html)
    assert_true("> ghijk </td>" in html)
    assert_true("> lmnop </td>" in html)


def test_explicit_zero_width_keeps_only_that_column_unwrapped() raises:
    var table = parse_semicolon_csv(
        "; ;A;B\n"
        + "1;1;alpha beta gamma;one two three\n"
    )
    var rendered = render_shell_table_with_width_reference(
        table, table, [0, 1], True, 5, False, 0, True, False, [0, 5]
    )
    assert_true("alpha beta gamma one t" in rendered)
    assert_true("wo th" in rendered)
    assert_true("ree" in rendered)
    assert_false("\n   beta gamma" in rendered)


def test_markup_exact_visible_fit_no_longer_wraps_at_spaces() raises:
    var visible = parse_semicolon_csv(
        "; ;A;B\n"
        + "1;1;first;(14) (n)\n"
    )
    var raw = parse_semicolon_csv(
        "; ;A;B\n"
        + "1;1;first;(14)  (n)\n"
    )
    var bbcode = render_bbcode_table_with_width_reference(
        visible, raw, [0, 1], True, 8, True, False, [0, 8]
    )
    assert_true("[td=\"\"](14) (n)[/td]" in bbcode)
    assert_false("[td=\"\"](14)[/td]" in bbcode)

    var html = render_html_table_with_context(
        visible, raw, [0, 1], [0, 1], "german",
        True, 8, True, False, [0, 8]
    )
    assert_true("> (14) (n) </td>" in html)
    assert_false("> (14) </td>" in html)


def test_shell_oversized_zero_width_reproduces_legacy_page_truncation() raises:
    var long_cell = (
        "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
        + "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
    )
    var first_zero = parse_semicolon_csv(
        "; ;A;B\n1;1;" + long_cell + ";kept\n"
    )
    var skipped = render_shell_table_with_width_reference(
        first_zero, first_zero, [0, 1], True, 8, False, 0, False,
        False, [0, 8], 80
    )
    assert_false(long_cell in skipped)
    assert_true("kept" in skipped)

    var second_zero = parse_semicolon_csv(
        "; ;A;B;C\n1;1;kept;" + long_cell + ";truncated\n"
    )
    var truncated = render_shell_table_with_width_reference(
        second_zero, second_zero, [0, 1], True, 8, False, 0, False,
        False, [8, 0, 8], 80
    )
    assert_true("kept" in truncated)
    assert_false(long_cell in truncated)
    assert_false("truncated" in truncated)


def test_markup_nocolor_uses_raw_serializer() raises:
    var table = parse_semicolon_csv(
        "; ;A;B\n"
        + "1;1;x;yy\n"
    )
    var raw_bbcode = render_bbcode_table_with_width_reference(
        table, table, [0, 1], True, 8, True, False, [5, 4], False
    )
    var rich_bbcode = render_bbcode_table_with_width_reference(
        table, table, [0, 1], True, 8, True, False, [5, 4], True
    )
    assert_true('[td=""]  [/td]' in raw_bbcode)
    assert_true('[td=""]1 [/td]' in raw_bbcode)
    assert_false('[td=""]  [/td]' in rich_bbcode)

    var raw_html = render_html_table_with_context(
        table, table, [0, 1], [0, 1], "german",
        True, 8, True, False, [5, 4], False
    )
    var rich_html = render_html_table_with_context(
        table, table, [0, 1], [0, 1], "german",
        True, 8, True, False, [5, 4], True
    )
    assert_true('<table border=0 id="bigtable">\n<tr ' in raw_html)
    assert_true('>\nA\n</td>\n ' in raw_html)
    assert_true('</tr>\n\n</table>\n\n' in raw_html)
    assert_false('>\nA\n</td>\n ' in rich_html)


def test_flat_csv_widths_preserve_legacy_space_fragments() raises:
    var table = parse_semicolon_csv(
        ";;A B;C\n"
        + "1;1;oder Bösartigkeit;xy\n"
    )
    assert_equal(
        render_table_with_width_reference(
            table, table, [0, 1], "csv", 0, True, False, 0,
            False, False, [5, 2]
        ),
        "; ;A B;C\n"
        + "1;1 ;oder ;xy\n"
        + "1; ;Bösar;\n"
        + "1; ;tigke;\n"
        + "1; ;it;\n",
    )

    var unnumbered = parse_semicolon_csv(
        "A;B\n"
        + "oder Bösartigkeit;xy\n"
    )
    assert_equal(
        render_table_with_width_reference(
            unnumbered, unnumbered, [0, 1], "csv", 0, False, False, 0,
            False, False, [5, 2]
        ),
        ";;A;B\n"
        + ";;oder ;xy\n"
        + ";;Bösar;\n"
        + ";;tigke;\n"
        + ";;it;\n",
    )


def test_flat_markdown_and_emacs_repeat_wrapped_heading_contract() raises:
    var table = parse_semicolon_csv(
        ";;Religionen;andere Sternpolygone\n"
        + "1;1;Magie;Voodoo\n"
    )
    var markdown = render_table_with_width_reference(
        table, table, [0, 1], "markdown", 0, True, False, 0,
        False, False, [5, 10]
    )
    assert_true(
        "| | |Relig |andere Ste |\n|:--:|:--:|:--:|:--:|\n"
        + "| | |ionen |rnpolygone |\n|:--:|:--:|:--:|:--:|\n"
        in markdown
    )
    assert_true("|1|1 |Magie |Voodoo |\n" in markdown)

    var emacs = render_table_with_width_reference(
        table, table, [0, 1], "emacs", 0, True, False, 0,
        False, False, [5, 10]
    )
    assert_true(
        "| | |Relig |andere Ste |\n|----+----+----+----|\n"
        + "| | |ionen |rnpolygone |\n|----+----+----+----|\n"
        in emacs
    )
    assert_true("|1|1 |Magie |Voodoo |\n" in emacs)

    var unnumbered = parse_semicolon_csv(
        "A;B\n"
        + "oder Bösartigkeit;xy\n"
    )
    var unnumbered_markdown = render_table_with_width_reference(
        unnumbered, unnumbered, [0, 1], "markdown", 0, False, False, 0,
        False, False, [5, 2]
    )
    assert_true("|oder |xy |\n" in unnumbered_markdown)
    assert_true("|Bösar | |\n" in unnumbered_markdown)

    var unnumbered_emacs = render_table_with_width_reference(
        unnumbered, unnumbered, [0, 1], "emacs", 0, False, False, 0,
        False, False, [5, 2]
    )
    assert_true("|oder |xy |\n" in unnumbered_emacs)
    assert_true("|Bösar | |\n" in unnumbered_emacs)

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
