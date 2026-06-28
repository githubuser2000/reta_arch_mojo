"""Generated parity tests from the Python table architecture."""

from std.collections import List
from std.testing import assert_equal, TestSuite
from reta_mojo.table_state import create_table_state
from reta_mojo.table_wrapping import split_more_if_not_small, width_for_row
from reta_mojo.output_modes import default_output_runtime_state, apply_output_mode


def test_generated_split_more_parity() raises:
    var source_0: List[String] = ["ab", "cd"]
    var result_0 = split_more_if_not_small(source_0, 2)
    var expected_0: List[String] = ["ab", "cd"]
    assert_equal(len(result_0), len(expected_0))
    for value_index in range(len(expected_0)):
        assert_equal(result_0[value_index], expected_0[value_index])
    var source_1: List[String] = ["abcde", "xy"]
    var result_1 = split_more_if_not_small(source_1, 2)
    var expected_1: List[String] = ["ab", "cd", "e", "xy"]
    assert_equal(len(result_1), len(expected_1))
    for value_index in range(len(expected_1)):
        assert_equal(result_1[value_index], expected_1[value_index])
    var source_2: List[String] = ["äöü漢字", "xy"]
    var result_2 = split_more_if_not_small(source_2, 2)
    var expected_2: List[String] = ["äö", "ü漢", "字", "xy"]
    assert_equal(len(result_2), len(expected_2))
    for value_index in range(len(expected_2)):
        assert_equal(result_2[value_index], expected_2[value_index])
    var source_3: List[String] = ["abcdef"]
    var result_3 = split_more_if_not_small(source_3, 4)
    var expected_3: List[String] = ["abcd", "ef"]
    assert_equal(len(result_3), len(expected_3))
    for value_index in range(len(expected_3)):
        assert_equal(result_3[value_index], expected_3[value_index])
    var source_4: List[String] = [""]
    var result_4 = split_more_if_not_small(source_4, 3)
    var expected_4: List[String] = [""]
    assert_equal(len(result_4), len(expected_4))
    for value_index in range(len(expected_4)):
        assert_equal(result_4[value_index], expected_4[value_index])


def test_generated_width_for_row_parity() raises:
    var widths_0: List[Int] = [10, 20, 30]
    assert_equal(width_for_row(80, 3, widths_0, 21, 1, 0), 10)
    var widths_1: List[Int] = [10, 20, 30]
    assert_equal(width_for_row(80, 3, widths_1, 21, 3, 0), 30)
    var widths_2: List[Int] = [10, 20, 30]
    assert_equal(width_for_row(80, 5, widths_2, 21, 1, 2), 21)
    var widths_3: List[Int] = [10, 20, 30]
    assert_equal(width_for_row(0, 3, widths_3, 21, 1, 0), 0)
    var widths_4: List[Int] = []
    assert_equal(width_for_row(80, 3, widths_4, 21, 1, 0), 21)
    var widths_5: List[Int] = [7, 8, 9]
    assert_equal(width_for_row(120, 6, widths_5, 44, 2, 3), 44)


def test_generated_table_state_parity() raises:
    var default_state = create_table_state()
    assert_equal(default_state.highest_rows[1024], 1024)
    assert_equal(default_state.highest_rows[114], 163)
    var explicit_state = create_table_state(42)
    assert_equal(explicit_state.highest_rows[1024], 42)
    assert_equal(explicit_state.highest_rows[114], 42)


def test_generated_output_mode_application_parity() raises:
    var state_bbcode = apply_output_mode(default_output_runtime_state(), "bbcode")
    assert_equal(state_bbcode.canonical_name, "bbcode")
    assert_equal(state_bbcode.syntax_class_name, "bbCodeSyntax")
    assert_equal(state_bbcode.one_table, False)
    assert_equal(state_bbcode.text_width, 21)
    assert_equal(state_bbcode.marks_html_or_bbcode, True)
    var state_csv = apply_output_mode(default_output_runtime_state(), "csv")
    assert_equal(state_csv.canonical_name, "csv")
    assert_equal(state_csv.syntax_class_name, "csvSyntax")
    assert_equal(state_csv.one_table, True)
    assert_equal(state_csv.text_width, 0)
    assert_equal(state_csv.marks_html_or_bbcode, False)
    var state_emacs = apply_output_mode(default_output_runtime_state(), "emacs")
    assert_equal(state_emacs.canonical_name, "emacs")
    assert_equal(state_emacs.syntax_class_name, "emacsSyntax")
    assert_equal(state_emacs.one_table, True)
    assert_equal(state_emacs.text_width, 0)
    assert_equal(state_emacs.marks_html_or_bbcode, False)
    var state_html = apply_output_mode(default_output_runtime_state(), "html")
    assert_equal(state_html.canonical_name, "html")
    assert_equal(state_html.syntax_class_name, "htmlSyntax")
    assert_equal(state_html.one_table, False)
    assert_equal(state_html.text_width, 21)
    assert_equal(state_html.marks_html_or_bbcode, True)
    var state_markdown = apply_output_mode(default_output_runtime_state(), "markdown")
    assert_equal(state_markdown.canonical_name, "markdown")
    assert_equal(state_markdown.syntax_class_name, "markdownSyntax")
    assert_equal(state_markdown.one_table, True)
    assert_equal(state_markdown.text_width, 0)
    assert_equal(state_markdown.marks_html_or_bbcode, False)
    var state_nichts = apply_output_mode(default_output_runtime_state(), "nichts")
    assert_equal(state_nichts.canonical_name, "nichts")
    assert_equal(state_nichts.syntax_class_name, "NichtsSyntax")
    assert_equal(state_nichts.one_table, False)
    assert_equal(state_nichts.text_width, 21)
    assert_equal(state_nichts.marks_html_or_bbcode, False)
    var state_shell = apply_output_mode(default_output_runtime_state(), "shell")
    assert_equal(state_shell.canonical_name, "shell")
    assert_equal(state_shell.syntax_class_name, "OutputSyntax")
    assert_equal(state_shell.one_table, False)
    assert_equal(state_shell.text_width, 21)
    assert_equal(state_shell.marks_html_or_bbcode, False)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
