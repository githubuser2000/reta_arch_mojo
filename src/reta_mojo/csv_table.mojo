"""Owned UTF-8 text loading and semicolon-CSV parsing for native Reta.

Filesystem reads, parsing, selection, fingerprinting and rendering are native
Mojo.  This module is the single byte-preserving asset-loading boundary used by
CSV tables, generated catalogs, prompt language assets and HTML metadata.
"""

from std.collections import List
from std.collections.string import ord


@fieldwise_init
struct CsvTable(Copyable):
    var rows: List[List[String]]
    var maximum_columns: Int


def empty_csv_table() -> CsvTable:
    return CsvTable(List[List[String]](), 0)


def _csv_slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])




def _parse_simple_semicolon_csv(text: String) -> CsvTable:
    var rows = List[List[String]]()
    var maximum_columns = 0
    var lines = text.split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.endswith("\r"):
            line = String(StringSlice(line)[byte=:-1])
        if line_index == len(lines) - 1 and line.byte_length() == 0:
            continue
        var pieces = line.split(";")
        var row = List[String]()
        for column_index in range(len(pieces)):
            row.append(String(pieces[column_index]))
        if len(row) > maximum_columns:
            maximum_columns = len(row)
        rows.append(row^)
    return CsvTable(rows^, maximum_columns)

def parse_semicolon_csv(text: String) -> CsvTable:
    if text.find("\"") < 0:
        return _parse_simple_semicolon_csv(text)
    var rows = List[List[String]]()
    var row = List[String]()
    var cell = String()
    var chunk_start = 0
    var index = 0
    var in_quotes = False
    var maximum_columns = 0
    var bytes = text.as_bytes()
    while index < len(bytes):
        var code = Int(bytes[index])
        if code == 34:
            # CSV quoting only starts when the quote is the first byte of a
            # field.  Quotes embedded in an unquoted cell (notably the
            # |{"":...}| religion JSON wrapper) are ordinary data and must
            # survive byte-for-byte, matching Python's csv.reader.
            if not in_quotes and index != chunk_start:
                index += 1
                continue
            cell += _csv_slice(text, chunk_start, index)
            if in_quotes and index + 1 < len(bytes) and Int(bytes[index + 1]) == 34:
                cell += "\""
                index += 2
                chunk_start = index
                continue
            in_quotes = not in_quotes
            index += 1
            chunk_start = index
            continue
        if not in_quotes and (code == 59 or code == 10 or code == 13):
            cell += _csv_slice(text, chunk_start, index)
            row.append(cell^)
            cell = String()
            if code == 59:
                index += 1
                chunk_start = index
                continue
            if code == 13 and index + 1 < len(bytes) and Int(bytes[index + 1]) == 10:
                index += 1
            if len(row) > maximum_columns:
                maximum_columns = len(row)
            rows.append(row^)
            row = List[String]()
            index += 1
            chunk_start = index
            continue
        index += 1
    if chunk_start < len(bytes) or cell.byte_length() > 0 or len(row) > 0:
        cell += _csv_slice(text, chunk_start, len(bytes))
        row.append(cell^)
        if len(row) > maximum_columns:
            maximum_columns = len(row)
        rows.append(row^)
    return CsvTable(rows^, maximum_columns)


def read_text_file(path: String) raises -> String:
    var file = open(path, "r")
    return file.read()


def read_semicolon_csv(path: String) raises -> CsvTable:
    return parse_semicolon_csv(read_text_file(path))


def table_cell_count(table: CsvTable) -> Int:
    var count = 0
    for row_index in range(len(table.rows)):
        count += len(table.rows[row_index])
    return count


def table_fingerprint(table: CsvTable) -> Int:
    comptime MOD = 1000000007
    var value = 17
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        for column_index in range(len(row)):
            var cell = row[column_index]
            var cell_bytes = cell.as_bytes()
            for byte_index in range(len(cell_bytes)):
                value = (value * 257 + Int(cell_bytes[byte_index]) + 1) % MOD
            value = (value * 257 + 257) % MOD
        value = (value * 257 + 258) % MOD
    return value


def _contains_column(columns: List[Int], value: Int) -> Bool:
    for index in range(len(columns)):
        if columns[index] == value:
            return True
    return False


def select_columns(table: CsvTable, one_based_columns: List[Int]) -> CsvTable:
    if len(one_based_columns) == 0:
        return table.copy()
    var rows = List[List[String]]()
    for row_index in range(len(table.rows)):
        var source = table.rows[row_index].copy()
        var row = List[String]()
        for column_index in range(len(one_based_columns)):
            var source_index = one_based_columns[column_index] - 1
            if source_index >= 0 and source_index < len(source):
                row.append(source[source_index])
        rows.append(row^)
    return CsvTable(rows^, len(one_based_columns))


def select_rows(table: CsvTable, zero_based_rows: List[Int]) -> CsvTable:
    var rows = List[List[String]]()
    for index in range(len(zero_based_rows)):
        var row_index = zero_based_rows[index]
        if row_index >= 0 and row_index < len(table.rows):
            rows.append(table.rows[row_index].copy())
    return CsvTable(rows^, table.maximum_columns)


def _escape_csv_cell(text: String) -> String:
    return text.replace("\\", "\\\\").replace(";", "\\;").replace("\"", "\\\"")


def render_semicolon_csv(table: CsvTable) -> String:
    var result = String()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        for column_index in range(len(row)):
            if column_index > 0:
                result += ";"
            result += _escape_csv_cell(row[column_index])
        result += "\n"
    return result^


def select_zero_based_columns(table: CsvTable, columns: List[Int]) -> CsvTable:
    if len(columns) == 0:
        return table.copy()
    var rows = List[List[String]]()
    for row_index in range(len(table.rows)):
        var source = table.rows[row_index].copy()
        var row = List[String]()
        for column_index in range(len(columns)):
            var source_index = columns[column_index]
            if source_index >= 0 and source_index < len(source):
                row.append(source[source_index])
        rows.append(row^)
    return CsvTable(rows^, len(columns))
