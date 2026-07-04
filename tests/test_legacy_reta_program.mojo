from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_reta_program import *
from reta_mojo.legacy_reta_program_catalog import *


def test_complete_module_and_program_surface() raises:
    var program = bootstrap_legacy_reta_program(
        ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--alles"]
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
    var program = bootstrap_legacy_reta_program(
        ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--alles"]
    )
    assert_true(breiteBreitenSysArgvPara(program, "breite=0"))
    assert_equal(program.runtime.width, 0)
    assert_true(apply_output_mode(program, "html"))
    assert_equal(program.runtime.output_mode, "html")
    assert_false(apply_output_mode(program, "unknown"))
    var columns = produceAllSpaltenNumbers(program)
    assert_true(len(columns) > 0)
    assert_true(oberesMaximum(program, "--oberesmaximum=77"))
    assert_equal(program.runtime.highest, 77)
    invertAlles(program)
    assert_true(program.invert_alles)
    set_propInfoLog(program, False)
    assert_false(propInfoLog(program))


def test_workflow_and_legacy_helpers_delegate_to_native_owners() raises:
    var program = bootstrap_legacy_reta_program()
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
    assert_equal(helpPage(), "owner=console_io/reta_help")
    var owners = legacy_reta_program_owner_snapshot()
    assert_equal(len(owners), 9)
    assert_equal(owners[7], "unsupported=explicit-child-process")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
