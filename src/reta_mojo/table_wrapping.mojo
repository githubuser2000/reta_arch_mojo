"""Complete typed text-width and wrapping owner for native reta tables.

The Python module keeps a mutable process-global runtime and optional dynamic
pyphen/pyhyphen callables.  The native owner makes that state explicit,
represents backend availability as capabilities, and performs every fallback
with Unicode-safe codepoint iteration.  No Python object or interpreter is
required.
"""

from std.collections import List
from .runtime_compat import getTextWrapThings


comptime WRAP_PYPHEN = 1
comptime WRAP_PYHYPHEN = 2
comptime WRAP_NOHYPHEN = 3


@fieldwise_init
struct TextWrapRuntime(Copyable, Equatable):
    var shell_rows_amount: Int
    var has_hyphenator: Bool
    var has_dictionary: Bool
    var has_fill: Bool
    var wrapping_type: Int


@fieldwise_init
struct TextWrapRuntimeSnapshot(Copyable):
    var class_name: String
    var shell_rows_amount: Int
    var has_hyphenator: Bool
    var has_dictionary: Bool
    var has_fill: Bool
    var wrapping_type_name: String


@fieldwise_init
struct TextWrapRuntimeState(Copyable):
    """Explicit replacement for Python's mutable module-global ``_RUNTIME``."""

    var runtime: TextWrapRuntime

    def refresh(mut self, wrapping_type: Int = 0, max_len: Int = 0) -> None:
        self.runtime = refresh_textwrap_runtime(wrapping_type, max_len)

    def set_shell_rows_amount(mut self, shell_rows_amount: Int) -> None:
        self.runtime.shell_rows_amount = shell_rows_amount

    def get_shell_rows_amount(self) -> Int:
        return self.runtime.shell_rows_amount

    def set_wrapping_type(mut self, wrapping_type: Int) -> None:
        self.runtime.wrapping_type = _normalise_wrapping_type(wrapping_type)

    def get_wrapping_type(self) -> Int:
        return self.runtime.wrapping_type


@fieldwise_init
struct WrapResult(Copyable):
    var wrapped: Bool
    var parts: List[String]


@fieldwise_init
struct TableWrappingSnapshot(Copyable):
    var class_name: String
    var runtime: TextWrapRuntimeSnapshot
    var morphisms: List[String]
    var legacy_owner: String


@fieldwise_init
struct TableWrappingBundle(Copyable):
    var runtime: TextWrapRuntime

    def wrap_text(self, text: String, length: Int) -> WrapResult:
        return wrap_cell_text(text, length, self.runtime)

    def width_for_row(
        self,
        rows_count: Int,
        widths: List[Int],
        text_width: Int,
        row_to_display: Int,
        combi_rows1: Int = 0,
    ) -> Int:
        return width_for_row(
            self.runtime.shell_rows_amount,
            rows_count,
            widths,
            text_width,
            row_to_display,
            combi_rows1,
        )

    def snapshot(self) -> TableWrappingSnapshot:
        return TableWrappingSnapshot(
            "TableWrappingBundle",
            text_wrap_runtime_snapshot(self.runtime),
            [
                "alxwrap",
                "wrap_cell_text",
                "width_for_row",
                "split_more_if_not_small",
            ],
            "libs.lib4tables_prepare.Prepare",
        )


def wrapping_type_name(wrapping_type: Int) -> String:
    if wrapping_type == WRAP_PYPHEN:
        return "pyphen"
    if wrapping_type == WRAP_NOHYPHEN:
        return "nohyphen"
    return "pyhyphen"


def _normalise_wrapping_type(wrapping_type: Int) -> Int:
    if (
        wrapping_type == WRAP_PYPHEN
        or wrapping_type == WRAP_PYHYPHEN
        or wrapping_type == WRAP_NOHYPHEN
    ):
        return wrapping_type
    return WRAP_PYHYPHEN


def default_text_wrap_runtime() -> TextWrapRuntime:
    return TextWrapRuntime(0, False, False, False, WRAP_PYHYPHEN)


def refresh_textwrap_runtime(
    wrapping_type: Int = 0, max_len: Int = 0
) -> TextWrapRuntime:
    """Refresh capabilities through the native runtime-compat owner."""
    var capabilities = getTextWrapThings(max_len)
    var resolved_type = (
        WRAP_PYHYPHEN
        if wrapping_type == 0
        else _normalise_wrapping_type(wrapping_type)
    )
    return TextWrapRuntime(
        capabilities.shell_rows_amount,
        capabilities.has_hyphenator,
        capabilities.has_dictionary,
        capabilities.has_fill,
        resolved_type,
    )


def textwrap_runtime() -> TextWrapRuntimeState:
    """Create the explicit native runtime state used instead of a singleton."""
    return TextWrapRuntimeState(refresh_textwrap_runtime())


def set_shell_rows_amount(
    mut state: TextWrapRuntimeState, shell_rows_amount: Int
) -> None:
    state.set_shell_rows_amount(shell_rows_amount)


def get_shell_rows_amount(state: TextWrapRuntimeState) -> Int:
    return state.get_shell_rows_amount()


def set_wrapping_type(mut state: TextWrapRuntimeState, wrapping_type: Int) -> None:
    state.set_wrapping_type(wrapping_type)


def get_wrapping_type(state: TextWrapRuntimeState) -> Int:
    return state.get_wrapping_type()


def text_wrap_runtime_snapshot(
    runtime: TextWrapRuntime
) -> TextWrapRuntimeSnapshot:
    return TextWrapRuntimeSnapshot(
        "TextWrapRuntime",
        runtime.shell_rows_amount,
        runtime.has_hyphenator,
        runtime.has_dictionary,
        runtime.has_fill,
        wrapping_type_name(runtime.wrapping_type),
    )


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


def chunks(text: String, width: Int) -> List[String]:
    """Typed specialization of Python's generic chunk generator for strings."""
    return hard_chunks(text, width)


def split_more_if_not_small(
    texts: List[String], target_length: Int
) -> List[String]:
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
            var parts = chunks(texts[index], target_length)
            for part_index in range(len(parts)):
                result.append(parts[part_index])
        else:
            result.append(texts[index])
    return result^


def alxwrap(
    text: String,
    length: Int,
    runtime: TextWrapRuntime = default_text_wrap_runtime(),
    wrapping_type: Int = 0,
) -> List[String]:
    """Wrap one string using explicit native backend capabilities.

    Python's pyphen and pyhyphen values are dynamic callables.  In the native
    owner the capabilities are booleans and the deterministic hard wrapper is
    the owned implementation.  Missing capabilities preserve the historical
    one-element fallback.
    """
    var resolved_type = (
        runtime.wrapping_type
        if wrapping_type == 0
        else _normalise_wrapping_type(wrapping_type)
    )
    if length == 0 or resolved_type == WRAP_NOHYPHEN:
        return [text]
    if resolved_type == WRAP_PYPHEN and not runtime.has_dictionary:
        if not runtime.has_fill:
            return [text]
    elif resolved_type == WRAP_PYHYPHEN and not runtime.has_fill:
        if not runtime.has_dictionary:
            return [text]
    return hard_chunks(text, length)


def wrap_cell_text(
    text: String,
    length: Int,
    runtime: TextWrapRuntime = default_text_wrap_runtime(),
) -> WrapResult:
    if length == 0 or codepoint_length(text) <= length:
        return WrapResult(False, List[String]())
    return WrapResult(True, alxwrap(text, length, runtime))


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


def bootstrap_table_wrapping(
    force_refresh: Bool = False,
    wrapping_type: Int = WRAP_PYHYPHEN,
    max_len: Int = 0,
) -> TableWrappingBundle:
    # Native state is explicit and immutable at bootstrap, so force_refresh is
    # intentionally observational only: every bootstrap returns fresh state.
    _ = force_refresh
    return TableWrappingBundle(
        refresh_textwrap_runtime(wrapping_type, max_len)
    )


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
