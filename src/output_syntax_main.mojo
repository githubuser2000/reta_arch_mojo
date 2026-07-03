"""Native diagnostics for output semantics and syntax ownership."""

from std.collections import List
from std.collections.string import atol
from reta_mojo.cli_arguments import owned_process_argv
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


def run_output_syntax_cli(args: List[String]) raises -> Int:
    var semantics = bootstrap_output_semantics()
    if len(args) == 1 or (len(args) == 2 and args[1] == "--summary"):
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
        return 0
    if len(args) == 3 and args[1] == "--canonical":
        print(semantics.canonicalize(args[2]))
        return 0
    if len(args) == 6 and args[1] == "--apply":
        var state = OutputRuntimeState(
            "shell",
            "OutputSyntax",
            _bool_value(args[4]),
            atol(args[3]),
            False,
        )
        var result = semantics.apply_mode_to_tables(
            state,
            args[2],
            _bool_value(args[5]),
        )
        print("applied=" + _bool_text(result.applied))
        print("mode=" + result.state.canonical_name)
        print("class=" + result.state.syntax_class_name)
        print("one_table=" + _bool_text(result.state.one_table))
        print("text_width=" + String(result.state.text_width))
        print("markup=" + _bool_text(result.state.marks_html_or_bbcode))
        return 0
    _usage()
    raise Error("invalid output-syntax diagnostic arguments")


def main() raises:
    _ = run_output_syntax_cli(owned_process_argv())
