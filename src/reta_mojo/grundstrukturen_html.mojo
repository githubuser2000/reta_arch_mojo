"""Native HTML renderer for the Grundstrukturen hierarchy.

This is the runtime port of ``python_reference/grundStrukHtml.py``.  The
localized hierarchy catalog is generated from the Python reference, but all
traversal-state handling and HTML emission in this module execute in Mojo.
"""

from std.collections import List
from .grundstrukturen_catalog import (
    GrundstrukturRenderRecord,
    german_basic_structures_label,
    international_basic_structures_label,
    german_grundstruktur_records,
    international_grundstruktur_records,
)


comptime _GROUP_DIV = (
    '<div style="white-space: normal; border-left: 40px solid rgba(0, 0, 0,'
    ' .0);" >'
)


def is_german_grundstrukturen_language(language: String) -> Bool:
    return language == "" or language == "deutsch" or language == "german"


def is_supported_grundstrukturen_language(language: String) -> Bool:
    return (
        is_german_grundstrukturen_language(language)
        or language == "english"
        or language == "englisch"
        or language == "vietnamese"
        or language == "vietnamesisch"
        or language == "tiếngviệt"
        or language == "chinese"
        or language == "chinesisch"
        or language == "中國人"
        or language == "korean"
        or language == "koreanisch"
        or language == "한국인"
    )


def _localized_records(language: String) -> List[GrundstrukturRenderRecord]:
    if is_german_grundstrukturen_language(language):
        return german_grundstruktur_records()
    return international_grundstruktur_records()


def basic_structures_label(language: String) -> String:
    if is_german_grundstrukturen_language(language):
        return german_basic_structures_label()
    return international_basic_structures_label()


def _underscores_to_spaces(text: String) -> String:
    var parts = text.split("_")
    var result = String()
    for index in range(len(parts)):
        if index > 0:
            result += " "
        result += String(parts[index])
    return result^


def grundstrukturen_record_count(language: String = "") -> Int:
    return len(_localized_records(language))


def grundstrukturen_leaf_count(language: String = "") -> Int:
    var records = _localized_records(language)
    var count = 0
    for index in range(len(records)):
        if records[index].is_leaf:
            count += 1
    return count


def render_grundstrukturen_html(
    blank: Bool = False, language: String = ""
) -> String:
    """Render byte-compatible HTML for the historical Grundstrukturen widget."""
    var records = _localized_records(language)
    var parameter_label = basic_structures_label(language)
    var result = String()

    if blank:
        result += (
            '<div style="white-space: normal; border-left: 40px solid rgba(0,'
            " 0, 0, .0);\" id='grundstrukturenDiv'>"
        )
    else:
        result += (
            '<div style="white-space: normal; border-left: 40px solid rgba(0,'
            ' 0, 0, .0);" >'
        )

    # Flat traversal records carry enough structure to stream the recursive
    # output.  ``stack_size`` avoids relying on a mutating List.pop API and
    # therefore keeps ownership explicit on all supported Mojo 1.0 betas.
    var stack_depths = List[Int]()
    var stack_open_divs = List[Bool]()
    var stack_size = 0

    for record_index in range(len(records)):
        var record = records[record_index].copy()

        while stack_size > 0 and stack_depths[stack_size - 1] >= record.depth:
            if stack_open_divs[stack_size - 1]:
                result += "</div>"
            stack_size -= 1

        if record.open_div:
            result += _GROUP_DIV

        if record.is_leaf:
            result += '<input type="checkbox"'
            if blank:
                result += ' class="ordGru" onchange="toggleP2(this,-10,\''
                result += "✗"
                result += parameter_label
                result += ","
                result += record.key
                result += '\');" id="ordGru'
                result += record.key
                result += '" value="'
                result += record.key
                result += '"'
            result += ">"
            result += '<label id="ordGruB'
            result += record.key
            result += '">'
            result += _underscores_to_spaces(record.key)
            result += "</label> "
            result += "</input>"
            if record.open_div:
                result += "</div>"
            continue

        if record.show_text:
            result += record.key
            result += " "

        if stack_size == len(stack_depths):
            stack_depths.append(record.depth)
            stack_open_divs.append(record.open_div)
        else:
            stack_depths[stack_size] = record.depth
            stack_open_divs[stack_size] = record.open_div
        stack_size += 1

    while stack_size > 0:
        if stack_open_divs[stack_size - 1]:
            result += "</div>"
        stack_size -= 1

    result += "</div>\n"
    return result^
