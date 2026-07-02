"""Typed native owner for the historical ``reta_architecture.combi_join`` API.

The Python owner used insertion-ordered mapping and set containers to make
otherwise set-like join selections reproducible.  The semantic result does not depend on
that insertion order: main row numbers and source row numbers form finite
relations.  Mojo therefore stores the relation as explicitly sorted typed
records.  Output-column order remains a separate, preserved concern in
``kombi_join_columns``.
"""

from std.collections import Dict, List
from std.collections.string import atol
from .csv_table import CsvTable, read_semicolon_csv
from .kombi_join_columns import (
    KombiColumnRequest,
    KombiJoinResult,
    apply_kombi_join_columns,
)
from .resource_paths import csv_resource


@fieldwise_init
struct KombiLineSelection(Copyable):
    """One main-table number and the one-based Kombi CSV rows joined to it."""

    var main_number: Int
    var source_rows: List[Int]


@fieldwise_init
struct KombiPreparedGroup(Copyable):
    """Decoded source rows belonging to one main-table number."""

    var main_number: Int
    var source_rows: List[List[String]]


@fieldwise_init
struct KombiRelationEntry(Copyable):
    """Bidirectional relation between appended and source columns."""

    var appended_column: Int
    var source_column: Int


@fieldwise_init
struct KombiSourceBundle(Copyable):
    """Result of the historical ``readKombiCsv`` preparation phase."""

    var kind: String
    var source_path: String
    var decorated_table: CsvTable
    var combinations: List[List[Int]]


@fieldwise_init
struct KombiAppendResult(Copyable):
    """Main table with Kombi placeholders and typed relation metadata."""

    var table: CsvTable
    var relations: List[KombiRelationEntry]
    var selected_columns: List[Int]


@fieldwise_init
struct KombiJoinBundle(Copyable):
    var implementation: String
    var morphisms: List[String]
    var csv_sources: List[String]
    var role: String


def _contains_int(values: List[Int], wanted: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique_int(mut values: List[Int], value: Int):
    if not _contains_int(values, value):
        values.append(value)


def _sort_ints(mut values: List[Int]):
    for index in range(1, len(values)):
        var value = values[index]
        var position = index - 1
        while position >= 0 and values[position] > value:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = value


def _sort_selections(mut values: List[KombiLineSelection]):
    for index in range(1, len(values)):
        var value = values[index].copy()
        var position = index - 1
        while position >= 0 and values[position].main_number > value.main_number:
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = value.copy()


def _is_ascii_decimal(text: String) -> Bool:
    var stripped = String(text.strip())
    if stripped.byte_length() == 0:
        return False
    var bytes = stripped.as_bytes()
    for index in range(len(bytes)):
        var code = Int(bytes[index])
        if code < 48 or code > 57:
            return False
    return True


def _strip_one_outer_pair(text: String) -> String:
    var stripped = String(text.strip())
    if (
        stripped.byte_length() > 1
        and stripped.startswith("(")
        and stripped.endswith(")")
    ):
        return String(StringSlice(stripped)[byte=1:-1])
    return stripped^


def parse_kombi_number_token(text: String) raises -> List[Int]:
    """Decode one legacy number, signed number, parenthesized number or n/m.

    Fractions contribute numerator and denominator independently, exactly like
    ``kombiNumbersCorrectTestAndSet``.  Values are absolute because Kombi
    relations connect religion numbers independently of their sign.
    """

    var token = _strip_one_outer_pair(text)
    if token.byte_length() == 0:
        raise Error("empty Kombi number token")
    if _is_ascii_decimal(token):
        return [abs(atol(token))]
    if (
        (token.startswith("+") or token.startswith("-"))
        and token.byte_length() > 1
    ):
        var tail = String(StringSlice(token)[byte=1:])
        if _is_ascii_decimal(tail):
            return [abs(atol(token))]
    var slash = token.find("/")
    if token.byte_length() > 2 and slash > 0:
        var left = parse_kombi_number_token(
            String(StringSlice(token)[byte=:slash])
        )
        var right = parse_kombi_number_token(
            String(StringSlice(token)[byte=slash + 1:])
        )
        var result = left.copy()
        for index in range(len(right)):
            result.append(right[index])
        return result^
    raise Error("invalid Kombi number token: " + token)


def parse_kombi_expression_numbers(text: String) raises -> List[Int]:
    """Decode the complete first CSV cell separated by ``|``."""

    var result = List[Int]()
    var parts = text.split("|")
    for index in range(len(parts)):
        var values = parse_kombi_number_token(String(parts[index]))
        for value_index in range(len(values)):
            result.append(values[value_index])
    return result^


def _kombi_source_path(kind: String, explicit_path: String = "") -> String:
    if explicit_path.byte_length() > 0:
        return explicit_path
    if kind == "galaxy":
        return csv_resource("kombi.csv")
    if kind == "universe":
        return csv_resource("kombi-meta.csv")
    return ""


def load_kombi_join_source(
    kind: String, path: String = ""
) raises -> KombiSourceBundle:
    """Read and decorate a Kombi CSV without Python or ordered containers."""

    var source_path = _kombi_source_path(kind, path)
    if source_path.byte_length() == 0:
        raise Error("unknown Kombi source kind: " + kind)
    var raw = read_semicolon_csv(source_path)
    var decorated_rows = List[List[String]]()
    var combinations = List[List[Int]]()
    for row_index in range(len(raw.rows)):
        var source_row = raw.rows[row_index].copy()
        var row = source_row.copy()
        var raw_expression = String()
        var expression = String()
        if len(source_row) > 0:
            raw_expression = source_row[0]
            expression = String(raw_expression.strip())
        if expression.byte_length() > 0:
            for column_index in range(1, len(row)):
                if String(row[column_index].strip()).byte_length() > 0:
                    # The Python owner tests the stripped expression but embeds
                    # the original CSV spelling, including its trailing space.
                    row[column_index] = (
                        "("
                        + raw_expression
                        + ") "
                        + row[column_index]
                        + " ("
                        + raw_expression
                        + ")"
                    )
        decorated_rows.append(row^)
        if row_index > 0 and expression.byte_length() > 0:
            combinations.append(parse_kombi_expression_numbers(expression))
    return KombiSourceBundle(
        kind,
        source_path,
        CsvTable(decorated_rows^, raw.maximum_columns),
        combinations^,
    )


def append_kombi_placeholders(
    main_table: CsvTable,
    source: KombiSourceBundle,
    selected_source_columns: List[Int],
) -> KombiAppendResult:
    """Model ``readKombiCsv``'s pre-join table extension.

    Every source column except the expression column gets an appended slot.
    ``selected_source_columns`` is one-based, as in the Python owner.
    """

    var source_columns = max(source.decorated_table.maximum_columns - 1, 0)
    var row_count = max(len(main_table.rows), len(source.decorated_table.rows))
    var rows = List[List[String]]()
    for row_index in range(row_count):
        var row = List[String]()
        if row_index < len(main_table.rows):
            row = main_table.rows[row_index].copy()
        while len(row) < main_table.maximum_columns:
            row.append("")
        if row_index == 0 and len(source.decorated_table.rows) > 0:
            var source_header = source.decorated_table.rows[0].copy()
            for source_column in range(1, source.decorated_table.maximum_columns):
                row.append(
                    source_header[source_column]
                    if source_column < len(source_header)
                    else ""
                )
        else:
            for _ in range(source_columns):
                row.append("")
        rows.append(row^)

    var relations = List[KombiRelationEntry]()
    for source_column in range(source_columns):
        relations.append(
            KombiRelationEntry(main_table.maximum_columns + source_column, source_column)
        )

    var selected = List[Int]()
    for index in range(len(selected_source_columns)):
        var source_column = selected_source_columns[index]
        if source_column > 0 and source_column <= source_columns:
            _append_unique_int(
                selected, main_table.maximum_columns + source_column - 1
            )
    _sort_ints(selected)
    return KombiAppendResult(
        CsvTable(rows^, main_table.maximum_columns + source_columns),
        relations^,
        selected^,
    )


def _has_kombi_condition(param_lines: List[String]) -> Bool:
    for index in range(len(param_lines)):
        if param_lines[index] == "ka" or param_lines[index] == "ka2":
            return True
    return False


def select_kombi_lines(
    param_lines: List[String],
    displaying_rows: List[Int],
    combinations: List[List[Int]],
) -> List[KombiLineSelection]:
    """Canonical order-independent replacement for ``prepare_kombi``."""

    var result = List[KombiLineSelection]()
    if not _has_kombi_condition(param_lines):
        return result^
    for source_index in range(len(combinations)):
        var numbers = combinations[source_index].copy()
        for number_index in range(len(numbers)):
            var number = numbers[number_index]
            if not _contains_int(displaying_rows, number):
                continue
            var found = -1
            for result_index in range(len(result)):
                if result[result_index].main_number == number:
                    found = result_index
                    break
            if found < 0:
                result.append(KombiLineSelection(number, [source_index + 1]))
            else:
                _append_unique_int(result[found].source_rows, source_index + 1)
    for index in range(len(result)):
        _sort_ints(result[index].source_rows)
    _sort_selections(result)
    return result^


def prepare_kombi_join_tables(
    selections: List[KombiLineSelection], source: KombiSourceBundle
) -> List[KombiPreparedGroup]:
    """Typed replacement for ``prepareTableJoin``."""

    var ordered = selections.copy()
    _sort_selections(ordered)
    var result = List[KombiPreparedGroup]()
    for selection_index in range(len(ordered)):
        var rows = List[List[String]]()
        var source_rows = ordered[selection_index].source_rows.copy()
        _sort_ints(source_rows)
        for row_index in range(len(source_rows)):
            var source_row = source_rows[row_index]
            if source_row >= 0 and source_row < len(source.decorated_table.rows):
                rows.append(source.decorated_table.rows[source_row].copy())
        result.append(
            KombiPreparedGroup(ordered[selection_index].main_number, rows^)
        )
    return result^


def _reduce_expression(expression: String, number: Int) raises -> String:
    var parts = expression.split("|")
    var kept = List[String]()
    for index in range(len(parts)):
        var token = _strip_one_outer_pair(String(parts[index]))
        var remove = False
        if token.find("/") < 0:
            try:
                var values = parse_kombi_number_token(token)
                if len(values) == 1:
                    remove = abs(values[0]) == abs(number)
            except:
                pass
        if not remove:
            kept.append(token^)
    var result = String()
    for index in range(len(kept)):
        if index > 0:
            result += "|"
        result += kept[index]
    return result^


def remove_kombi_number_from_cell(cell: String, number: Int) raises -> String:
    """String-level native replacement for ``removeOneNumber``.

    The trailing provenance expression remains unchanged, matching the legacy
    cell transformation.
    """

    var stripped = String(cell)
    if not stripped.startswith("("):
        return stripped^
    var close = stripped.find(") ")
    if close < 0:
        return stripped^
    var expression = String(StringSlice(stripped)[byte=1:close])
    var reduced = _reduce_expression(expression, number)
    var remainder = String(StringSlice(stripped)[byte=close + 2:])
    if reduced.byte_length() == 0:
        return " " + remainder
    return "(" + reduced + ") " + remainder


# Historical spellings retained as thin typed aliases.
def kombiNumbersCorrectTestAndSet(text: String) raises -> List[Int]:
    return parse_kombi_number_token(text)


def prepare_kombi(
    param_lines: List[String],
    displaying_rows: List[Int],
    combinations: List[List[Int]],
) -> List[KombiLineSelection]:
    return select_kombi_lines(param_lines, displaying_rows, combinations)


def prepareTableJoin(
    selections: List[KombiLineSelection], source: KombiSourceBundle
) -> List[KombiPreparedGroup]:
    return prepare_kombi_join_tables(selections, source)


def removeOneNumber(cell: String, number: Int) raises -> String:
    return remove_kombi_number_from_cell(cell, number)


def readKombiCsv(
    kind: String, path: String = ""
) raises -> KombiSourceBundle:
    return load_kombi_join_source(kind, path)


def tableJoin(
    table: CsvTable,
    requests: List[KombiColumnRequest],
    last_row: Int,
    output_mode: String = "shell",
) raises -> KombiJoinResult:
    return apply_kombi_join_columns(table, requests, last_row, output_mode)


def bootstrap_combi_join() -> KombiJoinBundle:
    return KombiJoinBundle(
        "KombiJoin",
        [
            "prepareTableJoin",
            "removeOneNumber",
            "tableJoin",
            "prepare_kombi",
            "readKombiCsv",
            "kombiNumbersCorrectTestAndSet",
        ],
        [csv_resource("kombi.csv"), csv_resource("kombi-meta.csv")],
        "Kombi CSV presheaf sections -> joined table section",
    )
