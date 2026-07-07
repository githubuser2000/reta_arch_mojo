from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_reta_program import *
from reta_mojo.legacy_reta_program_catalog import *
from reta_mojo.parallel_execution import make_parallel_config


def test_complete_module_and_program_surface() raises:
    var program = bootstrap_legacy_reta_program_with_parallel_config(
        ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--alles"],
        make_parallel_config("off", 1, 64, 128, "", "unit"),
    )
    var snapshot = program.snapshot()
    assert_equal(snapshot.exported_names_len, 27)
    assert_equal(snapshot.method_definitions_len, 18)
    assert_equal(snapshot.argv_len, 4)
    assert_equal(snapshot.output_mode, "shell")
    assert_false(snapshot.result_ready)
    assert_false(snapshot.compatibility_required)
    assert_false(snapshot.python_runtime_embedded)
    var names = legacy_reta_program_public_names()
    assert_equal(names[0], "os")
    assert_equal(names[26], "Program")
    var methods = legacy_reta_program_method_definitions()
    assert_equal(methods[0], "produceAllSpaltenNumbers")
    assert_equal(methods[17], "combiTableWorkflow")


def test_parameter_and_output_adapters_mutate_typed_state() raises:
    var program = bootstrap_legacy_reta_program_with_parallel_config(
        ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--alles"],
        make_parallel_config("off", 1, 64, 128, "", "unit"),
    )
    assert_true(breiteBreitenSysArgvPara(program, "breite=0"))
    assert_equal(program.runtime.width, 0)
    assert_true(apply_output_mode(program, "html"))
    assert_equal(program.runtime.output_mode, "html")
    assert_false(apply_output_mode(program, "unknown"))
    var columns = produceAllSpaltenNumbers(program)
    assert_true(len(columns) > 0)
    # Historical `oberesMaximum` is monotonic: a later explicit value may
    # raise the table ceiling, but it never shrinks the 1024 floor established
    # by `--vorhervonausschnitt=1-3` during bootstrap.
    assert_true(oberesMaximum(program, "--oberesmaximum=77"))
    assert_equal(program.runtime.highest, 1024)
    assert_true(oberesMaximum(program, "--oberesmaximum=2048"))
    assert_equal(program.runtime.highest, 2048)
    invertAlles(program)
    assert_true(program.invert_alles)
    set_propInfoLog(program, False)
    assert_false(propInfoLog(program))


def test_workflow_and_legacy_helpers_delegate_to_native_owners() raises:
    var program = bootstrap_legacy_reta_program_with_parallel_config(
        [], make_parallel_config("off", 1, 64, 128, "", "unit")
    )
    var first = combiTableWorkflow(
        program,
        program.workflow.csv_names.kombi13,
        40,
        3,
        5,
    )
    assert_true(first.valid)
    assert_equal(first.csv_number, 0)
    assert_equal(
        render_color("red", "x"),
        '<span style="color:red;">x</span>',
    )
    var help = helpPage()
    assert_equal(help.byte_length(), 12042)
    assert_true(help.startswith("Hauptprogramm ist reta oder reta.py\n"))
    var owners = legacy_reta_program_owner_snapshot()
    assert_equal(len(owners), 10)
    assert_equal(
        owners[7],
        "startup=native_cli_startup.mojo/native_cli_controls.mojo",
    )
    assert_equal(owners[8], "unsupported=explicit-child-process")


def test_reta_program_native_completion_witness_marks_top_level_complete() raises:
    var completion = plan_legacy_reta_program_native_completion()
    assert_equal(completion.source_file, "reta.py")
    assert_equal(completion.status, "nativ")
    assert_equal(completion.source_lines, 214)
    assert_equal(completion.public_names, 27)
    assert_equal(completion.method_definitions, 18)
    assert_equal(completion.owner_entries, 10)
    assert_true(completion.startup_native)
    assert_true(completion.controls_native)
    assert_true(completion.table_kernel_native)
    assert_true(completion.workflow_native)
    assert_true(completion.parallel_native)
    assert_true(completion.compatibility_boundary)
    assert_false(completion.python_runtime_embedded)
    assert_true(legacy_reta_program_native_completion_valid(completion))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
