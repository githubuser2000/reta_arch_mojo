from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite

from reta_mojo.parallel_execution import decode_religion_cell, make_parallel_config
from reta_mojo.program_workflow import *


def test_program_workflow_catalog_and_snapshot() raises:
    var bundle = bootstrap_program_workflow(
        ".", default_program_workflow_csv_names(), 1025
    )
    assert_true(program_workflow_catalog_valid(bundle.catalog))
    var snapshot = program_workflow_snapshot(bundle)
    assert_equal(snapshot.class_name, "ProgramWorkflowBundle")
    assert_equal(snapshot.main_csv, "religion.csv")
    assert_equal(len(snapshot.kombi_csvs), 2)
    assert_equal(len(snapshot.orchestration_steps), 12)
    assert_equal(snapshot.fields, 4)
    assert_equal(snapshot.methods, 11)
    assert_equal(snapshot.self_calls, 10)
    assert_equal(snapshot.bootstrap_functions, 1)
    assert_equal(snapshot.orchestration_steps[0], "load_religion_table")
    assert_equal(snapshot.orchestration_steps[10], "join_kombi_tables")


def test_program_workflow_output_kind_and_cell_decode() raises:
    var args = List[String]()
    args.append("reta")
    args.append("--art=html")
    assert_equal(
        requested_religion_output_kind(args, "art", "bbcode", "html"),
        "html",
    )
    args.append("--art=bbcode")
    assert_equal(
        requested_religion_output_kind(args, "art", "bbcode", "html"),
        "bbcode",
    )
    var reverse_args = List[String]()
    reverse_args.append("reta")
    reverse_args.append("--art=bbcode")
    reverse_args.append("--art=html")
    assert_equal(
        requested_religion_output_kind(reverse_args, "art", "bbcode", "html"),
        "bbcode",
    )
    assert_equal(decode_religion_cell("<x>", "html"), "&lt;x&gt;")
    assert_equal(
        decode_religion_cell("|{\"\":\"P\",\"html\":\"H\",\"bbcode\":\"B\"}|", "bbcode"),
        "B",
    )
    assert_equal(
        decode_religion_cell(
            "|{\"\":\"한글 中文 Việt\",\"html\":\"<b>한글 中文 Việt</b>\",\"bbcode\":\"[b]한글 中文 Việt[/b]\"}|",
            "plain",
        ),
        "한글 中文 Việt",
    )


def test_program_workflow_kombi_branch_plan() raises:
    var names = default_program_workflow_csv_names()
    var first = plan_kombi_workflow(names.kombi13, names, 40, 3, 5)
    assert_true(first.valid)
    assert_equal(first.csv_number, 0)
    assert_equal(first.row_source, "rowsOfcombi")
    assert_equal(first.reli_table_len_until_now, 32)
    var second = plan_kombi_workflow(names.kombi15, names, 40, 3, 5)
    assert_true(second.valid)
    assert_equal(second.csv_number, 1)
    assert_equal(second.row_source, "rowsOfcombi2")
    assert_equal(second.reli_table_len_until_now, 35)
    var unknown = plan_kombi_workflow("other.csv", names, 40, 3, 5)
    assert_false(unknown.valid)
    assert_equal(unknown.csv_number, -1)


def test_program_workflow_loads_and_pads_religion_table() raises:
    var loaded = load_program_workflow_religion_table(
        "religion.csv", "plain", 1024, make_parallel_config("off")
    )
    assert_equal(len(loaded.table.rows), 1025)
    assert_true(loaded.rows_len > 0)
    assert_equal(loaded.output_kind, "plain")
    assert_equal(loaded.stats.mode, "serial")
    assert_equal(loaded.table.rows[1][1], "한글 中文 Việt")
    assert_equal(loaded.table.rows[1][2], "plain")
    assert_equal(loaded.table.rows[2][1], '<x & "y">')


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
