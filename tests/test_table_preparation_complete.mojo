from std.collections import List, Set
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.row_filtering import RowFilterConfig
from reta_mojo.table_preparation import *
from reta_mojo.tag_schema import TAG_STERN_POLYGON, TAG_UNIVERSUM, TAG_GALAXIE
from reta_mojo.table_wrapping import default_text_wrap_runtime


def _columns() -> Set[Int]:
    var result = Set[Int]()
    result.add(0)
    result.add(2)
    return result^


def test_bundle_snapshot_matches_reference_surface() raises:
    var snapshot = bootstrap_table_preparation().snapshot()
    assert_equal(snapshot.class_name, "TablePreparationBundle")
    assert_equal(snapshot.display_line_morphism, "select_display_lines")
    assert_equal(snapshot.row_morphism, "prepare_row_cells")
    assert_equal(snapshot.tag_gluing_morphism, "tag_output_column")
    assert_equal(snapshot.cell_morphism, "cell_work")
    assert_equal(snapshot.parallel_row_morphism, "prepare_rows_in_processes")
    assert_equal(snapshot.deduplication_morphism, "deduplicate_parameter_sections")
    assert_equal(snapshot.last_line_morphism, "capture_last_line_number")
    assert_equal(len(snapshot.universal_operations), 5)
    assert_equal(snapshot.main_table_result, "MainTablePreparationResult")
    assert_equal(snapshot.kombi_table_result, "KombiTablePreparationResult")
    assert_equal(snapshot.legacy_delegate, "libs.lib4tables_prepare.Prepare")


def test_complete_output_orchestration_owns_mapping_wrapping_and_numbers() raises:
    var table = parse_semicolon_csv(
        "h0;ignored;h2\nabcdef;skip;xyzq\nhi;skip;終終終終\n"
    )
    var context = make_parallel_row_preparation_context(
        _columns(),
        shell_rows_amount=80,
        widths=[3, 2],
        text_width=21,
        wrapping_runtime=default_text_wrap_runtime(),
    )
    var result = bootstrap_table_preparation().prepare_output_table(
        RowFilterConfig(2, 2, False),
        table,
        List[String](),
        List[String](),
        context,
    )
    assert_equal(result.finally_display_lines, [0, 1, 2])
    assert_equal(result.rows_range, [0, 1, 2])
    assert_equal(result.old2new_table.output_for_source(0), 0)
    assert_equal(result.old2new_table.output_for_source(2), 1)
    assert_equal(result.old2new_table.source_for_output(1), 2)
    assert_equal(result.new_table[1][0], ["abc", "def"])
    assert_equal(result.new_table[1][1], ["xy", "zq"])
    assert_equal(result.religion_numbers, [0, 1, 2])
    assert_equal(result.stats.mode, "serial")
    assert_equal(result.stats.prepared_rows, 3)
    assert_equal(result.stats.prepared_columns, 2)


def test_generated_tag_overrides_are_explicit_and_owned() raises:
    var prime = Set[Int]()
    prime.add(2)
    var overrides = GeneratedTagOverrides(
        prime^, Set[Int](), Set[Int](), Set[Int](), Set[Int]()
    )
    var fresh = bootstrap_table_preparation().tag_output_column(
        2, 1, "header", overrides=overrides
    )
    var tagged = bootstrap_table_preparation().tag_output_column(
        2,
        1,
        "header",
        overrides=overrides,
        parameter_already_present=True,
    )
    assert_true(len(fresh.tags) > 0)
    assert_equal(tagged.output_column, 1)
    assert_equal(tagged.source_column, 2)
    assert_equal(tagged.parameter, "header")
    assert_equal(len(tagged.tags), 3)
    assert_equal(tagged.tags[0], TAG_STERN_POLYGON)
    assert_equal(tagged.tags[1], TAG_UNIVERSUM)
    assert_equal(tagged.tags[2], TAG_GALAXIE)


def test_parameter_deduplication_and_last_line_are_native() raises:
    var first = Set[Int]()
    first.add(1)
    first.add(2)
    var second = Set[Int]()
    second.add(2)
    second.add(3)
    var clean = deduplicate_parameter_sections(first, second)
    assert_true(1 in clean[0])
    assert_true(2 not in clean[0])
    assert_true(3 in clean[1])
    var table = parse_semicolon_csv("h\na\nb\n")
    var selection = select_display_lines(
        RowFilterConfig(2, 2, False),
        table,
        List[String](),
        List[String](),
    )
    assert_equal(capture_last_line_number(selection), 2)


def test_main_and_kombi_results_expose_reference_snapshots() raises:
    var table = parse_semicolon_csv("h0;h1\na;b\n")
    var columns = Set[Int]()
    columns.add(0)
    columns.add(1)
    var context = make_parallel_row_preparation_context(
        columns^,
        shell_rows_amount=80,
        widths=[2, 2],
        text_width=2,
    )
    var bundle = bootstrap_table_preparation()
    var main_result = bundle.prepare_main_output(
        RowFilterConfig(1, 1, False),
        table,
        List[String](),
        List[String](),
        context,
    )
    var main_snapshot = main_result.snapshot()
    assert_equal(main_snapshot.class_name, "MainTablePreparationResult")
    assert_equal(main_snapshot.finally_display_lines_len, 2)
    assert_equal(main_snapshot.new_table_len, 2)
    assert_equal(main_snapshot.rows_range_len, 2)

    var kombi_result = bundle.prepare_kombi_output(
        RowFilterConfig(1, 1, False), table, context, 20, 1
    )
    var kombi_snapshot = kombi_result.snapshot()
    assert_equal(kombi_snapshot.class_name, "KombiTablePreparationResult")
    assert_equal(kombi_snapshot.new_table_len, 2)
    assert_equal(kombi_snapshot.animals_professions_table_len, 2)
    assert_equal(kombi_result.column_tags[0].output_column, 20)


def test_heading_amount_uses_first_row_not_ragged_maximum() raises:
    var table = parse_semicolon_csv("h0;h1\na;b;c\n")
    var selection = select_display_lines(
        RowFilterConfig(1, 1, False),
        table,
        List[String](),
        List[String](),
    )
    assert_equal(selection.headings_amount, 2)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
