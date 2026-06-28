"""Deterministic text-width and wrapping morphisms for native tables.

External pyphen/pyhyphen dictionaries remain optional compatibility backends.
The native layer owns width selection, Unicode-safe hard chunking and the
no-backend behavior used by minimal environments.
"""

from std.collections import List


comptime WRAP_PYPHEN = 1
comptime WRAP_PYHYPHEN = 2
comptime WRAP_NOHYPHEN = 3


@fieldwise_init
struct TextWrapRuntime(Copyable):
    var shell_rows_amount: Int
    var has_hyphenator: Bool
    var has_dictionary: Bool
    var has_fill: Bool
    var wrapping_type: Int


@fieldwise_init
struct WrapResult(Copyable):
    var wrapped: Bool
    var parts: List[String]


def default_text_wrap_runtime() -> TextWrapRuntime:
    return TextWrapRuntime(0, False, False, False, WRAP_PYHYPHEN)


def codepoint_length(text: String) -> Int:
    return len(text.codepoints())


def hard_chunks(text: String, width: Int) -> List[String]:
    var result = List[String]()
    if width <= 0:
        result.append(text)
        return result^
    var current = String()
    var current_length = 0
    for character in text.codepoint_slices():
        current += String(character)
        current_length += 1
        if current_length == width:
            result.append(current^)
            current = String()
            current_length = 0
    if current_length > 0 or len(result) == 0:
        result.append(current^)
    return result^


def split_more_if_not_small(texts: List[String], target_length: Int) -> List[String]:
    if target_length <= 0:
        return texts.copy()
    var needed = False
    for index in range(len(texts)):
        if codepoint_length(texts[index]) > target_length:
            needed = True
            break
    if not needed:
        return texts.copy()

    var result = List[String]()
    for index in range(len(texts)):
        if codepoint_length(texts[index]) > target_length:
            var chunks = hard_chunks(texts[index], target_length)
            for chunk_index in range(len(chunks)):
                result.append(chunks[chunk_index])
        else:
            result.append(texts[index])
    return result^


def wrap_cell_text(
    text: String,
    length: Int,
    runtime: TextWrapRuntime = default_text_wrap_runtime(),
) -> WrapResult:
    if length == 0 or codepoint_length(text) <= length:
        return WrapResult(False, List[String]())

    # Exact Python fallback: when ``fill`` is unavailable, alxwrap returns the
    # unchanged text as a one-element tuple even though wrapping was requested.
    if not runtime.has_fill or runtime.wrapping_type == WRAP_NOHYPHEN:
        return WrapResult(True, [text])

    # The architecture's second pass always enforces the requested width.
    return WrapResult(True, hard_chunks(text, length))


def width_for_row(
    shell_rows_amount: Int,
    rows_count: Int,
    widths: List[Int],
    text_width: Int,
    row_to_display: Int,
    combi_rows1: Int = 0,
) -> Int:
    if shell_rows_amount == 0:
        return 0
    var combi_rows = combi_rows1 if combi_rows1 != 0 else rows_count
    var offset = rows_count - combi_rows
    if offset < len(widths):
        var index = offset + row_to_display - 1
        if index >= offset and index < len(widths):
            return widths[index]
    return text_width


def clamp_table_width(
    requested: Int,
    shell_rows_amount: Int,
    allows_zero: Bool,
) -> Int:
    if (
        (shell_rows_amount > requested + 7 or shell_rows_amount == 0)
        and (requested != 0 or allows_zero)
    ):
        return requested
    return shell_rows_amount - 7


def clamp_column_width(requested: Int, shell_rows_amount: Int) -> Int:
    if shell_rows_amount > requested + 7 or shell_rows_amount == 0:
        return requested
    return shell_rows_amount - 7
