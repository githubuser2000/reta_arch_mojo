"""Native operating-system adapter for explicit compatibility children.

The historical prompt exposes explicit commands whose purpose is to start
another program: ``shell``, ``python`` and ``math`` plus still-unported
``reta`` and atomic prompt-fallback paths.  Callers pass already separated
payloads or argv vectors; raw prompt-line compatibility is owned by callers
that still expose historical line-based facades.  Shell-style tokenization is
provided by the prompt runtime owner and imported here only for legacy payload
wrappers.  The general ``reta`` compatibility launcher uses the same boundary.  Their dispatch belongs to Mojo; importing
CPython merely to ask it to spawn a second interpreter is both slower and a
needless runtime dependency.

The adapter is explicit and byte-preserving: every child inherits stdin,
stdout, stderr and the complete environment.  This is process *execution*, not
process-based parallelism.  No table or number kernel uses this adapter.
"""

from std.collections import List
from std.ffi import CStringSlice, c_int, external_call
from std.os import getenv
from .prompt_runtime import shell_split


def shell_quote(value: String) -> String:
    """Return one argument safely quoted for the child shell wrapper."""
    return "'" + value.replace("'", "'\"'\"'") + "'"




def reta_child_arguments_native(arguments: List[String]) -> List[String]:
    """Drop an optional historical reta executable from an owned argv vector."""
    var result = List[String]()
    var start = 0
    if len(arguments) > 0 and (
        arguments[0] == "reta"
        or arguments[0] == "reta.py"
        or arguments[0].endswith("/reta.py")
    ):
        start = 1
    for index in range(start, len(arguments)):
        result.append(arguments[index])
    return result^


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


def run_shell_prompt_arguments_native(
    arguments: List[String],
    reference_root: String = "python_reference",
) raises -> Int:
    """Run an explicit shell argv vector without adapter-side tokenization."""
    if len(arguments) == 0:
        return 0
    var command = _working_command_prefix(reference_root)
    for index in range(len(arguments)):
        if index > 0:
            command += " "
        command += shell_quote(arguments[index])
    return _run_spawned_child(command)


def run_shell_prompt_payload_native(
    payload: String,
    reference_root: String = "python_reference",
) raises -> Int:
    """Run a legacy shell payload by tokenizing it at the compatibility edge."""
    return run_shell_prompt_arguments_native(
        shell_split(payload), reference_root
    )



def _first_payload_argument(arguments: List[String]) -> String:
    if len(arguments) == 0:
        return ""
    return String(arguments[0])


def run_python_prompt_arguments_native(
    arguments: List[String],
    reference_root: String = "python_reference",
) raises -> Int:
    """Run explicit Python code from an argv-owned prompt plan."""
    var payload = _first_payload_argument(arguments)
    var command = (
        _working_command_prefix(reference_root)
        + shell_quote(prompt_python_executable())
        + " -c "
        + shell_quote(payload)
    )
    return _run_spawned_child(command)


def run_python_prompt_payload_native(
    payload: String,
    reference_root: String = "python_reference",
) raises -> Int:
    """Run a legacy Python payload by wrapping it at the compatibility edge."""
    var arguments = List[String]()
    arguments.append(payload)
    return run_python_prompt_arguments_native(arguments, reference_root)


def run_math_prompt_arguments_native(
    arguments: List[String],
    reference_root: String = "python_reference",
) raises -> Int:
    """Run explicit math code from an argv-owned prompt plan."""
    var payload = _first_payload_argument(arguments)
    var program = "print(" + payload + ")"
    var command = (
        _working_command_prefix(reference_root)
        + shell_quote(prompt_python_executable())
        + " -c "
        + shell_quote(program)
    )
    return _run_spawned_child(command)


def run_math_prompt_payload_native(
    payload: String,
    reference_root: String = "python_reference",
) raises -> Int:
    """Run a legacy math payload by wrapping it at the compatibility edge."""
    var arguments = List[String]()
    arguments.append(payload)
    return run_math_prompt_arguments_native(arguments, reference_root)



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
