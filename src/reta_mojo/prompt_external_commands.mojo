"""Native operating-system adapter for explicit compatibility children.

The historical prompt exposes explicit commands whose purpose is to start
another program: ``shell``, ``python`` and ``math`` plus still-unported
``reta`` and atomic prompt-fallback paths.  Callers pass already separated
payloads or argv vectors; raw prompt-line compatibility is owned by callers
that still expose historical line-based facades.  The general ``reta``
compatibility launcher uses the same boundary.  Their dispatch belongs to Mojo; importing
CPython merely to ask it to spawn a second interpreter is both slower and a
needless runtime dependency.

The adapter is explicit and byte-preserving: every child inherits stdin,
stdout, stderr and the complete environment.  This is process *execution*, not
process-based parallelism.  No table or number kernel uses this adapter.
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
    is assembled exclusively from ``shell_quote``-escaped arguments.  The
    single standard C boundary is shared by the prompt and the historical CLI
    compatibility launcher; neither executable embeds CPython.
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


def run_shell_prompt_payload_native(
    payload: String,
    reference_root: String = "python_reference",
) raises -> Int:
    """Run an explicit shell payload already separated by the prompt owner."""
    var arguments = shell_split(payload)
    if len(arguments) == 0:
        return 0
    var command = _working_command_prefix(reference_root)
    for index in range(len(arguments)):
        if index > 0:
            command += " "
        command += shell_quote(arguments[index])
    return _run_spawned_child(command)



def run_python_prompt_payload_native(
    payload: String,
    reference_root: String = "python_reference",
) raises -> Int:
    """Run an explicit Python payload already separated by the prompt owner."""
    var command = (
        _working_command_prefix(reference_root)
        + shell_quote(prompt_python_executable())
        + " -c "
        + shell_quote(payload)
    )
    return _run_spawned_child(command)



def run_math_prompt_payload_native(
    payload: String,
    reference_root: String = "python_reference",
) raises -> Int:
    """Run an explicit math expression already separated by the prompt owner."""
    var program = "print(" + payload + ")"
    var command = (
        _working_command_prefix(reference_root)
        + shell_quote(prompt_python_executable())
        + " -c "
        + shell_quote(program)
    )
    return _run_spawned_child(command)



def _run_reference_python_script(
    script_name: String,
    arguments: List[String],
    reference_root: String = "python_reference",
) raises -> Int:
    """Run one bundled Python compatibility entry point without embedding it."""
    var command = (
        _working_command_prefix(reference_root)
        + shell_quote(prompt_python_executable())
        + " "
        + shell_quote(script_name)
    )
    for index in range(len(arguments)):
        command += " " + shell_quote(arguments[index])
    return _run_spawned_child(command)


def run_reta_arguments_native(
    arguments: List[String],
    reference_root: String = "python_reference",
) raises -> Int:
    """Run the historical ``reta.py`` CLI through the explicit child boundary.

    The caller already owns the argument vector, so no delimiter encoding or
    shell parsing is involved.  Empty arguments and Unicode are retained by
    quoting each element independently.
    """
    return _run_reference_python_script("reta.py", arguments, reference_root)



def run_reta_prompt_arguments_native(
    arguments: List[String],
    reference_root: String = "python_reference",
) raises -> Int:
    """Run historical ``retaPrompt.py`` with an already-tokenized argument list."""
    return _run_reference_python_script(
        "retaPrompt.py", arguments, reference_root
    )


def run_reta_prompt_fallback_arguments_native(
    profile_arguments: List[String],
    command_arguments: List[String],
    reference_root: String = "python_reference",
) raises -> Int:
    """Execute one unported prompt command with owned argv fragments.

    Profile arguments are already typed by the native controller, and the
    unported command line has already been tokenized by the prompt/legacy
    facade that still owns raw compatibility text.  The process adapter now
    only receives argv vectors and starts the explicit reference child.
    """
    var arguments = List[String]()
    for index in range(len(profile_arguments)):
        if profile_arguments[index].byte_length() > 0:
            arguments.append(profile_arguments[index])
    for index in range(len(command_arguments)):
        arguments.append(command_arguments[index])
    return _run_reference_python_script(
        "retaPrompt.py", arguments, reference_root
    )
