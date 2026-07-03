"""Native diagnostics for output semantics and syntax ownership."""

from std.sys import argv
from std.collections.string import atol
from reta_mojo.output_modes import (
    OutputRuntimeState,
    bootstrap_output_semantics,
)
from reta_mojo.output_syntax import bootstrap_output_syntax


def _usage() -> None:
    print("reta-mojo-output-syntax")
    print("  --summary")
    print("  --canonical VALUE")
    print("  --apply MODE WIDTH ONE_TABLE ZERO_WIDTH_CALLBACK")


def _bool_value(value: String) -> Bool:
    return value == "1" or value == "true" or value == "yes"


def _bool_text(value: Bool) -> String:
    return "true" if value else "false"


def main() raises:
    var args = argv()
    var semantics = bootstrap_output_semantics()
    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        var semantic_snapshot = semantics.snapshot()
        var syntax_snapshot = bootstrap_output_syntax().snapshot()
        print("semantics_class=" + semantic_snapshot.class_name)
        print("semantics_modes=" + String(len(semantic_snapshot.mode_specs)))
        print("syntax_class=" + syntax_snapshot.class_name)
        print("syntax_modes=" + String(len(syntax_snapshot.modes)))
        print("legacy_owner=" + syntax_snapshot.legacy_owner)
        print("architecture_owner=" + syntax_snapshot.architecture_owner)
        for index in range(len(semantic_snapshot.mode_specs)):
            var spec = semantic_snapshot.mode_specs[index].copy()
            print(
                "mode=" + spec.canonical_name
                + "|class=" + spec.syntax_class
                + "|one=" + _bool_text(spec.force_one_table)
                + "|zero=" + _bool_text(spec.force_zero_width)
                + "|markup=" + _bool_text(spec.marks_html_or_bbcode)
                + "|aliases=" + String(len(spec.aliases))
            )
        return
    if len(args) == 3 and String(args[1]) == "--canonical":
        print(semantics.canonicalize(String(args[2])))
        return
    if len(args) == 6 and String(args[1]) == "--apply":
        var state = OutputRuntimeState(
            "shell",
            "OutputSyntax",
            _bool_value(String(args[4])),
            atol(String(args[3])),
            False,
        )
        var result = semantics.apply_mode_to_tables(
            state,
            String(args[2]),
            _bool_value(String(args[5])),
        )
        print("applied=" + _bool_text(result.applied))
        print("mode=" + result.state.canonical_name)
        print("class=" + result.state.syntax_class_name)
        print("one_table=" + _bool_text(result.state.one_table))
        print("text_width=" + String(result.state.text_width))
        print("markup=" + _bool_text(result.state.marks_html_or_bbcode))
        return
    _usage()
    raise Error("invalid output-syntax diagnostic arguments")
