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
from .terminal_geometry import (
    automatic_cell_width,
    effective_cell_width,
    terminal_columns,
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


def _cell_fragment_visible(text: String, no_blank_contents: Bool) -> Bool:
    var clean = String(text.strip())
    if no_blank_contents:
        return codepoint_length(clean) >= 2
    return clean.byte_length() > 0


def _row_range_visible(
    row: List[String],
    start: Int,
    end: Int,
    no_blank_contents: Bool,
) -> Bool:
    for column_index in range(start, end):
        if _cell_fragment_visible(row[column_index], no_blank_contents):
            return True
    return False


def _filter_no_blank_rows(
    table: CsvTable,
    row_numbers: List[Int],
    data_start: Int,
    no_blank_contents: Bool,
) -> Tuple[CsvTable, List[Int]]:
    if not no_blank_contents:
        return table.copy(), row_numbers.copy()
    var rows = List[List[String]]()
    var numbers = List[Int]()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        if _row_range_visible(
            row, data_start, len(row), no_blank_contents
        ):
            rows.append(row^)
            numbers.append(
                row_numbers[row_index]
                if row_index < len(row_numbers)
                else row_index
            )
    return CsvTable(rows^, table.maximum_columns), numbers^


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


def render_csv_table(
    table: CsvTable, number_rows: Bool = True
) -> String:
    """Match Python ``csv.writer(delimiter=';')`` with LF line endings.

    The legacy CSV exporter retains two empty structural numbering fields even
    when ``--keinenummerierung`` hides their contents.  In that unnumbered
    path the selected data has not passed through ``add_numbering_columns``,
    so normalize its source whitespace here as Rich/csv did historically.
    """
    var result = String()
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        if not number_rows:
            result += ";;"
        for column_index in range(len(row)):
            if column_index > 0:
                result += ";"
            var value = row[column_index]
            if not number_rows:
                value = normalize_cell_whitespace(value)
            elif column_index == 1:
                value += " "
            result += _csv_quote_minimal(value)
        result += "\n"
    return result^


def _render_flat_width_csv_table(
    table: CsvTable, number_rows: Bool
) -> String:
    """Render prepared width fragments like the legacy Rich CSV path.

    Missing prepared data fragments are padded by the configured column width
    before Rich collapses whitespace; the observable CSV field is therefore a
    single space rather than an empty string.
    """
    var result = String()
    var data_start = 2 if number_rows else 0
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        if not number_rows:
            result += ";;"
        for column_index in range(len(row)):
            if column_index > 0:
                result += ";"
            var value = row[column_index]
            if column_index == 1 and number_rows:
                value += " "
            elif (
                column_index >= data_start
                and column_index + 1 < len(row)
                and value.byte_length() == 0
            ):
                value = " "
            result += _csv_quote_minimal(value)
        result += "\n"
    return result^


def render_markdown_table_with_rows(
    table: CsvTable,
    row_numbers: List[Int],
    number_rows: Bool = True,
) -> String:
    var result = String()
    if len(table.rows) == 0:
        return result^
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        var number = (
            row_numbers[row_index]
            if row_index < len(row_numbers)
            else row_index
        )
        result += "|"
        for column_index in range(len(row)):
            result += row[column_index]
            if number == 0 or not number_rows or column_index != 0:
                result += " "
            result += "|"
        result += "\n"
        # The Python renderer emits the Markdown separator after every visual
        # fragment of the logical heading row, not merely after the first
        # physical output line.
        if number == 0:
            result += "|"
            for _ in range(len(row)):
                result += ":--:|"
            result += "\n"
    return result^


def render_markdown_table(table: CsvTable) -> String:
    var row_numbers = List[Int]()
    for row_index in range(len(table.rows)):
        row_numbers.append(row_index)
    return render_markdown_table_with_rows(table, row_numbers^)


def _emacs_prime_power_separator(number: Int) -> Bool:
    """Match the legacy org-table separator after non-prime prime powers."""
    if number <= 1:
        return False
    var factors = prime_factors(number)
    if len(factors) <= 1:
        return False
    var first = factors[0]
    for index in range(1, len(factors)):
        if factors[index] != first:
            return False
    return True


def _append_emacs_separator(mut result: String, columns: Int) -> None:
    result += "|"
    for column_index in range(columns):
        result += "----"
        result += "+" if column_index + 1 < columns else "|"
    result += "\n"


def render_emacs_table_with_rows(
    table: CsvTable,
    row_numbers: List[Int],
    number_rows: Bool = True,
) -> String:
    var result = String()
    if len(table.rows) == 0:
        return result^
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        var number = (
            row_numbers[row_index]
            if row_index < len(row_numbers)
            else row_index
        )
        result += "|"
        for column_index in range(len(row)):
            result += row[column_index]
            if number == 0 or not number_rows or column_index != 0:
                result += " "
            result += "|"
        result += "\n"
        # Like Markdown, a wrapped logical heading remains a heading on every
        # physical line.  Prime-power separators likewise follow every visual
        # fragment of the corresponding data row in the legacy loop.
        if number == 0 or _emacs_prime_power_separator(number):
            _append_emacs_separator(result, len(row))
    return result^


def render_emacs_table(table: CsvTable) -> String:
    var row_numbers = List[Int]()
    for row_index in range(len(table.rows)):
        row_numbers.append(row_index)
    return render_emacs_table_with_rows(table, row_numbers^)


def _html_escape(text: String) -> String:
    """Escape HTML without any byte-indexed String slicing.

    The Modular String runtime validates UTF-8 boundaries strictly.  Walking
    code-point slices avoids both raw byte offsets and implementation-defined
    ``String.replace`` internals when a cell contains umlauts, CJK text or
    emoji before an escapable ASCII character.
    """
    var result = String()
    for character in text.codepoint_slices():
        var part = String(character)
        if part == "&":
            result += "&amp;"
        elif part == "<":
            result += "&lt;"
        elif part == ">":
            result += "&gt;"
        elif part == "\"":
            result += "&quot;"
        else:
            result += part
    return result^


def _html_ascii_letter(code: Int) -> Bool:
    return (code >= 65 and code <= 90) or (code >= 97 and code <= 122)


def _html_slice_bytes(text: String, start: Int, end: Int) -> String:
    """Return a valid UTF-8 span without constructing a raw byte slice.

    The HTML scanner records ASCII delimiter positions in bytes.  Those
    positions should be code-point boundaries, but malformed or future input
    must never turn a renderer into an illegal-instruction abort.  Rebuilding
    the span from code-point slices preserves exact text for aligned offsets
    and safely widens a mistakenly unaligned boundary to the containing
    codepoint instead of trapping.
    """
    if end <= start or end <= 0:
        return ""
    var wanted_start = max(start, 0)
    var result = String()
    var byte_cursor = 0
    for character in text.codepoint_slices():
        var part = String(character)
        var next_cursor = byte_cursor + part.byte_length()
        if next_cursor <= wanted_start:
            byte_cursor = next_cursor
            continue
        if byte_cursor >= end:
            break
        result += part
        byte_cursor = next_cursor
    return result^


def _html_contains_deliberate_tag(text: String) -> Bool:
    var bytes = text.as_bytes()
    var cursor = 0
    while cursor + 1 < len(bytes):
        if Int(bytes[cursor]) != 60:
            cursor += 1
            continue
        var next_code = Int(bytes[cursor + 1])
        var tag_start = (
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
            return True
        cursor += 1
    return False


def _html_escape_preserving_tags(
    text: String, trusted_generator: Bool = False
) -> String:
    """Escape plain cells, while retaining deliberate generator markup.

    Python's HTML generator treats a payload containing real tags as trusted
    markup: tag delimiters, quotes and standalone ``>`` characters remain
    verbatim.  Ampersands and comparison ``<`` characters outside tags still
    need escaping.  Plain cells use the complete HTML escaping contract.
    """
    if not trusted_generator and not _html_contains_deliberate_tag(text):
        return _html_escape(text)

    var preserve_raw_quotes = (
        trusted_generator
        and (text.find("<ul") >= 0 or text.find("<li") >= 0)
    )
    var result = String()
    var cursor = 0
    var plain_start = 0
    var bytes = text.as_bytes()
    while cursor < len(bytes):
        var code = Int(bytes[cursor])
        if code != 34 and code != 38 and code != 60 and code != 62:
            cursor += 1
            continue
        if cursor > plain_start:
            result += _html_slice_bytes(text, plain_start, cursor)
        if code == 34:
            result += "\"" if preserve_raw_quotes else "&quot;"
            cursor += 1
        elif code == 38:
            result += "&amp;"
            cursor += 1
        elif code == 62:
            if cursor > 0 and Int(bytes[cursor - 1]) == 45:
                result += ">"
            else:
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
                while closing < len(bytes) and Int(bytes[closing]) != 62:
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
    """Parse ASCII digits without indexing inside UTF-8 code points."""
    var result = 0
    for character in text.codepoint_slices():
        var part = String(character)
        var bytes = part.as_bytes()
        if len(bytes) != 1:
            return -1
        var code = Int(bytes[0])
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


def _pad_cell_raw(text: String, width: Int) -> String:
    """Preserve the exact ``str.ljust`` contract of ``--nocolor`` markup."""
    var result = text
    while width > 0 and codepoint_length(result) < width:
        result += " "
    return result^


def _raw_number_field(text: String, width: Int) -> String:
    """Return ``(text + " ").rjust(width)`` without Python."""
    var result = text + " "
    while codepoint_length(result) < width:
        result = " " + result
    return result^


def _append_long_word(mut result: List[String], word: String, width: Int) -> String:
    """Append TextWrapper-compatible long-word parts.

    Python's ``textwrap`` prefers an existing ASCII hyphen as a break point
    before falling back to hard chunks.  This distinction matters when a word
    is moved to a fresh visual line: ``Wildkatzen-Außerirdische)`` at width 21
    becomes ``Wildkatzen-`` / ``Außerirdische)`` rather than two arbitrary
    21-codepoint chunks.
    """
    if width <= 0:
        return word
    var remainder = word
    while codepoint_length(remainder) > width:
        var hyphen_prefix = _hyphen_prefix_fitting(remainder, width)
        if hyphen_prefix.byte_length() > 0:
            var next_remainder = _slice_after_ascii_prefix(
                remainder, hyphen_prefix
            )
            if next_remainder == remainder:
                # Defensive no-progress guard: a reconstructed prefix must be
                # exact, but a fallback hard split is safer than looping or
                # slicing at an invalid UTF-8 byte offset.
                var fallback_chunks = hard_chunks(remainder, width)
                for index in range(len(fallback_chunks) - 1):
                    result.append(fallback_chunks[index])
                return fallback_chunks[len(fallback_chunks) - 1]
            result.append(hyphen_prefix)
            remainder = next_remainder^
            continue
        var chunks = hard_chunks(remainder, width)
        if len(chunks) == 0:
            return ""
        for index in range(len(chunks) - 1):
            result.append(chunks[index])
        return chunks[len(chunks) - 1]
    return remainder^


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
    """Remove an exact prefix without constructing a raw byte slice.

    ``prefix`` is assembled from code-point slices or ASCII-hyphen split
    fragments.  ``removeprefix`` therefore preserves the UTF-8 boundary even
    when the prefix contains umlauts, CJK text or combining characters.
    """
    if prefix.byte_length() == 0:
        return text
    if not text.startswith(prefix):
        return text
    return String(text.removeprefix(prefix))


def _codepoint_prefix(text: String, wanted: Int) -> String:
    """Return at most ``wanted`` Unicode code points from ``text``."""
    if wanted <= 0:
        return ""
    var result = String()
    var count = 0
    for character in text.codepoint_slices():
        if count >= wanted:
            break
        result += String(character)
        count += 1
    return result^


def _split_markup_words(
    text: String,
    mut words: List[String],
    mut separator_widths: List[Int],
) -> None:
    """Split text while retaining the width of legacy whitespace runs.

    Iterate by Unicode code points rather than advancing raw byte offsets.  A
    byte scanner is sufficient for finding ASCII separators, but later slicing
    those offsets is needlessly fragile when a word contains multi-byte UTF-8.
    """
    var clean = String(text.strip())
    var pending_width = 0
    var current = String()
    for character in clean.codepoint_slices():
        var part = String(character)
        var whitespace = (
            part == " " or part == "\t" or part == "\n" or part == "\r"
        )
        if whitespace:
            if current.byte_length() > 0:
                words.append(current^)
                current = String()
            pending_width += 1
            continue
        if current.byte_length() == 0:
            separator_widths.append(
                0 if len(separator_widths) == 0 else pending_width
            )
            pending_width = 0
        current += part
    if current.byte_length() > 0:
        words.append(current^)


def _word_wrap_cell(text: String, width: Int) -> List[String]:
    var clean = normalize_cell_whitespace(text)
    var result = List[String]()
    if width <= 0:
        result.append(clean)
        return result^
    var words = List[String]()
    var separator_widths = List[Int]()
    _split_markup_words(text, words, separator_widths)
    if len(words) == 0:
        result.append(clean)
        return result^

    # Use the raw source width for the wrap decision.  Visible output remains
    # normalized, matching the HTML/BBCode serializers.
    var raw_width = 0
    for index in range(len(words)):
        raw_width += codepoint_length(words[index]) + separator_widths[index]
    if raw_width <= width:
        result.append(clean)
        return result^

    var current = String()
    for index in range(len(words)):
        var word = words[index]
        var separator_width = separator_widths[index]
        if current.byte_length() == 0:
            if codepoint_length(word) <= width:
                current = word
            else:
                current = _append_long_word(result, word, width)
        elif (
            codepoint_length(current)
            + separator_width
            + codepoint_length(word)
            <= width
        ):
            current += " " + word
        else:
            # Python's stdlib ``textwrap`` keeps ``break_on_hyphens=True``.
            # If an existing hyphen prefix still fits on the current line, it
            # is consumed there before the remainder starts the next line.
            var available = width - codepoint_length(current) - separator_width
            var prefix = _hyphen_prefix_fitting(word, available)
            if (
                prefix.byte_length() == 0
                and available > 0
                and codepoint_length(word) > width
                and not "-" in word
            ):
                prefix = _codepoint_prefix(word, available)
            if prefix.byte_length() > 0:
                current += " " + prefix
                result.append(current^)
                var remainder = _slice_after_ascii_prefix(word, prefix)
                if remainder == word:
                    var fallback = hard_chunks(word, width)
                    for fallback_index in range(len(fallback) - 1):
                        result.append(fallback[fallback_index])
                    current = fallback[len(fallback) - 1]
                elif codepoint_length(remainder) <= width:
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



def _raw_markup_word_wrap_cell(text: String, width: Int) -> List[String]:
    """Wrap like Python ``textwrap`` while retaining internal space runs.

    The raw HTML/BBCode path used by ``--nocolor`` bypasses Rich, therefore
    the prepared fragments themselves—not only their source widths—must keep
    significant runs of spaces.  Control whitespace is normalized to ASCII
    spaces, matching ``TextWrapper.replace_whitespace``.
    """
    var clean = String(text.strip())
    var result = List[String]()
    if width <= 0 or codepoint_length(clean) <= width:
        result.append(clean)
        return result^

    var words = List[String]()
    var separators = List[String]()
    var pending_spaces = String()
    var current_word = String()
    for character in clean.codepoint_slices():
        var part = String(character)
        var whitespace = (
            part == " " or part == "\t" or part == "\n" or part == "\r"
        )
        if whitespace:
            if current_word.byte_length() > 0:
                words.append(current_word^)
                current_word = String()
            pending_spaces += " "
            continue
        if current_word.byte_length() == 0:
            separators.append(
                "" if len(separators) == 0 else pending_spaces
            )
            pending_spaces = String()
        current_word += part
    if current_word.byte_length() > 0:
        words.append(current_word^)

    var current = String()
    for index in range(len(words)):
        var word = words[index]
        var separator = separators[index]
        var separator_width = codepoint_length(separator)
        if current.byte_length() == 0:
            if codepoint_length(word) <= width:
                current = word
            else:
                current = _append_long_word(result, word, width)
        elif (
            codepoint_length(current)
            + separator_width
            + codepoint_length(word)
            <= width
        ):
            current += separator + word
        else:
            var available = width - codepoint_length(current) - separator_width
            var prefix = _hyphen_prefix_fitting(word, available)
            if (
                prefix.byte_length() == 0
                and available > 0
                and codepoint_length(word) > width
                and not "-" in word
            ):
                prefix = _codepoint_prefix(word, available)
            if prefix.byte_length() > 0:
                current += separator + prefix
                result.append(current^)
                var remainder = _slice_after_ascii_prefix(word, prefix)
                if remainder == word:
                    var fallback = hard_chunks(word, width)
                    for fallback_index in range(len(fallback) - 1):
                        result.append(fallback[fallback_index])
                    current = fallback[len(fallback) - 1]
                elif codepoint_length(remainder) <= width:
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


def _markup_word_wrap_cell(
    text: String, width: Int, preserve_whitespace: Bool
) -> List[String]:
    if preserve_whitespace:
        return _raw_markup_word_wrap_cell(text, width)
    return _word_wrap_cell(text, width)


def _markup_wrapped_column_width(
    table: CsvTable,
    column: Int,
    width: Int,
    preserve_whitespace: Bool,
) -> Int:
    if width <= 0:
        return 0
    var maximum = 0
    for row_index in range(len(table.rows)):
        var parts = _markup_word_wrap_cell(
            table.rows[row_index][column], width, preserve_whitespace
        )
        for part_index in range(len(parts)):
            maximum = max(maximum, codepoint_length(parts[part_index]))
    return maximum


def _wrapped_column_width(table: CsvTable, column: Int, width: Int) -> Int:
    if width <= 0:
        return 0
    var maximum = 0
    for row_index in range(len(table.rows)):
        var parts = _word_wrap_cell(table.rows[row_index][column], width)
        for part_index in range(len(parts)):
            maximum = max(maximum, codepoint_length(parts[part_index]))
    return maximum


def _column_wrap_width(
    column: Int,
    data_start: Int,
    default_width: Int,
    widths: List[Int],
) -> Int:
    """Return the legacy per-selected-column preparation width.

    ``--breiten`` indexes only data columns.  The two synthetic numbering
    columns, when present, therefore do not consume entries from the list.
    Missing entries fall back to the ordinary ``--breite`` value.
    """
    var position = column - data_start
    if position >= 0 and position < len(widths):
        return widths[position]
    return default_width


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
    one_table: Bool = False,
    no_blank_contents: Bool = False,
    widths: List[Int] = List[Int](),
    color_rows: Bool = True,
) -> String:
    """Render BBCode with legacy wrapping, paging and significant spaces."""
    if len(table.rows) == 0:
        return ""
    var data_start = 2 if number_rows else 0
    var total_columns = len(table.rows[0])
    var result = String()
    var page_start = data_start
    var maximum_row_number = _maximum_row_number(row_numbers)
    var raw_number_width = _decimal_width(maximum_row_number) + 1
    var screen_width = 80 - _decimal_width(maximum_row_number) - 1
    while page_start < total_columns:
        var page_end = page_start
        if width <= 0 or one_table:
            page_end = total_columns
        else:
            var sum_widths = 0
            while page_end < total_columns:
                var requested_width = _column_wrap_width(
                    page_end, data_start, width, widths
                )
                var column_width = _markup_wrapped_column_width(
                    width_reference, page_end, requested_width, not color_rows
                )
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
            for column_index in range(page_start, page_end):
                var requested_width = _column_wrap_width(
                    column_index, data_start, width, widths
                )
                row_height = max(
                    row_height,
                    len(_markup_word_wrap_cell(
                        width_reference.rows[row_index][column_index],
                        requested_width,
                        not color_rows,
                    )),
                )
            for visual_line in range(row_height):
                if no_blank_contents:
                    var visible = False
                    for column_index in range(page_start, page_end):
                        var requested_width = _column_wrap_width(
                            column_index, data_start, width, widths
                        )
                        var visible_parts = _markup_word_wrap_cell(
                            width_reference.rows[row_index][column_index],
                            requested_width,
                            not color_rows,
                        )
                        var visible_part = (
                            visible_parts[visual_line]
                            if visual_line < len(visible_parts)
                            else ""
                        )
                        if _cell_fragment_visible(
                            visible_part, no_blank_contents
                        ):
                            visible = True
                            break
                    if not visible:
                        continue
                var number = row_numbers[row_index] if row_index < len(row_numbers) else row_index
                result += colored_row_begin("bbcode", number)
                var is_heading = number == 0
                if number_rows and len(row) > 0:
                    result += _bbcode_counting_cell(row[0], is_heading)
                if number_rows and len(row) > 1:
                    result += "[td=\"\"]"
                    if color_rows:
                        result += (
                            " "
                            if is_heading or visual_line > 0
                            else row[1] + " "
                        )
                    else:
                        result += _raw_number_field(
                            ""
                            if is_heading or visual_line > 0
                            else String(row[1].strip()),
                            raw_number_width,
                        )
                    result += "[/td]"
                for column_index in range(page_start, page_end):
                    var requested_width = _column_wrap_width(
                        column_index, data_start, width, widths
                    )
                    var parts = _markup_word_wrap_cell(
                        width_reference.rows[row_index][column_index],
                        requested_width,
                        not color_rows,
                    )
                    var part = parts[visual_line] if visual_line < len(parts) else ""
                    var column_width = _markup_wrapped_column_width(
                        width_reference, column_index, requested_width,
                        not color_rows,
                    )
                    var rendered_part = (
                        _pad_cell(part, column_width)
                        if color_rows
                        else _pad_cell_raw(part, column_width)
                    )
                    result += "[td=\"\"]" + rendered_part + "[/td] "
                result += "[/tr]\n"
        result += "[/table]\n"
        page_start = page_end
    return result^


def render_bbcode_table(
    table: CsvTable,
    row_numbers: List[Int],
    number_rows: Bool = True,
    width: Int = 0,
    one_table: Bool = False,
    no_blank_contents: Bool = False,
    widths: List[Int] = List[Int](),
    color_rows: Bool = True,
) -> String:
    return render_bbcode_table_with_width_reference(
        table,
        table,
        row_numbers,
        number_rows,
        width,
        one_table,
        no_blank_contents,
        widths,
        color_rows,
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
    one_table: Bool = False,
    no_blank_contents: Bool = False,
    widths: List[Int] = List[Int](),
    color_rows: Bool = True,
) raises -> String:
    if len(table.rows) == 0:
        return ""
    var catalog = load_html_cell_catalog()
    # ``--alles`` currently consists of 805 data columns plus the two legacy
    # numbering columns.  Its HTML classes are position-dependent in Python,
    # so use the frozen all-columns position map only for that exact layout.
    var all_columns_reference_layout = len(source_columns) == 805
    var data_start = 2 if number_rows else 0
    var total_columns = len(table.rows[0])
    var result = String()
    var page_start = data_start
    var maximum_row_number = _maximum_row_number(row_numbers)
    var raw_number_width = _decimal_width(maximum_row_number) + 1
    var screen_width = 80 - _decimal_width(maximum_row_number) - 1
    while page_start < total_columns:
        var page_end = page_start
        if width <= 0 or one_table:
            page_end = total_columns
        else:
            var sum_widths = 0
            while page_end < total_columns:
                var requested_width = _column_wrap_width(
                    page_end, data_start, width, widths
                )
                var column_width = _markup_wrapped_column_width(
                    width_reference, page_end, requested_width, not color_rows
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
            for column_index in range(page_start, page_end):
                var requested_width = _column_wrap_width(
                    column_index, data_start, width, widths
                )
                row_height = max(
                    row_height,
                    len(_markup_word_wrap_cell(
                        width_reference.rows[row_index][column_index],
                        requested_width,
                        not color_rows,
                    )),
                )
            for visual_line in range(row_height):
                if no_blank_contents:
                    var visible = False
                    for column_index in range(page_start, page_end):
                        var requested_width = _column_wrap_width(
                            column_index, data_start, width, widths
                        )
                        var visible_parts = _markup_word_wrap_cell(
                            width_reference.rows[row_index][column_index],
                            requested_width,
                            not color_rows,
                        )
                        var visible_part = (
                            visible_parts[visual_line]
                            if visual_line < len(visible_parts)
                            else ""
                        )
                        if _cell_fragment_visible(
                            visible_part, no_blank_contents
                        ):
                            visible = True
                            break
                    if not visible:
                        continue
                var number = (
                    row_numbers[row_index]
                    if row_index < len(row_numbers)
                    else row_index
                )
                var is_heading = number == 0
                if color_rows:
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
                            else String(row[1].strip())
                        )
                        result += _html_cell_payload(
                            _html_escape(number_text)
                        ) + "</td>"
                else:
                    # With ``--nocolor`` Python bypasses Rich's Syntax stream.
                    # Each legacy chunk is printed verbatim and receives one
                    # additional newline from ``print``.
                    result += colored_row_begin("html", number)
                    if number_rows and len(row) > 0:
                        result += _html_counting_open(
                            catalog, language, row[0], is_heading
                        ) + "\n"
                        result += _html_escape(
                            " " if is_heading else row[0]
                        ) + "\n</td>\n"
                    if number_rows and len(row) > 1:
                        result += html_cell_open(
                            catalog, language, -1, 1, is_heading, ""
                        ) + "\n"
                        result += _html_escape(
                            _raw_number_field(
                                ""
                                if is_heading or visual_line > 0
                                else String(row[1].strip()),
                                raw_number_width,
                            )
                        ) + "\n</td>\n"
                for column_index in range(page_start, page_end):
                    var requested_width = _column_wrap_width(
                        column_index, data_start, width, widths
                    )
                    var parts = _markup_word_wrap_cell(
                        width_reference.rows[row_index][column_index],
                        requested_width,
                        not color_rows,
                    )
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
                        table.rows[0][column_index]
                        if len(table.rows) > 0
                        and column_index < len(table.rows[0])
                        else ""
                    )
                    if color_rows:
                        result += " " + html_cell_open(
                            catalog,
                            language,
                            source_column,
                            source_position + 2,
                            is_heading,
                            semantic_heading,
                            all_columns_reference_layout,
                        )
                        var trusted_generator = source_column > 745
                        result += _html_cell_payload(
                            _html_escape_preserving_tags(
                                part, trusted_generator
                            )
                        ) + "</td>"
                    else:
                        result += html_cell_open(
                            catalog,
                            language,
                            source_column,
                            source_position + 2,
                            is_heading,
                            semantic_heading,
                            all_columns_reference_layout,
                        ) + "\n"
                        var trusted_generator = source_column > 745
                        var column_width = _markup_wrapped_column_width(
                            width_reference, column_index, requested_width,
                            not color_rows,
                        )
                        result += _html_escape_preserving_tags(
                            _pad_cell_raw(part, column_width),
                            trusted_generator,
                        ) + "\n</td>\n "
                if color_rows:
                    result += " </tr>\n"
                else:
                    result += "</tr>\n\n"
        if color_rows:
            result += "</table>\n"
        else:
            result += "</table>\n\n"
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


def colorize_shell_text(
    text: String, number: Int, rest: Bool = False
) -> String:
    """Public TableOutput-compatible wrapper around the ANSI color policy."""
    return _shell_colorize(text, number, rest)


def _shell_split_words(
    text: String,
    mut words: List[String],
    mut separators: List[String],
) -> None:
    """Split like ``textwrap`` while retaining inter-word space widths.

    This code-point implementation cannot create a substring that begins in a
    UTF-8 continuation byte, while preserving the historical ASCII whitespace
    contract exactly.
    """
    var clean = String(text.strip())
    var pending_spaces = String()
    var current_word = String()
    for character in clean.codepoint_slices():
        var part = String(character)
        var whitespace = (
            part == " " or part == "\t" or part == "\n" or part == "\r"
        )
        if whitespace:
            if current_word.byte_length() > 0:
                words.append(current_word^)
                current_word = String()
            pending_spaces += " "
            continue
        if current_word.byte_length() == 0:
            separators.append(
                "" if len(separators) == 0 else pending_spaces
            )
            pending_spaces = String()
        current_word += part
    if current_word.byte_length() > 0:
        words.append(current_word^)


def _shell_word_wrap_cell(text: String, width: Int) -> List[String]:
    """Wrap terminal cells with Python ``textwrap`` space-run semantics."""
    var clean = String(text.strip())
    var result = List[String]()
    if width <= 0 or codepoint_length(clean) <= width:
        result.append(clean)
        return result^

    var words = List[String]()
    var separators = List[String]()
    _shell_split_words(clean, words, separators)
    var current = String()
    for index in range(len(words)):
        var word = words[index]
        var separator = separators[index]
        var separator_width = codepoint_length(separator)
        if current.byte_length() == 0:
            if codepoint_length(word) <= width:
                current = word
            else:
                current = _append_long_word(result, word, width)
        elif (
            codepoint_length(current)
            + separator_width
            + codepoint_length(word)
            <= width
        ):
            current += separator + word
        else:
            # Whitespace chunks are discarded at a line boundary, matching
            # TextWrapper(drop_whitespace=True). Existing-hyphen prefixes may
            # still consume the remaining width on the current line.
            var available = (
                width - codepoint_length(current) - separator_width
            )
            var prefix = _hyphen_prefix_fitting(word, available)
            # ``textwrap.TextWrapper`` fills the remaining space of the
            # current line from an overlong word before continuing it on the
            # next line.  The former native path moved the complete word to a
            # fresh line and therefore diverged on words such as
            # ``Antitranszendentalien,``.
            if (
                prefix.byte_length() == 0
                and available > 0
                and codepoint_length(word) > width
                and not "-" in word
            ):
                prefix = _codepoint_prefix(word, available)
            if prefix.byte_length() > 0:
                current += separator + prefix
                result.append(current^)
                var remainder = _slice_after_ascii_prefix(word, prefix)
                if remainder == word:
                    var fallback = hard_chunks(word, width)
                    for fallback_index in range(len(fallback) - 1):
                        result.append(fallback[fallback_index])
                    current = fallback[len(fallback) - 1]
                elif codepoint_length(remainder) <= width:
                    current = remainder^
                else:
                    current = _append_long_word(result, remainder, width)
            else:
                result.append(current^)
                if codepoint_length(word) <= width:
                    current = word
                else:
                    current = _append_long_word(result, word, width)
    if current.byte_length() > 0 or len(result) == 0:
        result.append(current^)
    return result^


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
        prefix = "█" + String(prefix.removeprefix(" "))
    return prefix^


def _maximum_shell_cell_width(table: CsvTable) -> Int:
    """Return an exact no-wrap width for the historical one-table mode."""
    var maximum = 1
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        for column_index in range(len(row)):
            maximum = max(
                maximum, codepoint_length(String(row[column_index].strip()))
            )
    return maximum


def _shell_column_width(table: CsvTable, column: Int, width: Int) -> Int:
    """Measure the fragments produced by the fixed preparation width.

    The Python table pipeline wraps every selected cell with ``textWidth``
    before ``cliOut`` determines the visible column width.  The final width is
    therefore the longest prepared fragment, not ``min(raw_length, width)``.
    Keep the preparation width fixed while measuring so the later render pass
    cannot progressively narrow the same cell.
    """
    if width <= 0:
        var unwrapped_maximum = 0
        for row_index in range(len(table.rows)):
            unwrapped_maximum = max(
                unwrapped_maximum,
                codepoint_length(
                    String(table.rows[row_index][column].strip())
                ),
            )
        return unwrapped_maximum
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
    row: List[String],
    page_start: Int,
    page_end: Int,
    no_blank_contents: Bool = False,
) -> Bool:
    return _row_range_visible(
        row, page_start, page_end, no_blank_contents
    )

def _shell_page_has_data(
    table: CsvTable,
    row_numbers: List[Int],
    page_start: Int,
    page_end: Int,
    no_blank_contents: Bool = False,
) -> Bool:
    for row_index in range(len(table.rows)):
        var number = (
            row_numbers[row_index]
            if row_index < len(row_numbers)
            else row_index
        )
        if number != 0 and _shell_page_row_has_content(
            table.rows[row_index],
            page_start,
            page_end,
            no_blank_contents,
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
    one_table: Bool = False,
    no_blank_contents: Bool = False,
    widths: List[Int] = List[Int](),
    terminal_columns_override: Int = 0,
) -> String:
    """Render the legacy ANSI terminal table, including paging and wrapping."""
    if len(table.rows) == 0:
        return ""
    var data_start = 2 if number_rows else 0
    var total_columns = len(table.rows[0])
    var highest = max(_maximum_row_number(row_numbers), numbering_highest)
    var number_width = _decimal_width(highest) + 1 if number_rows else 0
    var counting = counting_groups(highest)
    # ``--breite=0`` means: use the current terminal, reserving the same
    # seven columns as the Python renderer.  A fixed 80/73 pair changed the
    # public behaviour on every wider terminal.
    var detected_columns = (
        terminal_columns_override
        if terminal_columns_override > 0
        else terminal_columns()
    )
    var automatic_width = automatic_cell_width(detected_columns)
    # In the legacy renderer ``--breite=0 --onetable`` means genuinely no
    # wrapping, not automatic terminal-width wrapping.  Use the longest full
    # cell as the preparation width so every row stays on one visual line.
    var effective_width = (
        _maximum_shell_cell_width(width_reference)
        if one_table and width == 0
        else effective_cell_width(width, detected_columns)
    )
    var screen_width = automatic_width if not number_rows else detected_columns
    var result = String()
    var page_start = data_start
    var terminate_pages = False
    while page_start < total_columns:
        var page_end = total_columns if one_table else page_start
        var skip_initial_oversized_zero = False
        # ``number_width`` already contains the legacy separator column.
        # Starting one column farther right made exact-fit data pages break
        # one column too early (notably ``--breite=0 --breiten=...``).
        var sum_widths = number_width
        while not one_table and page_end < total_columns:
            var requested_width = _column_wrap_width(
                page_end, data_start, effective_width, widths
            )
            var column_width = _shell_column_width(
                width_reference, page_end, requested_width
            )
            var candidate = sum_widths + column_width + 1
            # Preserve the legacy zero-width pagination edge case.  A truly
            # unwrapped column that cannot fit as the first column of a page is
            # not force-rendered: the very first data column is skipped once,
            # while the same condition on a later page terminates the remaining
            # horizontal stream.  This oddity is observable in the Python CLI
            # and therefore belongs to byte-compatible native execution.
            if (
                page_end == page_start
                and requested_width == 0
                and candidate >= screen_width
            ):
                if page_start == data_start:
                    skip_initial_oversized_zero = True
                else:
                    terminate_pages = True
                break
            if page_end > page_start and candidate >= screen_width:
                break
            sum_widths = candidate
            page_end += 1
        if terminate_pages:
            break
        if skip_initial_oversized_zero:
            page_start += 1
            continue
        if page_end == page_start:
            page_end += 1
        if page_start > data_start and not _shell_page_has_data(
            table,
            row_numbers,
            page_start,
            page_end,
            no_blank_contents,
        ):
            result += "\n"
        for row_index in range(len(table.rows)):
            var row = table.rows[row_index].copy()
            var number = row_numbers[row_index] if row_index < len(row_numbers) else row_index
            if number != 0 and not _shell_page_row_has_content(
                row, page_start, page_end, no_blank_contents
            ):
                continue
            var row_height = 1
            for column_index in range(page_start, page_end):
                var requested_width = _column_wrap_width(
                    column_index, data_start, effective_width, widths
                )
                row_height = max(
                    row_height,
                    len(_shell_word_wrap_cell(
                        row[column_index], requested_width
                    )),
                )
            for visual_line in range(row_height):
                if no_blank_contents:
                    var visible = False
                    for column_index in range(page_start, page_end):
                        var requested_width = _column_wrap_width(
                            column_index, data_start, effective_width, widths
                        )
                        var visible_parts = _shell_word_wrap_cell(
                            row[column_index], requested_width
                        )
                        var visible_part = (
                            visible_parts[visual_line]
                            if visual_line < len(visible_parts)
                            else ""
                        )
                        if _cell_fragment_visible(
                            visible_part, no_blank_contents
                        ):
                            visible = True
                            break
                    if not visible:
                        continue
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
                    var requested_width = _column_wrap_width(
                        column_index, data_start, effective_width, widths
                    )
                    var parts = _shell_word_wrap_cell(
                        row[column_index], requested_width
                    )
                    var has_fragment = visual_line < len(parts)
                    var part = parts[visual_line] if has_fragment else ""
                    var column_width = _shell_column_width(
                        width_reference, column_index, requested_width
                    )
                    var padded = _shell_pad(part, column_width)
                    if color_rows:
                        result += _shell_colorize(
                            padded, number, not has_fragment
                        ) + " "
                    else:
                        result += padded + " "
                result += "\n"
        page_start = page_end
    return result^

def _flat_width_text(text: String) -> String:
    """Normalize native combination sentinels before flat-format wrapping."""
    return (
        text.replace("@@RETA_COMBI_LEADING_SPACE@@", " ")
        .replace("@@RETA_COMBI_TRAILING_SPACE@@", " ")
    )


def _flat_word_wrap_cell(text: String, width: Int) -> List[String]:
    """Match Python preparation plus Rich normalization for flat formats.

    Wrapping decisions use the original whitespace widths, while visible
    fragments collapse internal whitespace to one space.  CPython's
    ``TextWrapper`` exposes one exceptional trailing space when a separator
    exactly fills the line immediately before an overlong word; CSV preserves
    that byte, whereas Markdown and Emacs normalize it later.
    """
    var clean = normalize_cell_whitespace(text)
    var result = List[String]()
    if width <= 0:
        result.append(clean)
        return result^

    var words = List[String]()
    var separator_widths = List[Int]()
    _split_markup_words(text, words, separator_widths)
    if len(words) == 0:
        result.append(clean)
        return result^

    var raw_width = 0
    for index in range(len(words)):
        raw_width += codepoint_length(words[index]) + separator_widths[index]
    if raw_width <= width:
        result.append(clean)
        return result^

    var current = String()
    var current_raw_width = 0
    for index in range(len(words)):
        var word = words[index]
        var separator_width = separator_widths[index]
        var word_width = codepoint_length(word)
        if current.byte_length() == 0:
            if word_width <= width:
                current = word
                current_raw_width = word_width
            else:
                current = _append_long_word(result, word, width)
                current_raw_width = codepoint_length(current)
        elif current_raw_width + separator_width + word_width <= width:
            current += " " + word
            current_raw_width += separator_width + word_width
        else:
            var available = width - current_raw_width - separator_width
            var prefix = _hyphen_prefix_fitting(word, available)
            if (
                prefix.byte_length() == 0
                and available > 0
                and word_width > width
                and not "-" in word
            ):
                prefix = _codepoint_prefix(word, available)
            if prefix.byte_length() > 0:
                current += " " + prefix
                result.append(current^)
                var remainder = _slice_after_ascii_prefix(word, prefix)
                if remainder == word:
                    var fallback = hard_chunks(word, width)
                    for fallback_index in range(len(fallback) - 1):
                        result.append(fallback[fallback_index])
                    current = fallback[len(fallback) - 1]
                elif codepoint_length(remainder) <= width:
                    current = remainder^
                else:
                    current = _append_long_word(result, remainder, width)
                current_raw_width = codepoint_length(current)
            else:
                # ``TextWrapper._handle_long_word`` appends an empty prefix
                # when no width remains.  Its later whitespace cleanup then
                # leaves the preceding separator observable, but only because
                # the pending next chunk itself is overlong.
                if (
                    current_raw_width + separator_width == width
                    and word_width > width
                ):
                    current += " "
                result.append(current^)
                if word_width <= width:
                    current = word^
                else:
                    current = _append_long_word(result, word, width)
                current_raw_width = codepoint_length(current)
    if current.byte_length() > 0 or len(result) == 0:
        result.append(current^)
    return result^


def _find_row_number_index(row_numbers: List[Int], wanted: Int) -> Int:
    for index in range(len(row_numbers)):
        if row_numbers[index] == wanted:
            return index
    return -1


def _expand_flat_width_rows(
    table: CsvTable,
    width_reference: CsvTable,
    row_numbers: List[Int],
    filtered_table: CsvTable,
    filtered_row_numbers: List[Int],
    number_rows: Bool,
    no_blank_contents: Bool,
    widths: List[Int],
    preserve_csv_spaces: Bool,
) -> Tuple[CsvTable, List[Int]]:
    """Expand logical rows for CSV/Markdown/Emacs ``--breiten`` output.

    Those formats force the ordinary global text width to zero, but explicit
    per-data-column widths still run through the historical preparation
    wrapper.  The counting-group column repeats on continuation lines, whereas
    the source-row number is shown only on the first visual line.
    """
    if len(widths) == 0 or len(filtered_table.rows) == 0:
        return filtered_table.copy(), filtered_row_numbers.copy()

    var data_start = 2 if number_rows else 0
    var rows = List[List[String]]()
    var numbers = List[Int]()
    var reference_offset = max(
        0, len(width_reference.rows) - len(table.rows)
    )

    for filtered_index in range(len(filtered_table.rows)):
        var row = filtered_table.rows[filtered_index].copy()
        var number = (
            filtered_row_numbers[filtered_index]
            if filtered_index < len(filtered_row_numbers)
            else filtered_index
        )
        var source_index = _find_row_number_index(row_numbers, number)
        if source_index < 0:
            source_index = filtered_index
        var reference_index = source_index + reference_offset
        if reference_index >= len(width_reference.rows):
            reference_index = min(filtered_index, len(width_reference.rows) - 1)
        var reference_row = width_reference.rows[reference_index].copy()

        var row_height = 1
        for column_index in range(data_start, len(row)):
            var requested_width = _column_wrap_width(
                column_index, data_start, 0, widths
            )
            var parts = _flat_word_wrap_cell(
                _flat_width_text(reference_row[column_index]),
                requested_width,
            )
            row_height = max(row_height, len(parts))

        for visual_line in range(row_height):
            var physical = List[String]()
            if number_rows:
                physical.append(row[0] if len(row) > 0 else "")
                physical.append(
                    row[1]
                    if len(row) > 1 and visual_line == 0
                    else ""
                )

            var visible = False
            for column_index in range(data_start, len(row)):
                var requested_width = _column_wrap_width(
                    column_index, data_start, 0, widths
                )
                var parts = _flat_word_wrap_cell(
                    _flat_width_text(reference_row[column_index]),
                    requested_width,
                )
                var part = (
                    parts[visual_line]
                    if visual_line < len(parts)
                    else ""
                )
                if not preserve_csv_spaces:
                    part = normalize_cell_whitespace(part)
                physical.append(part)
                if _cell_fragment_visible(part, no_blank_contents):
                    visible = True

            if visible:
                rows.append(physical^)
                numbers.append(number)

    return CsvTable(rows^, filtered_table.maximum_columns), numbers^


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
    one_table: Bool = False,
    no_blank_contents: Bool = False,
    widths: List[Int] = List[Int](),
) -> String:
    var filtered = _filter_no_blank_rows(
        table,
        row_numbers,
        2 if number_rows else 0,
        no_blank_contents,
    )
    var flat_table = filtered[0].copy()
    var flat_row_numbers = filtered[1].copy()
    if mode == "csv" or mode == "markdown" or mode == "emacs":
        var expanded = _expand_flat_width_rows(
            table,
            width_reference,
            row_numbers,
            flat_table,
            flat_row_numbers,
            number_rows,
            no_blank_contents,
            widths,
            mode == "csv",
        )
        flat_table = expanded[0].copy()
        flat_row_numbers = expanded[1].copy()
    if mode == "csv":
        if len(widths) > 0:
            return _render_flat_width_csv_table(flat_table, number_rows)
        return render_csv_table(flat_table, number_rows)
    if mode == "markdown":
        return render_markdown_table_with_rows(
            flat_table, flat_row_numbers, number_rows
        )
    if mode == "emacs":
        return render_emacs_table_with_rows(
            flat_table, flat_row_numbers, number_rows
        )
    if mode == "html":
        return render_html_table(flat_table, flat_row_numbers)
    if mode == "bbcode":
        return render_bbcode_table_with_width_reference(
            table,
            width_reference,
            row_numbers,
            number_rows,
            width,
            one_table,
            no_blank_contents,
            widths,
            color_rows,
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
            one_table,
            no_blank_contents,
            widths,
        )
    return render_plain_table(flat_table)



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
    one_table: Bool = False,
    no_blank_contents: Bool = False,
    widths: List[Int] = List[Int](),
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
            one_table,
            no_blank_contents,
            widths,
            color_rows,
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
        one_table,
        no_blank_contents,
        widths,
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
