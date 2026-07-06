from std.collections import List
from std.sys import argv
from reta_mojo.prompt_external_commands import (
    raw_command_payload,
    run_math_prompt_payload_native,
    run_python_prompt_payload_native,
    run_reta_arguments_native,
    run_reta_prompt_fallback_arguments_native,
    run_shell_prompt_payload_native,
    shell_split,
)


def _reta_child_arguments(arguments: List[String]) -> List[String]:
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


def _run(mode: String, line: String, reference_root: String) raises -> Int:
    if mode == "shell":
        return run_shell_prompt_payload_native(raw_command_payload(line), reference_root)
    if mode == "python":
        return run_python_prompt_payload_native(raw_command_payload(line), reference_root)
    if mode == "math":
        return run_math_prompt_payload_native(raw_command_payload(line), reference_root)
    if mode == "reta":
        return run_reta_arguments_native(
            _reta_child_arguments(shell_split(line)), reference_root
        )
    if mode == "fallback":
        var flags = List[String]()
        flags.append("-vi")
        flags.append("-language=english")
        flags.append("-befehl")
        return run_reta_prompt_fallback_arguments_native(
            flags, shell_split(line), reference_root
        )
    raise Error("unknown mode: " + mode)


def main() raises:
    var args = argv()
    if len(args) < 3:
        raise Error(
            "usage: prompt_external_commands_probe MODE RAW_LINE [REFERENCE_ROOT]"
        )
    var mode = String(args[1])
    var reference_root = "python_reference"
    if len(args) > 3:
        reference_root = String(args[3])
    var status = _run(mode, String(args[2]), reference_root)
    if status != 0:
        raise Error(mode + " child exited with status " + String(status))
