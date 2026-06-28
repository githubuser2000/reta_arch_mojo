from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.output_modes import *


def test_mode_inventory() raises:
    var specs = output_mode_specs()
    assert_equal(len(specs), 7)
    assert_equal(canonicalize_output_mode("markdown"), "markdown")
    assert_equal(canonicalize_output_mode("unknown"), "")


def test_forcing_flags() raises:
    var csv = output_mode_spec("csv")
    assert_true(csv.force_one_table)
    assert_true(csv.force_zero_width)
    var html = output_mode_spec("html")
    assert_true(html.marks_html_or_bbcode)
    assert_equal(html.begin_table, "<table border=0 id=\"bigtable\">")


def test_colored_rows() raises:
    assert_equal(colored_row_begin("html", 2), "<tr style=\"background-color:#66ff66;color:#000000;\">\n")
    assert_equal(colored_row_begin("bbcode", 4), "[tr=\"background-color:#9999ff;color:#202000;\"]")
    assert_equal(colored_row_begin("html", 9), "<tr style=\"background-color:#000099;color:#ffff66;\">\n")
    assert_equal(colored_row_begin("bbcode", 0), "[tr=\"background-color:#ff2222;color:#002222;\"]")
    assert_equal(colored_row_begin("html", 10, True), "<tr>\n")


def test_cells() raises:
    assert_equal(generate_simple_cell("markdown", 3), "|")
    assert_equal(generate_simple_cell("html", 3), "<td>\n")
    assert_equal(generate_simple_cell("bbcode", 3), "[td=\"\"]")
    assert_equal(generate_simple_cell("bbcode", -2, 4, True), "[td=\"background-color:#000000;color:#ffffff\"]")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
