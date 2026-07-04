from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import CsvTable
from reta_mojo.table_generation import *


def _small_table() -> CsvTable:
    var rows = List[List[String]]()
    rows.append(["h0", "h1", "h2"])
    rows.append(["a", "b", "c"])
    rows.append(["d", "e", "f"])
    return CsvTable(rows^, 3)


def test_table_generation_bundle_snapshot_covers_python_contract() raises:
    var snapshot = bootstrap_table_generation().snapshot()
    assert_equal(snapshot.class_name, "TableGenerationBundle")
    assert_equal(len(snapshot.csv_sources), 5)
    assert_equal(len(snapshot.generated_morphisms), 12)
    assert_equal(snapshot.table_preparation_dependency, "capture_last_line_number")
    assert_equal(len(snapshot.kombi_csvs), 2)


def test_capture_last_line_number_clamps_to_physical_table() raises:
    var table = _small_table()
    assert_equal(capture_last_line_number(table, -1), 2)
    assert_equal(capture_last_line_number(table, 1), 1)
    assert_equal(capture_last_line_number(table, 99), 2)


def test_empty_generation_plan_preserves_table_and_selection() raises:
    var plan = default_table_generation_plan()
    plan.selected_columns = [0, 2]
    plan.requested_last_line = 1
    var result = bootstrap_table_generation().build_for_program(
        _small_table(), plan
    )
    assert_equal(len(result.table.rows), 3)
    assert_equal(result.table.maximum_columns, 3)
    assert_equal(result.last_line_number, 1)
    assert_equal(len(result.output_columns), 2)
    assert_equal(result.output_columns[0], 0)
    assert_equal(result.output_columns[1], 2)
    assert_equal(len(result.generated_names), 0)


def test_result_snapshot_preserves_legacy_observable_fields() raises:
    var result = bootstrap_table_generation().build_for_program(
        _small_table(), default_table_generation_plan()
    )
    var snapshot = result.snapshot()
    assert_equal(snapshot.class_name, "TableGenerationResult")
    assert_true(not snapshot.has_prim_spalten)
    assert_equal(len(snapshot.gebr_keys), 0)
    assert_equal(snapshot.kombi_rows_len, 0)
    assert_equal(snapshot.animals_professions_table_len, 0)
    assert_equal(snapshot.animals_professions_table2_len, 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
