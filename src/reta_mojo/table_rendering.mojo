"""Native deterministic renderers for selected Reta table rows."""

from std.collections import List
from .csv_table import CsvTable
from .row_filtering import counting_groups
from .number_theory import moon_number, prime_factors
from .output_modes import colored_row_begin
from .table_wrapping import codepoint_length, hard_chunks
from .html_cell_metadata import (
    HtmlCellCatalog,
    html_cell_open,
    load_html_cell_catalog,
)


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
            row.append(
                normalize_cell_whitespace(source[column_index])
                .replace("@@RETA_COMBI_LEADING_SPACE@@", " ")
                .replace("@@RETA_COMBI_TRAILING_SPACE@@", " ")
            )
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


def add_numbering_columns(
    table: CsvTable,
    row_numbers: List[Int],
    normalize_cells: Bool = True,
) -> CsvTable:
    """Add historical counting and source-row columns before selected data."""
    var normalized = _normal_table(table) if normalize_cells else table.copy()
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


def _html_ascii_letter(code: Int) -> Bool:
    return (code >= 65 and code <= 90) or (code >= 97 and code <= 122)


def _html_slice_bytes(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _html_escape_preserving_tags(text: String) -> String:
    """Escape text while retaining deliberate HTML tags from CSV generators."""
    var result = String()
    var cursor = 0
    var plain_start = 0
    var bytes = text.as_bytes()
    while cursor < len(bytes):
        var code = Int(bytes[cursor])
        if code != 38 and code != 60 and code != 62:
            cursor += 1
            continue
        if cursor > plain_start:
            result += _html_slice_bytes(text, plain_start, cursor)
        if code == 38:
            result += "&amp;"
            cursor += 1
        elif code == 62:
            result += "&gt;"
            cursor += 1
        else:
            var tag_start = False
            if cursor + 1 < len(bytes):
                var next_code = Int(bytes[cursor + 1])
                tag_start = (
                    _html_ascii_letter(next_code)
                    or next_code == 33
                    or next_code == 63
                )
                if (
                    next_code == 47
                    and cursor + 2 < len(bytes)
                    and _html_ascii_letter(Int(bytes[cursor + 2]))
                ):
                    tag_start = True
            if tag_start:
                var closing = cursor + 1
                while (
                    closing < len(bytes)
                    and Int(bytes[closing]) != 62
                ):
                    closing += 1
                if closing < len(bytes):
                    result += _html_slice_bytes(text, cursor, closing + 1)
                    cursor = closing + 1
                else:
                    result += "&lt;"
                    cursor += 1
            else:
                result += "&lt;"
                cursor += 1
        plain_start = cursor
    if plain_start < len(bytes):
        result += _html_slice_bytes(text, plain_start, len(bytes))
    return result^


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


def _render_parse_uint(text: String) -> Int:
    var result = 0
    for index in range(text.byte_length()):
        var code = ord(text[byte=index])
        if code < 48 or code > 57:
            return -1
        result = result * 10 + code - 48
    return result


def _bbcode_counting_cell(content: String, heading: Bool) -> String:
    var style = String("background-color:#ffffff;color:#000000")
    if not heading and content.byte_length() > 0 and _render_parse_uint(content) % 2 == 0:
        style = "background-color:#000000;color:#ffffff"
    return "[td=\"" + style + "\"]" + (" " if heading else content) + "[/td]"


def _pad_cell(text: String, width: Int) -> String:
    # BBCode/HTML are passed through the legacy coloured console path, which
    # collapses every run of padding whitespace to one significant space.
    if width > 0 and codepoint_length(text) < width:
        return text + " "
    return text


def _append_long_word(mut result: List[String], word: String, width: Int) -> String:
    """Append complete chunks and return the final chunk as current line."""
    var chunks = hard_chunks(word, width)
    if len(chunks) == 0:
        return ""
    for index in range(len(chunks) - 1):
        result.append(chunks[index])
    return chunks[len(chunks) - 1]


def _hyphen_prefix_fitting(word: String, available: Int) -> String:
    """Return the longest existing-hyphen prefix fitting this line."""
    if available <= 0 or not "-" in word:
        return ""
    var parts = word.split("-")
    if len(parts) < 2:
        return ""
    var candidate = String()
    var best = String()
    for index in range(len(parts) - 1):
        if index > 0:
            candidate += "-"
        candidate += String(parts[index]) + "-"
        if codepoint_length(candidate) <= available:
            best = candidate
        else:
            break
    return best^


def _slice_after_ascii_prefix(text: String, prefix: String) -> String:
    return String(StringSlice(text)[byte=prefix.byte_length():])


def _word_wrap_cell(text: String, width: Int) -> List[String]:
    var clean = normalize_cell_whitespace(text)
    var result = List[String]()
    if width <= 0 or codepoint_length(clean) <= width:
        result.append(clean)
        return result^
    var words = clean.split()
    var current = String()
    for index in range(len(words)):
        var word = String(words[index])
        if current.byte_length() == 0:
            if codepoint_length(word) <= width:
                current = word^
            else:
                current = _append_long_word(result, word, width)
        elif codepoint_length(current) + 1 + codepoint_length(word) <= width:
            current += " " + word
        else:
            # Python's stdlib ``textwrap`` keeps ``break_on_hyphens=True``.
            # If an existing hyphen prefix still fits on the current line, it
            # is consumed there before the remainder starts the next line.
            var available = width - codepoint_length(current) - 1
            var prefix = _hyphen_prefix_fitting(word, available)
            if prefix.byte_length() > 0:
                current += " " + prefix
                result.append(current^)
                var remainder = _slice_after_ascii_prefix(word, prefix)
                if codepoint_length(remainder) <= width:
                    current = remainder^
                else:
                    current = _append_long_word(result, remainder, width)
            else:
                result.append(current^)
                if codepoint_length(word) <= width:
                    current = word^
                else:
                    current = _append_long_word(result, word, width)
    if current.byte_length() > 0 or len(result) == 0:
        result.append(current^)
    return result^


def _wrapped_column_width(table: CsvTable, column: Int, width: Int) -> Int:
    if width <= 0:
        return 0
    var maximum = 0
    for row_index in range(len(table.rows)):
        var parts = _word_wrap_cell(table.rows[row_index][column], width)
        for part_index in range(len(parts)):
            maximum = max(maximum, codepoint_length(parts[part_index]))
    return maximum


def _maximum_row_number(row_numbers: List[Int]) -> Int:
    var highest = 0
    for index in range(len(row_numbers)):
        highest = max(highest, row_numbers[index])
    return highest


def render_bbcode_table_with_width_reference(
    table: CsvTable,
    width_reference: CsvTable,
    row_numbers: List[Int],
    number_rows: Bool = True,
    width: Int = 0,
) -> String:
    """Render BBCode with legacy wrapping, paging and significant spaces."""
    if len(table.rows) == 0:
        return ""
    var data_start = 2 if number_rows else 0
    var total_columns = len(table.rows[0])
    var result = String()
    var page_start = data_start
    var screen_width = 80 - _decimal_width(_maximum_row_number(row_numbers)) - 1
    while page_start < total_columns:
        var page_end = page_start
        if width <= 0:
            page_end = total_columns
        else:
            var sum_widths = 0
            while page_end < total_columns:
                var column_width = _wrapped_column_width(width_reference, page_end, width)
                var candidate = sum_widths + column_width + 1
                if page_end > page_start and candidate >= screen_width:
                    break
                sum_widths = candidate
                page_end += 1
        if page_end == page_start:
            page_end += 1
        result += "[table]\n"
        for row_index in range(len(table.rows)):
            var row = table.rows[row_index].copy()
            var row_height = 1
            if width > 0:
                for column_index in range(page_start, page_end):
                    row_height = max(
                        row_height,
                        len(_word_wrap_cell(row[column_index], width)),
                    )
            for visual_line in range(row_height):
                var number = row_numbers[row_index] if row_index < len(row_numbers) else row_index
                result += colored_row_begin("bbcode", number)
                var is_heading = number == 0
                if number_rows and len(row) > 0:
                    result += _bbcode_counting_cell(row[0], is_heading)
                if number_rows and len(row) > 1:
                    result += "[td=\"\"]"
                    result += (
                        " "
                        if is_heading or visual_line > 0
                        else row[1] + " "
                    )
                    result += "[/td]"
                for column_index in range(page_start, page_end):
                    var parts = _word_wrap_cell(row[column_index], width)
                    var part = parts[visual_line] if visual_line < len(parts) else ""
                    var column_width = _wrapped_column_width(width_reference, column_index, width)
                    result += "[td=\"\"]" + _pad_cell(part, column_width) + "[/td] "
                result += "[/tr]\n"
        result += "[/table]\n"
        page_start = page_end
    return result^


def render_bbcode_table(
    table: CsvTable,
    row_numbers: List[Int],
    number_rows: Bool = True,
    width: Int = 0,
) -> String:
    return render_bbcode_table_with_width_reference(
        table, table, row_numbers, number_rows, width
    )


def _html_counting_open(
    catalog: HtmlCellCatalog,
    language: String,
    content: String,
    heading: Bool,
) -> String:
    if heading:
        return html_cell_open(catalog, language, -2, 0, True)
    if content.byte_length() > 0 and _render_parse_uint(content) % 2 == 0:
        return '<td style="background-color:#000000;color:#ffffff;">'
    return '<td style="background-color:#ffffff;color:#000000;">'


def _html_cell_payload(text: String) -> String:
    if text.byte_length() == 0:
        return " "
    return " " + text + " "


def render_html_table_with_context(
    table: CsvTable,
    width_reference: CsvTable,
    row_numbers: List[Int],
    source_columns: List[Int],
    language: String,
    number_rows: Bool = True,
    width: Int = 0,
) raises -> String:
    if len(table.rows) == 0:
        return ""
    var catalog = load_html_cell_catalog()
    var data_start = 2 if number_rows else 0
    var total_columns = len(table.rows[0])
    var result = String()
    var page_start = data_start
    var screen_width = 80 - _decimal_width(_maximum_row_number(row_numbers)) - 1
    while page_start < total_columns:
        var page_end = page_start
        if width <= 0:
            page_end = total_columns
        else:
            var sum_widths = 0
            while page_end < total_columns:
                var column_width = _wrapped_column_width(
                    width_reference, page_end, width
                )
                var candidate = sum_widths + column_width + 1
                if page_end > page_start and candidate >= screen_width:
                    break
                sum_widths = candidate
                page_end += 1
        if page_end == page_start:
            page_end += 1
        result += '<table border=0 id="bigtable">\n'
        for row_index in range(len(table.rows)):
            var row = table.rows[row_index].copy()
            var row_height = 1
            if width > 0:
                for column_index in range(page_start, page_end):
                    row_height = max(
                        row_height,
                        len(_word_wrap_cell(row[column_index], width)),
                    )
            for visual_line in range(row_height):
                var number = (
                    row_numbers[row_index]
                    if row_index < len(row_numbers)
                    else row_index
                )
                var is_heading = number == 0
                result += colored_row_begin("html", number).replace("\n", "")
                if number_rows and len(row) > 0:
                    result += " " + _html_counting_open(
                        catalog, language, row[0], is_heading
                    )
                    result += _html_cell_payload(
                        _html_escape("" if is_heading else row[0])
                    ) + "</td>"
                if number_rows and len(row) > 1:
                    result += " " + html_cell_open(
                        catalog, language, -1, 1, is_heading, ""
                    )
                    var number_text = (
                        ""
                        if is_heading or visual_line > 0
                        else row[1]
                    )
                    result += _html_cell_payload(
                        _html_escape(number_text)
                    ) + "</td>"
                for column_index in range(page_start, page_end):
                    var parts = _word_wrap_cell(row[column_index], width)
                    var part = (
                        parts[visual_line] if visual_line < len(parts) else ""
                    )
                    var source_position = column_index - data_start
                    var source_column = (
                        source_columns[source_position]
                        if source_position >= 0
                        and source_position < len(source_columns)
                        else -999999
                    )
                    var semantic_heading = (
                        width_reference.rows[0][column_index]
                        if len(width_reference.rows) > 0
                        and column_index < len(width_reference.rows[0])
                        else ""
                    )
                    result += " " + html_cell_open(
                        catalog,
                        language,
                        source_column,
                        source_position + 2,
                        is_heading,
                        semantic_heading,
                    )
                    result += _html_cell_payload(
                        _html_escape_preserving_tags(part)
                    ) + "</td>"
                result += " </tr>\n"
        result += "</table>\n"
        page_start = page_end
    return result^



def _shell_colorize(text: String, number: Int, rest: Bool = False) -> String:
    """Historical ANSI row colors used by the shell renderer."""
    if number == 0:
        return "\x1b[41m\x1b[30m\x1b[4m" + text + "\x1b[0m"
    if rest:
        if number % 2 == 0:
            return "\x1b[47m\x1b[30m" + text + "\x1b[0m\x1b[0m"
        return "\x1b[40m\x1b[37m" + text + "\x1b[0m\x1b[0m"
    if len(moon_number(number)[1]) > 0:
        if number % 2 == 0:
            return "\x1b[106m\x1b[30m" + text + "\x1b[0m\x1b[0m"
        return "\x1b[46m\x1b[30m" + text + "\x1b[0m\x1b[0m"
    if len(prime_factors(number)) == 1:
        if number % 2 == 0:
            return "\x1b[103m\x1b[30m\x1b[1m" + text + "\x1b[0m"
        return "\x1b[43m\x1b[30m" + text + "\x1b[0m\x1b[0m"
    if number % 2 == 0:
        return "\x1b[47m\x1b[30m" + text + "\x1b[0m\x1b[0m"
    return "\x1b[100m\x1b[37m" + text + "\x1b[0m\x1b[0m"


def _shell_word_wrap_cell(text: String, width: Int) -> List[String]:
    # Preserve significant repeated ASCII spaces while reusing the historical
    # word wrapper. Two non-whitespace markers keep the same display width.
    var protected = String(text.strip()).replace("  ", "§§")
    var parts = _word_wrap_cell(protected, width)
    for index in range(len(parts)):
        parts[index] = parts[index].replace("§§", "  ")
    return parts^


def _shell_pad(text: String, width: Int) -> String:
    var result = text
    while codepoint_length(result) < width:
        result += " "
    return result^


def _shell_prefix(
    number: Int,
    visual_line: Int,
    number_width: Int,
    counting_marker: Bool,
) -> String:
    var prefix = String()
    if number == 0 or visual_line > 0:
        while prefix.byte_length() < number_width + 1:
            prefix += " "
    else:
        prefix = _right_aligned_number(number, number_width) + " "
    # The first numbering cell is not merely padding.  The historical shell
    # syntax renders even counting groups as a solid block and odd groups as a
    # blank.  Wrapped visual lines retain the same group marker.
    if counting_marker and prefix.startswith(" "):
        prefix = "█" + String(prefix[byte=1:])
    return prefix^


def _shell_column_width(table: CsvTable, column: Int, width: Int) -> Int:
    """Measure the fragments produced by the fixed preparation width.

    The Python table pipeline wraps every selected cell with ``textWidth``
    before ``cliOut`` determines the visible column width.  The final width is
    therefore the longest prepared fragment, not ``min(raw_length, width)``.
    Keep the preparation width fixed while measuring so the later render pass
    cannot progressively narrow the same cell.
    """
    if width <= 0:
        return 0
    var maximum = 0
    for row_index in range(len(table.rows)):
        var clean = String(table.rows[row_index][column].strip())
        var fragments = _shell_word_wrap_cell(clean, width)
        for fragment_index in range(len(fragments)):
            maximum = max(
                maximum, codepoint_length(fragments[fragment_index])
            )
    return maximum


def _shell_page_row_has_content(
    row: List[String], page_start: Int, page_end: Int
) -> Bool:
    for column_index in range(page_start, page_end):
        if String(row[column_index].strip()).byte_length() > 0:
            return True
    return False

def _shell_page_has_data(
    table: CsvTable,
    row_numbers: List[Int],
    page_start: Int,
    page_end: Int,
) -> Bool:
    for row_index in range(len(table.rows)):
        var number = (
            row_numbers[row_index]
            if row_index < len(row_numbers)
            else row_index
        )
        if number != 0 and _shell_page_row_has_content(
            table.rows[row_index], page_start, page_end
        ):
            return True
    return False


def render_shell_table_with_width_reference(
    table: CsvTable,
    width_reference: CsvTable,
    row_numbers: List[Int],
    number_rows: Bool = True,
    width: Int = 0,
    color_rows: Bool = True,
    numbering_highest: Int = 0,
) -> String:
    """Render the legacy ANSI terminal table, including paging and wrapping."""
    if len(table.rows) == 0:
        return ""
    var data_start = 2 if number_rows else 0
    var total_columns = len(table.rows[0])
    var highest = max(_maximum_row_number(row_numbers), numbering_highest)
    var number_width = _decimal_width(highest) + 1 if number_rows else 0
    var counting = counting_groups(highest)
    # The historical runtime reserves seven terminal columns around table data.
    var effective_width = width if width > 0 else max(1, 80 - 7)
    var screen_width = 73 if not number_rows else 80
    var result = String()
    var page_start = data_start
    while page_start < total_columns:
        var page_end = page_start
        var sum_widths = number_width + (1 if number_rows else 0)
        while page_end < total_columns:
            var column_width = _shell_column_width(
                width_reference, page_end, effective_width
            )
            var candidate = sum_widths + column_width + 1
            if page_end > page_start and candidate >= screen_width:
                break
            sum_widths = candidate
            page_end += 1
        if page_end == page_start:
            page_end += 1
        if page_start > data_start and not _shell_page_has_data(
            table, row_numbers, page_start, page_end
        ):
            result += "\n"
        for row_index in range(len(table.rows)):
            var row = table.rows[row_index].copy()
            var number = row_numbers[row_index] if row_index < len(row_numbers) else row_index
            if number != 0 and not _shell_page_row_has_content(
                row, page_start, page_end
            ):
                continue
            var row_height = 1
            for column_index in range(page_start, page_end):
                row_height = max(
                    row_height,
                    len(_shell_word_wrap_cell(row[column_index], effective_width)),
                )
            for visual_line in range(row_height):
                if number_rows:
                    var counting_marker = (
                        number > 0
                        and number < len(counting)
                        and counting[number] % 2 == 0
                    )
                    result += _shell_prefix(
                        number, visual_line, number_width, counting_marker
                    )
                for column_index in range(page_start, page_end):
                    var parts = _shell_word_wrap_cell(row[column_index], effective_width)
                    var part = parts[visual_line] if visual_line < len(parts) else ""
                    var column_width = _shell_column_width(
                        width_reference, column_index, effective_width
                    )
                    var padded = _shell_pad(part, column_width)
                    if color_rows:
                        result += _shell_colorize(padded, number) + " "
                    else:
                        result += padded + " "
                result += "\n"
        page_start = page_end
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


def render_table_with_width_reference(
    table: CsvTable,
    width_reference: CsvTable,
    row_numbers: List[Int],
    mode: String,
    width: Int = 0,
    number_rows: Bool = True,
    color_rows: Bool = True,
    numbering_highest: Int = 0,
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
        return render_bbcode_table_with_width_reference(
            table, width_reference, row_numbers, number_rows, width
        )
    if mode == "nichts":
        return ""
    if mode == "shell":
        return render_shell_table_with_width_reference(
            table,
            width_reference,
            row_numbers,
            number_rows,
            width,
            color_rows,
            numbering_highest,
        )
    return render_plain_table(table)



def render_table_with_native_context(
    table: CsvTable,
    width_reference: CsvTable,
    row_numbers: List[Int],
    source_columns: List[Int],
    language: String,
    mode: String,
    width: Int = 0,
    number_rows: Bool = True,
    color_rows: Bool = True,
    numbering_highest: Int = 0,
) raises -> String:
    if mode == "html":
        return render_html_table_with_context(
            table,
            width_reference,
            row_numbers,
            source_columns,
            language,
            number_rows,
            width,
        )
    return render_table_with_width_reference(
        table,
        width_reference,
        row_numbers,
        mode,
        width,
        number_rows,
        color_rows,
        numbering_highest,
    )

def render_table(
    table: CsvTable,
    row_numbers: List[Int],
    mode: String,
    width: Int = 0,
    number_rows: Bool = True,
) -> String:
    return render_table_with_width_reference(
        table, table, row_numbers, mode, width, number_rows
    )
