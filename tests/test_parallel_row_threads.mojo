from std.collections import List
from reta_mojo.parallel_execution import (
    IndexedStringRow,
    decode_kombi_rows_threaded,
    decode_kombi_rows_serial,
    decode_religion_rows_threaded,
    decode_religion_rows_serial,
    make_parallel_config,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var checks = 0
    var config = make_parallel_config("threads", 2, 2, 1, "", "unit")
    var serial = make_parallel_config("off", 2, 2, 1, "", "unit")

    var religion_rows = List[IndexedStringRow]()
    religion_rows.append(
        IndexedStringRow(
            1,
            ['|{"":"eins","html":"<b>eins</b>","bbcode":"[b]eins[/b]"}|', "ä"],
        )
    )
    religion_rows.append(IndexedStringRow(4, ["7", "終"]))
    religion_rows.append(IndexedStringRow(2, ["3/4", "βeta"]))
    religion_rows.append(IndexedStringRow(3, ["5", "line\nbreak"]))
    var religion_reference = decode_religion_rows_serial(religion_rows, "html")
    var religion = decode_religion_rows_threaded(religion_rows, "html", config)
    assert_true(religion.stats.mode == "threads", "religion thread mode")
    checks += 1
    assert_true(religion.stats.workers == 2, "religion workers")
    checks += 1
    assert_true(religion.stats.chunks == 2, "religion chunks")
    checks += 1
    assert_true(
        len(religion.rows) == len(religion_reference), "religion row count"
    )
    checks += 1
    for row_index in range(len(religion.rows)):
        assert_true(
            religion.rows[row_index].index
            == religion_reference[row_index].index,
            "religion sorted index",
        )
        checks += 1
        assert_true(
            len(religion.rows[row_index].cells)
            == len(religion_reference[row_index].cells),
            "religion cell count",
        )
        checks += 1
        for column in range(len(religion.rows[row_index].cells)):
            assert_true(
                religion.rows[row_index].cells[column]
                == religion_reference[row_index].cells[column],
                "religion cell parity",
            )
            checks += 1
    assert_true(
        religion.rows[0].index == 1 and religion.rows[3].index == 4,
        "religion Python index ordering",
    )
    checks += 1

    var fallback = decode_religion_rows_threaded(religion_rows, "html", serial)
    assert_true(fallback.stats.mode == "serial", "religion serial fallback")
    checks += 1
    for row_index in range(len(fallback.rows)):
        assert_true(
            fallback.rows[row_index].index
            == religion_reference[row_index].index,
            "religion fallback order",
        )
        checks += 1

    var kombi_rows = List[IndexedStringRow]()
    kombi_rows.append(IndexedStringRow(4, ["7", "delta"]))
    kombi_rows.append(IndexedStringRow(2, ["3/4", "beta"]))
    kombi_rows.append(IndexedStringRow(1, ["2", "alpha"]))
    kombi_rows.append(IndexedStringRow(3, ["5", "gamma"]))
    var kombi_reference = decode_kombi_rows_serial(kombi_rows)
    var kombi = decode_kombi_rows_threaded(kombi_rows, config)
    assert_true(kombi.stats.mode == "threads", "kombi thread mode")
    checks += 1
    assert_true(kombi.stats.chunks == 2, "kombi chunks")
    checks += 1
    assert_true(len(kombi.rows) == len(kombi_reference), "kombi row count")
    checks += 1
    for row_index in range(len(kombi.rows)):
        assert_true(
            kombi.rows[row_index].index == kombi_reference[row_index].index,
            "kombi sorted index",
        )
        checks += 1
        assert_true(
            len(kombi.rows[row_index].cells)
            == len(kombi_reference[row_index].cells),
            "kombi cell count",
        )
        checks += 1
        for column in range(len(kombi.rows[row_index].cells)):
            assert_true(
                kombi.rows[row_index].cells[column]
                == kombi_reference[row_index].cells[column],
                "kombi cell parity",
            )
            checks += 1
        assert_true(
            len(kombi.rows[row_index].kombi_numbers)
            == len(kombi_reference[row_index].kombi_numbers),
            "kombi number count",
        )
        checks += 1
        for number_index in range(len(kombi.rows[row_index].kombi_numbers)):
            assert_true(
                kombi.rows[row_index].kombi_numbers[number_index]
                == kombi_reference[row_index].kombi_numbers[number_index],
                "kombi number parity",
            )
            checks += 1
    assert_true(
        kombi.rows[0].index == 1 and kombi.rows[3].index == 4,
        "kombi Python index ordering",
    )
    checks += 1

    print("parallel row thread tests:", checks, "/", checks)
