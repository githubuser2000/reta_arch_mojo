"""Threaded typed preparation of independent Reta table rows.

This is the Stage-11j replacement for the dynamic Python ``WorkerPrepare``
object. The worker context owns only the immutable values read by row
preparation. Row zero and header-tag mutation remain serial. Data rows are
written into one result slot per chunk and reduced by original row index after
the thread barrier, so no shared mutable table or lock is required.
"""

from std.algorithm import parallelize
from std.collections import List
from std.ffi import c_int, external_call

from .table_preparation import (
    ParallelRowPreparationContext,
    PreparedIndexedRow,
    PreparedRowsSerialResult,
    prepare_rows_serial,
)


@fieldwise_init
struct PreparationInputRow(Copyable):
    var index: Int
    var cells: List[String]


@fieldwise_init
struct ParallelRowPreparationConfig(Copyable):
    var mode: String
    var workers: Int
    var chunk_size: Int
    var threshold: Int
    var source: String

    def resolved_workers(self) -> Int:
        if self.workers > 0:
            return self.workers
        return max(1, Int(external_call["get_nprocs", c_int]()))

    def enabled(self) -> Bool:
        return self.mode == "auto" or self.mode == "threads"

    def should_use_threads(self, item_count: Int) -> Bool:
        return (
            self.enabled()
            and self.resolved_workers() > 1
            and item_count >= self.threshold
            and self.chunk_size > 0
        )


@fieldwise_init
struct ParallelRowPreparationStats(Copyable):
    var mode: String
    var workers: Int
    var chunks: Int
    var row_count: Int


@fieldwise_init
struct ParallelRowsResult(Copyable):
    var rows: List[List[List[String]]]
    var religion_numbers: List[Int]
    var stats: ParallelRowPreparationStats


@fieldwise_init
struct _PreparedChunk(Copyable):
    var index: Int
    var prepared: List[PreparedIndexedRow]


def make_parallel_row_config(
    mode: String = "auto",
    workers: Int = 0,
    chunk_size: Int = 64,
    threshold: Int = 128,
    source: String = "defaults",
) -> ParallelRowPreparationConfig:
    var normalized = String(mode.strip().lower())
    if (
        normalized == "1"
        or normalized == "on"
        or normalized == "true"
        or normalized == "thread"
        or normalized == "threaded"
        or normalized == "parallel"
    ):
        normalized = "threads"
    elif (
        normalized == "0"
        or normalized == "off"
        or normalized == "false"
        or normalized == "serial"
        or normalized == "single"
    ):
        normalized = "off"
    elif normalized != "auto" and normalized != "threads":
        normalized = "off"
    return ParallelRowPreparationConfig(
        normalized^,
        max(0, workers),
        chunk_size if chunk_size > 0 else 64,
        threshold if threshold > 0 else 128,
        source,
    )


def _copy_input_row(row: PreparationInputRow) -> PreparationInputRow:
    return PreparationInputRow(row.index, row.cells.copy())


def _chunk_count(item_count: Int, chunk_size: Int) -> Int:
    if item_count <= 0:
        return 0
    return (item_count + chunk_size - 1) // chunk_size


def _prepare_chunk(
    rows: List[PreparationInputRow],
    start: Int,
    end: Int,
    context: ParallelRowPreparationContext,
) -> PreparedRowsSerialResult:
    var indexes = List[Int]()
    var raw_rows = List[List[String]]()
    for index in range(start, end):
        indexes.append(rows[index].index)
        raw_rows.append(rows[index].cells.copy())
    return prepare_rows_serial(indexes, raw_rows, context)


def _sort_prepared_rows(mut rows: List[PreparedIndexedRow]):
    for index in range(1, len(rows)):
        var key = rows[index].copy()
        var position = index - 1
        while position >= 0 and rows[position].index > key.index:
            rows[position + 1] = rows[position].copy()
            position -= 1
        rows[position + 1] = key^


def _collect_result(
    mut prepared: List[PreparedIndexedRow],
    context: ParallelRowPreparationContext,
    mode: String,
    workers: Int,
    chunks: Int,
    row_count: Int,
) -> ParallelRowsResult:
    _sort_prepared_rows(prepared)
    var rows = List[List[List[String]]]()
    var religion_numbers = List[Int]()
    for prepared_row in prepared:
        var cells = List[List[String]]()
        for cell in prepared_row.cells:
            cells.append(cell.copy())
        rows.append(cells^)
        if context.religion_numbers_bool:
            religion_numbers.append(prepared_row.index)
    return ParallelRowsResult(
        rows^,
        religion_numbers^,
        ParallelRowPreparationStats(mode, workers, chunks, row_count),
    )


def prepare_rows_threaded(
    rows: List[PreparationInputRow],
    context: ParallelRowPreparationContext,
    config: ParallelRowPreparationConfig = make_parallel_row_config(),
) -> ParallelRowsResult:
    """Prepare data rows serially or on Mojo CPU worker threads.

    Input storage and the context are read-only. Each worker mutates only its
    own preallocated result slot. ``parallelize`` joins all workers before the
    deterministic reduction starts.
    """
    var row_count = len(rows)
    var chunks = _chunk_count(row_count, config.chunk_size)
    if not config.should_use_threads(row_count) or chunks <= 1:
        var serial = _prepare_chunk(rows, 0, row_count, context)
        var prepared_rows = serial.rows.copy()
        return _collect_result(
            prepared_rows,
            context,
            "serial",
            1,
            1 if row_count > 0 else 0,
            row_count,
        )

    var workers = min(config.resolved_workers(), chunks)
    var chunk_results = List[_PreparedChunk]()
    for chunk_index in range(chunks):
        chunk_results.append(
            _PreparedChunk(chunk_index, List[PreparedIndexedRow]())
        )

    @parameter
    def worker(chunk_index: Int):
        var start = chunk_index * config.chunk_size
        var end = min(row_count, start + config.chunk_size)
        var result = _prepare_chunk(rows, start, end, context)
        chunk_results[chunk_index] = _PreparedChunk(
            chunk_index, result.rows.copy()
        )

    parallelize[worker](chunks, workers)

    var prepared = List[PreparedIndexedRow]()
    for chunk_index in range(chunks):
        for row in chunk_results[chunk_index].prepared:
            prepared.append(row.copy())
    return _collect_result(
        prepared, context, "threads", workers, chunks, row_count
    )


def parallel_row_config_snapshot_json(
    config: ParallelRowPreparationConfig
) -> String:
    return (
        '{"class":"ParallelRowPreparationConfig","mode":"'
        + config.mode
        + '","enabled":'
        + ("true" if config.enabled() else "false")
        + ',"workers":'
        + String(config.workers)
        + ',"resolved_workers":'
        + String(config.resolved_workers())
        + ',"chunk_size":'
        + String(config.chunk_size)
        + ',"threshold":'
        + String(config.threshold)
        + ',"source":"'
        + config.source
        + '"}'
    )


def parallel_rows_result_snapshot_json(result: ParallelRowsResult) -> String:
    return (
        '{"class":"ParallelRowsResult","rows":'
        + String(len(result.rows))
        + ',"religion_numbers":'
        + String(len(result.religion_numbers))
        + ',"workers":'
        + String(result.stats.workers)
        + ',"chunks":'
        + String(result.stats.chunks)
        + ',"row_count":'
        + String(result.stats.row_count)
        + ',"mode":"'
        + result.stats.mode
        + '"}'
    )
