"""Pure native line-editor state for the interactive reta prompt.

The terminal adapter supplies decoded keys.  This module owns UTF-8-safe byte
cursor movement, editing, history traversal and replacement-token completion,
so almost all interactive semantics are testable without a pseudo-terminal.
"""

from std.collections import List
from .prompt_language import PromptLanguageCatalog, prompt_completion_candidates


@fieldwise_init
struct PromptEditorState(Copyable):
    var text: String
    var cursor: Int
    var history_index: Int
    var saved_current: String
    var vi_insert: Bool


@fieldwise_init
struct PromptCompletionResult(Copyable):
    var changed: Bool
    var unique: Bool
    var candidates: List[String]


def new_prompt_editor_state(history_length: Int, vi_mode: Bool) -> PromptEditorState:
    return PromptEditorState("", 0, history_length, "", True)


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _is_utf8_continuation(value: Int) -> Bool:
    return value >= 0x80 and value < 0xC0


def previous_utf8_boundary(text: String, cursor: Int) -> Int:
    var result = min(max(cursor, 0), text.byte_length())
    if result == 0:
        return 0
    result -= 1
    var bytes = text.as_bytes()
    while result > 0 and _is_utf8_continuation(Int(bytes[result])):
        result -= 1
    return result


def next_utf8_boundary(text: String, cursor: Int) -> Int:
    var result = min(max(cursor, 0), text.byte_length())
    if result >= text.byte_length():
        return text.byte_length()
    result += 1
    var bytes = text.as_bytes()
    while result < text.byte_length() and _is_utf8_continuation(Int(bytes[result])):
        result += 1
    return result


def utf8_display_width(text: String, start: Int = 0, end: Int = -1) -> Int:
    """Count Unicode scalar starts; prompt command glyphs are single-column."""
    var upper = text.byte_length() if end < 0 else min(end, text.byte_length())
    var lower = min(max(start, 0), upper)
    var width = 0
    var bytes = text.as_bytes()
    for index in range(lower, upper):
        if not _is_utf8_continuation(Int(bytes[index])):
            width += 1
    return width


def editor_set_text(mut state: PromptEditorState, value: String) -> None:
    state.text = value
    state.cursor = value.byte_length()


def editor_insert(mut state: PromptEditorState, value: String) -> None:
    if value.byte_length() == 0:
        return
    state.text = (
        _slice(state.text, 0, state.cursor)
        + value
        + _slice(state.text, state.cursor, state.text.byte_length())
    )
    state.cursor += value.byte_length()


def editor_move_left(mut state: PromptEditorState) -> None:
    state.cursor = previous_utf8_boundary(state.text, state.cursor)


def editor_move_right(mut state: PromptEditorState) -> None:
    state.cursor = next_utf8_boundary(state.text, state.cursor)


def editor_move_home(mut state: PromptEditorState) -> None:
    state.cursor = 0


def editor_move_end(mut state: PromptEditorState) -> None:
    state.cursor = state.text.byte_length()


def editor_backspace(mut state: PromptEditorState) -> None:
    if state.cursor <= 0:
        return
    var start = previous_utf8_boundary(state.text, state.cursor)
    state.text = (
        _slice(state.text, 0, start)
        + _slice(state.text, state.cursor, state.text.byte_length())
    )
    state.cursor = start


def editor_delete(mut state: PromptEditorState) -> None:
    if state.cursor >= state.text.byte_length():
        return
    var end = next_utf8_boundary(state.text, state.cursor)
    state.text = (
        _slice(state.text, 0, state.cursor)
        + _slice(state.text, end, state.text.byte_length())
    )


def editor_kill_before_cursor(mut state: PromptEditorState) -> None:
    state.text = _slice(state.text, state.cursor, state.text.byte_length())
    state.cursor = 0


def editor_kill_after_cursor(mut state: PromptEditorState) -> None:
    state.text = _slice(state.text, 0, state.cursor)


def _is_ascii_space_at(text: String, index: Int) -> Bool:
    if index < 0 or index >= text.byte_length():
        return False
    var value = Int(text.as_bytes()[index])
    return value == 32 or value == 9


def editor_move_word_left(mut state: PromptEditorState) -> None:
    var cursor = state.cursor
    while cursor > 0:
        var previous = previous_utf8_boundary(state.text, cursor)
        if not _is_ascii_space_at(state.text, previous):
            break
        cursor = previous
    while cursor > 0:
        var previous = previous_utf8_boundary(state.text, cursor)
        if _is_ascii_space_at(state.text, previous):
            break
        cursor = previous
    state.cursor = cursor


def editor_move_word_right(mut state: PromptEditorState) -> None:
    var cursor = state.cursor
    while cursor < state.text.byte_length() and not _is_ascii_space_at(
        state.text, cursor
    ):
        cursor = next_utf8_boundary(state.text, cursor)
    while cursor < state.text.byte_length() and _is_ascii_space_at(
        state.text, cursor
    ):
        cursor = next_utf8_boundary(state.text, cursor)
    state.cursor = cursor


def editor_delete_previous_word(mut state: PromptEditorState) -> None:
    var end = state.cursor
    editor_move_word_left(state)
    var start = state.cursor
    state.text = (
        _slice(state.text, 0, start)
        + _slice(state.text, end, state.text.byte_length())
    )


def _copy_strings(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def editor_history_previous(
    mut state: PromptEditorState, history: List[String]
) -> Bool:
    if len(history) == 0 or state.history_index <= 0:
        return False
    if state.history_index >= len(history):
        state.saved_current = state.text
    state.history_index -= 1
    editor_set_text(state, history[state.history_index])
    return True


def editor_history_next(
    mut state: PromptEditorState, history: List[String]
) -> Bool:
    if len(history) == 0 or state.history_index >= len(history):
        return False
    state.history_index += 1
    if state.history_index == len(history):
        var saved = state.saved_current
        editor_set_text(state, saved)
    else:
        editor_set_text(state, history[state.history_index])
    return True


def _is_completion_delimiter(value: Int) -> Bool:
    return value == 32 or value == 9 or value == 10 or value == 13 or value == 61 or value == 44


def completion_fragment_start(text: String, cursor: Int) -> Int:
    var result = min(max(cursor, 0), text.byte_length())
    var bytes = text.as_bytes()
    while result > 0:
        var previous = previous_utf8_boundary(text, result)
        if previous < text.byte_length() and _is_completion_delimiter(
            Int(bytes[previous])
        ):
            break
        result = previous
    return result


def _common_prefix(values: List[String]) -> String:
    if len(values) == 0:
        return ""
    var limit = values[0].byte_length()
    for index in range(1, len(values)):
        limit = min(limit, values[index].byte_length())
    var common = 0
    while common < limit:
        var expected = Int(values[0].as_bytes()[common])
        var matches = True
        for index in range(1, len(values)):
            if Int(values[index].as_bytes()[common]) != expected:
                matches = False
                break
        if not matches:
            break
        common += 1
    while common > 0 and common < values[0].byte_length() and _is_utf8_continuation(
        Int(values[0].as_bytes()[common])
    ):
        common -= 1
    return _slice(values[0], 0, common)


def _replace_fragment(
    mut state: PromptEditorState,
    start: Int,
    replacement: String,
    append_space: Bool,
) -> None:
    var suffix = _slice(state.text, state.cursor, state.text.byte_length())
    var addition = replacement
    if append_space and (
        suffix.byte_length() == 0 or not _is_ascii_space_at(suffix, 0)
    ):
        addition += " "
    state.text = _slice(state.text, 0, start) + addition + suffix
    state.cursor = start + addition.byte_length()


def editor_complete(
    mut state: PromptEditorState,
    catalog: PromptLanguageCatalog,
    language: String,
) -> PromptCompletionResult:
    var prefix = _slice(state.text, 0, state.cursor)
    var candidates = prompt_completion_candidates(catalog, language, prefix)
    if len(candidates) == 0:
        return PromptCompletionResult(False, False, candidates^)

    var start = completion_fragment_start(state.text, state.cursor)
    var fragment = _slice(state.text, start, state.cursor)
    if len(candidates) == 1:
        _replace_fragment(state, start, candidates[0], True)
        return PromptCompletionResult(True, True, candidates^)

    var common = _common_prefix(candidates)
    if common.byte_length() > fragment.byte_length():
        _replace_fragment(state, start, common, False)
        return PromptCompletionResult(True, False, candidates^)
    return PromptCompletionResult(False, False, candidates^)
