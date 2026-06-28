from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import read_semicolon_csv
from reta_mojo.kombi_join_columns import *


def test_alias_catalog_resolves_both_languages() raises:
    var catalog = load_kombi_alias_catalog()
    var german = resolve_kombi_alias(catalog, "german", "galaxie", "tiere")
    var english = resolve_kombi_alias(catalog, "english", "universe", "transcendence")
    assert_equal(german.kind, "galaxy")
    assert_equal(german.column, 1)
    assert_equal(english.kind, "universe")
    assert_equal(english.column, 5)


def test_single_galaxy_join_preserves_relation_order() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var joined = apply_kombi_join_columns(
        table, [KombiColumnRequest("galaxy", 1)], 3
    )
    assert_equal(len(joined.output_columns), 1)
    var column = joined.output_columns[0]
    assert_true(
        joined.table.rows[1][column].startswith(
            "(2|-5|-9|1/12|+13|21|23|24|-26|40|41|45|68)"
        )
    )
    assert_true(joined.table.rows[1][column].find("Mikroorganismen (1)") >= 0)


def test_multi_column_join_keeps_internal_empty_segments() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var joined = apply_kombi_join_columns(
        table,
        [
            KombiColumnRequest("galaxy", 1),
            KombiColumnRequest("galaxy", 2),
        ],
        1,
    )
    assert_equal(len(joined.output_columns), 2)
    var jobs = joined.table.rows[1][joined.output_columns[1]]
    assert_true(jobs.startswith("@@RETA_COMBI_LEADING_SPACE@@Zauberkünstler"))
    assert_true(jobs.find(" |  |  | ") >= 0)


def test_universe_heading_keeps_meta_prefix() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var joined = apply_kombi_join_columns(
        table, [KombiColumnRequest("universe", 1)], 1
    )
    var heading = joined.table.rows[0][joined.output_columns[0]]
    assert_true(heading.startswith("(Vorzeichen:"))
    assert_true(heading.endswith("Gegentranszendentalien)"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
