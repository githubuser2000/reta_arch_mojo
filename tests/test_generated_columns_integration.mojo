from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.csv_table import CsvTable
from reta_mojo.generated_aliases import (
    FractionColumnRequest,
    MetaColumnRequest,
    ModalConcept,
)
from reta_mojo.generated_columns_integration import *


def _empty_request(table: CsvTable) -> GeneratedColumnsApplicationRequest:
    return GeneratedColumnsApplicationRequest(
        table,
        List[Int](),
        List[ModalConcept](),
        List[MetaColumnRequest](),
        List[FractionColumnRequest](),
        List[String](),
        "german",
        "shell",
        len(table.rows) - 1,
    )


def test_typed_request_replaces_dynamic_concat_boundary() raises:
    var runtime = bootstrap_generated_columns_runtime()
    var snapshot = runtime.snapshot()
    assert_equal(snapshot.class_name, "GeneratedColumnsRuntime")
    assert_equal(snapshot.registry_count, 10)
    assert_equal(snapshot.request_fields, 9)
    assert_true(snapshot.ordered_pipeline)
    assert_false(snapshot.dynamic_concat_object)
    assert_false(snapshot.python_runtime)
    assert_equal(len(generated_columns_integration_contract()), 13)


def test_empty_plan_preserves_table_and_selection() raises:
    var table = CsvTable(
        [
            ["h0", "h1"],
            ["a", "b"],
            ["c", "d"],
        ],
        2,
    )
    var result = apply_generated_columns_request(_empty_request(table))
    assert_equal(result.table.rows, table.rows)
    assert_equal(result.table.maximum_columns, 2)
    assert_equal(len(result.output_columns), 0)
    assert_equal(len(result.generated_names), 0)


def test_scalar_trigger_runs_through_owned_pipeline() raises:
    var table = CsvTable(
        [
            ["header"],
            ["one"],
            ["two"],
        ],
        1,
    )
    var request = _empty_request(table)
    request.selected_columns = [132]
    var result = bootstrap_generated_columns_runtime().apply(request)
    assert_equal(result.table.maximum_columns, 2)
    assert_equal(result.output_columns, [132, 1])
    assert_equal(
        result.generated_names,
        ["concatGleichheitFreiheitDominieren"],
    )
    assert_equal(result.table.rows[0][1], "Gleichheit, Freiheit, Dominieren (Ordnungen [12]) Generiert")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
