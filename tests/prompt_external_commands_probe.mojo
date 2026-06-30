from std.sys import argv
from reta_mojo.prompt_external_commands import (
    run_math_prompt_line_native,
    run_python_prompt_line_native,
    run_shell_prompt_line_native,
)


def _run(mode: String, line: String) raises -> Int:
    if mode == "shell":
        return run_shell_prompt_line_native(line)
    if mode == "python":
        return run_python_prompt_line_native(line)
    if mode == "math":
        return run_math_prompt_line_native(line)
    raise Error("unknown mode: " + mode)


def main() raises:
    var args = argv()
    if len(args) < 3:
        raise Error("usage: prompt_external_commands_probe MODE RAW_LINE")
    var mode = String(args[1])
    var status = _run(mode, String(args[2]))
    if status != 0:
        raise Error(mode + " child exited with status " + String(status))
