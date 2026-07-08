"""Native OS line-ending helpers.

Mojo does not expose Python's ``os.linesep`` as a public constant in the
subset used by this project.  Keep the policy behind one helper so renderers
can stop baking literal LF into generated output.
"""

from std.collections import List
from std.os import getenv


def os_linesep() -> String:
    """Return the platform line separator, equivalent to Python os.linesep."""
    if String(getenv("OS", "")) == "Windows_NT":
        return "\r\n"
    return "\n"


def strip_line_endings(text: String) -> String:
    """Remove both LF and CR from markup fragments used inline."""
    return text.replace("\r", "").replace("\n", "")


def split_os_lines(text: String) -> List[String]:
    """Split text by OS line separator with CR/LF fallback tolerance.

    The primary separator is ``os_linesep()``.  The CR/LF normalization keeps
    repository assets readable when a checkout keeps LF files on another OS.
    """
    var normalized = text.replace("\r\n", "\n").replace("\r", "\n")
    var pieces = normalized.split("\n")
    var result = List[String]()
    for piece in pieces:
        result.append(String(piece))
    return result^


def has_line_ending(text: String) -> Bool:
    return text.find("\n") >= 0 or text.find("\r") >= 0


def endswith_line_ending(text: String) -> Bool:
    return text.endswith(os_linesep()) or text.endswith("\n") or text.endswith("\r")


def drop_one_trailing_line_ending(text: String) -> String:
    var sep = os_linesep()
    if text.endswith(sep):
        var end = text.byte_length() - sep.byte_length()
        return String(StringSlice(text)[byte=:end])
    if text.endswith("\n") or text.endswith("\r"):
        return String(StringSlice(text)[byte=:text.byte_length() - 1])
    return text
