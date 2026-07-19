from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import read_semicolon_csv
from reta_mojo.fraction_concat_columns import *
from reta_mojo.generated_aliases import FractionColumnRequest
from reta_mojo.parallel_execution import make_parallel_config


def test_universe_pair_uses_main_and_fraction_tables() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var generated = generate_fraction_concat_columns(
        table, [FractionColumnRequest("universe", 2)], 3, "csv", "german"
    )
    assert_equal(len(generated.columns), 2)
    assert_equal(generated.columns[0][0], "n/2 Universum")
    assert_equal(generated.columns[1][0], "2/n Universum")
    assert_true(generated.columns[0][1].startswith("1 / 2 Art und Weise"))
    assert_true(generated.columns[1][1].startswith("das Konkrete"))


def test_domain_order_matches_table_generation_pipeline() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var generated = generate_fraction_concat_columns(
        table,
        [
            FractionColumnRequest("size", 2),
            FractionColumnRequest("universe", 3),
            FractionColumnRequest("galaxy", 4),
            FractionColumnRequest("emotion", 2),
        ],
        1,
        "csv",
        "english",
    )
    assert_equal(generated.columns[0][0], "n/4 galaxy")
    assert_equal(generated.columns[1][0], "4/n galaxy")
    assert_equal(generated.columns[2][0], "n/3 universe")
    assert_equal(generated.columns[3][0], "3/n universe")
    assert_equal(generated.columns[4][0], "n/2 emotion")
    assert_equal(generated.columns[6][0], "n/2 structuresize")


def test_non_universe_integer_does_not_append_coordinate() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var fraction = read_semicolon_csv(
        "python_reference/csv/gebrochen-rational-galaxie.csv"
    )
    var value = fraction_domain_value(
        table, fraction, FractionCoordinate(2, 1), "galaxy", "csv"
    )
    assert_equal(value, table.rows[2][10])



def test_requests_outside_fraction_csv_shape_are_ignored() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var generated = generate_fraction_concat_columns(
        table,
        [
            FractionColumnRequest("galaxy", 21),
            FractionColumnRequest("galaxy", 22),
            FractionColumnRequest("universe", 19),
            FractionColumnRequest("universe", 20),
            FractionColumnRequest("universe", 21),
            FractionColumnRequest("emotion", 7),
            FractionColumnRequest("emotion", 8),
            FractionColumnRequest("size", 16),
            FractionColumnRequest("size", 17),
        ],
        1,
        "html",
        "german",
    )
    var headings = List[String]()
    for column_index in range(len(generated.columns)):
        headings.append(generated.columns[column_index][0])
    assert_equal(
        headings,
        [
            "n/21 Galaxie",
            "21/n Galaxie",
            "n/19 Universum",
            "19/n Universum",
            "20/n Universum",
            "21/n Universum",
            "n/7 Emotion",
            "7/n Emotion",
            "n/16 Strukturgroesse",
            "16/n Strukturgroesse",
        ],
    )


def test_parallel_fraction_loading_and_columns_match_serial() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var config = make_parallel_config(
        "threads", 4, 2, 1, "", "fraction-parity"
    )
    var requests = [
        FractionColumnRequest("galaxy", 2),
        FractionColumnRequest("universe", 3),
        FractionColumnRequest("emotion", 2),
        FractionColumnRequest("size", 2),
    ]
    var serial = generate_fraction_concat_columns(
        table, requests, 20, "bbcode", "german"
    )
    var parallel = generate_fraction_concat_columns_parallel(
        table, requests, 20, "bbcode", "german", config
    )
    assert_equal(len(serial.requests), len(parallel.requests))
    for index in range(len(serial.requests)):
        assert_equal(serial.requests[index].domain, parallel.requests[index].domain)
        assert_equal(
            serial.requests[index].denominator,
            parallel.requests[index].denominator,
        )
    assert_equal(serial.reciprocal_flags, parallel.reciprocal_flags)
    assert_equal(serial.columns, parallel.columns)


def test_single_fraction_column_uses_row_chunks_without_reordering() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var config = make_parallel_config(
        "threads", 3, 2, 1, "", "fraction-row-parity"
    )
    # At denominator 20 the universe source emits only the reciprocal column.
    var requests = [FractionColumnRequest("universe", 20)]
    var serial = generate_fraction_concat_columns(
        table, requests, 20, "shell", "german"
    )
    var parallel = generate_fraction_concat_columns_parallel(
        table, requests, 20, "shell", "german", config
    )
    assert_equal(len(parallel.columns), 1)
    assert_equal(serial.columns, parallel.columns)

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
