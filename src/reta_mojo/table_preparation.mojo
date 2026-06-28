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
