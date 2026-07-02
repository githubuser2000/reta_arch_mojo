from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.native_reta_cli import run_native_reta
from reta_mojo.resource_paths import csv_resource
from reta_mojo.table_rendering import render_html_table_with_context


def test_exact_all_columns_row_one_html_command_is_utf8_safe() raises:
    var tokens: List[String] = [
        "-zeilen",
        "--vorhervonausschnitt=1",
        "-spalten",
        "--alles",
        "-ausgabe",
        "--art=html",
    ]
    var rendered = run_native_reta(tokens, csv_resource("religion.csv"))
    assert_true(rendered.startswith('<table border=0 id="bigtable">'))
    assert_true("Religionen" in rendered)
    assert_true("</table>" in rendered)
    assert_false("String slice" in rendered)


def test_unicode_prefix_wrapping_never_uses_partial_bytes() raises:
    var table = parse_semicolon_csv(
        "; ;A;B;C\n"
        + "1;1;Überraschungs-漢字kombination;größer-Äußerung;emoji-🙂-Ende\n"
    )
    var rendered = render_html_table_with_context(
        table,
        table,
        [0, 1],
        [0, 1, 2],
        "german",
        True,
        17,
        True,
    )
    assert_true("Überraschungs-" in rendered)
    assert_true("漢字kombination" in rendered)
    assert_true("größer-" in rendered)
    assert_true("Äußerung" in rendered)
    assert_true("🙂" in rendered)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
