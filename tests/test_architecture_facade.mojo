from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.architecture_facade import *


def test_facade_catalog_counts_and_validation() raises:
    var catalog = load_architecture_facade_catalog()
    var snapshot = architecture_facade_snapshot(catalog)
    assert_equal(snapshot.fields, 45)
    assert_equal(snapshot.methods, 49)
    assert_equal(snapshot.bootstrap_steps, 45)
    assert_equal(snapshot.snapshot_entries, 48)
    assert_equal(snapshot.force_rebuild_methods, 44)
    assert_equal(snapshot.dependency_edges, 98)
    assert_true(architecture_facade_catalog_valid(catalog))


def test_facade_preserves_distinct_field_and_bootstrap_order() raises:
    var catalog = load_architecture_facade_catalog()
    var fields = architecture_facade_entries_for_kind(catalog, "field")
    var bootstraps = architecture_facade_entries_for_kind(catalog, "bootstrap")
    assert_equal(fields[0].name, "repo_root")
    assert_equal(fields[19].name, "architecture_validation")
    assert_equal(fields[33].name, "program_workflow")
    assert_equal(bootstraps[0].name, "repo_root")
    assert_equal(bootstraps[30].name, "architecture_validation")
    assert_equal(bootstraps[44].name, "program_workflow")


def test_facade_dependency_graph_is_typed() raises:
    var catalog = load_architecture_facade_catalog()
    var validation = architecture_facade_dependencies(
        catalog, "bootstrap_architecture_validation"
    )
    assert_equal(len(validation), 15)
    assert_equal(validation[0], "bootstrap_category_theory")
    assert_equal(validation[14], "bootstrap_nested_completion")
    var generation = architecture_facade_dependencies(
        catalog, "bootstrap_table_generation"
    )
    assert_equal(generation, [
        "bootstrap_generated_columns",
        "bootstrap_concat_csv",
        "bootstrap_combi_join",
    ])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
