from std.collections import Dict, List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.concat_csv import *
from reta_mojo.csv_table import CsvTable, read_semicolon_csv
from reta_mojo.runtime_compat import NPM_GAL_N, NPM_UNI_1_PLUS_N


def _synthetic_main() -> CsvTable:
    var rows = List[List[String]]()
    for row_index in range(8):
        var row = List[String]()
        for _ in range(50):
            row.append("")
        row[0] = "row" + String(row_index)
        row[10] = "galaxy-direct-" + String(row_index)
        row[42] = "galaxy-inverse-" + String(row_index)
        rows.append(row^)
    return CsvTable(rows^, 50)


def _synthetic_fraction_source() -> CsvTable:
    var rows = List[List[String]]()
    for row_index in range(8):
        var row = List[String]()
        for column_index in range(6):
            row.append(
                "fraction-" + String(row_index + 1) + "-" + String(column_index + 1)
            )
        rows.append(row^)
    return CsvTable(rows^, 6)


def _synthetic_prime_source() -> CsvTable:
    return CsvTable(
        [
            ["head"],
            ["abcd", "x", "efgh"],
            ["ijkl", "mnop"],
            ["qrst"],
        ],
        3,
    )


def test_bundle_and_source_contract() raises:
    var bundle = bootstrap_concat_csv()
    assert_equal(len(bundle.specs), 4)
    assert_equal(bundle.specs[0].method_name, "readConcatCsv")
    assert_equal(len(bundle.csv_sources), 5)
    assert_equal(concat_csv_filename(1), "primenumbers.csv")
    assert_equal(concat_csv_filename(NPM_GAL_N), "gebrochen-rational-galaxie.csv")
    assert_equal(concat_csv_domain(NPM_UNI_1_PLUS_N), "universe")
    assert_true(concat_csv_is_reciprocal(NPM_UNI_1_PLUS_N))


def test_exact_pair_grouping_and_combination() raises:
    var pairs = List[RationalPair]()
    pairs.append(RationalPair(rational(6), rational(2)))
    pairs.append(RationalPair(rational(3, 2), rational(1, 2)))
    pairs.append(RationalPair(rational(6), rational(2)))
    var divided = group_pairs_by_division(pairs)
    assert_equal(len(divided[3]), 2)
    assert_equal(divided[3][0].first.numerator, 6)
    assert_equal(len(divided), 1)
    var multiplication_pairs = List[RationalPair]()
    multiplication_pairs.append(RationalPair(rational(6), rational(2)))
    multiplication_pairs.append(RationalPair(rational(3, 2), rational(2)))
    var multiplied = group_pairs_by_multiplication(multiplication_pairs)
    assert_equal(len(multiplied[12]), 1)
    assert_equal(len(multiplied[3]), 1)
    var combined = combine_pair_groups(divided, multiplied)
    assert_true(3 in combined)
    assert_true(12 in combined)


def test_fraction_expansion_matches_integral_contract() raises:
    var fractions: List[RationalValue] = [rational(2, 3), rational(3, 2)]
    var secondary: List[RationalValue] = [rational(3, 2), rational(1, 2)]
    var expanded = expand_fraction_pairs(fractions, secondary, 12)
    assert_true(2 in expanded)
    assert_true(4 in expanded)
    assert_true(9 in expanded)
    var reciprocal = expand_fraction_pairs(fractions, secondary, 12, True)
    assert_true(3 in reciprocal)
    assert_true(6 in reciprocal)


def test_transpose_and_fraction_headings() raises:
    var source = CsvTable([["a", "b", "c"], ["d", "e", "f"]], 3)
    var transposed = transpose_csv_table(source)
    assert_equal(len(transposed.rows), 3)
    assert_equal(transposed.rows[0], ["a", "d"])
    var prepared = prepare_fraction_concat_source(source, NPM_GAL_N, "german")
    assert_equal(prepared.rows[0][0], "n/1 Galaxie")
    assert_equal(prepared.rows[0][2], "n/3 Galaxie")
    var reciprocal = prepare_fraction_concat_source(source, NPM_UNI_1_PLUS_N, "english")
    assert_equal(reciprocal.rows[0][0], "1/n universe")
    assert_equal(len(reciprocal.rows), 4)


def test_prime_compaction_modes() raises:
    var source = CsvTable(
        [["head"], ["abcd", "x", "efgh"], ["", "  "]], 3
    )
    var csv = prepare_prime_concat_source(source, "csv", "german")
    assert_equal(csv.rows[0][0], "Primzahlvielfache, nicht generiert")
    assert_equal(csv.rows[1][0], "| abcd | efgh |")
    assert_equal(csv.rows[2][0], "|")
    var html = prepare_prime_concat_source(source, "html", "english")
    assert_equal(html.rows[1][0], "<ul><li>abcd</li><li>efgh</li></ul>")
    var bbcode = prepare_prime_concat_source(source, "bbcode", "english")
    assert_equal(bbcode.rows[1][0], "[list][*]abcd[*]efgh[/list]")


def test_synthetic_fraction_attachment_and_metadata() raises:
    var main_table = _synthetic_main()
    var source = _synthetic_fraction_source()
    var result = append_concat_csv(
        main_table, source, [2, 4], NPM_GAL_N, "csv", "german"
    )
    assert_equal(len(result.selected_columns), 2)
    assert_equal(result.selected_columns[0], len(main_table.rows[0]) + 1)
    assert_equal(result.selected_columns[1], len(main_table.rows[0]) + 3)
    assert_equal(result.metadata[0].source_bucket, 6)
    assert_equal(result.metadata[0].source_index, 2)
    assert_equal(result.metadata[1].source_index, 4)
    assert_true(len(result.table.rows[1]) > len(main_table.rows[1]))


def test_synthetic_prime_attachment_selects_one_column() raises:
    var main_table = _synthetic_main()
    var source = _synthetic_prime_source()
    var result = append_concat_csv(main_table, source, [2], 1, "csv", "german")
    assert_equal(len(result.selected_columns), 1)
    assert_equal(result.selected_columns[0], len(main_table.rows[0]))
    assert_equal(result.metadata[0].tag_group, "Multiplikationen")
    assert_equal(result.metadata[0].tag_name, "Nicht_generiert")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
