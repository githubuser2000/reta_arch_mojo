from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.concat_csv import RationalPair, rational
from reta_mojo.csv_table import CsvTable
from reta_mojo.legacy_lib4tables_concat import *
from reta_mojo.runtime_compat import NPM_GAL_N


def _table() -> CsvTable:
    var rows = List[List[String]]()
    for row_index in range(10):
        var row = List[String]()
        for _ in range(60):
            row.append("")
        row[4] = "size-" + String(row_index)
        row[8] = "love-" + String(row_index)
        row[10] = "direct-" + String(row_index)
        row[42] = "inverse-" + String(row_index)
        rows.append(row^)
    return CsvTable(rows^, 60)


def test_snapshot_covers_all_python_methods() raises:
    var snapshot = legacy_concat_snapshot()
    assert_equal(len(snapshot.method_mappings), 34)
    assert_equal(snapshot.method_mappings[0].legacy_name, "concatLovePolygon")
    assert_equal(snapshot.method_mappings[33].legacy_name, "readConcatCsv_SetHtmlParamaters")
    assert_equal(snapshot.csv_same_keys, [1, 2, 3, 4, 5])
    assert_equal(snapshot.csv_same_values[1], [2, 4])
    assert_equal(len(snapshot.state_sections), 13)


def test_initial_state_matches_python_constructor() raises:
    var state = create_legacy_concat_state()
    assert_equal(len(state.ones), 0)
    assert_equal(len(state.csvs_already_read), 0)
    assert_equal(state.csv_same_values[4], [3, 5])
    assert_equal(len(state.fractions_universe), 0)
    assert_equal(len(state.div_uniform_galaxy), 0)


def test_scalar_and_love_aliases() raises:
    var table = _table()
    assert_equal(gleichheitFreiheitVergleich(4), "Dominieren, Unterordnen")
    assert_true(geistEmotionEnergieMaterieTopologie(12).byte_length() > 0)
    assert_equal(concatPrimCreativityType(1), "0. Primzahl 1")
    assert_true(concatLovePolygon(table, 2).find("love-2") >= 0)
    assert_true(concatLovePolygon(table, 2).find("size-2") >= 0)


def test_pair_aliases_forward_to_concat_owner() raises:
    var pairs: List[RationalPair] = [
        RationalPair(rational(6), rational(2)),
        RationalPair(rational(8), rational(2)),
    ]
    var divided = convertSetOfPaarenToDictOfNumToPaareDiv(pairs)
    assert_equal(len(divided[3]), 1)
    assert_equal(len(divided[4]), 1)
    var multiplied = convertSetOfPaarenToDictOfNumToPaareMul(pairs)
    assert_equal(len(multiplied[12]), 1)
    assert_equal(len(multiplied[16]), 1)


def test_concat_alias_attaches_selected_fraction_columns() raises:
    var table = _table()
    var source = CsvTable(
        [
            ["1/1", "1/2", "1/3", "1/4"],
            ["2/1", "2/2", "2/3", "2/4"],
            ["3/1", "3/2", "3/3", "3/4"],
        ],
        4,
    )
    var result = readConcatCsv(table, source, [2, 3], NPM_GAL_N)
    assert_equal(len(result.selected_columns), 2)
    assert_equal(result.metadata[0].source_bucket, 6)
    assert_true(readConcatCSV_choseCsvFile(NPM_GAL_N).endswith("gebrochen-rational-galaxie.csv"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
