from std.collections import List
from reta_mojo.parallel_execution import (
    IndexedStringRow,
    decode_religion_rows_in_processes,
    decode_religion_rows_serial,
    factor_pairs_in_processes,
    factor_pairs_serial,
    make_parallel_config,
    prime_factors_in_processes,
    prime_factors_serial,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var checks = 0
    var threads = make_parallel_config("auto", 2, 1, 1, "", "unit")
    assert_true(threads.resolved_backend() == "threads", "auto backend")
    checks += 1

    var numbers: List[Int] = [49, 6, 18, 6]
    var prime_reference = prime_factors_serial(numbers)
    var prime = prime_factors_in_processes(numbers, threads)
    assert_true(prime.stats.mode == "threads", "prime thread mode")
    checks += 1
    assert_true(prime.stats.workers == 2, "prime worker count")
    checks += 1
    assert_true(prime.stats.chunks == 4, "prime chunk count")
    checks += 1
    assert_true(len(prime.values) == len(prime_reference), "prime record count")
    checks += 1
    for index in range(len(prime.values)):
        assert_true(prime.values[index].number == prime_reference[index].number, "prime order")
        checks += 1
        assert_true(len(prime.values[index].values) == len(prime_reference[index].values), "prime factor count")
        checks += 1
        for factor in range(len(prime.values[index].values)):
            assert_true(prime.values[index].values[factor] == prime_reference[index].values[factor], "prime factor parity")
            checks += 1

    var pair_reference = factor_pairs_serial(numbers, True)
    var pairs = factor_pairs_in_processes(numbers, True, threads)
    assert_true(pairs.stats.mode == "threads", "pair thread mode")
    checks += 1
    assert_true(len(pairs.values) == len(pair_reference), "pair record count")
    checks += 1
    for index in range(len(pairs.values)):
        assert_true(pairs.values[index].number == pair_reference[index].number, "pair order")
        checks += 1
        assert_true(len(pairs.values[index].pairs) == len(pair_reference[index].pairs), "pair count")
        checks += 1

    var rows = List[IndexedStringRow]()
    rows.append(IndexedStringRow(3, ["<x>", "終"]))
    rows.append(IndexedStringRow(1, ['|{"":"eins","html":"<b>eins</b>"}|', "ä"]))
    rows.append(IndexedStringRow(2, ["5", "line\nbreak"]))
    var row_reference = decode_religion_rows_serial(rows, "html")
    var decoded = decode_religion_rows_in_processes(rows, "html", threads)
    assert_true(decoded.stats.mode == "threads", "row thread mode")
    checks += 1
    assert_true(len(decoded.rows) == len(row_reference), "row count")
    checks += 1
    for index in range(len(decoded.rows)):
        assert_true(decoded.rows[index].index == row_reference[index].index, "row order")
        checks += 1
        for column in range(len(decoded.rows[index].cells)):
            assert_true(decoded.rows[index].cells[column] == row_reference[index].cells[column], "row parity")
            checks += 1

    print("parallel thread backend tests:", checks, "/", checks)
