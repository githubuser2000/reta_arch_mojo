"""C-ABI entry points for the consolidated native diagnostic library.

The public ABI deliberately accepts only conventional C ``argc``/``argv``
values and returns an integer status.  Mojo-owned strings and collections never
cross the shared-library boundary.
"""

from std.ffi import c_char, c_int
from std.memory import UnsafePointer
from reta_mojo.cli_arguments import owned_c_argv
from table_generation_main import run_table_generation_cli
from output_syntax_main import run_output_syntax_cli
from console_io_main import run_console_io_cli
from table_output_main import run_table_output_cli


comptime DIAGNOSTICS_ABI_VERSION = 1


@export
def reta_mojo_diagnostics_abi_version() abi("C") -> c_int:
    return c_int(DIAGNOSTICS_ABI_VERSION)


@export
def reta_mojo_table_generation_entry(
    argc: c_int,
    values: UnsafePointer[
        UnsafePointer[c_char, MutUntrackedOrigin], MutUntrackedOrigin
    ],
) abi("C") -> c_int:
    try:
        return c_int(run_table_generation_cli(owned_c_argv(argc, values)))
    except:
        print("reta-mojo-table-generation: diagnostic failed")
        return c_int(1)


@export
def reta_mojo_output_syntax_entry(
    argc: c_int,
    values: UnsafePointer[
        UnsafePointer[c_char, MutUntrackedOrigin], MutUntrackedOrigin
    ],
) abi("C") -> c_int:
    try:
        return c_int(run_output_syntax_cli(owned_c_argv(argc, values)))
    except:
        print("reta-mojo-output-syntax: diagnostic failed")
        return c_int(1)


@export
def reta_mojo_console_io_entry(
    argc: c_int,
    values: UnsafePointer[
        UnsafePointer[c_char, MutUntrackedOrigin], MutUntrackedOrigin
    ],
) abi("C") -> c_int:
    try:
        return c_int(run_console_io_cli(owned_c_argv(argc, values)))
    except:
        print("reta-mojo-console-io: diagnostic failed")
        return c_int(1)


@export
def reta_mojo_table_output_entry(
    argc: c_int,
    values: UnsafePointer[
        UnsafePointer[c_char, MutUntrackedOrigin], MutUntrackedOrigin
    ],
) abi("C") -> c_int:
    try:
        return c_int(run_table_output_cli(owned_c_argv(argc, values)))
    except:
        print("reta-mojo-table-output: diagnostic failed")
        return c_int(1)
