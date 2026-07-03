"""Complete typed owner for ``reta_architecture.output_syntax``.

Python models output syntaxes as seven small classes and a dynamic class map.
The native owner uses immutable ``OutputModeSpec`` descriptors, an explicit
cell request and the generated HTML metadata catalog.  This preserves the
observable class constants, row coloring, cell openings, bundle lookup and
snapshot contract without dynamic Python classes or ``getattr``.
"""

from std.collections import List
from .html_cell_metadata import (
    HtmlCellCatalog,
    html_cell_open,
    load_html_cell_catalog,
)
from .output_modes import (
    OutputModeSpec,
    colored_row_begin,
    generate_simple_cell,
    output_mode_spec,
    output_mode_specs,
)


@fieldwise_init
struct OutputSyntaxModeSnapshot(Copyable, Equatable):
    var canonical_name: String
    var syntax_class_name: String
    var force_one_table: Bool
    var force_zero_width: Bool
    var marks_html_or_bbcode: Bool


@fieldwise_init
struct OutputSyntaxBundleSnapshot(Copyable):
    var class_name: String
    var modes: List[OutputSyntaxModeSnapshot]
    var legacy_owner: String
    var architecture_owner: String


@fieldwise_init
struct OutputCellRequest(Copyable):
    var source_column: Int
    var rendered_column: Int
    var row_number: Int
    var heading_text: String
    var content: Int
    var has_content: Bool
    var language: String
    var prefer_rendered_position: Bool


def default_output_cell_request() -> OutputCellRequest:
    return OutputCellRequest(-999999, 0, 0, "", 0, False, "german", False)


def OUTPUT_SYNTAX_CLASSES() -> List[OutputModeSpec]:
    """Typed replacement for the Python mode→class dictionary."""
    return output_mode_specs()


def NichtsSyntax() -> OutputModeSpec:
    return output_mode_spec("nichts")


def OutputSyntax() -> OutputModeSpec:
    return output_mode_spec("shell")


def csvSyntax() -> OutputModeSpec:
    return output_mode_spec("csv")


def emacsSyntax() -> OutputModeSpec:
    return output_mode_spec("emacs")


def markdownSyntax() -> OutputModeSpec:
    return output_mode_spec("markdown")


def bbCodeSyntax() -> OutputModeSpec:
    return output_mode_spec("bbcode")


def htmlSyntax() -> OutputModeSpec:
    return output_mode_spec("html")


@fieldwise_init
struct OutputSyntaxBundle(Copyable):
    var classes: List[OutputModeSpec]

    def class_for(self, mode: String) raises -> OutputModeSpec:
        for index in range(len(self.classes)):
            if self.classes[index].canonical_name == mode:
                return self.classes[index].copy()
        raise Error("unknown output syntax: " + mode)

    def colored_begin_col(
        self, mode: String, number: Int, rest: Bool = False
    ) -> String:
        return colored_row_begin(mode, number, rest)

    def generate_cell(
        self,
        mode: String,
        request: OutputCellRequest,
        catalog: HtmlCellCatalog,
    ) -> String:
        var spec = output_mode_spec(mode)
        if spec.canonical_name == "nichts":
            return ""
        if spec.canonical_name == "html":
            return html_cell_open(
                catalog,
                request.language,
                request.source_column,
                request.rendered_column,
                request.row_number == 0,
                request.heading_text,
                request.prefer_rendered_position,
            )
        if spec.canonical_name == "bbcode":
            return generate_simple_cell(
                "bbcode",
                request.source_column,
                request.content,
                request.has_content,
            )
        return spec.begin_cell

    def generate_cell_with_default_catalog(
        self, mode: String, request: OutputCellRequest
    ) raises -> String:
        var catalog = load_html_cell_catalog()
        return self.generate_cell(mode, request, catalog)

    def snapshot(self) -> OutputSyntaxBundleSnapshot:
        # Python sorts the mapping keys in the snapshot comprehension.
        var names: List[String] = [
            "bbcode",
            "csv",
            "emacs",
            "html",
            "markdown",
            "nichts",
            "shell",
        ]
        var modes = List[OutputSyntaxModeSnapshot]()
        for name in names:
            var spec = output_mode_spec(name)
            modes.append(
                OutputSyntaxModeSnapshot(
                    spec.canonical_name,
                    spec.syntax_class_name,
                    spec.force_one_table,
                    spec.force_zero_width,
                    spec.marks_html_or_bbcode,
                )
            )
        return OutputSyntaxBundleSnapshot(
            "OutputSyntaxBundle",
            modes^,
            "libs.lib4tables",
            "reta_architecture.output_syntax",
        )


def bootstrap_output_syntax() -> OutputSyntaxBundle:
    return OutputSyntaxBundle(OUTPUT_SYNTAX_CLASSES())


def output_syntax_snapshot() -> OutputSyntaxBundleSnapshot:
    var bundle = bootstrap_output_syntax()
    return bundle.snapshot()
