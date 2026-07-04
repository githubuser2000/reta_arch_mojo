"""Native row-selection and table slicing for the Reta pipeline."""

from std.collections import List, Set
from .row_filtering import RowFilterConfig, filter_original_lines, sorted_row_numbers
from .csv_table import CsvTable, select_rows


@fieldwise_init
struct DisplaySelection(Copyable):
    var rows: List[Int]
    var headings_amount: Int
    var numlen: Int


def _initial_rows(highest: Int) -> Set[Int]:
    var values = Set[Int]()
    for value in range(highest + 4):
        values.add(value)
    return values^


def _full_rows_with_header(highest: Int) -> Set[Int]:
    var values = Set[Int]()
    for value in range(highest + 1):
        values.add(value)
    return values^


def _copy_set(values: Set[Int]) -> Set[Int]:
    var result = Set[Int]()
    for value in values:
        result.add(value)
    return result^


def select_display_lines(
    config: RowFilterConfig,
    table: CsvTable,
    positive_conditions: List[String],
    negative_conditions: List[String],
) raises -> DisplaySelection:
    """Port of ``table_preparation.select_display_lines``.

    Row zero is always reinserted as the table heading. Negative conditions are
    evaluated through the same row-filter state machine before subtraction.
    """
    var selected = filter_original_lines(
        config, _initial_rows(config.highest_main), positive_conditions
    )

    if len(negative_conditions) > 0:
        var excluded = filter_original_lines(
            config, _copy_set(selected), negative_conditions
        )
        var changed = False
        for value in range(1, config.highest_main + 1):
            if value not in excluded:
                changed = True
                break
        if changed:
            for value in excluded:
                if value in selected:
                    selected.remove(value)

    if len(selected) == 0 and not config.rows_were_set:
        selected = _full_rows_with_header(config.highest_main)
    selected.add(0)

    var ordered = sorted_row_numbers(selected)
    var numlen = 1
    if len(ordered) > 0:
        numlen = String(ordered[len(ordered) - 1]).byte_length()
    var headings_amount = 0
    if len(table.rows) > 0:
        headings_amount = len(table.rows[0])
    return DisplaySelection(ordered^, headings_amount, numlen)


def select_display_table(table: CsvTable, selection: DisplaySelection) -> CsvTable:
    return select_rows(table, selection.rows)


# ---------------------------------------------------------------------------
# Typed row preparation context (Stage 11j)
# ---------------------------------------------------------------------------

from .table_wrapping import (
    TextWrapRuntime,
    codepoint_length,
    default_text_wrap_runtime,
    hard_chunks,
    width_for_row,
    wrap_cell_text,
)
from .tag_schema import (
    TAG_GALAXIE,
    TAG_GEBROCHEN_RATIONAL,
    TAG_GLEICHFOERMIGES_POLYGON,
    TAG_KEIN_PARA_OD_META,
    TAG_STERN_POLYGON,
    TAG_UNIVERSUM,
    TagSchemaBundle,
    tags_for_column,
)
from .tag_schema_catalog import bootstrap_tag_schema


@fieldwise_init
struct ParallelRowPreparationContext(Copyable):
    """Owned subset of the historical mutable ``Prepare`` object.

    Only values read by ``prepare_row_cells`` are carried into a worker. Header
    tag mutation deliberately stays outside this context and remains serial.
    ``reli_table_len_until_now == -1`` represents Python ``None``.
    """

    var rows_as_numbers: Set[Int]
    var combi_rows: Int
    var headings_amount: Int
    var shell_rows_amount: Int
    var widths: List[Int]
    var text_width: Int
    var wrapping_runtime: TextWrapRuntime
    var religion_numbers_bool: Bool
    var reli_table_len_until_now: Int
    var kombi_csv_number: Int


@fieldwise_init
struct PreparedIndexedRow(Copyable):
    var index: Int
    var cells: List[List[String]]


@fieldwise_init
struct PreparedRowsSerialResult(Copyable):
    var rows: List[PreparedIndexedRow]
    var religion_numbers: List[Int]


def make_parallel_row_preparation_context(
    rows_as_numbers: Set[Int],
    combi_rows: Int = 0,
    headings_amount: Int = 0,
    shell_rows_amount: Int = 0,
    widths: List[Int] = List[Int](),
    text_width: Int = 21,
    wrapping_runtime: TextWrapRuntime = default_text_wrap_runtime(),
    religion_numbers_bool: Bool = True,
    reli_table_len_until_now: Int = -1,
    kombi_csv_number: Int = 0,
) -> ParallelRowPreparationContext:
    var copied_rows = Set[Int]()
    for value in rows_as_numbers:
        copied_rows.add(value)
    var copied_widths = List[Int]()
    for value in widths:
        copied_widths.append(value)
    return ParallelRowPreparationContext(
        copied_rows^,
        combi_rows,
        headings_amount,
        shell_rows_amount,
        copied_widths^,
        text_width,
        wrapping_runtime.copy(),
        religion_numbers_bool,
        reli_table_len_until_now,
        kombi_csv_number,
    )


def prepare_cell_fragments(
    cell: String,
    width: Int,
    runtime: TextWrapRuntime,
) -> List[String]:
    """Port the observable cell boundary without a mutable Prepare facade."""
    var clean = String(cell.strip())
    if width == 0:
        return [clean]
    var wrapped = wrap_cell_text(clean, width, runtime)
    if not wrapped.wrapped or len(wrapped.parts) == 0:
        return [clean]

    # A missing optional hyphenation backend may return the original overlong
    # text as one part. Guarantee progress and the width invariant explicitly.
    var result = List[String]()
    for part in wrapped.parts:
        if width > 0 and codepoint_length(part) > width:
            var chunks = hard_chunks(part, width)
            for chunk in chunks:
                result.append(chunk)
        else:
            result.append(part)
    if len(result) == 0:
        result.append(clean)
    return result^


def prepare_indexed_row(
    row_index: Int,
    line: List[String],
    context: ParallelRowPreparationContext,
) -> PreparedIndexedRow:
    var prepared = List[List[String]]()
    var row_to_display = 0
    for column in range(len(line)):
        if column in context.rows_as_numbers:
            row_to_display += 1
            var width = width_for_row(
                context.shell_rows_amount,
                len(context.rows_as_numbers),
                context.widths,
                context.text_width,
                row_to_display,
                context.combi_rows,
            )
            prepared.append(
                prepare_cell_fragments(
                    line[column], width, context.wrapping_runtime
                )
            )
    return PreparedIndexedRow(row_index, prepared^)


def prepare_rows_serial(
    row_indexes: List[Int],
    rows: List[List[String]],
    context: ParallelRowPreparationContext,
) -> PreparedRowsSerialResult:
    var prepared = List[PreparedIndexedRow]()
    var religion_numbers = List[Int]()
    var count = min(len(row_indexes), len(rows))
    for index in range(count):
        var row_number = row_indexes[index]
        prepared.append(
            prepare_indexed_row(row_number, rows[index], context)
        )
        if context.religion_numbers_bool:
            religion_numbers.append(row_number)
    return PreparedRowsSerialResult(prepared^, religion_numbers^)


# ---------------------------------------------------------------------------
# Complete architecture owner surface (Stage 12c5ad)
# ---------------------------------------------------------------------------

@fieldwise_init
struct ColumnIndexEntry(Copyable, Equatable, Writable):
    """One historical old2Rows mapping pair.

    Python keeps two dictionaries (source→output and output→source).  The
    native owner stores the same bijection once and derives either direction.
    """

    var source_column: Int
    var output_column: Int

    def __eq__(self, other: Self) -> Bool:
        return (
            self.source_column == other.source_column
            and self.output_column == other.output_column
        )

    def write_to[W: Writer](self, mut writer: W):
        writer.write("(", self.source_column, "->", self.output_column, ")")


@fieldwise_init
struct ColumnIndexMapping(Copyable):
    var entries: List[ColumnIndexEntry]

    def source_for_output(self, output_column: Int) -> Int:
        for index in range(len(self.entries)):
            if self.entries[index].output_column == output_column:
                return self.entries[index].source_column
        return -1

    def output_for_source(self, source_column: Int) -> Int:
        for index in range(len(self.entries)):
            if self.entries[index].source_column == source_column:
                return self.entries[index].output_column
        return -1


@fieldwise_init
struct GeneratedTagOverrides(Copyable):
    """Typed replacement for the heterogeneous ``gebrSpalten`` dictionary."""

    var prime_columns: Set[Int]
    var galaxy_columns: Set[Int]
    var universe_columns: Set[Int]
    var emotion_columns: Set[Int]
    var size_columns: Set[Int]


def empty_generated_tag_overrides() -> GeneratedTagOverrides:
    return GeneratedTagOverrides(
        Set[Int](), Set[Int](), Set[Int](), Set[Int](), Set[Int]()
    )


@fieldwise_init
struct PreparedColumnTag(Copyable):
    var output_column: Int
    var source_column: Int
    var parameter: String
    var tags: List[Int]


@fieldwise_init
struct TablePreparationExecutionStats(Copyable):
    var mode: String
    var selected_rows: Int
    var prepared_rows: Int
    var prepared_columns: Int


@fieldwise_init
struct PreparedOutputTableResult(Copyable):
    var finally_display_lines: List[Int]
    var new_table: List[List[List[String]]]
    var numlen: Int
    var rows_range: List[Int]
    var old2new_table: ColumnIndexMapping
    var religion_numbers: List[Int]
    var column_tags: List[PreparedColumnTag]
    var stats: TablePreparationExecutionStats


@fieldwise_init
struct MainTablePreparationSnapshot(Copyable):
    var class_name: String
    var finally_display_lines_len: Int
    var new_table_len: Int
    var numlen: Int
    var rows_range_len: Int


@fieldwise_init
struct MainTablePreparationResult(Copyable):
    var finally_display_lines: List[Int]
    var new_table: List[List[List[String]]]
    var numlen: Int
    var rows_range: List[Int]
    var old2new_table: ColumnIndexMapping
    var religion_numbers: List[Int]
    var column_tags: List[PreparedColumnTag]

    def snapshot(self) -> MainTablePreparationSnapshot:
        return MainTablePreparationSnapshot(
            "MainTablePreparationResult",
            len(self.finally_display_lines),
            len(self.new_table),
            self.numlen,
            len(self.rows_range),
        )


@fieldwise_init
struct KombiTablePreparationSnapshot(Copyable):
    var class_name: String
    var finally_display_lines_len: Int
    var new_table_len: Int
    var line_len: Int
    var animals_professions_table_len: Int


@fieldwise_init
struct KombiTablePreparationResult(Copyable):
    var finally_display_lines: List[Int]
    var new_table: List[List[List[String]]]
    var line_len: Int
    var animals_professions_table: CsvTable
    var old2new_table_animals_professions: ColumnIndexMapping
    var religion_numbers: List[Int]
    var column_tags: List[PreparedColumnTag]

    def snapshot(self) -> KombiTablePreparationSnapshot:
        return KombiTablePreparationSnapshot(
            "KombiTablePreparationResult",
            len(self.finally_display_lines),
            len(self.new_table),
            self.line_len,
            len(self.animals_professions_table.rows),
        )


@fieldwise_init
struct TablePreparationBundleSnapshot(Copyable):
    var class_name: String
    var display_line_morphism: String
    var row_morphism: String
    var tag_gluing_morphism: String
    var cell_morphism: String
    var parallel_row_morphism: String
    var deduplication_morphism: String
    var last_line_morphism: String
    var universal_operations: List[String]
    var main_table_result: String
    var kombi_table_result: String
    var legacy_delegate: String


@fieldwise_init
struct TablePreparationBundle(Copyable):
    var schema: TagSchemaBundle

    def snapshot(self) -> TablePreparationBundleSnapshot:
        return TablePreparationBundleSnapshot(
            "TablePreparationBundle",
            "select_display_lines",
            "prepare_row_cells",
            "tag_output_column",
            "cell_work",
            "prepare_rows_in_processes",
            "deduplicate_parameter_sections",
            "capture_last_line_number",
            [
                "deduplicate_parameter_sections",
                "capture_last_line_number",
                "prepare_main_output",
                "prepare_kombi_output",
                "process_parallel_row_chunks",
            ],
            "MainTablePreparationResult",
            "KombiTablePreparationResult",
            "libs.lib4tables_prepare.Prepare",
        )

    def select_display_lines(
        self,
        config: RowFilterConfig,
        table: CsvTable,
        positive_conditions: List[String],
        negative_conditions: List[String],
    ) raises -> DisplaySelection:
        return select_display_lines(
            config, table, positive_conditions, negative_conditions
        )

    def prepare_row_cells(
        self,
        row_index: Int,
        line: List[String],
        context: ParallelRowPreparationContext,
    ) -> PreparedIndexedRow:
        return prepare_indexed_row(row_index, line, context)

    def tag_output_column(
        self,
        source_column: Int,
        output_column: Int,
        parameter: String,
        combi_rows: Int = 0,
        kombi_csv_number: Int = 0,
        reli_table_len_until_now: Int = 0,
        overrides: GeneratedTagOverrides = empty_generated_tag_overrides(),
        parameter_already_present: Bool = False,
    ) -> PreparedColumnTag:
        return tag_output_column(
            self.schema.copy(),
            source_column,
            output_column,
            parameter,
            combi_rows,
            kombi_csv_number,
            reli_table_len_until_now,
            overrides,
            parameter_already_present,
        )

    def cell_work(
        self, cell: String, width: Int, runtime: TextWrapRuntime
    ) -> List[String]:
        return prepare_cell_fragments(cell, width, runtime)

    def deduplicate_parameter_sections(
        self, first: Set[Int], second: Set[Int]
    ) -> Tuple[Set[Int], Set[Int]]:
        return deduplicate_parameter_sections(first, second)

    def capture_last_line_number(self, selection: DisplaySelection) -> Int:
        return capture_last_line_number(selection)

    def prepare_output_table(
        self,
        config: RowFilterConfig,
        table: CsvTable,
        positive_conditions: List[String],
        negative_conditions: List[String],
        context: ParallelRowPreparationContext,
        overrides: GeneratedTagOverrides = empty_generated_tag_overrides(),
    ) raises -> PreparedOutputTableResult:
        return prepare_output_table(
            config,
            table,
            positive_conditions,
            negative_conditions,
            context,
            self.schema.copy(),
            overrides,
        )

    def prepare_main_output(
        self,
        config: RowFilterConfig,
        table: CsvTable,
        positive_conditions: List[String],
        negative_conditions: List[String],
        context: ParallelRowPreparationContext,
        overrides: GeneratedTagOverrides = empty_generated_tag_overrides(),
    ) raises -> MainTablePreparationResult:
        var result = self.prepare_output_table(
            config,
            table,
            positive_conditions,
            negative_conditions,
            context,
            overrides,
        )
        return MainTablePreparationResult(
            result.finally_display_lines.copy(),
            result.new_table.copy(),
            result.numlen,
            result.rows_range.copy(),
            result.old2new_table.copy(),
            result.religion_numbers.copy(),
            result.column_tags.copy(),
        )

    def prepare_kombi_output(
        self,
        config: RowFilterConfig,
        table: CsvTable,
        context: ParallelRowPreparationContext,
        reli_table_len_until_now: Int,
        kombi_csv_number: Int,
    ) raises -> KombiTablePreparationResult:
        var kombi_context = context.copy()
        kombi_context.combi_rows = max(1, context.combi_rows)
        kombi_context.reli_table_len_until_now = reli_table_len_until_now
        kombi_context.kombi_csv_number = kombi_csv_number
        var result = prepare_output_table(
            config,
            table,
            List[String](),
            List[String](),
            kombi_context,
            self.schema.copy(),
            empty_generated_tag_overrides(),
        )
        return KombiTablePreparationResult(
            result.finally_display_lines.copy(),
            result.new_table.copy(),
            result.numlen,
            table.copy(),
            result.old2new_table.copy(),
            result.religion_numbers.copy(),
            result.column_tags.copy(),
        )


def _copy_tags(values: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _generated_override_tags(
    source_column: Int,
    overrides: GeneratedTagOverrides,
) -> List[Int]:
    if source_column in overrides.prime_columns:
        return [TAG_STERN_POLYGON, TAG_UNIVERSUM, TAG_GALAXIE]
    if source_column in overrides.galaxy_columns:
        return [
            TAG_STERN_POLYGON,
            TAG_GALAXIE,
            TAG_GLEICHFOERMIGES_POLYGON,
            TAG_GEBROCHEN_RATIONAL,
        ]
    if source_column in overrides.universe_columns:
        return [
            TAG_STERN_POLYGON,
            TAG_UNIVERSUM,
            TAG_GLEICHFOERMIGES_POLYGON,
            TAG_GEBROCHEN_RATIONAL,
        ]
    if (
        source_column in overrides.emotion_columns
        or source_column in overrides.size_columns
    ):
        return [
            TAG_STERN_POLYGON,
            TAG_GLEICHFOERMIGES_POLYGON,
            TAG_GEBROCHEN_RATIONAL,
            TAG_KEIN_PARA_OD_META,
        ]
    return List[Int]()


def tag_output_column(
    schema: TagSchemaBundle,
    source_column: Int,
    output_column: Int,
    parameter: String,
    combi_rows: Int = 0,
    kombi_csv_number: Int = 0,
    reli_table_len_until_now: Int = 0,
    overrides: GeneratedTagOverrides = empty_generated_tag_overrides(),
    parameter_already_present: Bool = False,
) -> PreparedColumnTag:
    """Own the formerly global generated-column tag mutation explicitly.

    The Python reference first installs the catalog tags for a new output
    column. Generated-column overrides are considered only when that output
    parameter already exists. Making this state explicit avoids relying on a
    mutable external dictionary while preserving the historical branch order.
    """
    var tags: List[Int]
    var target_column = output_column
    if combi_rows == 0:
        if parameter_already_present:
            var generated = _generated_override_tags(source_column, overrides)
            if len(generated) > 0:
                tags = generated^
            else:
                tags = tags_for_column(schema, source_column, -1)
        else:
            tags = tags_for_column(schema, source_column, -1)
    else:
        tags = tags_for_column(schema, source_column, kombi_csv_number)
        target_column = reli_table_len_until_now + output_column
    return PreparedColumnTag(
        target_column, source_column, parameter, _copy_tags(tags)
    )


def deduplicate_parameter_sections(
    first: Set[Int], second: Set[Int]
) -> Tuple[Set[Int], Set[Int]]:
    var clean_first = Set[Int]()
    var clean_second = Set[Int]()
    for value in first:
        if value not in second:
            clean_first.add(value)
    for value in second:
        if value not in first:
            clean_second.add(value)
    return (clean_first^, clean_second^)


def capture_last_line_number(selection: DisplaySelection) -> Int:
    if len(selection.rows) == 0:
        return 0
    return selection.rows[len(selection.rows) - 1]


def _rows_range(headings_amount: Int) -> List[Int]:
    var result = List[Int]()
    for value in range(headings_amount):
        result.append(value)
    return result^


def _selected_source_columns(
    line: List[String], rows_as_numbers: Set[Int]
) -> List[Int]:
    var result = List[Int]()
    for source_column in range(len(line)):
        if source_column in rows_as_numbers:
            result.append(source_column)
    return result^


def _column_mapping(source_columns: List[Int]) -> ColumnIndexMapping:
    var entries = List[ColumnIndexEntry]()
    for output_column in range(len(source_columns)):
        entries.append(
            ColumnIndexEntry(source_columns[output_column], output_column)
        )
    return ColumnIndexMapping(entries^)


def _contains_row(rows: List[Int], value: Int) -> Bool:
    for index in range(len(rows)):
        if rows[index] == value:
            return True
    return False


def prepare_output_table(
    config: RowFilterConfig,
    table: CsvTable,
    positive_conditions: List[String],
    negative_conditions: List[String],
    context: ParallelRowPreparationContext,
    schema: TagSchemaBundle = bootstrap_tag_schema(),
    overrides: GeneratedTagOverrides = empty_generated_tag_overrides(),
) raises -> PreparedOutputTableResult:
    """Typed serial owner of the complete local preparation orchestration.

    Row-zero/tag mutation stays serial exactly as in Python.  Independent data
    rows use the same pure ``prepare_indexed_row`` kernel that the separate
    thread owner calls, so parallel execution remains a replaceable outer
    strategy rather than a second semantic implementation.
    """
    var selection = select_display_lines(
        config, table, positive_conditions, negative_conditions
    )
    var prepared_rows = List[List[List[String]]]()
    var religion_numbers = List[Int]()
    var column_tags = List[PreparedColumnTag]()
    var source_columns = List[Int]()

    if len(table.rows) > 0:
        source_columns = _selected_source_columns(
            table.rows[0], context.rows_as_numbers
        )
        for output_column in range(len(source_columns)):
            var source_column = source_columns[output_column]
            var parameter = String()
            if source_column < len(table.rows[0]):
                parameter = table.rows[0][source_column]
            column_tags.append(
                tag_output_column(
                    schema,
                    source_column,
                    output_column,
                    parameter,
                    context.combi_rows,
                    context.kombi_csv_number,
                    max(0, context.reli_table_len_until_now),
                    overrides,
                )
            )

    for row_index in range(len(table.rows)):
        if context.combi_rows == 0 and not _contains_row(selection.rows, row_index):
            continue
        var prepared = prepare_indexed_row(
            row_index, table.rows[row_index], context
        )
        prepared_rows.append(prepared.cells.copy())
        if context.religion_numbers_bool:
            religion_numbers.append(row_index)

    var selected_row_count = len(selection.rows)
    var prepared_row_count = len(prepared_rows)
    var prepared_column_count = len(source_columns)
    return PreparedOutputTableResult(
        selection.rows.copy(),
        prepared_rows^,
        selection.numlen,
        _rows_range(selection.headings_amount),
        _column_mapping(source_columns),
        religion_numbers^,
        column_tags^,
        TablePreparationExecutionStats(
            "serial",
            selected_row_count,
            prepared_row_count,
            prepared_column_count,
        ),
    )


def bootstrap_table_preparation() -> TablePreparationBundle:
    return TablePreparationBundle(bootstrap_tag_schema())
