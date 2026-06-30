from std.collections import List, Set
from std.collections.string import atol
from std.sys import argv
from reta_mojo.parallel_row_preparation import PreparationInputRow, make_parallel_row_config, prepare_rows_threaded
from reta_mojo.table_preparation import make_parallel_row_preparation_context
from reta_mojo.table_wrapping import TextWrapRuntime, WRAP_PYHYPHEN

def main() raises:
    var args = argv()
    var mode = String(args[1])
    var count = atol(String(args[2]))
    var workers = atol(String(args[3]))
    var chunk = atol(String(args[4]))
    var columns = Set[Int](); columns.add(0); columns.add(1); columns.add(2)
    var context = make_parallel_row_preparation_context(
        columns^, 0, 3, 80, [12, 12, 12], 12,
        TextWrapRuntime(80, False, False, True, WRAP_PYHYPHEN),
        True, -1, 0,
    )
    var rows = List[PreparationInputRow]()
    for i in range(count):
        rows.append(PreparationInputRow(i + 1, [
            "alpha-beta-gamma-delta-" + String(i),
            "abcdefghijklmnopqrstuvwx" + String(i),
            "eins zwei drei vier fünf sechs " + String(i),
        ]))
    var result = prepare_rows_threaded(
        rows, context, make_parallel_row_config(mode, workers, chunk, 1, "bench")
    )
    var checksum = 0
    for row in result.rows:
        for cell in row:
            for fragment in cell:
                checksum += fragment.byte_length()
    print(result.stats.mode, len(result.rows), checksum)
