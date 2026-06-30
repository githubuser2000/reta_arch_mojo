from std.collections import List, Set
from reta_mojo.parallel_row_preparation import (
    PreparationInputRow,
    make_parallel_row_config,
    parallel_rows_result_snapshot_json,
    prepare_rows_threaded,
)
from reta_mojo.table_preparation import make_parallel_row_preparation_context
from reta_mojo.table_wrapping import TextWrapRuntime, WRAP_PYHYPHEN


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var checks = 0
    var columns = Set[Int]()
    columns.add(0)
    columns.add(2)
    var runtime = TextWrapRuntime(80, False, False, True, WRAP_PYHYPHEN)
    var context = make_parallel_row_preparation_context(
        columns^, 0, 3, 80, [4, 3], 9, runtime, True, -1, 0
    )
    var rows = List[PreparationInputRow]()
    rows.append(PreparationInputRow(4, ["abcdef", "skip", "xyzq"]))
    rows.append(PreparationInputRow(1, ["  hi  ", "skip", "終終終終"]))
    rows.append(PreparationInputRow(3, ["12345678", "skip", "z"]))
    rows.append(PreparationInputRow(2, ["xy", "skip", "uvw"]))

    var serial = prepare_rows_threaded(
        rows,
        context,
        make_parallel_row_config("off", 8, 1, 1, "unit"),
    )
    var threaded = prepare_rows_threaded(
        rows,
        context,
        make_parallel_row_config("threads", 2, 1, 1, "unit"),
    )
    assert_true(serial.stats.mode == "serial", "serial mode")
    checks += 1
    assert_true(threaded.stats.mode == "threads", "thread mode")
    checks += 1
    assert_true(threaded.stats.workers == 2, "thread workers")
    checks += 1
    assert_true(threaded.stats.chunks == 4, "thread chunks")
    checks += 1
    assert_true(len(threaded.rows) == 4, "row count")
    checks += 1
    assert_true(len(threaded.religion_numbers) == 4, "religion count")
    checks += 1
    for index in range(4):
        assert_true(
            threaded.religion_numbers[index] == index + 1,
            "deterministic row order",
        )
        checks += 1
        assert_true(
            len(threaded.rows[index]) == len(serial.rows[index]),
            "serial/thread cell count",
        )
        checks += 1
        for cell in range(len(serial.rows[index])):
            assert_true(
                len(threaded.rows[index][cell]) == len(serial.rows[index][cell]),
                "serial/thread fragment count",
            )
            checks += 1
            for fragment in range(len(serial.rows[index][cell])):
                assert_true(
                    threaded.rows[index][cell][fragment]
                    == serial.rows[index][cell][fragment],
                    "serial/thread fragment parity",
                )
                checks += 1
    assert_true(threaded.rows[3][0][0] == "abcd", "first hard chunk")
    checks += 1
    assert_true(threaded.rows[3][0][1] == "ef", "second hard chunk")
    checks += 1
    assert_true(threaded.rows[0][0][0] == "hi", "strip parity")
    checks += 1
    assert_true(
        threaded.rows[0][1][0] == "終終終",
        "unicode codepoint width",
    )
    checks += 1
    var snapshot = parallel_rows_result_snapshot_json(threaded)
    assert_true(snapshot.find('"mode":"threads"') >= 0, "snapshot mode")
    checks += 1
    assert_true(snapshot.find('"rows":4') >= 0, "snapshot rows")
    checks += 1
    print("parallel row preparation tests:", checks, "/", checks)
