from std.collections import List, Set
from reta_mojo.csv_table import CsvTable
from reta_mojo.parallel_execution import (
    ColumnBucket,
    KombiJoinSelection,
    make_parallel_config,
    max_cell_text_len_threaded,
    max_cell_text_len_serial,
    normalize_column_buckets_threaded,
    prepare_kombi_join_tables_threaded,
    select_columns_threaded,
    select_columns_serial,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var checks = 0
    var config = make_parallel_config("threads", 2, 1, 1, "", "unit")
    var table = CsvTable(
        [["r0c0", "r0c1", "終"], ["r1c0", "r1c1", "ä"], ["r2c0", "r2c1", "ß"]],
        3,
    )
    var columns: List[Int] = [3, 1]
    var selected_serial = select_columns_serial(table, columns)
    var selected = select_columns_threaded(table, columns, config)
    assert_true(selected.stats.mode == "threads", "select mode")
    checks += 1
    assert_true(selected.stats.chunks == 3, "select chunks")
    checks += 1
    assert_true(selected.table.maximum_columns == 2, "select width")
    checks += 1
    for row in range(len(selected_serial.rows)):
        for column in range(len(selected_serial.rows[row])):
            assert_true(
                selected.table.rows[row][column]
                == selected_serial.rows[row][column],
                "select parity",
            )
            checks += 1

    var fragments: List[List[List[String]]] = [
        [["a", "alpha"], ["bb", "b"]],
        [["ccc", "c"], ["d", "delta"]],
        [["終終", "終"], ["eeeee", "e"]],
    ]
    var fragment_indexes: List[Int] = [0, 1]
    var width_serial = max_cell_text_len_serial(fragments, fragment_indexes)
    var widths = max_cell_text_len_threaded(fragments, fragment_indexes, config)
    assert_true(widths.stats.mode == "threads", "width mode")
    checks += 1
    assert_true(len(widths.widths) == len(width_serial), "width count")
    checks += 1
    for index in range(len(width_serial)):
        assert_true(
            widths.widths[index].column == width_serial[index].column,
            "width column",
        )
        checks += 1
        assert_true(
            widths.widths[index].width == width_serial[index].width,
            "width value",
        )
        checks += 1

    var positive0 = Set[Int]()
    positive0.add(1)
    positive0.add(2)
    positive0.add(3)
    var negative0 = Set[Int]()
    negative0.add(2)
    var positive1 = Set[Int]()
    positive1.add(7)
    positive1.add(9)
    var negative1 = Set[Int]()
    negative1.add(9)
    var buckets = List[ColumnBucket]()
    buckets.append(ColumnBucket(1, positive1^, negative1^))
    buckets.append(ColumnBucket(0, positive0^, negative0^))
    var normalized = normalize_column_buckets_threaded(buckets, config)
    assert_true(normalized.stats.mode == "threads", "bucket mode")
    checks += 1
    assert_true(len(normalized.buckets) == 2, "bucket count")
    checks += 1
    assert_true(normalized.buckets[0].bucket_type == 0, "bucket order")
    checks += 1
    assert_true(1 in normalized.buckets[0].positive, "bucket keeps positive")
    checks += 1
    assert_true(
        2 not in normalized.buckets[0].positive, "bucket subtracts negative"
    )
    checks += 1
    assert_true(
        len(normalized.buckets[0].negative) == 0, "bucket clears negative"
    )
    checks += 1

    var selections = List[KombiJoinSelection]()
    selections.append(KombiJoinSelection(10, [0, 2]))
    selections.append(KombiJoinSelection(20, [1]))
    var joined = prepare_kombi_join_tables_threaded(selections, table, config)
    assert_true(joined.stats.mode == "threads", "join mode")
    checks += 1
    assert_true(
        len(joined.selections) == 2 and len(joined.tables) == 2, "join count"
    )
    checks += 1
    assert_true(joined.selections[0].key == 10, "join key")
    checks += 1
    assert_true(len(joined.tables[0].rows) == 2, "join rows")
    checks += 1
    assert_true(joined.tables[0].rows[1][0] == "r2c0", "join content")
    checks += 1

    print("parallel table execution tests:", checks, "/", checks)
