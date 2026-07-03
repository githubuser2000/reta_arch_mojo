"""Owned command-line vectors shared by executables and C-ABI libraries."""

from std.collections import List
from std.ffi import CStringSlice, c_char, c_int
from std.memory import UnsafePointer
from std.sys import argv


def owned_process_argv() -> List[String]:
    """Copy the process argument vector into owned UTF-8 strings."""
    var source = argv()
    var result = List[String]()
    for index in range(len(source)):
        result.append(String(source[index]))
    return result^


def owned_c_argv(
    argc: c_int,
    values: UnsafePointer[
        UnsafePointer[c_char, MutUntrackedOrigin], MutUntrackedOrigin
    ],
) -> List[String]:
    """Copy a conventional C ``argc``/``argv`` vector into Mojo strings."""
    var result = List[String]()
    for index in range(Int(argc)):
        var item = CStringSlice(unsafe_from_ptr=values[index])
        result.append(String(item))
    return result^
