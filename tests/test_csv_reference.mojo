from std.testing import assert_equal, TestSuite
from reta_mojo.csv_table import *

def _check(path: String, rows: Int, columns: Int, cells: Int, fingerprint: Int) raises:
    var table = read_semicolon_csv(path)
    assert_equal(len(table.rows), rows)
    assert_equal(table.maximum_columns, columns)
    assert_equal(table_cell_count(table), cells)
    assert_equal(table_fingerprint(table), fingerprint)

def test_reference_csv_files() raises:
    _check("python_reference/csv/2024-07-06-symbols-alt-ak-circle-sphere-etc.csv", 25, 10, 250, 984076100)
    _check("python_reference/csv/dualism-trinities-etc.csv", 24, 10, 240, 886210717)
    _check("python_reference/csv/gebrochen-rational-emotionen.csv", 7, 7, 49, 68041684)
    _check("python_reference/csv/gebrochen-rational-galaxie.csv", 21, 21, 441, 77991590)
    _check("python_reference/csv/gebrochen-rational-strukturgroesse.csv", 16, 16, 256, 479943425)
    _check("python_reference/csv/gebrochen-rational-universum.csv", 21, 19, 399, 819168685)
    _check("python_reference/csv/kombi-gedanken17-absichten13-bewusstsein15.csv", 10, 4, 40, 470300307)
    _check("python_reference/csv/kombi-meta-systeme.csv", 2, 2, 4, 644292270)
    _check("python_reference/csv/kombi-meta.csv", 262, 20, 5240, 187090895)
    _check("python_reference/csv/kombi-universelle-wirklichkeit.csv", 2, 3, 6, 256721202)
    _check("python_reference/csv/kombi.csv", 261, 18, 4698, 804734098)
    _check("python_reference/csv/kreisVomTyp18.csv", 20, 2, 40, 346715935)
    _check("python_reference/csv/meaningOfLife.csv", 5, 11, 55, 290752941)
    _check("python_reference/csv/primenumbers.csv", 101, 11, 1111, 330672468)
    _check("python_reference/csv/religion.csv", 1025, 746, 764650, 59471017)
    _check("python_reference/csv/sunMoonEtc.csv", 114, 6, 684, 903396446)

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
