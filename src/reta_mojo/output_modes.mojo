"""Typed output-mode semantics and renderer syntax constants.

This ports the static and state-independent part of
``reta_architecture.output_semantics`` and ``output_syntax``. Rich HTML header
construction that depends on Python's dynamic table metadata remains behind the
compatibility bridge.
"""

from std.collections import List
from .number_theory import prime_creativity


@fieldwise_init
struct OutputModeSpec(Copyable, Equatable, Writable):
    var canonical_name: String
    var cli_value: String
    var syntax_class_name: String
    var force_one_table: Bool
    var force_zero_width: Bool
    var marks_html_or_bbcode: Bool
    var begin_table: String
    var end_table: String
    var begin_cell: String
    var end_cell: String
    var begin_row: String
    var end_row: String


def output_mode_specs() -> List[OutputModeSpec]:
    return [
        OutputModeSpec("shell", "shell", "OutputSyntax", False, False, False, "", "", "", "", "", ""),
        OutputModeSpec("nichts", "nichts", "NichtsSyntax", False, False, False, "", "", "", "", "", ""),
        OutputModeSpec("csv", "csv", "csvSyntax", True, True, False, "", "", "", "", "", ""),
        OutputModeSpec("bbcode", "bbcode", "bbCodeSyntax", False, False, True, "[table]", "[/table]", "[td]", "[/td]", "[tr]", "[/tr]"),
        OutputModeSpec("html", "html", "htmlSyntax", False, False, True, "<table border=0 id=\"bigtable\">", "</table>\n", "<td>\n", "\n</td>\n", "", "</tr>\n"),
        OutputModeSpec("emacs", "emacs", "emacsSyntax", True, True, False, "", "", "|", "", "", "|"),
        OutputModeSpec("markdown", "markdown", "markdownSyntax", True, True, False, "", "", "|", "", "", "|"),
    ]


def output_mode_index(value: String) -> Int:
    var specs = output_mode_specs()
    for index in range(len(specs)):
        if specs[index].canonical_name == value or specs[index].cli_value == value:
            return index
    return -1


def canonicalize_output_mode(value: String) -> String:
    var index = output_mode_index(value)
    if index < 0:
        return ""
    return output_mode_specs()[index].canonical_name


def output_mode_spec(value: String) -> OutputModeSpec:
    var specs = output_mode_specs()
    var index = output_mode_index(value)
    if index < 0:
        return OutputModeSpec("", "", "", False, False, False, "", "", "", "", "", "")
    return specs[index].copy()


def colored_row_begin(mode: String, num: Int, rest: Bool = False) -> String:
    """Port of bbCodeSyntax/htmlSyntax.coloredBeginCol."""
    var canonical = canonicalize_output_mode(mode)
    if canonical != "html" and canonical != "bbcode":
        return output_mode_spec(canonical).begin_row
    if rest:
        if canonical == "html":
            return "<tr>\n"
        return "[tr]"

    var number_type = prime_creativity(num)
    var html_result = String()
    var bb_result = String()
    if number_type == 1:
        if num % 2 == 0:
            html_result = "<tr style=\"background-color:#66ff66;color:#000000;\">\n"
            bb_result = "[tr=\"background-color:#66ff66;color:#000000;\"]"
        else:
            html_result = "<tr style=\"background-color:#009900;color:#ffffff;\">\n"
            bb_result = "[tr=\"background-color:#009900;color:#ffffff;\"]"
    elif number_type == 2 or num == 1:
        if num % 2 == 0:
            html_result = "<tr style=\"background-color:#ffff66;color:#000099;\">\n"
            bb_result = "[tr=\"background-color:#ffff66;color:#000099;\"]"
        else:
            html_result = "<tr style=\"background-color:#555500;color:#aaaaff;\">\n"
            bb_result = "[tr=\"background-color:#555500;color:#aaaaff;\"]"
    elif number_type == 3:
        if num % 2 == 0:
            html_result = "<tr style=\"background-color:#9999ff;color:#202000;\">\n"
            bb_result = "[tr=\"background-color:#9999ff;color:#202000;\"]"
        else:
            html_result = "<tr style=\"background-color:#000099;color:#ffff66;\">\n"
            bb_result = "[tr=\"background-color:#000099;color:#ffff66;\"]"
    elif num == 0:
        html_result = "<tr style=\"background-color:#ff2222;color:#002222;\">\n"
        bb_result = "[tr=\"background-color:#ff2222;color:#002222;\"]"

    if canonical == "html":
        return html_result
    return bb_result


def generate_simple_cell(mode: String, column: Int, content: Int = 0, has_content: Bool = False) -> String:
    """Generate the state-independent cell opening used by simple renderers."""
    var canonical = canonicalize_output_mode(mode)
    if canonical == "html":
        return "<td>\n"
    if canonical == "bbcode":
        # Python increments the column by two. Its conditional branch for
        # column == 0 is therefore only reachable for the numbering sentinel -2.
        if column == -2 and has_content:
            if content % 2 == 0:
                return "[td=\"background-color:#000000;color:#ffffff\"]"
            return "[td=\"background-color:#ffffff;color:#000000\"]"
        return "[td=\"\"]"
    return output_mode_spec(canonical).begin_cell


@fieldwise_init
struct OutputRuntimeState(Copyable, Equatable):
    var canonical_name: String
    var syntax_class_name: String
    var one_table: Bool
    var text_width: Int
    var marks_html_or_bbcode: Bool


def default_output_runtime_state() -> OutputRuntimeState:
    return OutputRuntimeState("shell", "OutputSyntax", False, 21, False)


def apply_output_mode(
    state: OutputRuntimeState,
    mode: String,
) -> OutputRuntimeState:
    """Pure native equivalent of RetaOutputSemantics.apply_mode_to_tables."""
    var spec = output_mode_spec(mode)
    if spec.canonical_name.byte_length() == 0:
        return state.copy()
    var one_table = state.one_table or spec.force_one_table
    var width = 0 if spec.force_zero_width else state.text_width
    return OutputRuntimeState(
        spec.canonical_name,
        spec.syntax_class_name,
        one_table,
        width,
        spec.marks_html_or_bbcode,
    )


def is_output_mode(state: OutputRuntimeState, mode: String) -> Bool:
    var canonical = canonicalize_output_mode(mode)
    return canonical.byte_length() > 0 and state.canonical_name == canonical
