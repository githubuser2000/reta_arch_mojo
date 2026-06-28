from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.output_modes import *


def test_apply_shell_and_unknown_mode() raises:
    var state = default_output_runtime_state()
    var shell = apply_output_mode(state, "shell")
    assert_equal(shell.canonical_name, "shell")
    assert_equal(shell.text_width, 21)
    assert_false(shell.one_table)

    var unchanged = apply_output_mode(shell, "unbekannt")
    assert_equal(unchanged.canonical_name, "shell")
    assert_equal(unchanged.text_width, 21)


def test_table_oriented_modes_force_expected_flags() raises:
    var state = default_output_runtime_state()
    var csv = apply_output_mode(state, "csv")
    assert_equal(csv.syntax_class_name, "csvSyntax")
    assert_true(csv.one_table)
    assert_equal(csv.text_width, 0)
    assert_false(csv.marks_html_or_bbcode)

    var markdown = apply_output_mode(state, "markdown")
    assert_true(markdown.one_table)
    assert_equal(markdown.text_width, 0)


def test_html_and_bbcode_mark_rich_output() raises:
    var html = apply_output_mode(default_output_runtime_state(), "html")
    assert_true(html.marks_html_or_bbcode)
    assert_false(html.one_table)
    assert_equal(html.text_width, 21)
    assert_true(is_output_mode(html, "html"))
    assert_false(is_output_mode(html, "bbcode"))

    var bbcode = apply_output_mode(default_output_runtime_state(), "bbcode")
    assert_true(bbcode.marks_html_or_bbcode)
    assert_equal(bbcode.syntax_class_name, "bbCodeSyntax")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
