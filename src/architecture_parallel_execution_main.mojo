"""Command-line probe for native thread/process chunk execution."""

from std.collections import List
from std.collections.string import atol
from std.sys import argv
from reta_mojo.parallel_execution import (
    IndexedStringRow,
    bootstrap_parallel_execution,
    decode_kombi_rows_in_processes,
    decode_religion_rows_in_processes,
    factor_pairs_in_processes,
    filter_numbers_in_processes,
    make_parallel_config,
    moon_numbers_in_processes,
    parallel_config_from_environment,
    parallel_config_snapshot_json,
    parallel_execution_bundle_snapshot_json,
    prime_factors_in_processes,
    processor_core_counts_snapshot_json,
)


def _usage():
    print("reta-mojo-parallel-execution")
    print("  --summary")
    print("  --config MODE WORKERS CHUNK_SIZE THRESHOLD [START_METHOD]")
    print("  --demo [WORKERS] [CHUNK_SIZE]              # processes")
    print("  --demo-threads [WORKERS] [CHUNK_SIZE]")
    print("  --prime-factors NUMBER ...                 # auto/threads")
    print("  --prime-factors-processes NUMBER ...")
    print("  --factor-pairs NUMBER ...                  # auto/threads")
    print("  --factor-pairs-processes NUMBER ...")


def _numbers(args: List[String], start: Int) raises -> List[Int]:
    var values = List[Int]()
    for index in range(start, len(args)):
        values.append(atol(args[index]))
    return values^


def _join_ints(values: List[Int]) -> String:
    var output = String()
    for index in range(len(values)):
        if index > 0:
            output += ","
        output += String(values[index])
    return output^


def _demo(mode: String, workers: Int, chunk_size: Int) raises:
    var start_method = "fork" if mode == "processes" else ""
    var config = make_parallel_config(
        mode, workers, chunk_size, 1, start_method, "cli"
    )
    var rows = List[IndexedStringRow]()
    rows.append(IndexedStringRow(1, ['|{"":"eins","html":"<b>eins</b>","bbcode":"[b]eins[/b]"}|', "ä"]))
    rows.append(IndexedStringRow(2, ["3/4", "βeta"]))
    rows.append(IndexedStringRow(3, ["5", "line\nbreak"]))
    rows.append(IndexedStringRow(4, ["7", "終"]))
    var religion = decode_religion_rows_in_processes(rows, "html", config)
    var kombi_rows = List[IndexedStringRow]()
    kombi_rows.append(IndexedStringRow(1, ["2", "alpha"]))
    kombi_rows.append(IndexedStringRow(2, ["3/4", "beta"]))
    kombi_rows.append(IndexedStringRow(3, ["5", "gamma"]))
    kombi_rows.append(IndexedStringRow(4, ["7", "delta"]))
    var kombi = decode_kombi_rows_in_processes(kombi_rows, config)
    var numbers: List[Int] = [6, 8, 12, 18, 25, 27, 30, 49]
    var factors = prime_factors_in_processes(numbers, config)
    var moon = moon_numbers_in_processes(numbers, config)
    var criteria: List[Int] = [2, 5]
    var filtered = filter_numbers_in_processes(
        numbers, "ordinary_multiples", criteria, 0, True, config
    )
    var pairs = factor_pairs_in_processes(numbers, True, config)
    print("religion_mode=" + religion.stats.mode)
    print("religion_chunks=" + String(religion.stats.chunks))
    print("religion_first=" + religion.rows[0].cells[0])
    print("kombi_mode=" + kombi.stats.mode)
    print("kombi_numbers=" + String(len(kombi.rows[1].kombi_numbers)))
    print("prime_factors_mode=" + factors.stats.mode)
    print("prime_factors_first=" + _join_ints(factors.values[0].values))
    print("moon_mode=" + moon.stats.mode)
    print("moon_records=" + String(len(moon.values)))
    print("filtered=" + _join_ints(filtered.values))
    print("factor_pairs_mode=" + pairs.stats.mode)
    print("factor_pairs_first=" + String(len(pairs.values[0].pairs)))


def main() raises:
    var raw = argv()
    var args = List[String]()
    for value in raw:
        args.append(String(value))
    if len(args) == 1 or (len(args) == 2 and args[1] == "--summary"):
        var config = parallel_config_from_environment()
        var bundle = bootstrap_parallel_execution(config)
        print(parallel_execution_bundle_snapshot_json(bundle))
        print(parallel_config_snapshot_json(config))
        print(processor_core_counts_snapshot_json(bundle.processor_cores))
        return
    if len(args) >= 6 and args[1] == "--config":
        var start_method = args[6] if len(args) > 6 else "fork"
        var config = make_parallel_config(
            args[2], atol(args[3]), atol(args[4]), atol(args[5]), start_method, "cli"
        )
        print(parallel_config_snapshot_json(config))
        return
    if args[1] == "--demo" or args[1] == "--demo-threads":
        var workers = atol(args[2]) if len(args) > 2 else 2
        var chunk_size = atol(args[3]) if len(args) > 3 else 2
        var mode = "threads" if args[1] == "--demo-threads" else "processes"
        _demo(mode, workers, chunk_size)
        return
    if (
        args[1] == "--prime-factors"
        or args[1] == "--prime-factors-processes"
    ) and len(args) > 2:
        var mode = "processes" if args[1] == "--prime-factors-processes" else "auto"
        var start_method = "fork" if mode == "processes" else ""
        var config = make_parallel_config(mode, 2, 1, 1, start_method, "cli")
        var result = prime_factors_in_processes(_numbers(args, 2), config)
        for record in result.values:
            print(String(record.number) + ":" + _join_ints(record.values))
        return
    if (
        args[1] == "--factor-pairs"
        or args[1] == "--factor-pairs-processes"
    ) and len(args) > 2:
        var mode = "processes" if args[1] == "--factor-pairs-processes" else "auto"
        var start_method = "fork" if mode == "processes" else ""
        var config = make_parallel_config(mode, 2, 1, 1, start_method, "cli")
        var result = factor_pairs_in_processes(_numbers(args, 2), True, config)
        for record in result.values:
            print(String(record.number) + ":" + String(len(record.pairs)))
        return
    _usage()
    raise Error("invalid parallel-execution arguments")
