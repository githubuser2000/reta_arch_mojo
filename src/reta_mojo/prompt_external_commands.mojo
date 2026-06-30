"""Native operating-system adapter for explicit prompt child commands.

The historical prompt exposes three commands whose purpose is to start another
program: ``shell``, ``python`` and ``math``.  Their dispatch belongs to Mojo;
there is no reason to import ``mojo_bridge.py`` merely to spawn the requested
child.  This module keeps the boundary explicit and byte-preserving: the
spawned child inherits stdin, stdout, stderr and the complete environment.

This is process *execution*, not process-based parallelism.  No table or number
kernel uses this adapter.
"""

from std.collections import List
from std.collections.string import StringSlice
from std.ffi import CStringSlice, c_int, external_call
from std.os import getenv


comptime _STATE_NORMAL = 0
comptime _STATE_SINGLE_QUOTE = 1
comptime _STATE_DOUBLE_QUOTE = 2


def _slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _next_codepoint_end(text: String, start: Int) -> Int:
    """Return the byte offset after the UTF-8 codepoint at ``start``."""
    var bytes = text.as_bytes()
    if start >= len(bytes):
        return start
    var end = start + 1
    while end < len(bytes) and (Int(bytes[end]) & 0xC0) == 0x80:
        end += 1
    return end


def raw_command_payload(line: String) -> String:
    """Match Python ``line.partition(" ")[2]`` exactly."""
    var bytes = line.as_bytes()
    for index in range(len(bytes)):
        if Int(bytes[index]) == 32:
            return _slice(line, index + 1, len(bytes))
    return ""


def shell_split(text: String) raises -> List[String]:
    """Small POSIX-shlex parser used by the historical ``shell`` command.

    It preserves Unicode, empty quoted arguments, single/double quotes and
    backslash escaping while deliberately performing no variable expansion,
    globbing or shell interpretation, matching ``shlex.split`` + ``Popen(argv)``.
    """
    var result = List[String]()
    var current = String()
    var token_started = False
    var state = _STATE_NORMAL
    var index = 0
    var bytes = text.as_bytes()

    while index < len(bytes):
        var code = Int(bytes[index])
        var end = _next_codepoint_end(text, index)
        var value = _slice(text, index, end)

        if state == _STATE_NORMAL:
            if code == 32 or code == 9 or code == 10 or code == 13:
                if token_started:
                    result.append(current)
                    current = String()
                    token_started = False
                index = end
                continue
            if code == 39:  # '
                state = _STATE_SINGLE_QUOTE
                token_started = True
                index = end
                continue
            if code == 34:  # "
                state = _STATE_DOUBLE_QUOTE
                token_started = True
                index = end
                continue
            if code == 92:  # backslash
                if end >= len(bytes):
                    raise Error("No escaped character")
                var escaped_end = _next_codepoint_end(text, end)
                current += _slice(text, end, escaped_end)
                token_started = True
                index = escaped_end
                continue
            current += value
            token_started = True
            index = end
            continue

        if state == _STATE_SINGLE_QUOTE:
            if code == 39:
                state = _STATE_NORMAL
            else:
                current += value
            index = end
            continue

        # POSIX shlex inside double quotes: backslash only quotes backslash,
        # double quote, dollar, backtick and newline.  Before other characters
        # it remains a literal backslash.
        if code == 34:
            state = _STATE_NORMAL
            index = end
            continue
        if code == 92:
            if end >= len(bytes):
                raise Error("No escaped character")
            var escaped_end = _next_codepoint_end(text, end)
            var escaped_code = Int(bytes[end])
            if escaped_code == 10:
                pass
            elif (
                escaped_code == 34
                or escaped_code == 36
                or escaped_code == 92
                or escaped_code == 96
            ):
                current += _slice(text, end, escaped_end)
            else:
                current += "\\" + _slice(text, end, escaped_end)
            token_started = True
            index = escaped_end
            continue
        current += value
        token_started = True
        index = end

    if state != _STATE_NORMAL:
        raise Error("No closing quotation")
    if token_started:
        result.append(current)
    return result^


def shell_quote(value: String) -> String:
    """Return one argument safely quoted for the child shell wrapper."""
    return "'" + value.replace("'", "'\"'\"'") + "'"


def _decode_system_status(status: Int) -> Int:
    if status < 0:
        return status
    var signal = status & 0x7F
    if signal != 0:
        return 128 + signal
    return (status >> 8) & 0xFF


def _run_spawned_child(command: String) raises -> Int:
    """Execute one explicitly requested child command byte-preservingly.

    libc ``system`` invokes ``/bin/sh -c`` synchronously and inherits the
    complete environment plus stdin, stdout and stderr.  The command payload
    is assembled exclusively from ``shell_quote``-escaped arguments.  Using
    this standard C boundary avoids a second, conflicting declaration of
    ``dlsym`` when the full prompt controller also imports ``std.python``.
    """
    var command_storage = command + "\0"
    var status = Int(
        external_call["system", c_int](CStringSlice(command_storage))
    )
    if status < 0:
        raise Error("system failed while starting prompt child")
    return _decode_system_status(status)

def _working_command_prefix(reference_root: String) -> String:
    return "cd " + shell_quote(reference_root) + " && exec "


def prompt_python_executable() -> String:
    """Return the explicit prompt Python executable, defaulting historically."""
    var configured = String(getenv("RETA_PYTHON", "").strip())
    return configured if configured.byte_length() > 0 else "python3"


def run_shell_prompt_line_native(
    line: String,
    reference_root: String = "python_reference",
) raises -> Int:
    var arguments = shell_split(raw_command_payload(line))
    if len(arguments) == 0:
        return 0
    var command = _working_command_prefix(reference_root)
    for index in range(len(arguments)):
        if index > 0:
            command += " "
        command += shell_quote(arguments[index])
    return _run_spawned_child(command)


def run_python_prompt_line_native(
    line: String,
    reference_root: String = "python_reference",
) raises -> Int:
    var code = raw_command_payload(line)
    var command = (
        _working_command_prefix(reference_root)
        + shell_quote(prompt_python_executable())
        + " -c "
        + shell_quote(code)
    )
    return _run_spawned_child(command)


def run_math_prompt_line_native(
    line: String,
    reference_root: String = "python_reference",
) raises -> Int:
    var expression = raw_command_payload(line)
    var program = "print(" + expression + ")"
    var command = (
        _working_command_prefix(reference_root)
        + shell_quote(prompt_python_executable())
        + " -c "
        + shell_quote(program)
    )
    return _run_spawned_child(command)
