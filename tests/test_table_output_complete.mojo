from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.table_output import *


def test_bundle_snapshot_matches_python_contract() raises:
    var snapshot = bootstrap_table_output().snapshot()
    assert_equal(snapshot.class_name, "TableOutputBundle")
    assert_equal(snapshot.output_class, "TableOutput")
    assert_equal(snapshot.responsibility, "table-output-rendering-morphism")
    assert_equal(snapshot.legacy_nested_class, "Tables.Output")


def test_default_runtime_and_mode_application() raises:
    var output = bootstrap_table_output().create_default()
    var snapshot = output.snapshot()
    assert_equal(snapshot.class_name, "TableOutput")
    assert_equal(snapshot.output_mode, "shell")
    assert_equal(snapshot.syntax_class_name, "OutputSyntax")
    assert_true(snapshot.color)
    assert_false(snapshot.one_table)
    assert_true(snapshot.number_rows)
    assert_equal(snapshot.text_width, 21)
    output.set_out_type("markdown")
    snapshot = output.snapshot()
    assert_equal(snapshot.output_mode, "markdown")
    assert_equal(snapshot.syntax_class_name, "markdownSyntax")
    assert_true(snapshot.one_table)
    assert_equal(snapshot.text_width, 0)


def test_only_that_columns_preserves_requested_order_and_ignores_missing() raises:
    var output = bootstrap_table_output().create_default()
    var table = parse_semicolon_csv("a;b;c\nd;e;f\n")
    var selected = output.only_that_columns(table, [3, 1, 9])
    assert_equal(len(selected.rows), 2)
    assert_equal(selected.rows[0], ["c", "a"])
    assert_equal(selected.rows[1], ["f", "d"])


def test_cliout2_records_chunks_even_when_physical_output_is_hidden() raises:
    var config = default_table_output_config()
    config.nothing_output = True
    var output = bootstrap_table_output().create(config, List[String]())
    assert_equal(output.cliout2("eins"), "")
    assert_equal(output.cliout2("zwei"), "")
    assert_equal(output.resulting_table, ["eins", "zwei"])


def test_colorize_delegates_historical_shell_policy() raises:
    var output = bootstrap_table_output().create_default()
    assert_equal(
        output.colorize("H", 0),
        "\x1b[41m\x1b[30m\x1b[4mH\x1b[0m",
    )
    assert_equal(
        output.colorize("x", 2, True),
        "\x1b[47m\x1b[30mx\x1b[0m\x1b[0m",
    )


def test_cli_out_owns_renderer_result_and_buffer() raises:
    var config = default_table_output_config()
    config.output_mode = "csv"
    config.syntax_class_name = "csvSyntax"
    config.color = False
    config.one_table = True
    config.text_width = 0
    var output = bootstrap_table_output().create(config, List[String]())
    var table = parse_semicolon_csv(";;H1;H2\n1;1;foo;bar\n")
    var result = output.cli_out(table, table, [0, 1])
    assert_equal(result.rendered_text, "; ;H1;H2\n1;1 ;foo;bar\n")
    assert_equal(result.emitted_text, result.rendered_text)
    assert_equal(len(result.resulting_table), 1)
    assert_equal(output.resulting_table[0], result.rendered_text)


def test_no_heading_state_removes_heading_and_number_together() raises:
    var config = default_table_output_config()
    config.output_mode = "csv"
    config.syntax_class_name = "csvSyntax"
    config.color = False
    config.one_table = True
    config.text_width = 0
    config.no_headings = True
    var output = bootstrap_table_output().create(config, List[String]())
    var table = parse_semicolon_csv(";;H\n1;1;data\n")
    var result = output.cli_out(table, table, [0, 1])
    assert_equal(result.row_numbers, [1])
    assert_equal(result.rendered_text, "1;1 ;data\n")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
