"""Native POSIX terminal adapter for the interactive reta prompt.

The pure editor state lives in :mod:`prompt_line_editor`.  This module owns the
small operating-system boundary only: raw ``termios`` mode, byte decoding,
common Emacs/Vi key bindings, history navigation and rendering.  Linux and
macOS use their native ``FIONREAD`` request to distinguish a lone Escape key
from an ANSI cursor-key sequence.
"""

from std.collections import InlineArray, List
from std.ffi import c_int, c_ulong, external_call
from std.io import FileDescriptor
from std.memory import Span, UnsafePointer, stack_allocation
from std.sys.info import CompilationTarget
from .prompt_language import PromptLanguageCatalog
from .terminal_geometry import terminal_columns
from .prompt_line_editor import (
    PromptEditorState,
    editor_backspace,
    editor_complete,
    editor_delete,
    editor_delete_previous_word,
    editor_history_next,
    editor_history_previous,
    editor_insert,
    editor_kill_after_cursor,
    editor_kill_before_cursor,
    editor_move_end,
    editor_move_home,
    editor_move_left,
    editor_move_right,
    editor_move_word_left,
    editor_move_word_right,
    new_prompt_editor_state,
    utf8_display_width,
)


comptime _TCSANOW = 0
comptime _LINUX_FIONREAD = 0x541B
comptime _DARWIN_FIONREAD = 0x4004667F
comptime _TERM_STATE_BYTES = 256
comptime _ESCAPE_WAIT_MICROSECONDS = 20000
comptime _SEQUENCE_WAIT_MICROSECONDS = 4000


@fieldwise_init
struct PromptTerminalResult(Copyable):
    var line: String
    var interrupted: Bool
    var eof: Bool
    var native_ready: Bool


@fieldwise_init
struct PromptRenderState(Copyable):
    var rows: Int
    var cursor_row: Int
    var end_row: Int
    var active: Bool


def _write_text(mut output: FileDescriptor, text: String) raises:
    output.write_string(StringSlice(text))


def _fionread_request() -> UInt64:
    if CompilationTarget.is_linux():
        return UInt64(_LINUX_FIONREAD)
    if CompilationTarget.is_macos():
        return UInt64(_DARWIN_FIONREAD)
    return UInt64(0)


def _pending_input() -> Int:
    var request = _fionread_request()
    if request == 0:
        return 0
    var available = stack_allocation[1, c_int]()
    available[0] = c_int(0)
    var status = external_call["ioctl", c_int](
        c_int(0), c_ulong(request), available
    )
    if Int(status) != 0:
        return 0
    return max(0, Int(available[0]))


def _sleep_microseconds(value: Int):
    _ = external_call["usleep", c_int](UInt32(max(0, value)))


def _read_byte(mut input: FileDescriptor) raises -> Int:
    var buffer = InlineArray[UInt8, 1](fill=0)
    var span = Span(buffer)
    var count = input.read_bytes(span)
    if count == 0:
        return -1
    return Int(buffer[0])


def _utf8_length(first: Int) -> Int:
    if first < 0x80:
        return 1
    if first >= 0xC2 and first <= 0xDF:
        return 2
    if first >= 0xE0 and first <= 0xEF:
        return 3
    if first >= 0xF0 and first <= 0xF4:
        return 4
    return 1


def _decode_character(first: Int, mut input: FileDescriptor) raises -> String:
    var length = _utf8_length(first)
    if length == 1:
        return chr(first)
    var buffer = InlineArray[UInt8, 4](fill=0)
    buffer[0] = UInt8(first)
    var actual = 1
    while actual < length:
        var next = _read_byte(input)
        if next < 0:
            break
        buffer[actual] = UInt8(next)
        actual += 1
    var span = Span(buffer)
    return String(from_utf8_lossy=span.unsafe_subspan(offset=0, length=actual))


def _read_key(mut input: FileDescriptor) raises -> String:
    var first = _read_byte(input)
    if first < 0:
        return "\x04"
    if first != 27:
        return _decode_character(first, input)

    _sleep_microseconds(_ESCAPE_WAIT_MICROSECONDS)
    if _pending_input() <= 0:
        return "\x1b"

    var second = _read_byte(input)
    if second < 0:
        return "\x1b"
    if second != 91 and second != 79:
        return "\x1b" + _decode_character(second, input)

    var sequence = "\x1b" + chr(second)
    for _ in range(6):
        if _pending_input() <= 0:
            _sleep_microseconds(_SEQUENCE_WAIT_MICROSECONDS)
        if _pending_input() <= 0:
            break
        var value = _read_byte(input)
        if value < 0:
            break
        sequence += chr(value)
        if (
            (value >= 65 and value <= 90)
            or (value >= 97 and value <= 122)
            or value == 126
        ):
            break
    return sequence^


def _enable_raw_mode(
    original: UnsafePointer[UInt8, MutUntrackedOrigin]
) -> Bool:
    var raw = stack_allocation[_TERM_STATE_BYTES, UInt8]()
    if Int(external_call["tcgetattr", c_int](c_int(0), original)) != 0:
        return False
    if Int(external_call["tcgetattr", c_int](c_int(0), raw)) != 0:
        return False
    _ = external_call["cfmakeraw", NoneType](raw)
    return (
        Int(external_call["tcsetattr", c_int](c_int(0), c_int(_TCSANOW), raw))
        == 0
    )


def _restore_terminal(original: UnsafePointer[UInt8, MutUntrackedOrigin]):
    _ = external_call["tcsetattr", c_int](c_int(0), c_int(_TCSANOW), original)


def _move_up(mut output: FileDescriptor, rows: Int) raises:
    if rows > 0:
        _write_text(output, "\x1b[" + String(rows) + "A")


def _move_down(mut output: FileDescriptor, rows: Int) raises:
    if rows > 0:
        _write_text(output, "\x1b[" + String(rows) + "B")


def _move_right(mut output: FileDescriptor, columns: Int) raises:
    if columns > 0:
        _write_text(output, "\x1b[" + String(columns) + "C")


def _clear_previous_render(
    mut output: FileDescriptor, render: PromptRenderState
) raises:
    if not render.active:
        return
    _write_text(output, "\r")
    _move_up(output, render.cursor_row)
    for row in range(render.rows):
        _write_text(output, "\x1b[2K")
        if row + 1 < render.rows:
            _move_down(output, 1)
            _write_text(output, "\r")
    _move_up(output, render.rows - 1)
    _write_text(output, "\r")


def _wrapped_content(content: String, columns: Int) -> String:
    """Render explicit CRLF wraps so cursor rows are deterministic."""
    var result = ""
    var cursor = 0
    var column = 0
    while cursor < content.byte_length():
        var next = cursor + 1
        var bytes = content.as_bytes()
        while next < content.byte_length() and (
            Int(bytes[next]) >= 0x80 and Int(bytes[next]) < 0xC0
        ):
            next += 1
        result += String(StringSlice(content)[byte=cursor:next])
        column += 1
        cursor = next
        if column >= columns:
            # Explicitly enter the next physical row even at an exact-width
            # line end.  This avoids the terminal's ambiguous auto-wrap flag.
            result += "\r\n"
            column = 0
    return result^


def _move_from_end_to_cursor(
    mut output: FileDescriptor,
    end_row: Int,
    cursor_row: Int,
    cursor_column: Int,
) raises:
    _write_text(output, "\r")
    _move_up(output, end_row - cursor_row)
    _move_right(output, cursor_column)


def _move_after_render(
    mut output: FileDescriptor, render: PromptRenderState
) raises:
    if not render.active:
        return
    _write_text(output, "\r")
    _move_down(output, render.end_row - render.cursor_row)


def _redraw(
    mut output: FileDescriptor,
    prompt: String,
    state: PromptEditorState,
    mut render: PromptRenderState,
) raises:
    _clear_previous_render(output, render)
    var columns = max(1, terminal_columns())
    var prompt_width = utf8_display_width(prompt)
    var prefix_width = utf8_display_width(state.text, 0, state.cursor)
    var total_width = prompt_width + utf8_display_width(state.text)
    var cursor_offset = prompt_width + prefix_width
    var cursor_row = cursor_offset // columns
    var cursor_column = cursor_offset % columns
    var end_row = total_width // columns
    var content = prompt + state.text
    _write_text(output, _wrapped_content(content, columns))
    _move_from_end_to_cursor(
        output, end_row, cursor_row, cursor_column
    )
    render.rows = end_row + 1
    render.cursor_row = cursor_row
    render.end_row = end_row
    render.active = True


def _show_candidates(
    mut output: FileDescriptor,
    prompt: String,
    state: PromptEditorState,
    candidates: List[String],
    mut render: PromptRenderState,
) raises:
    _move_after_render(output, render)
    _write_text(output, "\r\n")
    for index in range(len(candidates)):
        if index > 0:
            _write_text(output, "  ")
        _write_text(output, candidates[index])
    _write_text(output, "\r\n")
    render.active = False
    _redraw(output, prompt, state, render)

def _is_printable_key(key: String) -> Bool:
    if key.byte_length() == 0:
        return False
    var first = Int(key.as_bytes()[0])
    return first >= 32 and first != 127


def _handle_navigation_key(
    mut state: PromptEditorState,
    key: String,
    history: List[String],
) -> Bool:
    if key == "\x1b[D":
        editor_move_left(state)
    elif key == "\x1b[C":
        editor_move_right(state)
    elif key == "\x1b[A":
        _ = editor_history_previous(state, history)
    elif key == "\x1b[B":
        _ = editor_history_next(state, history)
    elif key == "\x1b[H" or key == "\x1bOH" or key == "\x1b[1~":
        editor_move_home(state)
    elif key == "\x1b[F" or key == "\x1bOF" or key == "\x1b[4~":
        editor_move_end(state)
    elif key == "\x1b[3~":
        editor_delete(state)
    else:
        return False
    return True


def _handle_emacs_key(
    mut state: PromptEditorState,
    key: String,
    history: List[String],
) -> Bool:
    if _handle_navigation_key(state, key, history):
        return True
    if key == "\x01":
        editor_move_home(state)
    elif key == "\x05":
        editor_move_end(state)
    elif key == "\x02":
        editor_move_left(state)
    elif key == "\x06":
        editor_move_right(state)
    elif key == "\x10":
        _ = editor_history_previous(state, history)
    elif key == "\x0e":
        _ = editor_history_next(state, history)
    elif key == "\x15":
        editor_kill_before_cursor(state)
    elif key == "\x0b":
        editor_kill_after_cursor(state)
    elif key == "\x17":
        editor_delete_previous_word(state)
    elif key == "\x1bb":
        editor_move_word_left(state)
    elif key == "\x1bf":
        editor_move_word_right(state)
    elif key == "\x7f" or key == "\x08":
        editor_backspace(state)
    else:
        return False
    return True


def _handle_vi_normal_key(
    mut state: PromptEditorState,
    key: String,
    history: List[String],
) -> Bool:
    if _handle_navigation_key(state, key, history):
        return True
    if key == "h":
        editor_move_left(state)
    elif key == "l":
        editor_move_right(state)
    elif key == "0" or key == "I":
        editor_move_home(state)
        if key == "I":
            state.vi_insert = True
    elif key == "$" or key == "A":
        editor_move_end(state)
        if key == "A":
            state.vi_insert = True
    elif key == "i":
        state.vi_insert = True
    elif key == "a":
        editor_move_right(state)
        state.vi_insert = True
    elif key == "x":
        editor_delete(state)
    elif key == "X":
        editor_backspace(state)
    elif key == "b":
        editor_move_word_left(state)
    elif key == "w":
        editor_move_word_right(state)
    elif key == "k":
        _ = editor_history_previous(state, history)
    elif key == "j":
        _ = editor_history_next(state, history)
    else:
        return False
    return True


def _process_vi_escape_tail(
    mut state: PromptEditorState,
    key: String,
    history: List[String],
) -> Bool:
    if not key.startswith("\x1b") or key.byte_length() <= 1:
        return False
    state.vi_insert = False
    var tail = String(StringSlice(key)[byte=1:])
    return _handle_vi_normal_key(state, tail, history)


def read_terminal_prompt_line(
    prompt: String,
    history: List[String],
    catalog: PromptLanguageCatalog,
    language: String,
    vi_mode: Bool,
) raises -> PromptTerminalResult:
    """Read one line in native raw mode and restore terminal state on exit."""
    var original = stack_allocation[_TERM_STATE_BYTES, UInt8]()
    if not _enable_raw_mode(original):
        return PromptTerminalResult("", False, False, False)

    var input = FileDescriptor(0)
    var output = FileDescriptor(1)
    var state = new_prompt_editor_state(len(history), vi_mode)
    var render = PromptRenderState(1, 0, 0, False)
    try:
        _redraw(output, prompt, state, render)
        while True:
            var key = _read_key(input)
            if key == "\x04":
                if state.text.byte_length() == 0:
                    _move_after_render(output, render)
                    _write_text(output, "\r\n")
                    _restore_terminal(original)
                    return PromptTerminalResult("", False, True, True)
                editor_delete(state)
                _redraw(output, prompt, state, render)
                continue
            if key == "\x03":
                _move_after_render(output, render)
                _write_text(output, "\r\n")
                _restore_terminal(original)
                return PromptTerminalResult("", True, False, True)
            if key == "\r" or key == "\n":
                _move_after_render(output, render)
                _write_text(output, "\r\n")
                var completed = state.text
                _restore_terminal(original)
                return PromptTerminalResult(completed, False, False, True)
            if key == "\x0c":
                _write_text(output, "\x1b[2J\x1b[H")
                render.active = False
                _redraw(output, prompt, state, render)
                continue
            if key == "\t":
                var completion = editor_complete(state, catalog, language)
                if len(completion.candidates) > 1 and not completion.changed:
                    _show_candidates(
                        output, prompt, state, completion.candidates, render
                    )
                else:
                    _redraw(output, prompt, state, render)
                continue

            var handled: Bool
            if vi_mode:
                if state.vi_insert:
                    if key == "\x1b":
                        state.vi_insert = False
                        handled = True
                    elif _process_vi_escape_tail(state, key, history):
                        handled = True
                    else:
                        handled = _handle_emacs_key(state, key, history)
                        if not handled and _is_printable_key(key):
                            editor_insert(state, key)
                            handled = True
                else:
                    handled = _handle_vi_normal_key(state, key, history)
            else:
                handled = _handle_emacs_key(state, key, history)
                if not handled and _is_printable_key(key):
                    editor_insert(state, key)
                    handled = True
            if handled:
                _redraw(output, prompt, state, render)
    except:
        _restore_terminal(original)
        return PromptTerminalResult("", False, True, True)
