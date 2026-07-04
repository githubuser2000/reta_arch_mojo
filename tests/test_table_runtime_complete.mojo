from std.collections import List, Set
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.table_runtime import (
    Tables,
    _concat_class,
    _get_text_wrap_things,
    _prepare_class,
    bootstrap_table_runtime,
    table_reduced_in_lines_by_type_set,
)
from reta_mojo.table_state import bootstrap_table_state


def test_bundle_snapshot_matches_python_contract() raises:
    var snapshot = bootstrap_table_runtime().snapshot()
    assert_equal(snapshot.class_name, "TableRuntimeBundle")
    assert_equal(snapshot.table_class, "Tables")
    assert_true(snapshot.owns_legacy_tables)
    assert_equal(snapshot.legacy_facade, "libs/tableHandling.py")
    assert_equal(snapshot.state_sections.class_name, "TableStateBundle")
    assert_equal(snapshot.state_sections.sections[0], "highest_rows")
    assert_equal(snapshot.state_sections.sections[4], "generated_rows")
    assert_equal(len(snapshot.component_morphisms), 5)
    assert_equal(snapshot.component_morphisms[0], "Prepare")
    assert_equal(snapshot.component_morphisms[4], "GeneratedColumns")


def test_tables_constructor_owns_and_synchronizes_runtime_sections() raises:
    var tables = bootstrap_table_runtime().create_tables(42, ["txt"], 80)
    var snapshot = tables.snapshot()
    assert_equal(snapshot.class_name, "Tables")
    assert_equal(snapshot.highest_main, 42)
    assert_equal(snapshot.highest_multiple, 42)
    assert_equal(snapshot.output_mode, "shell")
    assert_true(snapshot.numbering)
    assert_equal(snapshot.text_width, 21)
    assert_false(snapshot.no_headings)

    tables.set_keineUeberschriften(True)
    tables.set_keineleereninhalte(True)
    tables.set_spaltegGestirn(True)
    tables.set_ifZeilenSetted(True)
    tables.set_ifPrimMultis(True)
    tables.set_nummeriere(False)
    tables.set_textHeight(7)
    tables.set_textWidth(30)
    tables.set_breitenn([5, 30])
    snapshot = tables.snapshot()
    assert_true(snapshot.no_headings)
    assert_true(snapshot.no_empty_contents)
    assert_true(snapshot.star_column)
    assert_true(snapshot.rows_were_set)
    assert_true(snapshot.prime_multiples)
    assert_false(snapshot.numbering)
    assert_equal(snapshot.text_height, 7)
    assert_equal(snapshot.text_width, 30)
    assert_equal(tables.breitenn(), [5, 30])
    assert_true(tables.getOut.config.no_headings)
    assert_true(tables.getOut.config.no_blank_contents)
    assert_false(tables.getPrepare.state.numbering)


def test_output_mode_and_zero_width_contract_are_native() raises:
    var tables = bootstrap_table_runtime().create_tables(10, List[String](), 80)
    tables.set_outType("html")
    assert_equal(tables.outputModeName(), "html")
    assert_true(tables.htmlOutputYes())
    assert_false(tables.markdownOutputYes())
    assert_equal(tables.outType().syntax_class_name, "htmlSyntax")
    tables.set_textWidth(0)
    assert_equal(tables.textWidth(), 0)


def test_fill_both_and_row_reduction_preserve_order() raises:
    var filled = Tables.fillBoth(["a"], ["b", "c"])
    assert_equal(filled[0], ["a", ""])
    assert_equal(filled[1], ["b", "c"])
    var allowed = Set[Int]()
    allowed.add(0)
    allowed.add(2)
    var table = parse_semicolon_csv("h\na\nb\nc\n")
    var reduced = table_reduced_in_lines_by_type_set(table, allowed)
    assert_equal(len(reduced.rows), 2)
    assert_equal(reduced.rows[0][0], "h")
    assert_equal(reduced.rows[1][0], "b")


def test_gestirn_generation_updates_owned_state() raises:
    var tables = bootstrap_table_runtime().create_tables(4)
    var selected = Set[Int]()
    selected.add(64)
    var table = parse_semicolon_csv("h\na\nb\nc\n")
    tables.set_SpaltenVanillaAmount(7)
    var result = tables.createSpalteGestirn(table, selected)
    assert_true(result.applied)
    assert_equal(result.generated_source_column, 64)
    assert_equal(result.appended_table_column, 1)
    assert_equal(result.generated_output_column, 1)
    assert_equal(result.table.maximum_columns, 2)
    assert_equal(result.table.rows[0][1], "Gestirn")
    assert_true(1 in result.rows_as_numbers)
    assert_equal(len(result.tags), 3)
    assert_equal(len(tables.state.generated_columns.parameters), 1)
    assert_true(7 in tables.state.generated_columns.parameters)
    assert_equal(len(tables.state.generated_columns.tags), 1)
    assert_equal(tables.SpaltenVanillaAmount(), 7)
    assert_true(tables.spaltegGestirn())


def test_explicit_component_descriptors_replace_lazy_class_imports() raises:
    var prepare = _prepare_class()
    var concat = _concat_class()
    assert_equal(prepare.class_name, "Prepare")
    assert_equal(concat.class_name, "Concat")
    assert_equal(_get_text_wrap_things(77)[0], 77)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
