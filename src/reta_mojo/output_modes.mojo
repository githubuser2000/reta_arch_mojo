"""Complete typed owner for output semantics and static syntax descriptors.

This module owns the public surface of
``reta_architecture.output_semantics`` and the state-independent part of
``reta_architecture.output_syntax``.  Python's dynamic syntax classes become
immutable ``OutputModeSpec`` values, while table mutation is represented by an
owned ``OutputRuntimeState`` and an explicit application result.
"""

from std.collections import List
from .number_theory import prime_creativity


@fieldwise_init
struct OutputModeSpecSnapshot(Copyable, Equatable):
    var canonical_name: String
    var cli_value: String
    var syntax_class: String
    var force_one_table: Bool
    var force_zero_width: Bool
    var marks_html_or_bbcode: Bool
    var aliases: List[String]


@fieldwise_init
struct OutputModeApplicationSnapshot(Copyable, Equatable):
    var canonical_name: String
    var syntax_class_name: String
    var force_one_table: Bool
    var force_zero_width: Bool
    var marks_html_or_bbcode: Bool


@fieldwise_init
struct OutputSemanticsSnapshot(Copyable):
    var class_name: String
    var available_modes: List[String]
    var mode_specs: List[OutputModeSpecSnapshot]


@fieldwise_init
struct OutputModeSpec(Copyable, Equatable):
    var canonical_name: String
    var cli_value: String
    var syntax_class_name: String
    var force_one_table: Bool
    var force_zero_width: Bool
    var marks_html_or_bbcode: Bool
    var aliases: List[String]
    var begin_table: String
    var end_table: String
    var begin_cell: String
    var end_cell: String
    var begin_row: String
    var end_row: String

    def snapshot(self) -> OutputModeSpecSnapshot:
        return OutputModeSpecSnapshot(
            self.canonical_name,
            self.cli_value,
            self.syntax_class_name,
            self.force_one_table,
            self.force_zero_width,
            self.marks_html_or_bbcode,
            self.aliases.copy(),
        )


@fieldwise_init
struct OutputModeApplication(Copyable, Equatable):
    var canonical_name: String
    var syntax_class_name: String
    var force_one_table: Bool
    var force_zero_width: Bool
    var marks_html_or_bbcode: Bool

    def snapshot(self) -> OutputModeApplicationSnapshot:
        return OutputModeApplicationSnapshot(
            self.canonical_name,
            self.syntax_class_name,
            self.force_one_table,
            self.force_zero_width,
            self.marks_html_or_bbcode,
        )


@fieldwise_init
struct OutputRuntimeState(Copyable, Equatable):
    var canonical_name: String
    var syntax_class_name: String
    var one_table: Bool
    var text_width: Int
    var marks_html_or_bbcode: Bool


@fieldwise_init
struct OutputModeApplyResult(Copyable):
    var applied: Bool
    var state: OutputRuntimeState
    var application: OutputModeApplication


def _empty_output_mode_spec() -> OutputModeSpec:
    return OutputModeSpec(
        "",
        "",
        "",
        False,
        False,
        False,
        List[String](),
        "",
        "",
        "",
        "",
        "",
        "",
    )


def _empty_output_mode_application() -> OutputModeApplication:
    return OutputModeApplication("", "", False, False, False)


def output_mode_specs() -> List[OutputModeSpec]:
    """Return modes in the insertion order of ``i18n.words_context.ausgabeArt``."""
    return [
        OutputModeSpec(
            "bbcode",
            "bbcode",
            "bbCodeSyntax",
            False,
            False,
            True,
            ["bbcode"],
            "[table]",
            "[/table]",
            "[td]",
            "[/td]",
            "[tr]",
            "[/tr]",
        ),
        OutputModeSpec(
            "html",
            "html",
            "htmlSyntax",
            False,
            False,
            True,
            ["html"],
            "<table border=0 id=\"bigtable\">",
            "</table>\n",
            "<td>\n",
            "\n</td>\n",
            "",
            "</tr>\n",
        ),
        OutputModeSpec(
            "csv",
            "csv",
            "csvSyntax",
            True,
            True,
            False,
            ["csv"],
            "",
            "",
            "",
            "",
            "",
            "",
        ),
        OutputModeSpec(
            "shell",
            "shell",
            "OutputSyntax",
            False,
            False,
            False,
            ["shell"],
            "",
            "",
            "",
            "",
            "",
            "",
        ),
        OutputModeSpec(
            "markdown",
            "markdown",
            "markdownSyntax",
            True,
            True,
            False,
            ["markdown"],
            "",
            "",
            "|",
            "",
            "",
            "|",
        ),
        OutputModeSpec(
            "emacs",
            "emacs",
            "emacsSyntax",
            True,
            True,
            False,
            ["emacs"],
            "",
            "",
            "|",
            "",
            "",
            "|",
        ),
        OutputModeSpec(
            "nichts",
            "nichts",
            "NichtsSyntax",
            False,
            False,
            False,
            ["nichts"],
            "",
            "",
            "",
            "",
            "",
            "",
        ),
    ]


def _alias_matches(spec: OutputModeSpec, value: String) -> Bool:
    if spec.canonical_name == value or spec.cli_value == value:
        return True
    for alias in spec.aliases:
        if alias == value:
            return True
    return False


def output_mode_index(value: String) -> Int:
    var specs = output_mode_specs()
    for index in range(len(specs)):
        if _alias_matches(specs[index], value):
            return index
    return -1


def canonicalize_output_mode(value: String) -> String:
    var specs = output_mode_specs()
    for index in range(len(specs)):
        if _alias_matches(specs[index], value):
            return specs[index].canonical_name.copy()
    return ""


def output_mode_spec(value: String) -> OutputModeSpec:
    var specs = output_mode_specs()
    for index in range(len(specs)):
        if _alias_matches(specs[index], value):
            return specs[index].copy()
    return _empty_output_mode_spec()


def default_output_runtime_state() -> OutputRuntimeState:
    return OutputRuntimeState("shell", "OutputSyntax", False, 21, False)


@fieldwise_init
struct RetaOutputSemantics(Copyable):
    var repo_root: String
    var mode_specs: List[OutputModeSpec]

    def canonicalize(self, value: String) -> String:
        for index in range(len(self.mode_specs)):
            if _alias_matches(self.mode_specs[index], value):
                return self.mode_specs[index].canonical_name.copy()
        return ""

    def spec_for(self, value: String) -> OutputModeSpec:
        var canonical = self.canonicalize(value)
        if canonical.byte_length() == 0:
            return _empty_output_mode_spec()
        for index in range(len(self.mode_specs)):
            if self.mode_specs[index].canonical_name == canonical:
                return self.mode_specs[index].copy()
        return _empty_output_mode_spec()

    def create_syntax(self, value: String) raises -> OutputModeSpec:
        var spec = self.spec_for(value)
        if spec.canonical_name.byte_length() == 0:
            raise Error("unknown output mode: " + value)
        return spec^

    def mode_for_output_syntax(self, out_type: OutputModeSpec) -> String:
        var mode_name = self.canonicalize(out_type.canonical_name)
        if mode_name.byte_length() > 0:
            return mode_name^
        for index in range(len(self.mode_specs)):
            if (
                self.mode_specs[index].syntax_class_name
                == out_type.syntax_class_name
            ):
                return self.mode_specs[index].canonical_name.copy()
        return ""

    def mode_for_tables(self, tables: OutputRuntimeState) -> String:
        var canonical = self.canonicalize(tables.canonical_name)
        if canonical.byte_length() > 0:
            return canonical^
        for index in range(len(self.mode_specs)):
            if (
                self.mode_specs[index].syntax_class_name
                == tables.syntax_class_name
            ):
                return self.mode_specs[index].canonical_name.copy()
        return "shell"

    def is_mode(self, tables: OutputRuntimeState, mode: String) -> Bool:
        var canonical = self.canonicalize(mode)
        return (
            canonical.byte_length() > 0
            and self.mode_for_tables(tables) == canonical
        )

    def apply_mode_to_tables(
        self,
        tables: OutputRuntimeState,
        mode: String,
        zero_width_callback_available: Bool = True,
    ) -> OutputModeApplyResult:
        var spec = self.spec_for(mode)
        if spec.canonical_name.byte_length() == 0:
            return OutputModeApplyResult(
                False,
                tables.copy(),
                _empty_output_mode_application(),
            )
        var next_width = tables.text_width
        if spec.force_zero_width and zero_width_callback_available:
            next_width = 0
        var next_state = OutputRuntimeState(
            spec.canonical_name,
            spec.syntax_class_name,
            tables.one_table or spec.force_one_table,
            next_width,
            spec.marks_html_or_bbcode,
        )
        var application = OutputModeApplication(
            spec.canonical_name,
            spec.syntax_class_name,
            spec.force_one_table,
            spec.force_zero_width,
            spec.marks_html_or_bbcode,
        )
        return OutputModeApplyResult(True, next_state^, application^)

    def snapshot(self) -> OutputSemanticsSnapshot:
        # Python sorts both the top-level mode list and the mapping keys.
        var names: List[String] = [
            "bbcode",
            "csv",
            "emacs",
            "html",
            "markdown",
            "nichts",
            "shell",
        ]
        var snapshots = List[OutputModeSpecSnapshot]()
        for name in names:
            snapshots.append(self.spec_for(name).snapshot())
        return OutputSemanticsSnapshot(
            "RetaOutputSemantics", names^, snapshots^
        )


def bootstrap_output_semantics(
    repo_root: String = ""
) -> RetaOutputSemantics:
    return RetaOutputSemantics(repo_root, output_mode_specs())


def apply_output_mode(
    state: OutputRuntimeState,
    mode: String,
) -> OutputRuntimeState:
    """Pure native equivalent of ``apply_mode_to_tables`` with a callback."""
    var semantics = bootstrap_output_semantics()
    var result = semantics.apply_mode_to_tables(state, mode, True)
    return result.state.copy()


def is_output_mode(state: OutputRuntimeState, mode: String) -> Bool:
    return bootstrap_output_semantics().is_mode(state, mode)


def colored_row_begin(mode: String, num: Int, rest: Bool = False) -> String:
    """Port of ``bbCodeSyntax/htmlSyntax.coloredBeginCol``."""
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


def generate_simple_cell(
    mode: String,
    column: Int,
    content: Int = 0,
    has_content: Bool = False,
) -> String:
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
