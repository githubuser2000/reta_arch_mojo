from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import read_semicolon_csv
from reta_mojo.prime_universe_columns import *
from reta_mojo.parallel_execution import make_parallel_config


def test_integer_command_coordinates_are_deduplicated_and_ordered() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands: List[String] = ["primMotivStern", "primStrukStern"]
    var generated = generate_integer_prime_universe_columns(
        table, commands, 8, "csv", "german"
    )
    assert_equal(len(generated.coordinates), 4)
    for index in range(4):
        assert_equal(generated.coordinates[index].polygon, 0)
        assert_equal(generated.coordinates[index].combination, index)
    assert_equal(len(generated.columns), 4)


def test_german_star_motif_headings_and_rows() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands: List[String] = ["primMotivStern"]
    var generated = generate_integer_prime_universe_columns(
        table, commands, 6, "csv", "german"
    )
    assert_equal(len(generated.columns), 3)
    assert_equal(
        generated.columns[0][0],
        "generierte Multiplikationen Sternpolygone Motiv -> Motiv",
    )
    assert_equal(
        generated.columns[1][0],
        "generierte Multiplikationen Sternpolygone Motiv -> Strukur",
    )
    assert_true(generated.columns[0][4].find(" * ") >= 0)
    assert_true(generated.columns[0][4].find("außerdem") >= 0)
    assert_equal(generated.columns[0][7], "")


def test_english_regular_structure_heading() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands: List[String] = ["primStrukGleichf"]
    var generated = generate_integer_prime_universe_columns(
        table, commands, 5, "csv", "english"
    )
    assert_equal(len(generated.columns), 3)
    assert_equal(generated.coordinates[2].polygon, 1)
    assert_equal(generated.coordinates[2].combination, 3)
    assert_equal(
        generated.columns[2][0],
        "generated multiplicationsregular polygons Structure -> Structure",
    )


def test_fraction_catalog_preserves_legacy_pair_order() raises:
    var coordinates = List[PrimeUniverseCoordinate]()
    coordinates.append(PrimeUniverseCoordinate(0, 0))
    var entries = load_fraction_pair_entries(
        "assets/fraction_pairs.tsv", coordinates, 1
    )
    assert_true(len(entries) >= 3)
    assert_equal(entries[0].combination, 0)
    assert_equal(entries[0].polygon, 0)
    assert_equal(entries[0].result_number, 1)
    assert_equal(entries[0].order, 0)
    assert_equal(entries[0].first.numerator, 2)
    assert_equal(entries[0].first.denominator, 9)
    assert_equal(entries[0].second.numerator, 9)
    assert_equal(entries[0].second.denominator, 2)
    assert_equal(entries[1].first.numerator, 7)
    assert_equal(entries[1].first.denominator, 3)


def test_fractional_motif_star_generates_three_exact_columns() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands: List[String] = ["primMotivSternGebr"]
    var generated = generate_fractional_prime_universe_columns(
        table, commands, 3, "csv", "german"
    )
    assert_equal(len(generated.coordinates), 3)
    assert_equal(len(generated.columns), 3)
    assert_equal(
        generated.columns[0][0],
        "generierte Multiplikationen Sternpolygone Motiv -> Motiv, mit Faktoren aus gebrochen-rationalen Zahlen",
    )
    assert_true(generated.columns[0][1].find("(2/9)*(9/2)") >= 0)
    assert_true(generated.columns[0][1].find("| außerdem: ") >= 0)


def test_fractional_english_heading_and_separator() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands: List[String] = ["primMotivSternGebr"]
    var generated = generate_fractional_prime_universe_columns(
        table, commands, 1, "csv", "english"
    )
    assert_equal(
        generated.columns[0][0],
        "generated multiplicationsstar_polygons Motif -> Motif, with factors from fractional-rational numbers",
    )
    assert_true(generated.columns[0][1].find("| moreover:") >= 0)


def test_parallel_prime_universe_columns_match_serial() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var config = make_parallel_config(
        "threads", 3, 2, 1, "", "prime-universe-parity"
    )
    var integer_commands: List[String] = [
        "primMotivStern", "primStrukStern"
    ]
    var serial_integer = generate_integer_prime_universe_columns(
        table, integer_commands, 20, "bbcode", "german"
    )
    var parallel_integer = generate_integer_prime_universe_columns_parallel(
        table, integer_commands, 20, "bbcode", "german", config
    )
    assert_equal(
        len(serial_integer.coordinates), len(parallel_integer.coordinates)
    )
    for index in range(len(serial_integer.coordinates)):
        assert_equal(
            serial_integer.coordinates[index].polygon,
            parallel_integer.coordinates[index].polygon,
        )
        assert_equal(
            serial_integer.coordinates[index].combination,
            parallel_integer.coordinates[index].combination,
        )
    assert_equal(serial_integer.columns, parallel_integer.columns)

    var fraction_commands: List[String] = ["primMotivSternGebr"]
    var serial_fraction = generate_fractional_prime_universe_columns(
        table, fraction_commands, 20, "bbcode", "german"
    )
    var parallel_fraction = generate_fractional_prime_universe_columns_parallel(
        table, fraction_commands, 20, "bbcode", "german", config
    )
    assert_equal(
        len(serial_fraction.coordinates), len(parallel_fraction.coordinates)
    )
    for index in range(len(serial_fraction.coordinates)):
        assert_equal(
            serial_fraction.coordinates[index].polygon,
            parallel_fraction.coordinates[index].polygon,
        )
        assert_equal(
            serial_fraction.coordinates[index].combination,
            parallel_fraction.coordinates[index].combination,
        )
    assert_equal(serial_fraction.columns, parallel_fraction.columns)

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
