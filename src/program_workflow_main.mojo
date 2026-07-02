"""Native diagnostic CLI for the program-workflow owner."""

from std.collections import List
from std.collections.string import atol
from std.sys import argv

from reta_mojo.parallel_execution import parallel_config_from_environment
from reta_mojo.program_workflow import *


def _usage() -> None:
    print("reta-mojo-workflow")
    print("  --summary")
    print("  --steps")
    print("  --csv-path FILE")
    print("  --decode-cell plain|html|bbcode CELL")
    print("  --output-kind ART BB HTML ARG...")
    print("  --kombi-plan FILE COLUMNS ROWS13 ROWS15")
    print("  --load-religion KIND HIGHEST")


def _bundle() raises -> ProgramWorkflowBundle:
    return bootstrap_program_workflow(
        ".", default_program_workflow_csv_names(), 0
    )


def _print_summary(bundle: ProgramWorkflowBundle) -> None:
    var snapshot = program_workflow_snapshot(bundle)
    print("class=" + snapshot.class_name)
    print("repo_root=" + snapshot.repo_root)
    print("main_csv=" + snapshot.main_csv)
    print("kombi_csvs=" + String(len(snapshot.kombi_csvs)))
    print("steps=" + String(len(snapshot.orchestration_steps)))
    print("fields=" + String(snapshot.fields))
    print("methods=" + String(snapshot.methods))
    print("self_calls=" + String(snapshot.self_calls))
    print("bootstrap_functions=" + String(snapshot.bootstrap_functions))
    print(
        "valid="
        + ("true" if program_workflow_catalog_valid(bundle.catalog) else "false")
    )


def main() raises:
    var args = argv()
    var bundle = _bundle()
    if len(args) == 1 or (len(args) == 2 and String(args[1]) == "--summary"):
        _print_summary(bundle)
        return
    if len(args) == 2 and String(args[1]) == "--steps":
        var steps = program_workflow_steps(bundle.catalog)
        for index in range(len(steps)):
            print(steps[index])
        return
    if len(args) == 3 and String(args[1]) == "--csv-path":
        print(program_workflow_csv_path(String(args[2])))
        return
    if len(args) == 4 and String(args[1]) == "--decode-cell":
        print(decode_religion_cell(String(args[3]), String(args[2])))
        return
    if len(args) >= 6 and String(args[1]) == "--output-kind":
        var workflow_args = List[String]()
        for index in range(5, len(args)):
            workflow_args.append(String(args[index]))
        print(
            requested_religion_output_kind(
                workflow_args,
                String(args[2]),
                String(args[3]),
                String(args[4]),
            )
        )
        return
    if len(args) == 6 and String(args[1]) == "--kombi-plan":
        var plan = plan_kombi_workflow(
            String(args[2]),
            bundle.csv_names,
            atol(String(args[3])),
            atol(String(args[4])),
            atol(String(args[5])),
        )
        print("valid=" + ("true" if plan.valid else "false"))
        print("csv_number=" + String(plan.csv_number))
        print("row_source=" + plan.row_source)
        print("reli_table_len_until_now=" + String(plan.reli_table_len_until_now))
        return
    if len(args) == 4 and String(args[1]) == "--load-religion":
        var loaded = load_program_workflow_religion_table(
            bundle.csv_names.religion,
            String(args[2]),
            atol(String(args[3])),
            parallel_config_from_environment(),
        )
        print("rows=" + String(len(loaded.table.rows)))
        print("rows_len=" + String(loaded.rows_len))
        print("maximum_columns=" + String(loaded.table.maximum_columns))
        print("mode=" + loaded.stats.mode)
        return
    _usage()
    raise Error("invalid program-workflow arguments")
