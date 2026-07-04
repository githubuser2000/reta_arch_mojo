"""Native thread-chunked table and number preparation for Reta.

This module ports the deterministic core of
``reta_architecture.parallel_execution``. Mutable column generation and shared
output boundaries remain serial. Pure row, cell and number transformations are
split into indexed chunks and run on Mojo CPU worker threads. Results are glued
back in source order; no Python, pickle, dynamic import, ``fork`` or pipe
boundary is involved. Legacy process-mode spellings are accepted as aliases for
the thread backend so existing command lines keep working.
"""

from std.algorithm import parallelize
from std.collections import Dict, List, Set
from std.collections.string import atol, ord
from std.os import getenv

from .arithmetic import factor_pairs
from .csv_table import CsvTable
from .execution_network import available_worker_count
from .number_theory import (
    is_prime_multiple,
    moon_number,
    prime_factors,
    prime_repeat,
)
from .types import IntPair


@fieldwise_init
struct ProcessorCoreCounts(Copyable):
    var physical: Int
    var virtual: Int
    var available: Int

    def default_workers(self) -> Int:
        return max(1, self.available)


@fieldwise_init
struct ParallelEnvironmentValues(Copyable):
    var parallel_present: Bool
    var parallel: String
    var mode_present: Bool
    var mode: String
    var workers: String
    var chunk_size: String
    var threshold: String
    var start_method: String


def default_parallel_environment_values() -> ParallelEnvironmentValues:
    return ParallelEnvironmentValues(
        False, String(), False, String(), String(), String(), String(), String()
    )


def parallel_environment_values(
    parallel: String = "",
    mode: String = "",
    workers: String = "",
    chunk_size: String = "",
    threshold: String = "",
    start_method: String = "",
    parallel_present: Bool = False,
    mode_present: Bool = False,
) -> ParallelEnvironmentValues:
    return ParallelEnvironmentValues(
        parallel_present,
        parallel,
        mode_present,
        mode,
        workers,
        chunk_size,
        threshold,
        start_method,
    )


@fieldwise_init
struct ParallelExecutionConfig(Copyable):
    var mode: String
    var workers: Int
    var chunk_size: Int
    var threshold: Int
    var start_method: String
    var source: String

    def resolved_workers(self) -> Int:
        return (
            self.workers if self.workers
            > 0 else processor_core_counts().default_workers()
        )

    def enabled_by_mode(self) -> Bool:
        return self.mode == "auto" or self.mode == "threads"

    def resolved_backend(self) -> String:
        if self.mode == "auto" or self.mode == "threads":
            return "threads"
        return "serial"

    def should_use_parallel(self, item_count: Int) -> Bool:
        return (
            self.enabled_by_mode()
            and self.resolved_workers() > 1
            and item_count >= self.threshold
            and self.chunk_size > 0
        )

    def should_use_threads(self, item_count: Int) -> Bool:
        return (
            self.resolved_backend() == "threads"
            and self.should_use_parallel(item_count)
        )

    def should_use_processes(self, item_count: Int) -> Bool:
        # Compatibility probe for older callers. Native Mojo no longer forks.
        _ = item_count
        return False


@fieldwise_init
struct ParallelArgvResult(Copyable):
    var argv: List[String]
    var config: ParallelExecutionConfig


@fieldwise_init
struct ParallelOperationStats(Copyable):
    var operation: String
    var workers: Int
    var chunks: Int
    var item_count: Int
    var mode: String
    var config: ParallelExecutionConfig


@fieldwise_init
struct IndexedStringRow(Copyable):
    var index: Int
    var cells: List[String]


@fieldwise_init
struct DecodedKombiRow(Copyable):
    var index: Int
    var cells: List[String]
    var kombi_numbers: List[Int]


@fieldwise_init
struct IntListRecord(Copyable):
    var number: Int
    var values: List[Int]


@fieldwise_init
struct MoonNumberRecord(Copyable):
    var number: Int
    var bases: List[Int]
    var exponent_markers: List[Int]


@fieldwise_init
struct FactorPairRecord(Copyable):
    var number: Int
    var pairs: List[IntPair]


@fieldwise_init
struct ColumnWidth(Copyable):
    var column: Int
    var width: Int


@fieldwise_init
struct ColumnBucket(Copyable):
    var bucket_type: Int
    var positive: Set[Int]
    var negative: Set[Int]


@fieldwise_init
struct KombiJoinSelection(Copyable):
    var key: Int
    var row_numbers: List[Int]


@fieldwise_init
struct ReligionRowsResult(Copyable):
    var rows: List[IndexedStringRow]
    var stats: ParallelOperationStats


@fieldwise_init
struct KombiRowsResult(Copyable):
    var rows: List[DecodedKombiRow]
    var stats: ParallelOperationStats


@fieldwise_init
struct TableOperationResult(Copyable):
    var table: CsvTable
    var stats: ParallelOperationStats


@fieldwise_init
struct WidthOperationResult(Copyable):
    var widths: List[ColumnWidth]
    var stats: ParallelOperationStats


@fieldwise_init
struct IntListOperationResult(Copyable):
    var values: List[IntListRecord]
    var stats: ParallelOperationStats


@fieldwise_init
struct MoonOperationResult(Copyable):
    var values: List[MoonNumberRecord]
    var stats: ParallelOperationStats


@fieldwise_init
struct FactorPairOperationResult(Copyable):
    var values: List[FactorPairRecord]
    var stats: ParallelOperationStats


@fieldwise_init
struct NumberFilterResult(Copyable):
    var values: List[Int]
    var stats: ParallelOperationStats


@fieldwise_init
struct BucketOperationResult(Copyable):
    var buckets: List[ColumnBucket]
    var stats: ParallelOperationStats


@fieldwise_init
struct KombiJoinResult(Copyable):
    var selections: List[KombiJoinSelection]
    var tables: List[CsvTable]
    var stats: ParallelOperationStats


@fieldwise_init
struct ParallelExecutionBundle(Copyable):
    var config: ParallelExecutionConfig
    var processor_cores: ProcessorCoreCounts


def _normalized_mode(value: String) -> String:
    var mode = value.strip().lower()
    if (
        mode == ""
        or mode == "0"
        or mode == "off"
        or mode == "false"
        or mode == "no"
        or mode == "none"
        or mode == "serial"
        or mode == "single"
    ):
        return "off"
    if (
        mode == "1"
        or mode == "on"
        or mode == "true"
        or mode == "yes"
        or mode == "thread"
        or mode == "threads"
        or mode == "threaded"
        or mode == "parallel"
    ):
        return "threads"
    if (
        mode == "process"
        or mode == "processes"
        or mode == "multiprocess"
        or mode == "multiprocessing"
        or mode == "mp"
    ):
        # Legacy PyPy/CPython process-mode names now select Mojo threads.
        return "threads"
    if mode == "auto" or mode == "pypy" or mode == "pypy3":
        return "auto"
    return mode^


def _positive_int(value: String, fallback: Int) -> Int:
    var text = value.strip()
    if text.byte_length() == 0:
        return fallback
    var start = 0
    if ord(text[byte=0]) == 43:
        start = 1
    if start >= text.byte_length():
        return fallback
    for index in range(start, text.byte_length()):
        var code = ord(text[byte=index])
        if code < 48 or code > 57:
            return fallback
    var parsed = 0
    for index in range(start, text.byte_length()):
        parsed = parsed * 10 + ord(text[byte=index]) - 48
    return parsed if parsed > 0 else fallback


def make_parallel_config(
    mode: String = "auto",
    workers: Int = 0,
    chunk_size: Int = 64,
    threshold: Int = 128,
    start_method: String = "",
    source: String = "defaults",
) -> ParallelExecutionConfig:
    _ = start_method
    return ParallelExecutionConfig(
        _normalized_mode(mode),
        max(0, workers),
        chunk_size if chunk_size > 0 else 64,
        threshold if threshold > 0 else 128,
        String(),
        source,
    )


def parallel_config_from_environment_values(
    values: ParallelEnvironmentValues,
) -> ParallelExecutionConfig:
    var mode = String("auto")
    if values.mode_present:
        mode = values.mode.copy()
    elif values.parallel_present:
        mode = values.parallel.copy()
    var source = (
        "environment"
        if values.parallel_present or values.mode_present
        else "defaults"
    )
    return make_parallel_config(
        mode,
        _positive_int(values.workers.copy(), 0),
        _positive_int(values.chunk_size.copy(), 64),
        _positive_int(values.threshold.copy(), 128),
        values.start_method.copy(),
        source,
    )


def read_parallel_environment() -> ParallelEnvironmentValues:
    # ``getenv`` is a runtime effect. Keep it out of default-argument
    # expressions because Mojo 1.0 tries to evaluate those at compile time.
    var sentinel = "__RETA_ENV_UNSET_12C5AS__"
    var parallel_raw = String(getenv("RETA_PARALLEL", sentinel))
    var mode_raw = String(getenv("RETA_PARALLEL_MODE", sentinel))
    var parallel_present = parallel_raw != sentinel
    var mode_present = mode_raw != sentinel
    return ParallelEnvironmentValues(
        parallel_present,
        parallel_raw if parallel_present else String(),
        mode_present,
        mode_raw if mode_present else String(),
        String(getenv("RETA_PARALLEL_WORKERS", "")),
        String(getenv("RETA_PARALLEL_CHUNK_SIZE", "")),
        String(getenv("RETA_PARALLEL_THRESHOLD", "")),
        String(getenv("RETA_PARALLEL_START_METHOD", "")),
    )


def parallel_config_from_environment() -> ParallelExecutionConfig:
    return parallel_config_from_environment_values(read_parallel_environment())


def _linux_physical_cpu_count() raises -> Int:
    var file = open("/proc/cpuinfo", "r")
    var text = file.read()
    file.close()
    var pairs = Set[String]()
    var physical_id = String()
    var core_id = String()
    var processors = 0
    var lines = text.split("\n")
    for line_slice in lines:
        var line = String(line_slice).strip()
        if line.byte_length() == 0:
            if physical_id.byte_length() > 0 and core_id.byte_length() > 0:
                pairs.add(physical_id + ":" + core_id)
            physical_id = String()
            core_id = String()
        elif line.startswith("processor") and line.find(":") >= 0:
            processors += 1
        elif line.startswith("physical id") and line.find(":") >= 0:
            var pieces = line.split(":")
            if len(pieces) > 1:
                physical_id = String(String(pieces[1]).strip())
        elif line.startswith("core id") and line.find(":") >= 0:
            var pieces = line.split(":")
            if len(pieces) > 1:
                core_id = String(String(pieces[1]).strip())
    if physical_id.byte_length() > 0 and core_id.byte_length() > 0:
        pairs.add(physical_id + ":" + core_id)
    if len(pairs) > 0:
        return len(pairs)
    return max(1, processors)


def processor_core_counts() -> ProcessorCoreCounts:
    var virtual = max(1, available_worker_count())
    var physical = virtual
    try:
        physical = min(virtual, max(1, _linux_physical_cpu_count()))
    except:
        pass
    # ``get_nprocs`` reports online processors.  A future affinity-specific
    # implementation can lower ``available`` without changing the API.
    return ProcessorCoreCounts(physical, virtual, virtual)


def bootstrap_parallel_execution(
    config: ParallelExecutionConfig,
) -> ParallelExecutionBundle:
    return ParallelExecutionBundle(config.copy(), processor_core_counts())


def bootstrap_parallel_execution_from_environment() -> ParallelExecutionBundle:
    return bootstrap_parallel_execution(parallel_config_from_environment())


def _consume_value(argv: List[String], index: Int) -> Tuple[String, Int]:
    var next_index = index + 1
    if next_index < len(argv) and not argv[next_index].startswith("-"):
        return (argv[next_index].copy(), 1)
    return (String(), 0)


def extract_parallel_config_from_argv(
    argv: List[String],
    inherited: ParallelExecutionConfig,
) -> ParallelArgvResult:
    var clean = List[String]()
    var mode = inherited.mode.copy()
    var workers = inherited.workers
    var chunk_size = inherited.chunk_size
    var threshold = inherited.threshold
    var start_method = inherited.start_method.copy()
    var recognised = False
    var index = 0
    while index < len(argv):
        var arg = argv[index].strip()
        if arg == "--no-parallel":
            mode = "off"
            recognised = True
        elif arg == "--parallel":
            mode = "threads"
            recognised = True
        elif arg.startswith("--parallel="):
            mode = String(StringSlice(arg)[byte=11:])
            recognised = True
        elif (
            arg == "--parallel-workers"
            or arg == "--parallel-worker"
            or arg == "--parallel-prozesse"
        ):
            var consumed = _consume_value(argv, index)
            workers = _positive_int(consumed[0], workers)
            index += consumed[1]
            recognised = True
        elif (
            arg.startswith("--parallel-workers=")
            or arg.startswith("--parallel-worker=")
            or arg.startswith("--parallel-prozesse=")
        ):
            var pieces = arg.split("=")
            workers = _positive_int(String(pieces[len(pieces) - 1]), workers)
            recognised = True
        elif (
            arg == "--parallel-chunk-size"
            or arg == "--parallel-chunksize"
            or arg == "--parallel-chunk"
        ):
            var consumed = _consume_value(argv, index)
            chunk_size = _positive_int(consumed[0], chunk_size)
            index += consumed[1]
            recognised = True
        elif (
            arg.startswith("--parallel-chunk-size=")
            or arg.startswith("--parallel-chunksize=")
            or arg.startswith("--parallel-chunk=")
        ):
            var pieces = arg.split("=")
            chunk_size = _positive_int(
                String(pieces[len(pieces) - 1]), chunk_size
            )
            recognised = True
        elif arg == "--parallel-threshold" or arg == "--parallel-min-rows":
            var consumed = _consume_value(argv, index)
            threshold = _positive_int(consumed[0], threshold)
            index += consumed[1]
            recognised = True
        elif arg.startswith("--parallel-threshold=") or arg.startswith(
            "--parallel-min-rows="
        ):
            var pieces = arg.split("=")
            threshold = _positive_int(
                String(pieces[len(pieces) - 1]), threshold
            )
            recognised = True
        elif arg == "--parallel-start-method" or arg == "--parallel-start":
            var consumed = _consume_value(argv, index)
            start_method = consumed[0]
            index += consumed[1]
            recognised = True
        elif arg.startswith("--parallel-start-method=") or arg.startswith(
            "--parallel-start="
        ):
            var pieces = arg.split("=")
            start_method = String(pieces[len(pieces) - 1])
            recognised = True
        else:
            clean.append(String(arg))
        index += 1
    var source = "argv" if recognised else inherited.source.copy()
    return ParallelArgvResult(
        clean^,
        make_parallel_config(
            mode, workers, chunk_size, threshold, start_method, source
        ),
    )


def extract_parallel_config_from_environment_argv(
    argv: List[String],
) -> ParallelArgvResult:
    return extract_parallel_config_from_argv(
        argv, parallel_config_from_environment()
    )


def _stats(
    operation: String,
    workers: Int,
    chunks: Int,
    item_count: Int,
    mode: String,
    config: ParallelExecutionConfig,
) -> ParallelOperationStats:
    return ParallelOperationStats(
        operation, workers, chunks, item_count, mode, config.copy()
    )


def _copy_ints(values: List[Int]) -> List[Int]:
    var result = List[Int]()
    for value in values:
        result.append(value)
    return result^


def _copy_strings(values: List[String]) -> List[String]:
    var result = List[String]()
    for value in values:
        result.append(value.copy())
    return result^


def _copy_row(row: IndexedStringRow) -> IndexedStringRow:
    return IndexedStringRow(row.index, _copy_strings(row.cells))


def _sort_indexed_rows(mut values: List[IndexedStringRow]) -> None:
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and values[position].index > key.index:
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key^


def _sort_kombi_rows(mut values: List[DecodedKombiRow]) -> None:
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and values[position].index > key.index:
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key^


def _sort_int_list_records(mut values: List[IntListRecord]) -> None:
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and values[position].number > key.number:
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key^


def _sort_moon_records(mut values: List[MoonNumberRecord]) -> None:
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and values[position].number > key.number:
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key^


def _sort_factor_pair_records(mut values: List[FactorPairRecord]) -> None:
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and values[position].number > key.number:
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key^


def _sort_buckets(mut values: List[ColumnBucket]) -> None:
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and values[position].bucket_type > key.bucket_type:
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key^


def _sort_unique_ints(mut values: List[Int]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key
    if len(values) < 2:
        return
    var write = 1
    for read_index in range(1, len(values)):
        if values[read_index] != values[write - 1]:
            values[write] = values[read_index]
            write += 1
    while len(values) > write:
        _ = values.pop()


def _html_escape(text: String) -> String:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&#x27;")
    )


def _hex_value(code: Int) -> Int:
    if code >= 48 and code <= 57:
        return code - 48
    if code >= 65 and code <= 70:
        return code - 55
    if code >= 97 and code <= 102:
        return code - 87
    return -1


def _json_string_for_key(json: String, key: String) raises -> String:
    var needle = '"' + key.replace("\\", "\\\\").replace('"', '\\"') + '":'
    var position = json.find(needle)
    if position < 0:
        raise Error("missing religion cell JSON key: " + key)
    # String byte indexing is only legal on UTF-8 codepoint boundaries.  JSON
    # syntax is ASCII, but values contain Korean, Chinese and Vietnamese text;
    # scan raw bytes and only create StringSlice values at ASCII delimiters.
    var bytes = json.as_bytes()
    var cursor = position + needle.byte_length()
    while cursor < len(bytes) and (
        Int(bytes[cursor]) == 32 or Int(bytes[cursor]) == 9
    ):
        cursor += 1
    if cursor >= len(bytes) or Int(bytes[cursor]) != 34:
        raise Error("religion cell JSON value is not a string")
    cursor += 1
    var result = String()
    var chunk_start = cursor
    while cursor < len(bytes):
        var code = Int(bytes[cursor])
        if code == 34:
            if cursor > chunk_start:
                result += String(StringSlice(json)[byte=chunk_start:cursor])
            return result^
        if code != 92:
            cursor += 1
            continue
        if cursor > chunk_start:
            result += String(StringSlice(json)[byte=chunk_start:cursor])
        cursor += 1
        if cursor >= len(bytes):
            raise Error("truncated religion cell JSON escape")
        var escaped = Int(bytes[cursor])
        if escaped == 34 or escaped == 47 or escaped == 92:
            result += chr(escaped)
            cursor += 1
        elif escaped == 98:
            result += chr(8)
            cursor += 1
        elif escaped == 102:
            result += chr(12)
            cursor += 1
        elif escaped == 110:
            result += "\n"
            cursor += 1
        elif escaped == 114:
            result += "\r"
            cursor += 1
        elif escaped == 116:
            result += "\t"
            cursor += 1
        elif escaped == 117:
            if cursor + 4 >= len(bytes):
                raise Error("truncated unicode JSON escape")
            var value = 0
            for offset in range(1, 5):
                var digit = _hex_value(Int(bytes[cursor + offset]))
                if digit < 0:
                    raise Error("invalid unicode JSON escape")
                value = value * 16 + digit
            result += chr(value)
            cursor += 5
        else:
            raise Error("unsupported religion cell JSON escape")
        chunk_start = cursor
    raise Error("unterminated religion cell JSON string")


def decode_religion_cell(cell: String, output_kind: String) raises -> String:
    if not (cell.startswith("|{") and cell.endswith("}|")):
        return _html_escape(cell) if output_kind == "html" else cell.copy()
    var json = String(StringSlice(cell)[byte=1:-1])
    if output_kind == "bbcode":
        return _json_string_for_key(json, "bbcode")
    if output_kind == "html":
        return _json_string_for_key(json, "html")
    return _json_string_for_key(json, "")


def decode_religion_rows_serial(
    rows: List[IndexedStringRow], output_kind: String
) raises -> List[IndexedStringRow]:
    var result = List[IndexedStringRow]()
    for row in rows:
        var cells = List[String]()
        for cell in row.cells:
            cells.append(decode_religion_cell(cell, output_kind))
        result.append(IndexedStringRow(row.index, cells^))
    _sort_indexed_rows(result)
    return result^


def _parse_kombi_number_into(text: String, mut values: List[Int]) raises:
    var number = text.strip()
    if (
        number.byte_length() > 2
        and number.startswith("(")
        and number.endswith(")")
    ):
        _parse_kombi_number_into(String(StringSlice(number)[byte=1:-1]), values)
        return
    var slash = number.find("/")
    if number.byte_length() > 2 and slash >= 0:
        _parse_kombi_number_into(
            String(StringSlice(number)[byte=:slash]), values
        )
        _parse_kombi_number_into(
            String(StringSlice(number)[byte = slash + 1 :]), values
        )
        return
    var start = 0
    if number.byte_length() > 0 and (
        ord(number[byte=0]) == 43 or ord(number[byte=0]) == 45
    ):
        start = 1
    if start >= number.byte_length():
        raise Error("invalid kombi number: " + number)
    for index in range(start, number.byte_length()):
        var code = ord(number[byte=index])
        if code < 48 or code > 57:
            raise Error("invalid kombi number: " + number)
    values.append(abs(atol(number)))


def parse_kombi_number(text: String) raises -> List[Int]:
    var result = List[Int]()
    _parse_kombi_number_into(text, result)
    return result^


def decode_kombi_rows_serial(
    rows: List[IndexedStringRow],
) raises -> List[DecodedKombiRow]:
    var result = List[DecodedKombiRow]()
    for source in rows:
        var cells = _copy_strings(source.cells)
        if len(cells) > 0:
            var label = cells[0].strip()
            for column in range(1, len(cells)):
                if (
                    cells[column].strip().byte_length() > 0
                    and label.byte_length() > 0
                ):
                    cells[column] = (
                        "("
                        + cells[0]
                        + ") "
                        + cells[column]
                        + " ("
                        + cells[0]
                        + ")"
                    )
        var numbers = List[Int]()
        if len(cells) > 0 and source.index > 0:
            var pieces = cells[0].split("|")
            for piece in pieces:
                var parsed = parse_kombi_number(String(piece))
                for value in parsed:
                    numbers.append(value)
        result.append(DecodedKombiRow(source.index, cells^, numbers^))
    _sort_kombi_rows(result)
    return result^


def select_columns_serial(
    table: CsvTable, one_based_columns: List[Int]
) -> CsvTable:
    if len(one_based_columns) == 0:
        return table.copy()
    var rows = List[List[String]]()
    for source in table.rows:
        var row = List[String]()
        for column in one_based_columns:
            var index = column - 1
            if index >= 0 and index < len(source):
                row.append(source[index])
        rows.append(row^)
    return CsvTable(rows^, len(one_based_columns))


def max_cell_text_len_serial(
    table: List[List[List[String]]], fragment_indexes: List[Int]
) -> List[ColumnWidth]:
    var maximum_columns = 0
    for row in table:
        maximum_columns = max(maximum_columns, len(row))
    var widths = List[Int]()
    for _ in range(maximum_columns):
        widths.append(-1)
    for row in table:
        for column in range(len(row)):
            for fragment_index in fragment_indexes:
                if fragment_index >= 0 and fragment_index < len(row[column]):
                    widths[column] = max(
                        widths[column],
                        row[column][fragment_index].count_codepoints(),
                    )
    var result = List[ColumnWidth]()
    for column in range(len(widths)):
        if widths[column] >= 0:
            result.append(ColumnWidth(column, widths[column]))
    return result^


def moon_numbers_serial(numbers: List[Int]) -> List[MoonNumberRecord]:
    var result = List[MoonNumberRecord]()
    for number in numbers:
        var moon = moon_number(number)
        result.append(MoonNumberRecord(number, moon[0].copy(), moon[1].copy()))
    _sort_moon_records(result)
    return result^


def prime_factors_serial(numbers: List[Int]) -> List[IntListRecord]:
    var result = List[IntListRecord]()
    for number in numbers:
        result.append(IntListRecord(number, prime_factors(number)))
    _sort_int_list_records(result)
    return result^


def _mixed_prime_exponents(number: Int) -> Bool:
    var grouped = prime_repeat(prime_factors(number))
    var has_one = False
    var has_other = False
    for pair in grouped:
        if pair.second == 1:
            has_one = True
        else:
            has_other = True
    return has_one and has_other


def filter_numbers_serial(
    numbers: List[Int],
    mode: String,
    criteria: List[Int] = List[Int](),
    modulo_remainder: Int = 0,
    want_moon: Bool = True,
) -> List[Int]:
    var result = List[Int]()
    for number in numbers:
        var selected = False
        if mode == "sonne_mit_mondanteil":
            selected = _mixed_prime_exponents(number)
        elif mode == "prime_multiples":
            selected = is_prime_multiple(number, criteria)
        elif mode == "ordinary_multiples":
            for divisor in criteria:
                if divisor != 0 and number % divisor == 0:
                    selected = True
                    break
        elif mode == "modulo":
            if len(criteria) > 0 and criteria[0] != 0:
                selected = number % criteria[0] == modulo_remainder
        elif mode == "moon":
            selected = (len(moon_number(number)[0]) > 0) == want_moon
        if selected:
            result.append(number)
    _sort_unique_ints(result)
    return result^


def factor_pairs_serial(
    numbers: List[Int], include_one: Bool = True
) -> List[FactorPairRecord]:
    var result = List[FactorPairRecord]()
    for number in numbers:
        result.append(
            FactorPairRecord(number, factor_pairs(number, include_one))
        )
    _sort_factor_pair_records(result)
    return result^


def normalize_column_buckets_serial(
    buckets: List[ColumnBucket],
) -> List[ColumnBucket]:
    var result = List[ColumnBucket]()
    for bucket in buckets:
        var positive = Set[Int]()
        for value in bucket.positive:
            if value not in bucket.negative:
                positive.add(value)
        result.append(ColumnBucket(bucket.bucket_type, positive^, Set[Int]()))
    _sort_buckets(result)
    return result^


def prepare_kombi_join_tables_serial(
    selections: List[KombiJoinSelection], source: CsvTable
) -> Tuple[List[KombiJoinSelection], List[CsvTable]]:
    var kept = List[KombiJoinSelection]()
    var tables = List[CsvTable]()
    for selection in selections:
        var rows = List[List[String]]()
        for row_number in selection.row_numbers:
            if row_number >= 0 and row_number < len(source.rows):
                rows.append(source.rows[row_number].copy())
        if len(rows) > 0:
            kept.append(
                KombiJoinSelection(
                    selection.key, _copy_ints(selection.row_numbers)
                )
            )
            tables.append(CsvTable(rows^, source.maximum_columns))
    return (kept^, tables^)


def processor_core_counts_snapshot_json(counts: ProcessorCoreCounts) -> String:
    return (
        '{"physical":'
        + String(counts.physical)
        + ',"virtual":'
        + String(counts.virtual)
        + ',"available":'
        + String(counts.available)
        + ',"default_workers":'
        + String(counts.default_workers())
        + "}"
    )


def parallel_config_snapshot_json(config: ParallelExecutionConfig) -> String:
    var workers = String(config.workers) if config.workers > 0 else "null"
    var start = (
        '"' + config.start_method + '"' if config.start_method.byte_length()
        > 0 else "null"
    )
    return (
        '{"class":"ParallelExecutionConfig","mode":"'
        + config.mode
        + '","enabled_by_mode":'
        + ("true" if config.enabled_by_mode() else "false")
        + ',"resolved_backend":"'
        + config.resolved_backend()
        + '"'
        + ',"workers":'
        + workers
        + ',"resolved_workers":'
        + String(config.resolved_workers())
        + ',"chunk_size":'
        + String(config.chunk_size)
        + ',"threshold":'
        + String(config.threshold)
        + ',"start_method":'
        + start
        + ',"runtime":"Mojo","source":"'
        + config.source
        + '","processor_cores":'
        + processor_core_counts_snapshot_json(processor_core_counts())
        + "}"
    )


def parallel_execution_bundle_snapshot_json(
    bundle: ParallelExecutionBundle,
) -> String:
    return (
        '{"class":"ParallelExecutionBundle","strategy":"thread_only_chunked_table_work",'
        + '"execution_network":"reta_mojo.execution_network.ExecutionNetworkBundle",'
        + '"config":'
        + parallel_config_snapshot_json(bundle.config)
        + ',"processor_cores":'
        + processor_core_counts_snapshot_json(bundle.processor_cores)
        + ',"morphisms":["extract_parallel_config_from_argv",'
        + '"decode_religion_rows_threaded","decode_kombi_rows_threaded",'
        + '"select_columns_threaded","max_cell_text_len_threaded",'
        + '"prepare_kombi_join_tables_threaded","moon_numbers_threaded",'
        + '"prime_factors_threaded","filter_numbers_threaded",'
        + '"factor_pairs_threaded","normalize_column_buckets_threaded"],'
        + '"default_policy":"auto_threads_legacy_process_aliases_to_threads",'
        + '"default_workers":'
        + String(bundle.processor_cores.default_workers())
        + "}"
    )


# ---------------------------------------------------------------------------
# Native typed thread chunks
# ---------------------------------------------------------------------------


def _chunk_count(item_count: Int, chunk_size: Int) -> Int:
    if item_count <= 0:
        return 0
    return (item_count + chunk_size - 1) // chunk_size


def _use_parallel_chunks(
    item_count: Int, config: ParallelExecutionConfig
) -> Bool:
    return (
        config.should_use_threads(item_count)
        and _chunk_count(item_count, config.chunk_size) > 1
    )


def _raise_thread_errors(errors: List[String], operation: String) raises:
    for slot in range(len(errors)):
        if errors[slot].byte_length() > 0:
            raise Error(
                "native "
                + operation
                + " thread "
                + String(slot)
                + " failed: "
                + errors[slot]
            )


def _chunk_indexed_rows(
    rows: List[IndexedStringRow], start: Int, end: Int
) -> List[IndexedStringRow]:
    var chunk = List[IndexedStringRow]()
    for index in range(start, end):
        chunk.append(_copy_row(rows[index]))
    return chunk^


def _chunk_ints(values: List[Int], start: Int, end: Int) -> List[Int]:
    var chunk = List[Int]()
    for index in range(start, end):
        chunk.append(values[index])
    return chunk^


def _chunk_csv_table(table: CsvTable, start: Int, end: Int) -> CsvTable:
    var rows = List[List[String]]()
    for index in range(start, end):
        rows.append(table.rows[index].copy())
    return CsvTable(rows^, table.maximum_columns)


def _chunk_fragment_table(
    table: List[List[List[String]]], start: Int, end: Int
) -> List[List[List[String]]]:
    var rows = List[List[List[String]]]()
    for row_index in range(start, end):
        var row = List[List[String]]()
        for cell in table[row_index]:
            row.append(cell.copy())
        rows.append(row^)
    return rows^


def _chunk_buckets(
    buckets: List[ColumnBucket], start: Int, end: Int
) -> List[ColumnBucket]:
    var result = List[ColumnBucket]()
    for index in range(start, end):
        result.append(buckets[index].copy())
    return result^


def _chunk_selections(
    selections: List[KombiJoinSelection], start: Int, end: Int
) -> List[KombiJoinSelection]:
    var result = List[KombiJoinSelection]()
    for index in range(start, end):
        result.append(selections[index].copy())
    return result^


@fieldwise_init
struct _KombiJoinChunk(Copyable):
    var selections: List[KombiJoinSelection]
    var tables: List[CsvTable]


def decode_religion_rows_threaded(
    rows: List[IndexedStringRow],
    output_kind: String,
    config: ParallelExecutionConfig,
) raises -> ReligionRowsResult:
    var item_count = len(rows)
    if not _use_parallel_chunks(item_count, config):
        return ReligionRowsResult(
            decode_religion_rows_serial(rows, output_kind),
            _stats(
                "decode_religion_rows",
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[List[IndexedStringRow]]()
    var errors = List[String]()
    for _ in range(chunks):
        chunk_results.append(List[IndexedStringRow]())
        errors.append(String())

    @parameter
    def worker(chunk_index: Int):
        try:
            var start = chunk_index * config.chunk_size
            var end = min(item_count, start + config.chunk_size)
            chunk_results[chunk_index] = decode_religion_rows_serial(
                _chunk_indexed_rows(rows, start, end), output_kind
            )
        except error:
            errors[chunk_index] = String(error)

    parallelize[worker](chunks, workers)
    _raise_thread_errors(errors, "decode_religion_rows")
    var decoded = List[IndexedStringRow]()
    for chunk in chunk_results:
        for row in chunk:
            decoded.append(row.copy())
    _sort_indexed_rows(decoded)
    return ReligionRowsResult(
        decoded^,
        _stats(
            "decode_religion_rows",
            workers,
            chunks,
            item_count,
            "threads",
            config,
        ),
    )


def decode_kombi_rows_threaded(
    rows: List[IndexedStringRow], config: ParallelExecutionConfig
) raises -> KombiRowsResult:
    var item_count = len(rows)
    if not _use_parallel_chunks(item_count, config):
        return KombiRowsResult(
            decode_kombi_rows_serial(rows),
            _stats(
                "decode_kombi_rows",
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[List[DecodedKombiRow]]()
    var errors = List[String]()
    for _ in range(chunks):
        chunk_results.append(List[DecodedKombiRow]())
        errors.append(String())

    @parameter
    def worker(chunk_index: Int):
        try:
            var start = chunk_index * config.chunk_size
            var end = min(item_count, start + config.chunk_size)
            chunk_results[chunk_index] = decode_kombi_rows_serial(
                _chunk_indexed_rows(rows, start, end)
            )
        except error:
            errors[chunk_index] = String(error)

    parallelize[worker](chunks, workers)
    _raise_thread_errors(errors, "decode_kombi_rows")
    var decoded = List[DecodedKombiRow]()
    for chunk in chunk_results:
        for row in chunk:
            decoded.append(row.copy())
    _sort_kombi_rows(decoded)
    return KombiRowsResult(
        decoded^,
        _stats(
            "decode_kombi_rows", workers, chunks, item_count, "threads", config
        ),
    )


def moon_numbers_threaded(
    numbers: List[Int], config: ParallelExecutionConfig
) raises -> MoonOperationResult:
    var item_count = len(numbers)
    if not _use_parallel_chunks(item_count, config):
        return MoonOperationResult(
            moon_numbers_serial(numbers),
            _stats(
                "moon_numbers",
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[List[MoonNumberRecord]]()
    for _ in range(chunks):
        chunk_results.append(List[MoonNumberRecord]())

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * config.chunk_size
        var end = min(item_count, start + config.chunk_size)
        chunk_results[chunk_index] = moon_numbers_serial(
            _chunk_ints(numbers, start, end)
        )

    parallelize[worker](chunks, workers)
    var records = List[MoonNumberRecord]()
    for chunk in chunk_results:
        for value in chunk:
            records.append(value.copy())
    _sort_moon_records(records)
    return MoonOperationResult(
        records^,
        _stats("moon_numbers", workers, chunks, item_count, "threads", config),
    )


def prime_factors_threaded(
    numbers: List[Int], config: ParallelExecutionConfig
) raises -> IntListOperationResult:
    var item_count = len(numbers)
    if not _use_parallel_chunks(item_count, config):
        return IntListOperationResult(
            prime_factors_serial(numbers),
            _stats(
                "prime_factors",
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[List[IntListRecord]]()
    for _ in range(chunks):
        chunk_results.append(List[IntListRecord]())

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * config.chunk_size
        var end = min(item_count, start + config.chunk_size)
        chunk_results[chunk_index] = prime_factors_serial(
            _chunk_ints(numbers, start, end)
        )

    parallelize[worker](chunks, workers)
    var records = List[IntListRecord]()
    for chunk in chunk_results:
        for value in chunk:
            records.append(value.copy())
    _sort_int_list_records(records)
    return IntListOperationResult(
        records^,
        _stats("prime_factors", workers, chunks, item_count, "threads", config),
    )


def filter_numbers_threaded(
    numbers: List[Int],
    mode: String,
    criteria: List[Int],
    modulo_remainder: Int,
    want_moon: Bool,
    config: ParallelExecutionConfig,
) raises -> NumberFilterResult:
    var item_count = len(numbers)
    if not _use_parallel_chunks(item_count, config):
        return NumberFilterResult(
            filter_numbers_serial(
                numbers, mode, criteria, modulo_remainder, want_moon
            ),
            _stats(
                "filter_numbers:" + mode,
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[List[Int]]()
    for _ in range(chunks):
        chunk_results.append(List[Int]())

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * config.chunk_size
        var end = min(item_count, start + config.chunk_size)
        chunk_results[chunk_index] = filter_numbers_serial(
            _chunk_ints(numbers, start, end),
            mode,
            criteria,
            modulo_remainder,
            want_moon,
        )

    parallelize[worker](chunks, workers)
    var values = List[Int]()
    for chunk in chunk_results:
        for value in chunk:
            values.append(value)
    _sort_unique_ints(values)
    return NumberFilterResult(
        values^,
        _stats(
            "filter_numbers:" + mode,
            workers,
            chunks,
            item_count,
            "threads",
            config,
        ),
    )


def factor_pairs_threaded(
    numbers: List[Int], include_one: Bool, config: ParallelExecutionConfig
) raises -> FactorPairOperationResult:
    var item_count = len(numbers)
    if not _use_parallel_chunks(item_count, config):
        return FactorPairOperationResult(
            factor_pairs_serial(numbers, include_one),
            _stats(
                "factor_pairs",
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[List[FactorPairRecord]]()
    for _ in range(chunks):
        chunk_results.append(List[FactorPairRecord]())

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * config.chunk_size
        var end = min(item_count, start + config.chunk_size)
        chunk_results[chunk_index] = factor_pairs_serial(
            _chunk_ints(numbers, start, end), include_one
        )

    parallelize[worker](chunks, workers)
    var records = List[FactorPairRecord]()
    for chunk in chunk_results:
        for value in chunk:
            records.append(value.copy())
    _sort_factor_pair_records(records)
    return FactorPairOperationResult(
        records^,
        _stats("factor_pairs", workers, chunks, item_count, "threads", config),
    )


def select_columns_threaded(
    table: CsvTable,
    one_based_columns: List[Int],
    config: ParallelExecutionConfig,
) raises -> TableOperationResult:
    var item_count = len(table.rows)
    if not _use_parallel_chunks(item_count, config):
        return TableOperationResult(
            select_columns_serial(table, one_based_columns),
            _stats(
                "select_columns",
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[CsvTable]()
    for _ in range(chunks):
        chunk_results.append(CsvTable(List[List[String]](), 0))

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * config.chunk_size
        var end = min(item_count, start + config.chunk_size)
        chunk_results[chunk_index] = select_columns_serial(
            _chunk_csv_table(table, start, end), one_based_columns
        )

    parallelize[worker](chunks, workers)
    var rows = List[List[String]]()
    for selected in chunk_results:
        for row in selected.rows:
            rows.append(row.copy())
    return TableOperationResult(
        CsvTable(rows^, len(one_based_columns)),
        _stats(
            "select_columns", workers, chunks, item_count, "threads", config
        ),
    )


def max_cell_text_len_threaded(
    table: List[List[List[String]]],
    fragment_indexes: List[Int],
    config: ParallelExecutionConfig,
) raises -> WidthOperationResult:
    var item_count = len(table)
    if not _use_parallel_chunks(item_count, config):
        return WidthOperationResult(
            max_cell_text_len_serial(table, fragment_indexes),
            _stats(
                "max_cell_text_len",
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[List[ColumnWidth]]()
    for _ in range(chunks):
        chunk_results.append(List[ColumnWidth]())

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * config.chunk_size
        var end = min(item_count, start + config.chunk_size)
        chunk_results[chunk_index] = max_cell_text_len_serial(
            _chunk_fragment_table(table, start, end), fragment_indexes
        )

    parallelize[worker](chunks, workers)
    var merged = List[Int]()
    for widths in chunk_results:
        for width in widths:
            while len(merged) <= width.column:
                merged.append(-1)
            merged[width.column] = max(merged[width.column], width.width)
    var result = List[ColumnWidth]()
    for column in range(len(merged)):
        if merged[column] >= 0:
            result.append(ColumnWidth(column, merged[column]))
    return WidthOperationResult(
        result^,
        _stats(
            "max_cell_text_len", workers, chunks, item_count, "threads", config
        ),
    )


def normalize_column_buckets_threaded(
    buckets: List[ColumnBucket], config: ParallelExecutionConfig
) raises -> BucketOperationResult:
    var item_count = 0
    for bucket in buckets:
        item_count += len(bucket.positive) + len(bucket.negative)
    var chunk_size = (
        1 if item_count >= config.threshold
        and len(buckets) > 1 else config.chunk_size
    )
    var chunks = _chunk_count(len(buckets), max(1, chunk_size))
    if (
        not config.should_use_threads(item_count)
        or len(buckets) <= 1
        or chunks <= 1
    ):
        return BucketOperationResult(
            normalize_column_buckets_serial(buckets),
            _stats(
                "normalize_column_buckets",
                1,
                1 if len(buckets) > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[List[ColumnBucket]]()
    for _ in range(chunks):
        chunk_results.append(List[ColumnBucket]())

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * chunk_size
        var end = min(len(buckets), start + chunk_size)
        chunk_results[chunk_index] = normalize_column_buckets_serial(
            _chunk_buckets(buckets, start, end)
        )

    parallelize[worker](chunks, workers)
    var result = List[ColumnBucket]()
    for chunk in chunk_results:
        for value in chunk:
            result.append(value.copy())
    _sort_buckets(result)
    return BucketOperationResult(
        result^,
        _stats(
            "normalize_column_buckets",
            workers,
            chunks,
            item_count,
            "threads",
            config,
        ),
    )


def prepare_kombi_join_tables_threaded(
    selections: List[KombiJoinSelection],
    source: CsvTable,
    config: ParallelExecutionConfig,
) raises -> KombiJoinResult:
    var item_count = len(selections)
    if not _use_parallel_chunks(item_count, config):
        var serial = prepare_kombi_join_tables_serial(selections, source)
        return KombiJoinResult(
            serial[0].copy(),
            serial[1].copy(),
            _stats(
                "prepare_kombi_join_tables",
                1,
                1 if item_count > 0 else 0,
                item_count,
                "serial",
                config,
            ),
        )
    var chunks = _chunk_count(item_count, config.chunk_size)
    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[_KombiJoinChunk]()
    for _ in range(chunks):
        chunk_results.append(
            _KombiJoinChunk(List[KombiJoinSelection](), List[CsvTable]())
        )

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * config.chunk_size
        var end = min(item_count, start + config.chunk_size)
        var result = prepare_kombi_join_tables_serial(
            _chunk_selections(selections, start, end), source
        )
        chunk_results[chunk_index] = _KombiJoinChunk(
            result[0].copy(), result[1].copy()
        )

    parallelize[worker](chunks, workers)
    var kept = List[KombiJoinSelection]()
    var tables = List[CsvTable]()
    for chunk in chunk_results:
        for value in chunk.selections:
            kept.append(value.copy())
        for table in chunk.tables:
            tables.append(table.copy())
    return KombiJoinResult(
        kept^,
        tables^,
        _stats(
            "prepare_kombi_join_tables",
            workers,
            chunks,
            item_count,
            "threads",
            config,
        ),
    )


# ---------------------------------------------------------------------------
# Legacy API aliases
# ---------------------------------------------------------------------------
# The Python reference and older Mojo callers used ``*_in_processes`` names.
# Keep those source-compatible, but route every call to the thread-only native
# implementation. No process is created by any alias below.


def decode_religion_rows_in_processes(
    rows: List[IndexedStringRow],
    output_kind: String,
    config: ParallelExecutionConfig,
) raises -> ReligionRowsResult:
    return decode_religion_rows_threaded(rows, output_kind, config)


def decode_kombi_rows_in_processes(
    rows: List[IndexedStringRow], config: ParallelExecutionConfig
) raises -> KombiRowsResult:
    return decode_kombi_rows_threaded(rows, config)


def moon_numbers_in_processes(
    numbers: List[Int], config: ParallelExecutionConfig
) raises -> MoonOperationResult:
    return moon_numbers_threaded(numbers, config)


def prime_factors_in_processes(
    numbers: List[Int], config: ParallelExecutionConfig
) raises -> IntListOperationResult:
    return prime_factors_threaded(numbers, config)


def filter_numbers_in_processes(
    numbers: List[Int],
    mode: String,
    criteria: List[Int],
    modulo_remainder: Int,
    want_moon: Bool,
    config: ParallelExecutionConfig,
) raises -> NumberFilterResult:
    return filter_numbers_threaded(
        numbers, mode, criteria, modulo_remainder, want_moon, config
    )


def factor_pairs_in_processes(
    numbers: List[Int], include_one: Bool, config: ParallelExecutionConfig
) raises -> FactorPairOperationResult:
    return factor_pairs_threaded(numbers, include_one, config)


def select_columns_in_processes(
    table: CsvTable,
    one_based_columns: List[Int],
    config: ParallelExecutionConfig,
) raises -> TableOperationResult:
    return select_columns_threaded(table, one_based_columns, config)


def max_cell_text_len_in_processes(
    table: List[List[List[String]]],
    fragment_indexes: List[Int],
    config: ParallelExecutionConfig,
) raises -> WidthOperationResult:
    return max_cell_text_len_threaded(table, fragment_indexes, config)


def normalize_column_buckets_in_processes(
    buckets: List[ColumnBucket], config: ParallelExecutionConfig
) raises -> BucketOperationResult:
    return normalize_column_buckets_threaded(buckets, config)


def prepare_kombi_join_tables_in_processes(
    selections: List[KombiJoinSelection],
    source: CsvTable,
    config: ParallelExecutionConfig,
) raises -> KombiJoinResult:
    return prepare_kombi_join_tables_threaded(selections, source, config)
