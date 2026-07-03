"""Native diagnostics for the table-generation gluing owner."""

from std.sys import argv
from std.collections import List
from std.collections.string import atol
from reta_mojo.csv_table import CsvTable, read_semicolon_csv
from reta_mojo.generated_aliases import FractionColumnRequest
from reta_mojo.kombi_join_columns import KombiColumnRequest
from reta_mojo.resource_paths import csv_resource
from reta_mojo.table_generation import *


def _usage() -> None:
    print("reta-mojo-table-generation")
    print("  --summary")
    print("  --last-line REQUESTED ROWS")
    print("  --sample")


def main() raises:
    var args = argv()
    var bundle = bootstrap_table_generation()
    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        var snapshot = bundle.snapshot()
        print("csv_sources=" + String(len(snapshot.csv_sources)))
        print("generated_morphisms=" + String(len(snapshot.generated_morphisms)))
        print("kombi_csvs=" + String(len(snapshot.kombi_csvs)))
        print("table_preparation=" + snapshot.table_preparation_dependency)
        return
    if len(args) == 4 and String(args[1]) == "--last-line":
        var requested = atol(String(args[2]))
        var row_count = atol(String(args[3]))
        var rows = List[List[String]]()
        for index in range(max(row_count, 0)):
            rows.append([String(index)])
        print(capture_last_line_number(CsvTable(rows^, 1), requested))
        return
    if len(args) == 2 and String(args[1]) == "--sample":
        var table = read_semicolon_csv(csv_resource("religion.csv"))
        var plan = default_table_generation_plan()
        plan.selected_columns = [0, 1, 4]
        plan.fraction_requests = [FractionColumnRequest("universe", 2)]
        plan.generated_commands = ["PrimCSV"]
        plan.kombi_requests = List[KombiColumnRequest]()
        plan.requested_last_line = 3
        var result = bundle.build_for_program(table, plan)
        var snapshot = result.snapshot()
        print("rows=" + String(len(result.table.rows)))
        print("columns=" + String(result.table.maximum_columns))
        print("generated=" + String(len(result.generated_names)))
        print("gebr_keys=" + String(len(snapshot.gebr_keys)))
        return
    _usage()
    raise Error("invalid table-generation diagnostic arguments")
