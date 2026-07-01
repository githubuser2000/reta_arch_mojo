"""Native-first launcher for the complete historical Reta command line.

Every argument vector is first checked by the conservative native ownership
predicate.  Fully owned invocations execute in the compiled Mojo table engine;
anything unknown or only partly ported is passed atomically to the bundled
Python reference through the explicit child-process adapter.  No CPython
runtime is embedded in this executable.
"""

from std.collections import List
from std.ffi import c_int, external_call
from std.os import getenv
from std.sys import argv
from reta_mojo.native_reta_cli import (
    native_reta_tokens_supported,
    run_native_reta,
)
from reta_mojo.native_cli_startup import native_cli_startup
from reta_mojo.native_cli_controls import normalize_native_cli_controls
from reta_mojo.prompt_external_commands import run_reta_arguments_native
from reta_mojo.resource_paths import csv_resource, reference_root



def main() raises:
    var raw = argv()
    var arguments = List[String]()
    for index in range(1, len(raw)):
        arguments.append(String(raw[index]))

    # Startup/help and the orthogonal -debug/-nichts control mains are
    # classified before table ownership.  The controls are removed only for a
    # fully native vector; an unknown combination still falls back atomically
    # with its original argv intact.
    var force_reference = getenv("RETA_FORCE_REFERENCE", "") == "1"
    var controls = normalize_native_cli_controls(arguments)
    if not force_reference:
        if controls.had_control and len(controls.tokens) == 0:
            print(controls.debug_prefix, end="")
            return
        var startup = native_cli_startup(controls.tokens)
        if startup.owned:
            print(controls.debug_prefix + startup.output, end="")
            return

    var csv_path = csv_resource("religion.csv")
    if (
        not force_reference
        and native_reta_tokens_supported(controls.tokens, csv_path)
    ):
        print(
            controls.debug_prefix
            + run_native_reta(controls.tokens, csv_path),
            end="",
        )
        return

    var status = run_reta_arguments_native(arguments, reference_root())
    # ``main`` cannot return an integer status.  Terminate through the stable
    # C runtime boundary so the compatibility executable mirrors its child.
    _ = external_call["exit", NoneType](c_int(status))
