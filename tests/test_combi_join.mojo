from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.combi_join import *
from reta_mojo.csv_table import CsvTable
from reta_mojo.kombi_join_columns import KombiColumnRequest


def _small_main() -> CsvTable:
    return CsvTable([["h0", "h1"], ["1", "a"], ["2", "b"]], 2)


def test_number_parser_matches_legacy_recursive_contract() raises:
    assert_equal(parse_kombi_number_token("-13"), [13])
    assert_equal(parse_kombi_number_token("(+7)"), [7])
    assert_equal(parse_kombi_number_token("12/5"), [12, 5])
    assert_equal(parse_kombi_expression_numbers("1|-2|(3/4)"), [1, 2, 3, 4])


def test_real_sources_decode_without_ordered_containers() raises:
    var galaxy = load_kombi_join_source("galaxy")
    var universe = load_kombi_join_source("universe")
    assert_true(len(galaxy.decorated_table.rows) > 10)
    assert_true(len(universe.decorated_table.rows) > 10)
    assert_equal(len(galaxy.combinations), len(galaxy.decorated_table.rows) - 1)
    assert_equal(len(universe.combinations), len(universe.decorated_table.rows) - 1)
    assert_true(galaxy.decorated_table.rows[2][2].startswith("("))


def test_prepare_kombi_is_canonical_and_order_independent() raises:
    var combinations: List[List[Int]] = [[2, 1], [3, 2], [1]]
    var first = select_kombi_lines(["ka"], [2, 1], combinations)
    var second = select_kombi_lines(["ka2"], [1, 2], combinations)
    assert_equal(len(first), 2)
    assert_equal(first[0].main_number, 1)
    assert_equal(first[0].source_rows, [1, 3])
    assert_equal(first[1].main_number, 2)
    assert_equal(first[1].source_rows, [1, 2])
    assert_equal(first[0].main_number, second[0].main_number)
    assert_equal(first[0].source_rows, second[0].source_rows)
    assert_equal(first[1].source_rows, second[1].source_rows)


def test_read_phase_appends_all_source_slots_and_selects_requested_columns() raises:
    var source = load_kombi_join_source("galaxy")
    var appended = append_kombi_placeholders(_small_main(), source, [2, 1, 2])
    assert_equal(
        appended.table.maximum_columns,
        2 + source.decorated_table.maximum_columns - 1,
    )
    assert_equal(len(appended.relations), source.decorated_table.maximum_columns - 1)
    assert_equal(appended.relations[0].appended_column, 2)
    assert_equal(appended.relations[0].source_column, 0)
    assert_equal(appended.selected_columns, [2, 3])
    assert_equal(appended.table.rows[0][2], source.decorated_table.rows[0][1])
    assert_equal(appended.table.rows[1][2], "")


def test_prepare_table_join_copies_selected_real_rows() raises:
    var source = load_kombi_join_source("galaxy")
    var selected: List[KombiLineSelection] = [
        KombiLineSelection(1, [2, 1]),
        KombiLineSelection(2, [3]),
    ]
    var groups = prepare_kombi_join_tables(selected, source)
    assert_equal(len(groups), 2)
    assert_equal(groups[0].main_number, 1)
    assert_equal(len(groups[0].source_rows), 2)
    assert_equal(groups[0].source_rows[0], source.decorated_table.rows[1])
    assert_equal(groups[0].source_rows[1], source.decorated_table.rows[2])


def test_remove_number_preserves_provenance_and_fraction_tokens() raises:
    assert_equal(
        remove_kombi_number_from_cell("(1|2|3/4) Inhalt (1|2|3/4)", 2),
        "(1|3/4) Inhalt (1|2|3/4)",
    )
    assert_equal(
        remove_kombi_number_from_cell("(2) Inhalt (2)", 2),
        " Inhalt (2)",
    )
    assert_equal(remove_kombi_number_from_cell("ohne Präfix", 2), "ohne Präfix")


def test_table_join_alias_uses_existing_native_join_owner() raises:
    var result = tableJoin(
        _small_main(), [KombiColumnRequest("galaxy", 1)], 2
    )
    assert_equal(len(result.output_columns), 1)
    assert_true(result.table.rows[1][result.output_columns[0]].byte_length() > 0)


def test_bundle_covers_all_historical_morphisms() raises:
    var bundle = bootstrap_combi_join()
    assert_equal(bundle.implementation, "KombiJoin")
    assert_equal(len(bundle.morphisms), 6)
    assert_equal(len(bundle.csv_sources), 2)
    assert_true(bundle.csv_sources[0].endswith("kombi.csv"))
    assert_true(bundle.csv_sources[1].endswith("kombi-meta.csv"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
