"""Native terminal geometry matching Python ``os.get_terminal_size`` semantics.

The terminal renderer must derive ``--breite=0`` from the current terminal,
not from a compile-time 80-column default.  Linux ``TIOCGWINSZ`` is queried on
stdout first, then stdin/stderr, with ``COLUMNS`` and finally 80 as fallbacks.
"""

from std.collections.string import atol
from std.ffi import c_int, c_ulong, external_call
from std.memory import stack_allocation
from std.os import getenv


comptime _TIOCGWINSZ = 0x5413


def _ioctl_terminal_columns(fd: Int) -> Int:
    var size = stack_allocation[4, UInt16]()
    size[0] = 0
    size[1] = 0
    size[2] = 0
    size[3] = 0
    var status = external_call["ioctl", c_int](
        c_int(fd), c_ulong(_TIOCGWINSZ), size
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
