"""Native deterministic renderers for selected Reta table rows."""

from std.collections import List
from .csv_table import CsvTable
from .row_filtering import counting_groups
from .output_modes import colored_row_begin


def normalize_cell_whitespace(text: String) -> String:
    var result = String()
    var pending_space = False
    var started = False
    for slice in text.codepoint_slices():
        var part = String(slice)
        var whitespace = (
            part == " " or part == "\t" or part == "\n" or part == "\r"
        )
        if whitespace:
            if started:
                pending_space = True
            continue
        if pending_space:
            result += " "
            pending_space = False
        result += part
        started = True
    return result^


def _normal_table(table: CsvTable) -> CsvTable:
    var rows = List[List[String]]()
    for row_index in range(len(table.rows)):
        var row = List[String]()
        var source = table.rows[row_index].copy()
        for column_index in range(len(source)):
            row.append(normalize_cell_whitespace(source[column_index]))
        rows.append(row^)
    return CsvTable(rows^, table.maximum_columns)


def _decimal_width(value: Int) -> Int:
    var number = abs(value)
    var width = 1
    while number >= 10:
        number //= 10
        width += 1
    return width


def _right_aligned_number(value: Int, width: Int) -> String:
    var result = String(value)
    while result.byte_length() < width:
        result = " " + result
    return result^


def add_numbering_columns(table: CsvTable, row_numbers: List[Int]) -> CsvTable:
    """Add historical counting and source-row columns before selected data."""
    var normalized = _normal_table(table)
    var highest = 0
    for index in range(len(row_numbers)):
        if row_numbers[index] > highest:
            highest = row_numbers[index]
    var groups = counting_groups(highest)
    var number_width = _decimal_width(highest)
    var rows = List[List[String]]()
    for index in range(len(normalized.rows)):
        var source = normalized.rows[index].copy()
        var row = List[String]()
        var number = row_numbers[index] if index < len(row_numbers) else index
        if number == 0:
            row.append("")
            row.append("")
        else:
            row.append(String(groups[number]))
            row.append(_right_aligned_number(number, number_width))
        for column_index in range(len(source)):
            row.append(source[column_index] + ("" if number == 0 else ""))
        rows.append(row^)
    return CsvTable(rows^, normalized.maximum_columns + 2)


def _csv_quote_minimal(text: String) -> String:
    var value = text
    if value.find(";") >= 0 or value.find("\"") >= 0 or value.find("\n") >= 0 or value.find("\r") >= 0:
        return "\"" + value.replace("\"", "\"\"") + "\""
    return value^


def render_csv_table(table: CsvTable) -> String:
    """Match Python ``csv.writer(delimiter=';')`` with LF line endings."""
    var result = String()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        for column_index in range(len(row)):
            if column_index > 0:
                result += ";"
            var value = row[column_index]
            if column_index == 1:
                value += " "
            result += _csv_quote_minimal(value)
        result += "\n"
    return result^


def render_markdown_table(table: CsvTable) -> String:
    var result = String()
    if len(table.rows) == 0:
        return result^
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        result += "|"
        for column_index in range(len(row)):
            result += row[column_index]
            if row_index == 0 or column_index != 0:
                result += " "
            result += "|"
        result += "\n"
        if row_index == 0:
            result += "|"
            for _ in range(len(row)):
                result += ":--:|"
            result += "\n"
    return result^


def render_emacs_table(table: CsvTable) -> String:
    var result = String()
    if len(table.rows) == 0:
        return result^
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        result += "|"
        for column_index in range(len(row)):
            result += row[column_index]
            if row_index == 0 or column_index != 0:
                result += " "
            result += "|"
        result += "\n"
        if row_index == 0:
            result += "|"
            for column_index in range(len(row)):
                result += "----"
                result += "+" if column_index + 1 < len(row) else "|"
            result += "\n"
    return result^


def _html_escape(text: String) -> String:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def render_html_table(table: CsvTable, row_numbers: List[Int]) -> String:
    var result = String("<table border=0 id=\"bigtable\">\n")
    for row_index in range(len(table.rows)):
        var number = row_numbers[row_index] if row_index < len(row_numbers) else row_index
        result += colored_row_begin("html", number)
        var row = table.rows[row_index].copy()
        for column_index in range(len(row)):
            if column_index == 0:
                result += " <td style=\"background-color:#ffffff;color:#000000;\"> "
            else:
                result += " <td> "
            result += _html_escape(row[column_index]) + " </td>"
        result += " </tr>\n"
    result += "</table>\n"
    return result^


def render_bbcode_table(table: CsvTable, row_numbers: List[Int]) -> String:
    var result = String("[table]\n")
    for row_index in range(len(table.rows)):
        var number = row_numbers[row_index] if row_index < len(row_numbers) else row_index
        result += colored_row_begin("bbcode", number)
        var row = table.rows[row_index].copy()
        for column_index in range(len(row)):
            if column_index == 0:
                result += "[td=\"background-color:#ffffff;color:#000000\"]"
            else:
                result += "[td=\"\"]"
            result += row[column_index] + "[/td]"
        result += " [/tr]\n"
    result += "[/table]\n"
    return result^


def render_plain_table(table: CsvTable) -> String:
    var result = String()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        for column_index in range(len(row)):
            if column_index > 0:
                result += " | "
            result += row[column_index]
        result += "\n"
    return result^


def render_table(
    table: CsvTable, row_numbers: List[Int], mode: String
) -> String:
    if mode == "csv":
        return render_csv_table(table)
    if mode == "markdown":
        return render_markdown_table(table)
    if mode == "emacs":
        return render_emacs_table(table)
    if mode == "html":
        return render_html_table(table, row_numbers)
    if mode == "bbcode":
        return render_bbcode_table(table, row_numbers)
    if mode == "nichts":
        return ""
    return render_plain_table(table)
