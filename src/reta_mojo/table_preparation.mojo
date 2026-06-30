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
    return DisplaySelection(ordered^, table.maximum_columns, numlen)


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
