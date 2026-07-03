"""Complete typed owner for ``reta_architecture.table_output``.

The historical Python ``TableOutput`` class mixes mutable renderer settings,
column projection, output buffering, terminal colour selection and the actual
format serializers.  The serializers already live in ``table_rendering``;
this module owns the missing class/bundle boundary and turns the implicit
``Tables`` object graph into an explicit ``TableOutputConfig`` value.
"""

from std.collections import List
from .csv_table import CsvTable, empty_csv_table, select_columns
from .output_modes import canonicalize_output_mode, output_mode_spec
from .table_rendering import (
    colorize_shell_text,
    render_table_with_native_context,
)


@fieldwise_init
struct TableOutputBundleSnapshot(Copyable, Equatable):
    var class_name: String
    var output_class: String
    var responsibility: String
    var legacy_nested_class: String


@fieldwise_init
struct TableOutputRuntimeSnapshot(Copyable, Equatable):
    var class_name: String
    var output_mode: String
    var syntax_class_name: String
    var color: Bool
    var one_table: Bool
    var number_rows: Bool
    var text_height: Int
    var text_width: Int
    var width_count: Int
    var resulting_chunk_count: Int
    var no_headings: Bool
    var no_blank_contents: Bool
    var nothing_output: Bool
    var language: String


@fieldwise_init
struct TableOutputConfig(Copyable, Equatable):
    var output_mode: String
    var syntax_class_name: String
    var color: Bool
    var one_table: Bool
    var widths: List[Int]
    var number_rows: Bool
    var text_height: Int
    var text_width: Int
    var no_headings: Bool
    var no_blank_contents: Bool
    var nothing_output: Bool
    var language: String
    var source_columns: List[Int]
    var numbering_highest: Int


@fieldwise_init
struct TableOutputRenderResult(Copyable):
    var table: CsvTable
    var width_reference: CsvTable
    var row_numbers: List[Int]
    var rendered_text: String
    var emitted_text: String
    var resulting_table: List[String]


@fieldwise_init
struct TableOutput(Copyable):
    """Typed replacement for the dynamic Python renderer instance.

    ``TableOutputConfig`` contains every mutable property consumed by the
    renderer.  ``text_state`` preserves the constructor boundary, while
    ``resulting_table`` models the historical list populated by ``cliout2``.
    """

    var config: TableOutputConfig
    var text_state: List[String]
    var resulting_table: List[String]

    def out_type(self) -> String:
        return self.config.output_mode.copy()

    def set_out_type(mut self, value: String) raises:
        var canonical = canonicalize_output_mode(value)
        if canonical.byte_length() == 0:
            raise Error("unknown output mode: " + value)
        var spec = output_mode_spec(canonical)
        self.config.output_mode = spec.canonical_name.copy()
        self.config.syntax_class_name = spec.syntax_class_name.copy()
        if spec.force_one_table:
            self.config.one_table = True
        if spec.force_zero_width:
            self.config.text_width = 0

    def color(self) -> Bool:
        return self.config.color

    def set_color(mut self, value: Bool):
        self.config.color = value

    def one_table(self) -> Bool:
        return self.config.one_table

    def set_one_table(mut self, value: Bool):
        self.config.one_table = value

    def breitenn(self) -> List[Int]:
        return self.config.widths.copy()

    def set_breitenn(mut self, value: List[Int]):
        self.config.widths = value.copy()

    def nummeriere(self) -> Bool:
        return self.config.number_rows

    def set_nummeriere(mut self, value: Bool):
        self.config.number_rows = value

    def text_height(self) -> Int:
        return self.config.text_height

    def set_text_height(mut self, value: Int):
        self.config.text_height = value

    def text_width(self) -> Int:
        return self.config.text_width

    def set_text_width(mut self, value: Int):
        self.config.text_width = value

    def only_that_columns(
        self, table: CsvTable, one_based_columns: List[Int]
    ) -> CsvTable:
        return select_columns(table, one_based_columns)

    def cliout2(mut self, text: String) -> String:
        """Append an output chunk and return the physically emitted text.

        Python always records the chunk in ``resultingTable`` and suppresses
        only the console effect for ``NichtsOutputYes``.  Returning the effect
        text keeps this boundary deterministic and testable.
        """
        self.resulting_table.append(text)
        if self.config.nothing_output:
            return ""
        return text.copy()

    def colorize(
        self, text: String, number: Int, rest: Bool = False
    ) -> String:
        return colorize_shell_text(text, number, rest)

    def cli_out(
        mut self,
        table: CsvTable,
        width_reference: CsvTable,
        row_numbers: List[Int],
    ) raises -> TableOutputRenderResult:
        var active_table = table.copy()
        var active_width_reference = width_reference.copy()
        var active_numbers = row_numbers.copy()
        if self.config.no_headings:
            active_table = _without_heading(active_table)
            active_width_reference = _without_heading(active_width_reference)
            active_numbers = _without_heading_number(active_numbers)

        var source_columns = self.config.source_columns.copy()
        if len(source_columns) == 0:
            source_columns = _default_source_columns(
                active_table,
                2 if self.config.number_rows else 0,
            )

        var maximum_number = self.config.numbering_highest
        if maximum_number <= 0:
            maximum_number = _maximum_row_number(active_numbers)

        var rendered = render_table_with_native_context(
            active_table,
            active_width_reference,
            active_numbers,
            source_columns,
            self.config.language.copy(),
            self.config.output_mode.copy(),
            self.config.text_width,
            self.config.number_rows,
            self.config.color,
            maximum_number,
            self.config.one_table,
            self.config.no_blank_contents,
            self.config.widths.copy(),
        )
        var emitted = self.cliout2(rendered.copy())
        return TableOutputRenderResult(
            active_table^,
            active_width_reference^,
            active_numbers^,
            rendered^,
            emitted^,
            self.resulting_table.copy(),
        )

    def snapshot(self) -> TableOutputRuntimeSnapshot:
        return TableOutputRuntimeSnapshot(
            "TableOutput",
            self.config.output_mode,
            self.config.syntax_class_name,
            self.config.color,
            self.config.one_table,
            self.config.number_rows,
            self.config.text_height,
            self.config.text_width,
            len(self.config.widths),
            len(self.resulting_table),
            self.config.no_headings,
            self.config.no_blank_contents,
            self.config.nothing_output,
            self.config.language,
        )


@fieldwise_init
struct TableOutputBundle(Copyable):
    var output_class_name: String

    def create(
        self, config: TableOutputConfig, text_state: List[String]
    ) -> TableOutput:
        return TableOutput(config.copy(), text_state.copy(), List[String]())

    def create_default(self) -> TableOutput:
        return self.create(default_table_output_config(), List[String]())

    def snapshot(self) -> TableOutputBundleSnapshot:
        return TableOutputBundleSnapshot(
            "TableOutputBundle",
            self.output_class_name,
            "table-output-rendering-morphism",
            "Tables.Output",
        )


def default_table_output_config() -> TableOutputConfig:
    var spec = output_mode_spec("shell")
    return TableOutputConfig(
        spec.canonical_name,
        spec.syntax_class_name,
        True,
        False,
        List[Int](),
        True,
        0,
        21,
        False,
        False,
        False,
        "german",
        List[Int](),
        0,
    )


def bootstrap_table_output() -> TableOutputBundle:
    return TableOutputBundle("TableOutput")


def _without_heading(table: CsvTable) -> CsvTable:
    if len(table.rows) <= 1:
        return empty_csv_table()
    var rows = List[List[String]]()
    for row_index in range(1, len(table.rows)):
        rows.append(table.rows[row_index].copy())
    return CsvTable(rows^, table.maximum_columns)


def _without_heading_number(row_numbers: List[Int]) -> List[Int]:
    if len(row_numbers) <= 1:
        return List[Int]()
    var result = List[Int]()
    for index in range(1, len(row_numbers)):
        result.append(row_numbers[index])
    return result^


def _default_source_columns(table: CsvTable, data_start: Int) -> List[Int]:
    var result = List[Int]()
    var columns = table.maximum_columns
    if len(table.rows) > 0:
        columns = max(columns, len(table.rows[0]))
    for index in range(data_start, columns):
        result.append(index - data_start)
    return result^


def _maximum_row_number(row_numbers: List[Int]) -> Int:
    var result = 0
    for index in range(len(row_numbers)):
        if row_numbers[index] > result:
            result = row_numbers[index]
    return result
