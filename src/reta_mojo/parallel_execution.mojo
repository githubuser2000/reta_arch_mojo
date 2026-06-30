"""Native threaded/process-chunked table and number preparation for Reta.

This module ports the deterministic core of
``reta_architecture.parallel_execution``. Mutable column generation and shared
output boundaries remain serial. Pure row, cell and number transformations are
split into indexed chunks. Native Mojo threads are the default because they can
share immutable table storage without a Python GIL or pipe serialization. Linux
``fork`` workers remain an explicit isolation backend. Results are always glued
back in source order; no Python, pickle or dynamic import boundary is involved.
"""

from std.algorithm import parallelize
from std.collections import Dict, List, Set
from std.collections.string import atol, ord
from std.ffi import c_int, c_char, external_call
from std.io import FileHandle
from std.memory import stack_allocation
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
struct ParallelExecutionConfig(Copyable):
    var mode: String
    var workers: Int
    var chunk_size: Int
    var threshold: Int
    var start_method: String
    var source: String

    def resolved_workers(self) -> Int:
        return self.workers if self.workers > 0 else processor_core_counts().default_workers()

    def enabled_by_mode(self) -> Bool:
        # Native Mojo has no Python GIL. ``auto`` therefore resolves to shared-
        # memory worker threads. ``processes`` remains available when crash or
        # address-space isolation is explicitly preferred.
        return (
            self.mode == "auto"
            or self.mode == "threads"
            or self.mode == "processes"
        )

    def resolved_backend(self) -> String:
        if self.mode == "processes":
            return "processes"
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
        return (
            self.resolved_backend() == "processes"
            and self.should_use_parallel(item_count)
        )


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
        return "processes"
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
    var start = start_method.strip().lower()
    if start == "default" or start == "none":
        start = ""
    return ParallelExecutionConfig(
        _normalized_mode(mode),
        max(0, workers),
        chunk_size if chunk_size > 0 else 64,
        threshold if threshold > 0 else 128,
        start^,
        source,
    )


def parallel_config_from_environment() -> ParallelExecutionConfig:
    var mode = String(getenv("RETA_PARALLEL_MODE", getenv("RETA_PARALLEL", "auto")))
    var workers = _positive_int(String(getenv("RETA_PARALLEL_WORKERS", "")), 0)
    var chunk_size = _positive_int(String(getenv("RETA_PARALLEL_CHUNK_SIZE", "")), 64)
    var threshold = _positive_int(String(getenv("RETA_PARALLEL_THRESHOLD", "")), 128)
    var start = String(getenv("RETA_PARALLEL_START_METHOD", ""))
    var source = "defaults"
    if String(getenv("RETA_PARALLEL", "")).byte_length() > 0 or String(getenv("RETA_PARALLEL_MODE", "")).byte_length() > 0:
        source = "environment"
    return make_parallel_config(mode, workers, chunk_size, threshold, start, source)


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
    config: ParallelExecutionConfig = parallel_config_from_environment(),
) -> ParallelExecutionBundle:
    return ParallelExecutionBundle(config.copy(), processor_core_counts())


def _consume_value(argv: List[String], index: Int) -> Tuple[String, Int]:
    var next_index = index + 1
    if next_index < len(argv) and not argv[next_index].startswith("-"):
        return (argv[next_index].copy(), 1)
    return (String(), 0)


def extract_parallel_config_from_argv(
    argv: List[String],
    inherited: ParallelExecutionConfig = parallel_config_from_environment(),
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
        elif arg == "--parallel-workers" or arg == "--parallel-worker" or arg == "--parallel-prozesse":
            var consumed = _consume_value(argv, index)
            workers = _positive_int(consumed[0], workers)
            index += consumed[1]
            recognised = True
        elif arg.startswith("--parallel-workers=") or arg.startswith("--parallel-worker=") or arg.startswith("--parallel-prozesse="):
            var pieces = arg.split("=")
            workers = _positive_int(String(pieces[len(pieces) - 1]), workers)
            recognised = True
        elif arg == "--parallel-chunk-size" or arg == "--parallel-chunksize" or arg == "--parallel-chunk":
            var consumed = _consume_value(argv, index)
            chunk_size = _positive_int(consumed[0], chunk_size)
            index += consumed[1]
            recognised = True
        elif arg.startswith("--parallel-chunk-size=") or arg.startswith("--parallel-chunksize=") or arg.startswith("--parallel-chunk="):
            var pieces = arg.split("=")
            chunk_size = _positive_int(String(pieces[len(pieces) - 1]), chunk_size)
            recognised = True
        elif arg == "--parallel-threshold" or arg == "--parallel-min-rows":
            var consumed = _consume_value(argv, index)
            threshold = _positive_int(consumed[0], threshold)
            index += consumed[1]
            recognised = True
        elif arg.startswith("--parallel-threshold=") or arg.startswith("--parallel-min-rows="):
            var pieces = arg.split("=")
            threshold = _positive_int(String(pieces[len(pieces) - 1]), threshold)
            recognised = True
        elif arg == "--parallel-start-method" or arg == "--parallel-start":
            var consumed = _consume_value(argv, index)
            start_method = consumed[0]
            index += consumed[1]
            recognised = True
        elif arg.startswith("--parallel-start-method=") or arg.startswith("--parallel-start="):
            var pieces = arg.split("=")
            start_method = String(pieces[len(pieces) - 1])
            recognised = True
        else:
            clean.append(String(arg))
        index += 1
    var source = "argv" if recognised else inherited.source.copy()
    return ParallelArgvResult(
        clean^,
        make_parallel_config(mode, workers, chunk_size, threshold, start_method, source),
    )


def _stats(
    operation: String,
    workers: Int,
    chunks: Int,
    item_count: Int,
    mode: String,
    config: ParallelExecutionConfig,
) -> ParallelOperationStats:
    return ParallelOperationStats(operation, workers, chunks, item_count, mode, config.copy())


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
    var cursor = position + needle.byte_length()
    while cursor < json.byte_length() and (ord(json[byte=cursor]) == 32 or ord(json[byte=cursor]) == 9):
        cursor += 1
    if cursor >= json.byte_length() or ord(json[byte=cursor]) != 34:
        raise Error("religion cell JSON value is not a string")
    cursor += 1
    var result = String()
    var chunk_start = cursor
    while cursor < json.byte_length():
        var code = ord(json[byte=cursor])
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
        if cursor >= json.byte_length():
            raise Error("truncated religion cell JSON escape")
        var escaped = ord(json[byte=cursor])
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
            if cursor + 4 >= json.byte_length():
                raise Error("truncated unicode JSON escape")
            var value = 0
            for offset in range(1, 5):
                var digit = _hex_value(ord(json[byte=cursor + offset]))
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
    if number.byte_length() > 2 and number.startswith("(") and number.endswith(")"):
        _parse_kombi_number_into(String(StringSlice(number)[byte=1:-1]), values)
        return
    var slash = number.find("/")
    if number.byte_length() > 2 and slash >= 0:
        _parse_kombi_number_into(String(StringSlice(number)[byte=:slash]), values)
        _parse_kombi_number_into(String(StringSlice(number)[byte=slash + 1:]), values)
        return
    var start = 0
    if number.byte_length() > 0 and (ord(number[byte=0]) == 43 or ord(number[byte=0]) == 45):
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


def decode_kombi_rows_serial(rows: List[IndexedStringRow]) raises -> List[DecodedKombiRow]:
    var result = List[DecodedKombiRow]()
    for source in rows:
        var cells = _copy_strings(source.cells)
        if len(cells) > 0:
            var label = cells[0].strip()
            for column in range(1, len(cells)):
                if cells[column].strip().byte_length() > 0 and label.byte_length() > 0:
                    cells[column] = "(" + cells[0] + ") " + cells[column] + " (" + cells[0] + ")"
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


def select_columns_serial(table: CsvTable, one_based_columns: List[Int]) -> CsvTable:
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
                    widths[column] = max(widths[column], row[column][fragment_index].count_codepoints())
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


def factor_pairs_serial(numbers: List[Int], include_one: Bool = True) -> List[FactorPairRecord]:
    var result = List[FactorPairRecord]()
    for number in numbers:
        result.append(FactorPairRecord(number, factor_pairs(number, include_one)))
    _sort_factor_pair_records(result)
    return result^


def normalize_column_buckets_serial(buckets: List[ColumnBucket]) -> List[ColumnBucket]:
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
            kept.append(KombiJoinSelection(selection.key, _copy_ints(selection.row_numbers)))
            tables.append(CsvTable(rows^, source.maximum_columns))
    return (kept^, tables^)


def processor_core_counts_snapshot_json(counts: ProcessorCoreCounts) -> String:
    return (
        '{"physical":' + String(counts.physical)
        + ',"virtual":' + String(counts.virtual)
        + ',"available":' + String(counts.available)
        + ',"default_workers":' + String(counts.default_workers()) + "}"
    )


def parallel_config_snapshot_json(config: ParallelExecutionConfig) -> String:
    var workers = String(config.workers) if config.workers > 0 else "null"
    var start = '"' + config.start_method + '"' if config.start_method.byte_length() > 0 else "null"
    return (
        '{"class":"ParallelExecutionConfig","mode":"' + config.mode
        + '","enabled_by_mode":' + ("true" if config.enabled_by_mode() else "false")
        + ',"resolved_backend":"' + config.resolved_backend() + '"'
        + ',"workers":' + workers
        + ',"resolved_workers":' + String(config.resolved_workers())
        + ',"chunk_size":' + String(config.chunk_size)
        + ',"threshold":' + String(config.threshold)
        + ',"start_method":' + start
        + ',"runtime":"Mojo","source":"' + config.source
        + '","processor_cores":' + processor_core_counts_snapshot_json(processor_core_counts()) + "}"
    )


def parallel_execution_bundle_snapshot_json(bundle: ParallelExecutionBundle) -> String:
    return (
        '{"class":"ParallelExecutionBundle","strategy":"thread_preferred_chunked_table_work",'
        + '"execution_network":"reta_mojo.execution_network.ExecutionNetworkBundle",'
        + '"config":' + parallel_config_snapshot_json(bundle.config)
        + ',"processor_cores":' + processor_core_counts_snapshot_json(bundle.processor_cores)
        + ',"morphisms":["extract_parallel_config_from_argv",'
        + '"decode_religion_rows_in_processes","decode_kombi_rows_in_processes",'
        + '"select_columns_in_processes","max_cell_text_len_in_processes",'
        + '"prepare_kombi_join_tables_in_processes","moon_numbers_in_processes",'
        + '"prime_factors_in_processes","filter_numbers_in_processes",'
        + '"factor_pairs_in_processes","normalize_column_buckets_in_processes"],'
        + '"default_policy":"auto_threads_processes_explicit",'
        + '"default_workers":' + String(bundle.processor_cores.default_workers()) + "}"
    )


# ---------------------------------------------------------------------------
# Native process-chunk transport
# ---------------------------------------------------------------------------

@fieldwise_init
struct ParallelChunkTask(Copyable):
    var index: Int
    var operation: String
    var payload: String


@fieldwise_init
struct ParallelChunkResult(Copyable):
    var index: Int
    var payload: String


struct _FieldReader:
    var payload: String
    var cursor: Int

    def __init__(out self, payload: String):
        self.payload = payload
        self.cursor = 0

    def read_field(mut self) raises -> String:
        var colon = self.payload.find(":", self.cursor)
        if colon < 0:
            raise Error("parallel payload is missing a field separator")
        var length_text = String(StringSlice(self.payload)[byte=self.cursor:colon])
        var length = _positive_int(length_text, -1)
        if length < 0:
            raise Error("parallel payload contains an invalid field length")
        var start = colon + 1
        var end = start + length
        if end > self.payload.byte_length():
            raise Error("parallel payload field exceeds its byte length")
        var value = String(StringSlice(self.payload)[byte=start:end])
        self.cursor = end
        return value^

    def read_int(mut self) raises -> Int:
        return atol(self.read_field())

    def exhausted(self) -> Bool:
        return self.cursor == self.payload.byte_length()


def _encode_field(value: String) -> String:
    return String(value.byte_length()) + ":" + value


def _encode_int_field(value: Int) -> String:
    return _encode_field(String(value))


def _encode_bool_field(value: Bool) -> String:
    return _encode_field("1" if value else "0")


def _encode_ints(values: List[Int]) -> String:
    var payload = _encode_int_field(len(values))
    for value in values:
        payload += _encode_int_field(value)
    return payload^


def _decode_ints(payload: String) raises -> List[Int]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var result = List[Int]()
    for _ in range(count):
        result.append(reader.read_int())
    if not reader.exhausted():
        raise Error("parallel integer payload has trailing bytes")
    return result^


def _encode_strings(values: List[String]) -> String:
    var payload = _encode_int_field(len(values))
    for value in values:
        payload += _encode_field(value)
    return payload^


def _decode_strings(payload: String) raises -> List[String]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var result = List[String]()
    for _ in range(count):
        result.append(reader.read_field())
    if not reader.exhausted():
        raise Error("parallel string payload has trailing bytes")
    return result^


def _encode_indexed_rows(rows: List[IndexedStringRow]) -> String:
    var payload = _encode_int_field(len(rows))
    for row in rows:
        payload += _encode_int_field(row.index)
        payload += _encode_field(_encode_strings(row.cells))
    return payload^


def _decode_indexed_rows(payload: String) raises -> List[IndexedStringRow]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var rows = List[IndexedStringRow]()
    for _ in range(count):
        var index = reader.read_int()
        var cells = _decode_strings(reader.read_field())
        rows.append(IndexedStringRow(index, cells^))
    if not reader.exhausted():
        raise Error("parallel row payload has trailing bytes")
    return rows^


def _encode_kombi_rows(rows: List[DecodedKombiRow]) -> String:
    var payload = _encode_int_field(len(rows))
    for row in rows:
        payload += _encode_int_field(row.index)
        payload += _encode_field(_encode_strings(row.cells))
        payload += _encode_field(_encode_ints(row.kombi_numbers))
    return payload^


def _decode_kombi_rows(payload: String) raises -> List[DecodedKombiRow]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var rows = List[DecodedKombiRow]()
    for _ in range(count):
        var index = reader.read_int()
        var cells = _decode_strings(reader.read_field())
        var numbers = _decode_ints(reader.read_field())
        rows.append(DecodedKombiRow(index, cells^, numbers^))
    if not reader.exhausted():
        raise Error("parallel kombi payload has trailing bytes")
    return rows^


def _encode_int_list_records(records: List[IntListRecord]) -> String:
    var payload = _encode_int_field(len(records))
    for record in records:
        payload += _encode_int_field(record.number)
        payload += _encode_field(_encode_ints(record.values))
    return payload^


def _decode_int_list_records(payload: String) raises -> List[IntListRecord]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var records = List[IntListRecord]()
    for _ in range(count):
        var number = reader.read_int()
        var values = _decode_ints(reader.read_field())
        records.append(IntListRecord(number, values^))
    if not reader.exhausted():
        raise Error("parallel integer-list payload has trailing bytes")
    return records^


def _encode_moon_records(records: List[MoonNumberRecord]) -> String:
    var payload = _encode_int_field(len(records))
    for record in records:
        payload += _encode_int_field(record.number)
        payload += _encode_field(_encode_ints(record.bases))
        payload += _encode_field(_encode_ints(record.exponent_markers))
    return payload^


def _decode_moon_records(payload: String) raises -> List[MoonNumberRecord]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var records = List[MoonNumberRecord]()
    for _ in range(count):
        var number = reader.read_int()
        var bases = _decode_ints(reader.read_field())
        var markers = _decode_ints(reader.read_field())
        records.append(MoonNumberRecord(number, bases^, markers^))
    if not reader.exhausted():
        raise Error("parallel moon payload has trailing bytes")
    return records^


def _encode_factor_pair_records(records: List[FactorPairRecord]) -> String:
    var payload = _encode_int_field(len(records))
    for record in records:
        payload += _encode_int_field(record.number)
        payload += _encode_int_field(len(record.pairs))
        for pair in record.pairs:
            payload += _encode_int_field(pair.first)
            payload += _encode_int_field(pair.second)
    return payload^


def _decode_factor_pair_records(payload: String) raises -> List[FactorPairRecord]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var records = List[FactorPairRecord]()
    for _ in range(count):
        var number = reader.read_int()
        var pair_count = reader.read_int()
        var pairs = List[IntPair]()
        for _ in range(pair_count):
            pairs.append(IntPair(reader.read_int(), reader.read_int()))
        records.append(FactorPairRecord(number, pairs^))
    if not reader.exhausted():
        raise Error("parallel factor-pair payload has trailing bytes")
    return records^


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


def _parallel_chunk_worker(task: ParallelChunkTask) raises -> ParallelChunkResult:
    if task.operation == "decode_religion_rows":
        var reader = _FieldReader(task.payload)
        var output_kind = reader.read_field()
        var rows = _decode_indexed_rows(reader.read_field())
        return ParallelChunkResult(
            task.index,
            _encode_indexed_rows(decode_religion_rows_serial(rows, output_kind)),
        )
    if task.operation == "decode_kombi_rows":
        return ParallelChunkResult(
            task.index,
            _encode_kombi_rows(
                decode_kombi_rows_serial(_decode_indexed_rows(task.payload))
            ),
        )
    if task.operation == "moon_numbers":
        return ParallelChunkResult(
            task.index,
            _encode_moon_records(moon_numbers_serial(_decode_ints(task.payload))),
        )
    if task.operation == "prime_factors":
        return ParallelChunkResult(
            task.index,
            _encode_int_list_records(prime_factors_serial(_decode_ints(task.payload))),
        )
    if task.operation == "filter_numbers":
        var reader = _FieldReader(task.payload)
        var mode = reader.read_field()
        var criteria = _decode_ints(reader.read_field())
        var modulo_remainder = reader.read_int()
        var want_moon = reader.read_int() != 0
        var numbers = _decode_ints(reader.read_field())
        return ParallelChunkResult(
            task.index,
            _encode_ints(
                filter_numbers_serial(
                    numbers, mode, criteria, modulo_remainder, want_moon
                )
            ),
        )
    if task.operation == "factor_pairs":
        var reader = _FieldReader(task.payload)
        var include_one = reader.read_int() != 0
        var numbers = _decode_ints(reader.read_field())
        return ParallelChunkResult(
            task.index,
            _encode_factor_pair_records(
                factor_pairs_serial(numbers, include_one)
            ),
        )
    if task.operation == "select_columns":
        var reader = _FieldReader(task.payload)
        var columns = _decode_ints(reader.read_field())
        var table = _decode_csv_table(reader.read_field())
        return ParallelChunkResult(
            task.index, _encode_csv_table(select_columns_serial(table, columns))
        )
    if task.operation == "max_cell_text_len":
        var reader = _FieldReader(task.payload)
        var fragments = _decode_ints(reader.read_field())
        var table = _decode_fragment_table(reader.read_field())
        return ParallelChunkResult(
            task.index, _encode_widths(max_cell_text_len_serial(table, fragments))
        )
    if task.operation == "normalize_column_buckets":
        return ParallelChunkResult(
            task.index,
            _encode_buckets(
                normalize_column_buckets_serial(_decode_buckets(task.payload))
            ),
        )
    if task.operation == "prepare_kombi_join_tables":
        var reader = _FieldReader(task.payload)
        var selections = _decode_join_selections(reader.read_field())
        var source = _decode_csv_table(reader.read_field())
        var joined = prepare_kombi_join_tables_serial(selections, source)
        return ParallelChunkResult(
            task.index, _encode_join_result(joined[0], joined[1])
        )
    raise Error("unknown native parallel chunk operation: " + task.operation)


def _wait_parallel_worker(pid: Int) -> Int:
    var status = stack_allocation[1, c_int]()
    status[0] = c_int(0)
    _ = external_call["waitpid", c_int](c_int(pid), status, c_int(0))
    return (Int(status[0]) >> 8) & 255


def _run_parallel_process_batch(
    tasks: List[ParallelChunkTask], start: Int, end: Int
) raises -> List[ParallelChunkResult]:
    var pids = List[Int]()
    var read_fds = List[Int]()
    var indexes = List[Int]()
    for task_index in range(start, end):
        var descriptors = stack_allocation[2, c_int]()
        if external_call["pipe", c_int](descriptors) != 0:
            raise Error("unable to create native parallel worker pipe")
        var pid = Int(external_call["fork", c_int]())
        if pid < 0:
            _ = external_call["close", c_int](descriptors[0])
            _ = external_call["close", c_int](descriptors[1])
            raise Error("unable to fork native parallel worker")
        if pid == 0:
            _ = external_call["close", c_int](descriptors[0])
            var writer = FileHandle()
            writer.handle = Int(descriptors[1])
            try:
                var child_result = _parallel_chunk_worker(tasks[task_index])
                writer.write_all(child_result.payload.as_bytes())
                writer.close()
                _ = external_call["_exit", NoneType](c_int(0))
            except:
                writer.write_all(
                    String("native parallel worker failed").as_bytes()
                )
                writer.close()
                _ = external_call["_exit", NoneType](c_int(70))
        _ = external_call["close", c_int](descriptors[1])
        pids.append(pid)
        read_fds.append(Int(descriptors[0]))
        indexes.append(tasks[task_index].index)

    var results = List[ParallelChunkResult]()
    for slot in range(len(pids)):
        var reader = FileHandle()
        reader.handle = read_fds[slot]
        var payload = reader.read()
        reader.close()
        var exit_code = _wait_parallel_worker(pids[slot])
        if exit_code != 0:
            raise Error(
                "native parallel worker exited with code "
                + String(exit_code)
                + ": "
                + payload
            )
        results.append(ParallelChunkResult(indexes[slot], payload^))
    return results^


def _run_parallel_thread_tasks(
    tasks: List[ParallelChunkTask], workers: Int
) raises -> List[ParallelChunkResult]:
    """Run chunk slots on Mojo's shared-memory CPU worker runtime."""
    var results = List[ParallelChunkResult]()
    var errors = List[String]()
    for index in range(len(tasks)):
        results.append(ParallelChunkResult(tasks[index].index, ""))
        errors.append("")

    @parameter
    def worker(slot: Int):
        try:
            results[slot] = _parallel_chunk_worker(tasks[slot])
        except error:
            errors[slot] = String(error)

    parallelize[worker](len(tasks), max(1, workers))
    for index in range(len(errors)):
        if errors[index].byte_length() > 0:
            raise Error(
                "native thread worker "
                + String(index)
                + " failed: "
                + errors[index]
            )
    return results^


def _run_parallel_tasks(
    tasks: List[ParallelChunkTask],
    workers: Int,
    config: ParallelExecutionConfig,
) raises -> List[ParallelChunkResult]:
    if config.resolved_backend() == "threads":
        return _run_parallel_thread_tasks(tasks, workers)
    if config.resolved_backend() != "processes":
        raise Error("parallel task runner requires threads or processes")
    if config.start_method.byte_length() > 0 and config.start_method != "fork":
        raise Error("native process execution currently supports start_method=fork")
    var results = List[ParallelChunkResult]()
    var start = 0
    while start < len(tasks):
        var end = min(len(tasks), start + max(1, workers))
        var batch = _run_parallel_process_batch(tasks, start, end)
        for result in batch:
            results.append(result.copy())
        start = end
    return results^


def _chunk_count(item_count: Int, chunk_size: Int) -> Int:
    if item_count <= 0:
        return 0
    return (item_count + chunk_size - 1) // chunk_size


def _use_parallel_chunks(
    item_count: Int, config: ParallelExecutionConfig
) -> Bool:
    return config.should_use_parallel(item_count) and _chunk_count(
        item_count, config.chunk_size
    ) > 1


def decode_religion_rows_in_processes(
    rows: List[IndexedStringRow],
    output_kind: String,
    config: ParallelExecutionConfig,
) raises -> ReligionRowsResult:
    var item_count = len(rows)
    if not _use_parallel_chunks(item_count, config):
        return ReligionRowsResult(
            decode_religion_rows_serial(rows, output_kind),
            _stats("decode_religion_rows", 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        var chunk = _chunk_indexed_rows(rows, start, end)
        var payload = _encode_field(output_kind) + _encode_field(_encode_indexed_rows(chunk))
        tasks.append(ParallelChunkTask(chunk_index, "decode_religion_rows", payload^))
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var decoded = List[IndexedStringRow]()
    for chunk in chunks:
        var chunk_rows = _decode_indexed_rows(chunk.payload)
        for row in chunk_rows:
            decoded.append(row.copy())
    _sort_indexed_rows(decoded)
    return ReligionRowsResult(
        decoded^,
        _stats("decode_religion_rows", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def decode_kombi_rows_in_processes(
    rows: List[IndexedStringRow], config: ParallelExecutionConfig
) raises -> KombiRowsResult:
    var item_count = len(rows)
    if not _use_parallel_chunks(item_count, config):
        return KombiRowsResult(
            decode_kombi_rows_serial(rows),
            _stats("decode_kombi_rows", 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        tasks.append(
            ParallelChunkTask(
                chunk_index,
                "decode_kombi_rows",
                _encode_indexed_rows(_chunk_indexed_rows(rows, start, end)),
            )
        )
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var decoded = List[DecodedKombiRow]()
    for chunk in chunks:
        var chunk_rows = _decode_kombi_rows(chunk.payload)
        for row in chunk_rows:
            decoded.append(row.copy())
    _sort_kombi_rows(decoded)
    return KombiRowsResult(
        decoded^,
        _stats("decode_kombi_rows", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def moon_numbers_in_processes(
    numbers: List[Int], config: ParallelExecutionConfig
) raises -> MoonOperationResult:
    var item_count = len(numbers)
    if not _use_parallel_chunks(item_count, config):
        return MoonOperationResult(
            moon_numbers_serial(numbers),
            _stats("moon_numbers", 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        tasks.append(ParallelChunkTask(chunk_index, "moon_numbers", _encode_ints(_chunk_ints(numbers, start, end))))
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var records = List[MoonNumberRecord]()
    for chunk in chunks:
        var values = _decode_moon_records(chunk.payload)
        for value in values:
            records.append(value.copy())
    _sort_moon_records(records)
    return MoonOperationResult(
        records^,
        _stats("moon_numbers", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def prime_factors_in_processes(
    numbers: List[Int], config: ParallelExecutionConfig
) raises -> IntListOperationResult:
    var item_count = len(numbers)
    if not _use_parallel_chunks(item_count, config):
        return IntListOperationResult(
            prime_factors_serial(numbers),
            _stats("prime_factors", 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        tasks.append(ParallelChunkTask(chunk_index, "prime_factors", _encode_ints(_chunk_ints(numbers, start, end))))
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var records = List[IntListRecord]()
    for chunk in chunks:
        var values = _decode_int_list_records(chunk.payload)
        for value in values:
            records.append(value.copy())
    _sort_int_list_records(records)
    return IntListOperationResult(
        records^,
        _stats("prime_factors", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def filter_numbers_in_processes(
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
            filter_numbers_serial(numbers, mode, criteria, modulo_remainder, want_moon),
            _stats("filter_numbers:" + mode, 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        var payload = (
            _encode_field(mode)
            + _encode_field(_encode_ints(criteria))
            + _encode_int_field(modulo_remainder)
            + _encode_bool_field(want_moon)
            + _encode_field(_encode_ints(_chunk_ints(numbers, start, end)))
        )
        tasks.append(ParallelChunkTask(chunk_index, "filter_numbers", payload^))
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var values = List[Int]()
    for chunk in chunks:
        var chunk_values = _decode_ints(chunk.payload)
        for value in chunk_values:
            values.append(value)
    _sort_unique_ints(values)
    return NumberFilterResult(
        values^,
        _stats("filter_numbers:" + mode, workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def factor_pairs_in_processes(
    numbers: List[Int], include_one: Bool, config: ParallelExecutionConfig
) raises -> FactorPairOperationResult:
    var item_count = len(numbers)
    if not _use_parallel_chunks(item_count, config):
        return FactorPairOperationResult(
            factor_pairs_serial(numbers, include_one),
            _stats("factor_pairs", 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        var payload = _encode_bool_field(include_one) + _encode_field(_encode_ints(_chunk_ints(numbers, start, end)))
        tasks.append(ParallelChunkTask(chunk_index, "factor_pairs", payload^))
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var records = List[FactorPairRecord]()
    for chunk in chunks:
        var values = _decode_factor_pair_records(chunk.payload)
        for value in values:
            records.append(value.copy())
    _sort_factor_pair_records(records)
    return FactorPairOperationResult(
        records^,
        _stats("factor_pairs", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


# ---------------------------------------------------------------------------
# Table-shaped process kernels
# ---------------------------------------------------------------------------

def _encode_csv_table(table: CsvTable) -> String:
    var payload = _encode_int_field(table.maximum_columns)
    payload += _encode_int_field(len(table.rows))
    for row in table.rows:
        payload += _encode_field(_encode_strings(row))
    return payload^


def _decode_csv_table(payload: String) raises -> CsvTable:
    var reader = _FieldReader(payload)
    var maximum_columns = reader.read_int()
    var row_count = reader.read_int()
    var rows = List[List[String]]()
    for _ in range(row_count):
        rows.append(_decode_strings(reader.read_field()))
    if not reader.exhausted():
        raise Error("parallel CSV table payload has trailing bytes")
    return CsvTable(rows^, maximum_columns)


def _encode_fragment_table(table: List[List[List[String]]]) -> String:
    var payload = _encode_int_field(len(table))
    for row in table:
        payload += _encode_int_field(len(row))
        for cell in row:
            payload += _encode_field(_encode_strings(cell))
    return payload^


def _decode_fragment_table(payload: String) raises -> List[List[List[String]]]:
    var reader = _FieldReader(payload)
    var row_count = reader.read_int()
    var table = List[List[List[String]]]()
    for _ in range(row_count):
        var cell_count = reader.read_int()
        var row = List[List[String]]()
        for _ in range(cell_count):
            row.append(_decode_strings(reader.read_field()))
        table.append(row^)
    if not reader.exhausted():
        raise Error("parallel fragment-table payload has trailing bytes")
    return table^


def _encode_widths(widths: List[ColumnWidth]) -> String:
    var payload = _encode_int_field(len(widths))
    for width in widths:
        payload += _encode_int_field(width.column)
        payload += _encode_int_field(width.width)
    return payload^


def _decode_widths(payload: String) raises -> List[ColumnWidth]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var widths = List[ColumnWidth]()
    for _ in range(count):
        widths.append(ColumnWidth(reader.read_int(), reader.read_int()))
    if not reader.exhausted():
        raise Error("parallel width payload has trailing bytes")
    return widths^


def _sorted_set_values(values: Set[Int]) -> List[Int]:
    var result = List[Int]()
    for value in values:
        result.append(value)
    for index in range(1, len(result)):
        var current = result[index]
        var position = index
        while position > 0 and result[position - 1] > current:
            result[position] = result[position - 1]
            position -= 1
        result[position] = current
    return result^


def _encode_buckets(buckets: List[ColumnBucket]) -> String:
    var payload = _encode_int_field(len(buckets))
    for bucket in buckets:
        payload += _encode_int_field(bucket.bucket_type)
        payload += _encode_field(_encode_ints(_sorted_set_values(bucket.positive)))
        payload += _encode_field(_encode_ints(_sorted_set_values(bucket.negative)))
    return payload^


def _decode_buckets(payload: String) raises -> List[ColumnBucket]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var buckets = List[ColumnBucket]()
    for _ in range(count):
        var bucket_type = reader.read_int()
        var positives = _decode_ints(reader.read_field())
        var negatives = _decode_ints(reader.read_field())
        var positive_set = Set[Int]()
        var negative_set = Set[Int]()
        for value in positives:
            positive_set.add(value)
        for value in negatives:
            negative_set.add(value)
        buckets.append(ColumnBucket(bucket_type, positive_set^, negative_set^))
    if not reader.exhausted():
        raise Error("parallel bucket payload has trailing bytes")
    return buckets^


def _encode_join_result(
    selections: List[KombiJoinSelection], tables: List[CsvTable]
) -> String:
    var payload = _encode_int_field(len(selections))
    for index in range(len(selections)):
        payload += _encode_int_field(selections[index].key)
        payload += _encode_field(_encode_ints(selections[index].row_numbers))
        payload += _encode_field(_encode_csv_table(tables[index]))
    return payload^


def _decode_join_result(
    payload: String
) raises -> Tuple[List[KombiJoinSelection], List[CsvTable]]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var selections = List[KombiJoinSelection]()
    var tables = List[CsvTable]()
    for _ in range(count):
        var key = reader.read_int()
        var row_numbers = _decode_ints(reader.read_field())
        selections.append(KombiJoinSelection(key, row_numbers^))
        tables.append(_decode_csv_table(reader.read_field()))
    if not reader.exhausted():
        raise Error("parallel join payload has trailing bytes")
    return (selections^, tables^)


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


def select_columns_in_processes(
    table: CsvTable,
    one_based_columns: List[Int],
    config: ParallelExecutionConfig,
) raises -> TableOperationResult:
    var item_count = len(table.rows)
    if not _use_parallel_chunks(item_count, config):
        return TableOperationResult(
            select_columns_serial(table, one_based_columns),
            _stats("select_columns", 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        var payload = _encode_field(_encode_ints(one_based_columns)) + _encode_field(
            _encode_csv_table(_chunk_csv_table(table, start, end))
        )
        tasks.append(ParallelChunkTask(chunk_index, "select_columns", payload^))
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var rows = List[List[String]]()
    for chunk in chunks:
        var selected = _decode_csv_table(chunk.payload)
        for row in selected.rows:
            rows.append(row.copy())
    return TableOperationResult(
        CsvTable(rows^, len(one_based_columns)),
        _stats("select_columns", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def max_cell_text_len_in_processes(
    table: List[List[List[String]]],
    fragment_indexes: List[Int],
    config: ParallelExecutionConfig,
) raises -> WidthOperationResult:
    var item_count = len(table)
    if not _use_parallel_chunks(item_count, config):
        return WidthOperationResult(
            max_cell_text_len_serial(table, fragment_indexes),
            _stats("max_cell_text_len", 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        var payload = _encode_field(_encode_ints(fragment_indexes)) + _encode_field(
            _encode_fragment_table(_chunk_fragment_table(table, start, end))
        )
        tasks.append(ParallelChunkTask(chunk_index, "max_cell_text_len", payload^))
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var merged = List[Int]()
    for chunk in chunks:
        var widths = _decode_widths(chunk.payload)
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
        _stats("max_cell_text_len", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def normalize_column_buckets_in_processes(
    buckets: List[ColumnBucket], config: ParallelExecutionConfig
) raises -> BucketOperationResult:
    var item_count = 0
    for bucket in buckets:
        item_count += len(bucket.positive) + len(bucket.negative)
    var chunk_size = 1 if item_count >= config.threshold and len(buckets) > 1 else config.chunk_size
    if not config.should_use_parallel(item_count) or len(buckets) <= 1:
        return BucketOperationResult(
            normalize_column_buckets_serial(buckets),
            _stats("normalize_column_buckets", 1, 1 if len(buckets) > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < len(buckets):
        var end = min(len(buckets), start + max(1, chunk_size))
        tasks.append(
            ParallelChunkTask(
                chunk_index,
                "normalize_column_buckets",
                _encode_buckets(_chunk_buckets(buckets, start, end)),
            )
        )
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var result = List[ColumnBucket]()
    for chunk in chunks:
        var values = _decode_buckets(chunk.payload)
        for value in values:
            result.append(value.copy())
    _sort_buckets(result)
    return BucketOperationResult(
        result^,
        _stats("normalize_column_buckets", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def prepare_kombi_join_tables_in_processes(
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
            _stats("prepare_kombi_join_tables", 1, 1 if item_count > 0 else 0, item_count, "serial", config),
        )
    var tasks = List[ParallelChunkTask]()
    var start = 0
    var chunk_index = 0
    while start < item_count:
        var end = min(item_count, start + config.chunk_size)
        var payload = _encode_field(
            _encode_int_field(end - start)
            + _encode_join_selections(_chunk_selections(selections, start, end))
        ) + _encode_field(_encode_csv_table(source))
        tasks.append(ParallelChunkTask(chunk_index, "prepare_kombi_join_tables", payload^))
        chunk_index += 1
        start = end
    var workers = min(config.resolved_workers(), len(tasks))
    var chunks = _run_parallel_tasks(tasks, workers, config)
    var kept = List[KombiJoinSelection]()
    var tables = List[CsvTable]()
    for chunk in chunks:
        var decoded = _decode_join_result(chunk.payload)
        for value in decoded[0]:
            kept.append(value.copy())
        for table in decoded[1]:
            tables.append(table.copy())
    return KombiJoinResult(
        kept^,
        tables^,
        _stats("prepare_kombi_join_tables", workers, len(tasks), item_count, config.resolved_backend(), config),
    )


def _encode_join_selections(selections: List[KombiJoinSelection]) -> String:
    var payload = String()
    for selection in selections:
        payload += _encode_int_field(selection.key)
        payload += _encode_field(_encode_ints(selection.row_numbers))
    return payload^


def _decode_join_selections(payload: String) raises -> List[KombiJoinSelection]:
    var reader = _FieldReader(payload)
    var count = reader.read_int()
    var selections = List[KombiJoinSelection]()
    for _ in range(count):
        var key = reader.read_int()
        var rows = _decode_ints(reader.read_field())
        selections.append(KombiJoinSelection(key, rows^))
    if not reader.exhausted():
        raise Error("parallel selection payload has trailing bytes")
    return selections^
