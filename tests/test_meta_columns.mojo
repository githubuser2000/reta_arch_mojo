from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import read_semicolon_csv
from reta_mojo.generated_aliases import MetaColumnRequest
from reta_mojo.meta_columns import (
    generate_meta_columns,
    generate_meta_columns_parallel,
    meta_column_value,
)
from reta_mojo.parallel_execution import make_parallel_config


def test_meta_pair_has_historical_headings_and_identity() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var fraction = read_semicolon_csv(
        "python_reference/csv/gebrochen-rational-universum.csv"
    )
    var request = MetaColumnRequest(2, 0)
    var generated = generate_meta_columns(
        table, [request.copy()], 3, "csv", "german"
    )
    assert_equal(len(generated.columns), 2)
    assert_equal(generated.columns[0][0], "Meta für n")
    assert_equal(generated.columns[1][0], "Meta für 1/n statt n")
    assert_equal(generated.columns[0][1], "")
    assert_true(generated.columns[0][2].startswith("Meta-Thema:"))
    assert_true(
        meta_column_value(table, fraction, 2, request, 0, "csv", "german").find(
            "Meta-Meta-Thema:"
        ) >= 0
    )


def test_concrete_identity_keeps_legacy_double_marker() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var fraction = read_semicolon_csv(
        "python_reference/csv/gebrochen-rational-universum.csv"
    )
    var value = meta_column_value(
        table, fraction, 2, MetaColumnRequest(2, 1), 0, "csv", "german"
    )
    assert_true(value.find("(1/1)(1)") >= 0)
    assert_true(value.startswith("Konkretes:"))


def test_english_historical_spelling_is_preserved() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var fraction = read_semicolon_csv(
        "python_reference/csv/gebrochen-rational-universum.csv"
    )
    var value = meta_column_value(
        table, fraction, 2, MetaColumnRequest(2, 1), 0, "csv", "english"
    )
    assert_true(value.startswith("sonrete things:"))


def test_parallel_meta_columns_match_serial() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var requests = [
        MetaColumnRequest(2, 0),
        MetaColumnRequest(3, 1),
    ]
    var config = make_parallel_config(
        "threads", 4, 2, 1, "", "meta-parity"
    )
    var serial = generate_meta_columns(
        table, requests, 20, "bbcode", "german"
    )
    var parallel = generate_meta_columns_parallel(
        table, requests, 20, "bbcode", "german", config
    )
    assert_equal(serial.inversion_flags, parallel.inversion_flags)
    assert_equal(serial.columns, parallel.columns)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
