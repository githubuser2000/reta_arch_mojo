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
from reta_mojo.prompt_external_commands import run_reta_arguments_native
from reta_mojo.resource_paths import csv_resource, reference_root



def main() raises:
    var raw = argv()
    var arguments = List[String]()
    for index in range(1, len(raw)):
        arguments.append(String(raw[index]))

    # The empty historical invocation has additional help/default semantics
    # outside the native table subset.  Keep it on the reference path.  For
    # non-empty vectors the ownership predicate rejects every unknown section,
    # option, value pair, positional token and output mode before native work.
    var force_reference = getenv("RETA_FORCE_REFERENCE", "") == "1"
    var csv_path = csv_resource("religion.csv")
    if (
        not force_reference
        and len(arguments) > 0
        and native_reta_tokens_supported(arguments, csv_path)
    ):
        print(run_native_reta(arguments, csv_path), end="")
        return

    var status = run_reta_arguments_native(arguments, reference_root())
    # ``main`` cannot return an integer status.  Terminate through the stable
    # C runtime boundary so the compatibility executable mirrors its child.
    _ = external_call["exit", NoneType](c_int(status))
