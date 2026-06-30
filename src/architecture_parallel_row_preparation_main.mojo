"""CLI probe for the Stage-11j typed threaded Prepare-row path."""

from std.collections import List, Set
from std.collections.string import atol
from std.sys import argv

from reta_mojo.parallel_row_preparation import (
    PreparationInputRow,
    ParallelRowsResult,
    make_parallel_row_config,
    parallel_row_config_snapshot_json,
    parallel_rows_result_snapshot_json,
    prepare_rows_threaded,
)
from reta_mojo.table_preparation import (
    ParallelRowPreparationContext,
    make_parallel_row_preparation_context,
)
from reta_mojo.table_wrapping import TextWrapRuntime, WRAP_PYHYPHEN


def _usage():
    print("reta-mojo-row-preparation")
    print("  --summary [WORKERS] [CHUNK_SIZE] [THRESHOLD]")
    print("  --demo [WORKERS] [CHUNK_SIZE]")
    print("  --parity-fixture serial|threads")


def _context() -> ParallelRowPreparationContext:
    var columns = Set[Int]()
    columns.add(0)
    columns.add(2)
    return make_parallel_row_preparation_context(
        columns^,
        0,
        3,
        80,
        [4, 3],
        21,
        TextWrapRuntime(80, False, False, True, WRAP_PYHYPHEN),
        True,
        -1,
        0,
    )


def _rows() -> List[PreparationInputRow]:
    return [
        PreparationInputRow(4, ["abcdef", "ignored", "xyzq"]),
        PreparationInputRow(1, ["  hi  ", "ignored", "終終終終"]),
        PreparationInputRow(3, ["12345678", "ignored", "z"]),
        PreparationInputRow(2, ["xy", "ignored", "uvw"]),
    ]


def _print_full_rows(result: ParallelRowsResult):
    for index in range(len(result.rows)):
        var line = String(result.religion_numbers[index]) + ":"
        for cell_index in range(len(result.rows[index])):
            if cell_index > 0:
                line += "|"
            for fragment_index in range(len(result.rows[index][cell_index])):
                if fragment_index > 0:
                    line += "~"
                line += result.rows[index][cell_index][fragment_index]
        print(line)


def main() raises:
    var raw = argv()
    var args = List[String]()
    for value in raw:
        args.append(String(value))
    if len(args) == 1 or args[1] == "--summary":
        var workers = atol(args[2]) if len(args) > 2 else 0
        var chunk_size = atol(args[3]) if len(args) > 3 else 64
        var threshold = atol(args[4]) if len(args) > 4 else 128
        print(
            parallel_row_config_snapshot_json(
                make_parallel_row_config(
                    "auto", workers, chunk_size, threshold, "cli"
                )
            )
        )
        return
    if args[1] == "--demo":
        var workers = atol(args[2]) if len(args) > 2 else 2
        var chunk_size = atol(args[3]) if len(args) > 3 else 1
        var result = prepare_rows_threaded(
            _rows(),
            _context(),
            make_parallel_row_config(
                "threads", workers, chunk_size, 1, "cli"
            ),
        )
        print(parallel_rows_result_snapshot_json(result))
        _print_full_rows(result)
        return
    if args[1] == "--parity-fixture" and len(args) == 3:
        var mode = String(args[2])
        if mode != "serial" and mode != "threads":
            raise Error("parity fixture mode must be serial or threads")
        var config_mode = "off" if mode == "serial" else "threads"
        var result = prepare_rows_threaded(
            _rows(),
            _context(),
            make_parallel_row_config(config_mode, 2, 1, 1, "parity"),
        )
        _print_full_rows(result)
        return
    _usage()
    raise Error("invalid row-preparation arguments")
