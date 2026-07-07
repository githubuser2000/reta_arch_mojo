"""C-ABI entry points for the shared native prompt execution library.

The prompt ABI is intentionally narrow: thin starters pass a conventional
``argc``/``argv`` vector whose first owned element is the historical prompt
profile name (``rpb``, ``rp`` and friends).  The library returns a process
status code and never exposes Mojo ``String`` or collection values across the
shared-library boundary.
"""

from std.collections import List
from std.ffi import c_char, c_int
from std.memory import UnsafePointer
from reta_mojo.cli_arguments import owned_c_argv
from prompt_main import run_prompt_profile_from_args


comptime RETA_PROMPT_ABI_VERSION = 1


@export
def reta_prompt_abi_version() abi("C") -> c_int:
    return c_int(RETA_PROMPT_ABI_VERSION)


@export
def reta_prompt_entry(
    argc: c_int,
    values: UnsafePointer[
        UnsafePointer[c_char, MutUntrackedOrigin], MutUntrackedOrigin
    ],
) abi("C") -> c_int:
    try:
        var args = owned_c_argv(argc, values)
        if len(args) < 1:
            print("retaPrompt: Promptprofil fehlt")
            return c_int(2)
        var profile_name = args[0].copy()
        var startup_args = List[String]()
        for index in range(1, len(args)):
            startup_args.append(args[index].copy())
        run_prompt_profile_from_args(profile_name, startup_args)
        return c_int(0)
    except:
        print("retaPrompt: prompt library execution failed")
        return c_int(1)
