from std.collections import Dict, List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.parameter_semantics import *
from reta_mojo.schema_catalog import bootstrap_reta_schema
from reta_mojo.sheaves import *
from reta_mojo.table_state import *


def test_complete_sheaf_bundle_loads_native_catalogs() raises:
    var bundle = SheafBundle.from_repo("", bootstrap_reta_schema())
    var snapshot = bundle.snapshot()
    assert_equal(snapshot.parameter_semantics.main_alias_groups, 33)
    assert_equal(snapshot.parameter_semantics.pair_to_columns, 428)
    assert_equal(snapshot.generated_columns.generated_spalten_parameter_count, 0)
    assert_equal(snapshot.table_output.section_count, 0)
    assert_equal(snapshot.html_reference_size, 669)


def test_parameter_semantics_full_surface() raises:
    var sheaf = build_parameter_semantics(bootstrap_reta_schema())
    var groups = canonical_main_alias_groups(sheaf)
    assert_equal(len(groups), 33)
    var metadata = exact_meta_for_column(sheaf, 4)
    assert_true(len(metadata) > 0)
    sync_program_semantics(sheaf, 17, [3, 5, 8])
    var snapshot = parameter_semantics_snapshot(sheaf)
    assert_equal(snapshot.global_parameter_dict_size, 17)
    assert_equal(len(snapshot.global_data_dict_sizes), 3)


def test_generated_columns_sheaf_copies_explicit_table_state() raises:
    var state = create_table_state()
    state.generated_columns.parameters[700] = "generated"
    state.generated_columns.tags[700] = "tag"
    var sheaf = GeneratedColumnsSheaf()
    sheaf.sync_from_tables(state)
    assert_equal(sheaf.generated_spalten_parameter[700], "generated")
    assert_equal(sheaf.generated_spalten_parameter_tags[700], "tag")
    state.generated_columns.parameters[700] = "changed"
    assert_equal(sheaf.generated_spalten_parameter[700], "generated")


def test_table_output_sheaf_replaces_mode_section() raises:
    var sheaf = TableOutputSheaf()
    var first = List[List[String]]()
    first.append(["a", "b"])
    sheaf.sync_from_tables(first, "html", [1], True, [0, 1], True)
    assert_equal(sheaf.snapshot().section_count, 1)
    var second = List[List[String]]()
    second.append(["c"])
    sheaf.sync_from_tables(second, "html")
    assert_equal(sheaf.snapshot().section_count, 1)
    assert_equal(sheaf.section("html").resulting_table[0][0], "c")


def test_html_reference_sheaf_keeps_complete_json_payload() raises:
    var sheaf = HtmlReferenceSheaf.from_jsonl()
    var payload = sheaf.html_meta_for_column(0)
    assert_true("\"column_number\":0" in payload)
    assert_true("\"raw_html\"" in payload)
    assert_equal(sheaf.html_meta_for_column(999999), "{}")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
