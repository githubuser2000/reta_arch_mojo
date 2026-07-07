"""C-ABI entry points for the shared native reta core library.

The core ABI is intentionally narrow: executable starters pass conventional
``argc``/``argv`` vectors, and the shared library returns a process status code.
No Mojo ``String`` or collection type crosses the dynamic-library boundary.
"""

from std.collections import List
from std.ffi import c_char, c_int
from std.memory import UnsafePointer
from reta_mojo.cli_arguments import owned_c_argv
from reta_mojo.grundstrukturen_html import (
    is_supported_grundstrukturen_language,
    render_grundstrukturen_html,
)
from reta_mojo.native_reta_cli import run_native_reta
from reta_mojo.resource_paths import csv_resource


comptime RETA_CORE_ABI_VERSION = 1


@export
def reta_core_abi_version() abi("C") -> c_int:
    return c_int(RETA_CORE_ABI_VERSION)


@export
def reta_core_reta_entry(
    argc: c_int,
    values: UnsafePointer[
        UnsafePointer[c_char, MutUntrackedOrigin], MutUntrackedOrigin
    ],
) abi("C") -> c_int:
    try:
        var args = owned_c_argv(argc, values)
        var tokens = List[String]()
        for index in range(1, len(args)):
            tokens.append(args[index].copy())
        print(run_native_reta(tokens, csv_resource("religion.csv")), end="")
        return c_int(0)
    except:
        print("reta: core library execution failed")
        return c_int(1)


@export
def reta_core_grundstrukhtml_entry(
    argc: c_int,
    values: UnsafePointer[
        UnsafePointer[c_char, MutUntrackedOrigin], MutUntrackedOrigin
    ],
) abi("C") -> c_int:
    try:
        var args = owned_c_argv(argc, values)
        var blank = len(args) > 1 and args[1] == "blank"
        var language = String()
        var selected_language = String()
        var debug = False

        for index in range(1, len(args)):
            var argument = args[index].copy()
            if argument == "-language=english" or argument == "-language=englisch":
                language = "english"
                selected_language = String(StringSlice(argument)[byte=10:])
            elif argument == "-language=deutsch" or argument == "-language=german":
                language = "german"
                selected_language = String(StringSlice(argument)[byte=10:])
            elif (
                argument == "-language=vietnamese"
                or argument == "-language=vietnamesisch"
                or argument == "-language=tiếngviệt"
            ):
                language = "vietnamese"
                selected_language = String(StringSlice(argument)[byte=10:])
            elif (
                argument == "-language=chinese"
                or argument == "-language=chinesisch"
                or argument == "-language=中國人"
            ):
                language = "chinese"
                selected_language = String(StringSlice(argument)[byte=10:])
            elif (
                argument == "-language=korean"
                or argument == "-language=koreanisch"
                or argument == "-language=한국인"
            ):
                language = "korean"
                selected_language = String(StringSlice(argument)[byte=10:])
            elif argument == "-debug":
                debug = True
            elif argument != "blank":
                continue

        if not is_supported_grundstrukturen_language(language):
            raise Error("nicht unterstützte Sprache: " + language)
        if debug:
            print("Sprachenwahl:", selected_language)
            if language == "" or language == "german":
                print("german")
            else:
                print("not german")
        print(render_grundstrukturen_html(blank, language), end="")
        return c_int(0)
    except:
        print("grundStrukHtml: core library execution failed")
        return c_int(1)
