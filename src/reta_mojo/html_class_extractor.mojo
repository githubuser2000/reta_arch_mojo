"""Native HTML header-cell metadata extraction.

This module replaces ``reta_extract_html_classes.py``.  It parses the first
HTML table row, preserves duplicate attributes, derives the historical class
metadata and renders compact UTF-8 JSONL without Python, regexes or a child
process.
"""

from std.collections import List
from std.collections.string import atol
from .os_line_endings import os_linesep


@fieldwise_init
struct HtmlAttribute(Copyable):
    var key: String
    var value: String


@fieldwise_init
struct HtmlClassCell(Copyable):
    var column_number: Int
    var row_number: Int
    var row_number_present: Bool
    var classes: List[String]
    var class_string: String
    var class_attributes: List[String]
    var extra_class_strings: List[String]
    var all_classes: List[String]
    var attributes: List[HtmlAttribute]
    var text: String
    var raw_open_tag: String
    var raw_html: String


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _is_ascii_space(code: Int) -> Bool:
    return code == 32 or code == 9 or code == 10 or code == 13 or code == 12


def _is_attr_name_start_byte(code: Int) -> Bool:
    return (
        (code >= 65 and code <= 90)
        or (code >= 97 and code <= 122)
        or code == 95
        or code == 58
    )


def _is_attr_name_byte(code: Int) -> Bool:
    return (
        _is_attr_name_start_byte(code)
        or (code >= 48 and code <= 57)
        or code == 45
        or code == 46
    )


def _find_from(text: String, needle: String, start: Int) -> Int:
    var haystack = text.as_bytes()
    var wanted = needle.as_bytes()
    if len(wanted) == 0:
        return min(max(start, 0), len(haystack))
    var index = max(start, 0)
    while index + len(wanted) <= len(haystack):
        var matches = True
        for offset in range(len(wanted)):
            if haystack[index + offset] != wanted[offset]:
                matches = False
                break
        if matches:
            return index
        index += 1
    return -1


def _find_last(text: String, needle: String) -> Int:
    var haystack = text.as_bytes()
    var wanted = needle.as_bytes()
    if len(wanted) == 0:
        return len(haystack)
    var index = len(haystack) - len(wanted)
    while index >= 0:
        var matches = True
        for offset in range(len(wanted)):
            if haystack[index + offset] != wanted[offset]:
                matches = False
                break
        if matches:
            return index
        index -= 1
    return -1


def _split_ascii_whitespace(text: String) -> List[String]:
    var result = List[String]()
    var bytes = text.as_bytes()
    var start = 0
    var index = 0
    while index <= len(bytes):
        if index == len(bytes) or _is_ascii_space(Int(bytes[index])):
            if index > start:
                result.append(_slice(text, start, index))
            index += 1
            while index < len(bytes) and _is_ascii_space(Int(bytes[index])):
                index += 1
            start = index
            continue
        index += 1
    return result^


def _contains(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _digits_only(text: String) -> Bool:
    if text.byte_length() == 0:
        return False
    var bytes = text.as_bytes()
    for index in range(len(bytes)):
        var code = Int(bytes[index])
        if code < 48 or code > 57:
            return False
    return True


def _parse_attrs(open_tag: String) -> List[HtmlAttribute]:
    var result = List[HtmlAttribute]()
    var bytes = open_tag.as_bytes()
    var index = 3
    while index < len(bytes):
        while index < len(bytes) and _is_ascii_space(Int(bytes[index])):
            index += 1
        var key_start = index
        if index >= len(bytes) or not _is_attr_name_start_byte(Int(bytes[index])):
            index += 1
            continue
        index += 1
        while index < len(bytes) and _is_attr_name_byte(Int(bytes[index])):
            index += 1
        var key_end = index
        if index + 1 >= len(bytes) or Int(bytes[index]) != 61 or Int(bytes[index + 1]) != 34:
            continue
        index += 2
        var value_start = index
        while index < len(bytes) and Int(bytes[index]) != 34:
            index += 1
        if index >= len(bytes):
            break
        result.append(
            HtmlAttribute(
                _slice(open_tag, key_start, key_end),
                _slice(open_tag, value_start, index),
            )
        )
        index += 1
    return result^


def _first_attr_value(attributes: List[HtmlAttribute], key: String) -> String:
    for index in range(len(attributes)):
        if attributes[index].key == key:
            return attributes[index].value.copy()
    return String()


def _class_attribute_values(attributes: List[HtmlAttribute]) -> List[String]:
    var result = List[String]()
    for index in range(len(attributes)):
        if attributes[index].key == "class":
            result.append(attributes[index].value.copy())
    return result^


def _unicode_whitespace_to_ascii(text: String) -> String:
    var result = text.copy()
    result = result.replace(chr(0x85), " ").replace(chr(0xA0), " ")
    for codepoint in range(0x2000, 0x200B):
        result = result.replace(chr(codepoint), " ")
    for codepoint in [0x2028, 0x2029, 0x202F, 0x205F, 0x3000]:
        result = result.replace(chr(codepoint), " ")
    return result^


def _collapsed_text(inner_html: String) -> String:
    var normalized = _unicode_whitespace_to_ascii(inner_html)
    var result = String()
    var bytes = normalized.as_bytes()
    var index = 0
    var chunk_start = 0
    var pending_space = False
    while index < len(bytes):
        var code = Int(bytes[index])
        if code == 60:
            if index > chunk_start:
                if pending_space and result.byte_length() > 0:
                    result += " "
                result += _slice(normalized, chunk_start, index)
            var close = index + 1
            while close < len(bytes) and Int(bytes[close]) != 62:
                close += 1
            pending_space = result.byte_length() > 0
            index = min(close + 1, len(bytes))
            chunk_start = index
            continue
        if _is_ascii_space(code):
            if index > chunk_start:
                if pending_space and result.byte_length() > 0:
                    result += " "
                result += _slice(normalized, chunk_start, index)
                pending_space = True
            index += 1
            while index < len(bytes) and _is_ascii_space(Int(bytes[index])):
                index += 1
            chunk_start = index
            continue
        index += 1
    if len(bytes) > chunk_start:
        if pending_space and result.byte_length() > 0:
            result += " "
        result += _slice(normalized, chunk_start, len(bytes))
    return String(result.strip())


def _find_td_open(row_html: String, start: Int) -> Int:
    var position = _find_from(row_html, "<td", start)
    var bytes = row_html.as_bytes()
    while position >= 0:
        var after = position + 3
        if after >= len(bytes) or _is_ascii_space(Int(bytes[after])) or Int(bytes[after]) == 62:
            return position
        position = _find_from(row_html, "<td", position + 3)
    return -1


def extract_header_cells(html: String) raises -> List[HtmlClassCell]:
    var tr_start = _find_from(html, "<tr", 0)
    if tr_start < 0:
        raise Error("Konnte die HTML-Kopfzeile im reta-Output nicht finden.")
    var tr_open_end = _find_from(html, ">", tr_start)
    var tr_close = _find_last(html, "</tr>")
    if tr_open_end < 0 or tr_close < tr_open_end:
        raise Error("Konnte die HTML-Kopfzeile im reta-Output nicht finden.")
    var row_html = _slice(html, tr_open_end + 1, tr_close)
    var cells = List[HtmlClassCell]()
    var cursor = 0
    while True:
        var td_start = _find_td_open(row_html, cursor)
        if td_start < 0:
            break
        var open_end = _find_from(row_html, ">", td_start)
        var close_start = _find_from(row_html, "</td>", open_end + 1)
        if open_end < 0 or close_start < 0:
            break
        var raw_open_tag = _slice(row_html, td_start, open_end + 1)
        var inner_html = _slice(row_html, open_end + 1, close_start)
        var raw_html = _slice(row_html, td_start, close_start + 5)
        var attributes = _parse_attrs(raw_open_tag)
        var class_attributes = _class_attribute_values(attributes)
        var class_string = (
            class_attributes[0].copy() if len(class_attributes) > 0 else String()
        )
        var classes = _split_ascii_whitespace(class_string)
        var extra_class_strings = List[String]()
        var all_classes = classes.copy()
        for class_index in range(1, len(class_attributes)):
            var extra_string = class_attributes[class_index]
            extra_class_strings.append(extra_string.copy())
            var extra_classes = _split_ascii_whitespace(extra_string)
            for extra_index in range(len(extra_classes)):
                if not _contains(classes, extra_classes[extra_index]):
                    all_classes.append(extra_classes[extra_index])
        var row_number = 0
        var row_number_present = False
        var column_number = -1
        for class_index in range(len(classes)):
            var token = classes[class_index]
            if token.startswith("z_"):
                var suffix = _slice(token, 2, token.byte_length())
                if _digits_only(suffix):
                    row_number = atol(suffix)
                    row_number_present = True
            if token.startswith("r_"):
                var suffix = _slice(token, 2, token.byte_length())
                if _digits_only(suffix):
                    column_number = atol(suffix)
        if column_number < 0:
            column_number = len(cells)
        cells.append(
            HtmlClassCell(
                column_number,
                row_number,
                row_number_present,
                classes^,
                class_string^,
                class_attributes^,
                extra_class_strings^,
                all_classes^,
                attributes^,
                _collapsed_text(inner_html),
                raw_open_tag^,
                raw_html^,
            )
        )
        cursor = close_start + 5
    return cells^


def _hex_nibble(value: Int) -> String:
    return String(chr(48 + value)) if value < 10 else String(chr(87 + value))


def json_quote(value: String) -> String:
    var escaped = value.replace("\\", "\\\\")
    escaped = escaped.replace('"', '\\"')
    escaped = escaped.replace(chr(8), "\\b")
    escaped = escaped.replace(chr(12), "\\f")
    escaped = escaped.replace("\n", "\\n")
    escaped = escaped.replace("\r", "\\r")
    escaped = escaped.replace("\t", "\\t")
    for code in range(32):
        if code == 8 or code == 9 or code == 10 or code == 12 or code == 13:
            continue
        escaped = escaped.replace(
            chr(code),
            "\\u00" + _hex_nibble((code >> 4) & 15) + _hex_nibble(code & 15),
        )
    return '"' + escaped + '"'


def _json_string_list(values: List[String]) -> String:
    var result = "["
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += json_quote(values[index])
    return result + "]"


def _json_attributes(attributes: List[HtmlAttribute]) -> String:
    var result = "["
    for index in range(len(attributes)):
        if index > 0:
            result += ","
        result += "[" + json_quote(attributes[index].key) + "," + json_quote(attributes[index].value) + "]"
    return result + "]"


def _json_first_attr_map(
    attributes: List[HtmlAttribute], data_only: Bool = False
) -> String:
    var result = "{"
    var seen = List[String]()
    var count = 0
    for index in range(len(attributes)):
        var entry = attributes[index].copy()
        if data_only and not entry.key.startswith("data-"):
            continue
        if _contains(seen, entry.key):
            continue
        seen.append(entry.key.copy())
        if count > 0:
            result += ","
        result += json_quote(entry.key) + ":" + json_quote(entry.value)
        count += 1
    return result + "}"


def html_class_cell_json(cell: HtmlClassCell) -> String:
    var row_json = String(cell.row_number) if cell.row_number_present else "null"
    var attributes_first = _json_first_attr_map(cell.attributes)
    var element_attributes = attributes_first.copy()
    return (
        '{"column_number":'
        + String(cell.column_number)
        + ',"row_number":'
        + row_json
        + ',"tag":"td","classes":'
        + _json_string_list(cell.classes)
        + ',"class_string":'
        + json_quote(cell.class_string)
        + ',"class_attributes":'
        + _json_string_list(cell.class_attributes)
        + ',"extra_class_strings":'
        + _json_string_list(cell.extra_class_strings)
        + ',"all_classes":'
        + _json_string_list(cell.all_classes)
        + ',"data_attributes":'
        + _json_first_attr_map(cell.attributes, True)
        + ',"attributes":'
        + _json_attributes(cell.attributes)
        + ',"attributes_first":'
        + attributes_first
        + ',"text":'
        + json_quote(cell.text)
        + ',"raw_open_tag":'
        + json_quote(cell.raw_open_tag)
        + ',"raw_html":'
        + json_quote(cell.raw_html)
        + ',"html_elements":[{"tag":"td","classes":'
        + _json_string_list(cell.classes)
        + ',"class_string":'
        + json_quote(cell.class_string)
        + ',"attributes":'
        + element_attributes
        + ',"html":'
        + json_quote(cell.raw_html)
        + "}]}"
    )


def render_html_class_jsonl(cells: List[HtmlClassCell]) -> String:
    var result = String()
    for index in range(len(cells)):
        result += html_class_cell_json(cells[index]) + os_linesep()
    return result^
