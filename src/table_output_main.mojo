"""Native diagnostics for the complete TableOutput owner."""

from std.collections import List
from std.collections.string import atol
from reta_mojo.cli_arguments import owned_process_argv
from reta_mojo.csv_table import CsvTable, parse_semicolon_csv
from reta_mojo.table_output import *


def _bool_text(value: Bool) -> String:
    return "true" if value else "false"


def _print_table(table: CsvTable):
    for row_index in range(len(table.rows)):
        var row = table.rows[row_index].copy()
        print("row=", end="")
        for column_index in range(len(row)):
            if column_index > 0:
                print("\x1f", end="")
            print(row[column_index], end="")
        print()


def _usage():
    print("reta-mojo-table-output")
    print("  --summary")
    print("  --select")
    print("  --colorize NUMBER REST TEXT")
    print("  --state MODE")
    print("  --sample MODE")


def run_table_output_cli(args: List[String]) raises -> Int:
    var bundle = bootstrap_table_output()
    if len(args) == 1 or (len(args) == 2 and args[1] == "--summary"):
        var snapshot = bundle.snapshot()
        print("class=" + snapshot.class_name)
        print("output_class=" + snapshot.output_class)
        print("responsibility=" + snapshot.responsibility)
        print("legacy_nested_class=" + snapshot.legacy_nested_class)
        return 0

    if len(args) == 2 and args[1] == "--select":
        var output = bundle.create_default()
        var table = parse_semicolon_csv("a;b;c\nd;e;f\n")
        _print_table(output.only_that_columns(table, [3, 1, 9]))
        return 0

    if len(args) == 5 and args[1] == "--colorize":
        var output = bundle.create_default()
        var rest = args[3] == "true" or args[3] == "1"
        print(output.colorize(args[4], atol(args[2]), rest), end="")
        return 0

    if len(args) == 3 and args[1] == "--state":
        var output = bundle.create_default()
        output.set_out_type(args[2])
        var snapshot = output.snapshot()
        print("class=" + snapshot.class_name)
        print("mode=" + snapshot.output_mode)
        print("syntax=" + snapshot.syntax_class_name)
        print("color=" + _bool_text(snapshot.color))
        print("one_table=" + _bool_text(snapshot.one_table))
        print("number_rows=" + _bool_text(snapshot.number_rows))
        print("text_height=" + String(snapshot.text_height))
        print("text_width=" + String(snapshot.text_width))
        print("chunks=" + String(snapshot.resulting_chunk_count))
        return 0

    if len(args) == 3 and args[1] == "--sample":
        var config = default_table_output_config()
        config.color = False
        config.one_table = True
        config.text_width = 20
        var output = bundle.create(config, List[String]())
        output.set_out_type(args[2])
        var table = parse_semicolon_csv(";;H1;H2\n1;1;foo;bar\n")
        var result = output.cli_out(table, table, [0, 1])
        print(result.emitted_text, end="")
        return 0

    _usage()
    raise Error("invalid table-output diagnostic arguments")


def main() raises:
    _ = run_table_output_cli(owned_process_argv())
