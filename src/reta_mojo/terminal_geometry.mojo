"""Native terminal geometry matching Python ``os.get_terminal_size`` semantics.

The terminal renderer must derive ``--breite=0`` from the current terminal,
not from a compile-time 80-column default. Linux/macOS ``TIOCGWINSZ`` is
queried through a small OS adapter on stdout first, then stdin/stderr, with
``COLUMNS`` and finally 80 as fallbacks.
"""

from std.collections.string import atol
from std.ffi import c_int, c_ulong, external_call
from std.memory import stack_allocation
from std.os import getenv
from std.sys.info import CompilationTarget


comptime _LINUX_TIOCGWINSZ = 0x5413
comptime _DARWIN_TIOCGWINSZ = 0x40087468


def terminal_geometry_backend() -> String:
    """Return the active native terminal-geometry backend name."""
    if CompilationTarget.is_linux():
        return "linux-ioctl"
    if CompilationTarget.is_macos():
        return "darwin-ioctl"
    return "environment-fallback"


def _terminal_size_request() -> UInt64:
    # TIOCGWINSZ is an OS ABI constant, not a universal POSIX number.
    if CompilationTarget.is_linux():
        return UInt64(_LINUX_TIOCGWINSZ)
    if CompilationTarget.is_macos():
        return UInt64(_DARWIN_TIOCGWINSZ)
    return UInt64(0)


def _ioctl_terminal_columns(fd: Int) -> Int:
    var request = _terminal_size_request()
    if request == 0:
        return 0
    var size = stack_allocation[4, UInt16]()
    size[0] = 0
    size[1] = 0
    size[2] = 0
    size[3] = 0
    var status = external_call["ioctl", c_int](
        c_int(fd), c_ulong(request), size
    )
    if Int(status) == 0 and Int(size[1]) > 0:
        return Int(size[1])
    return 0


def terminal_columns(fallback: Int = 80) -> Int:
    """Return visible terminal columns, or the historical 80-column fallback."""
    # Python's os.get_terminal_size() queries stdout by default.  The stdin
    # and stderr probes reproduce its historical ``stty`` fallback more
    # closely when output is attached differently.
    var columns = _ioctl_terminal_columns(1)
    if columns <= 0:
        columns = _ioctl_terminal_columns(0)
    if columns <= 0:
        columns = _ioctl_terminal_columns(2)
    if columns > 0:
        return columns

    var configured = String(getenv("COLUMNS", "").strip())
    if configured.byte_length() > 0:
        try:
            columns = atol(configured)
            if columns > 0:
                return columns
        except:
            pass
    return max(1, fallback)


def automatic_cell_width(columns: Int) -> Int:
    """Legacy ``--breite=0`` width: reserve seven terminal columns."""
    return max(1, columns - 7)


def effective_cell_width(requested: Int, columns: Int) -> Int:
    """Apply the legacy positive-width clamp and automatic-width semantics."""
    var automatic = automatic_cell_width(columns)
    return min(requested, automatic) if requested > 0 else automatic
