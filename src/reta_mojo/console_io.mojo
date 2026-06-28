"""Pure console and finite-section helpers from console_io.py.

Terminal probing, rich rendering and help-file I/O remain OS/file boundaries;
chunking, ordered uniqueness and visible text normalization are native.
"""

from std.collections import List, Set


@fieldwise_init
struct ConsoleContext(Copyable):
    var shell_width: Int
    var output_enabled: Bool
    var info_log: Bool


def default_console_context() -> ConsoleContext:
    return ConsoleContext(80, True, False)


def chunks_strings(values: List[String], size: Int) raises -> List[List[String]]:
    if size <= 0:
        raise Error("chunk size must be positive")
    var result = List[List[String]]()
    var index = 0
    while index < len(values):
        var chunk = List[String]()
        var end = min(index + size, len(values))
        while index < end:
            chunk.append(values[index])
            index += 1
        result.append(chunk^)
    return result^


def unique_everseen_strings(values: List[String]) -> List[String]:
    var seen = Set[String]()
    var result = List[String]()
    for index in range(len(values)):
        var value = values[index]
        if value not in seen:
            seen.add(value)
            result.append(value)
    return result^


def normalize_colored_cli_text(text: String) -> String:
    """Mirror ``' '.join(text.split())`` used by colored cli_output."""
    var words = text.split()
    var result = String()
    for index in range(len(words)):
        if index > 0:
            result += " "
        result += String(words[index])
    return result^


def debug_pair_text(label: String, value: String) -> String:
    return label + ": " + value


def should_emit(context: ConsoleContext) -> Bool:
    return context.output_enabled


def should_emit_debug(context: ConsoleContext) -> Bool:
    return context.output_enabled and context.info_log
