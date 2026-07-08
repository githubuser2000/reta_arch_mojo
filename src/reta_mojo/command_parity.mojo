"""Native owner for the historical representative command-parity matrix.

The four command vectors originate in ``tests/test_command_parity.py``.  Their
canonical Python outputs are generated into immutable assets.  Runtime parity
then executes the native table kernel directly and needs neither a Python
interpreter nor a subprocess.
"""

from std.collections import List

from .csv_table import read_text_file
from .resource_paths import asset_resource
from .table_rendering import normalize_cell_whitespace
from .os_line_endings import split_os_lines


@fieldwise_init
struct CommandParityCase(Copyable, Equatable):
    var label: String
    var comparison_mode: String
    var output_asset: String
    var expected_sha256: String
    var tokens: List[String]


@fieldwise_init
struct CommandParitySnapshot(Copyable, Equatable):
    var cases: Int
    var exact_cases: Int
    var html_cases: Int
    var total_tokens: Int


def _parity_slice(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _parity_ascii_digit(code: Int) -> Bool:
    return code >= 48 and code <= 57


def _parity_sort(mut values: List[Int]):
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _sorted_p4_payload(payload: String) raises -> String:
    var pieces = payload.split(",")
    var values = List[Int]()
    for index in range(len(pieces)):
        var part = String(pieces[index])
        if part.byte_length() == 0:
            continue
        var bytes = part.as_bytes()
        for byte_index in range(len(bytes)):
            if not _parity_ascii_digit(Int(bytes[byte_index])):
                return payload
        values.append(atol(part))
    _parity_sort(values)
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += String(values[index])
    return result^


def normalize_command_parity_html(text: String) raises -> String:
    """Mirror the historical test's p4 ordering and whitespace normalizer."""
    var bytes = text.as_bytes()
    var result = String()
    var cursor = 0
    var index = 0
    while index + 3 <= len(bytes):
        if (
            Int(bytes[index]) == 112
            and Int(bytes[index + 1]) == 52
            and Int(bytes[index + 2]) == 95
        ):
            var payload_start = index + 3
            var payload_end = payload_start
            while payload_end < len(bytes):
                var code = Int(bytes[payload_end])
                if not (_parity_ascii_digit(code) or code == 44):
                    break
                payload_end += 1
            if payload_end > payload_start:
                result += _parity_slice(text, cursor, index)
                result += "p4_"
                result += _sorted_p4_payload(
                    _parity_slice(text, payload_start, payload_end)
                )
                cursor = payload_end
                index = payload_end
                continue
        index += 1
    result += _parity_slice(text, cursor, len(bytes))
    return normalize_cell_whitespace(result^)


def normalize_command_parity_output(
    text: String, comparison_mode: String
) raises -> String:
    if comparison_mode == "html":
        return normalize_command_parity_html(text)
    return text


def load_command_parity_cases(
    path: String = "",
) raises -> List[CommandParityCase]:
    var source_path = (
        path
        if path.byte_length() > 0
        else asset_resource("command_parity.tsv")
    )
    var cases = List[CommandParityCase]()
    var lines = split_os_lines(read_text_file(source_path))
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("label\t"):
            continue
        var fields = line.split("\t")
        if len(fields) < 5:
            raise Error(
                "invalid command parity row " + String(line_index + 1)
            )
        var tokens = List[String]()
        for field_index in range(4, len(fields)):
            tokens.append(String(fields[field_index]))
        cases.append(
            CommandParityCase(
                String(fields[0]),
                String(fields[1]),
                String(fields[2]),
                String(fields[3]),
                tokens^,
            )
        )
    return cases^


def expected_command_parity_output(
    entry: CommandParityCase,
) raises -> String:
    return read_text_file(
        asset_resource("command_parity/" + entry.output_asset)
    )


def command_parity_snapshot(
    cases: List[CommandParityCase],
) -> CommandParitySnapshot:
    var exact_cases = 0
    var html_cases = 0
    var total_tokens = 0
    for index in range(len(cases)):
        var entry = cases[index].copy()
        total_tokens += len(entry.tokens)
        if entry.comparison_mode == "html":
            html_cases += 1
        else:
            exact_cases += 1
    return CommandParitySnapshot(
        len(cases), exact_cases, html_cases, total_tokens
    )
