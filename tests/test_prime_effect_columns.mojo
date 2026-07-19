from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import read_semicolon_csv
from reta_mojo.prime_effect_columns import *
from reta_mojo.parallel_execution import make_parallel_config


def test_source_commands_are_unique_and_sorted() raises:
    var commands: List[String] = [
        "prime_effect:42",
        "prime_effect:none",
        "prime_effect:10",
        "prime_effect:42",
    ]
    assert_equal(prime_effect_sources(commands), [-1, 10, 42])


def test_german_galaxy_effect_matches_reference_rows() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands: List[String] = ["prime_effect:10"]
    var result = generate_prime_effect_columns(table, commands, 12, "german")
    assert_equal(len(result.columns), 1)
    assert_equal(result.columns[0][0], "Primzahlwirkung (7, Richtung) Galaxie n")
    assert_equal(result.columns[0][1], "für außen")
    assert_equal(
        result.columns[0][6],
        '"für seitlich und gegen Schwächlinge innen" + "gegen seitlich und für Schwächlinge innen"',
    )
    assert_true(result.columns[0][8].endswith(' * "für seitlich und gegen Schwächlinge innen"'))


def test_direction_direction_uses_previous_generated_rows() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands: List[String] = ["prime_effect:none"]
    var result = generate_prime_effect_columns(table, commands, 8, "english")
    assert_equal(
        result.columns[0][4],
        '["for other sides and against weaklings inside"] * finally: "for other sides and against weaklings inside"',
    )


def test_parallel_prime_effect_columns_match_serial() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands: List[String] = [
        "prime_effect:none",
        "prime_effect:10",
        "prime_effect:42",
    ]
    var config = make_parallel_config(
        "threads", 3, 2, 1, "", "prime-effect-parity"
    )
    var serial = generate_prime_effect_columns(
        table, commands, 30, "german"
    )
    var parallel = generate_prime_effect_columns_parallel(
        table, commands, 30, "german", config
    )
    assert_equal(serial.source_columns, parallel.source_columns)
    assert_equal(serial.columns, parallel.columns)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
