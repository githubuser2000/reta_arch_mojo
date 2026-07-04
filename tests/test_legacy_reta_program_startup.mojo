from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_reta_program import *
from reta_mojo.parallel_execution import make_parallel_config


def _program(arguments: List[String]) raises -> LegacyRetaProgram:
    return bootstrap_legacy_reta_program_with_parallel_config(
        arguments,
        make_parallel_config("off", 1, 64, 128, "", "unit"),
    )


def test_empty_and_language_only_startup_are_native() raises:
    var empty_program = _program(List[String]())
    var empty = workflowEverything(empty_program)
    assert_true(empty.native)
    assert_false(empty.compatibility_required)
    assert_equal(empty.output, "Versuche Parameter -h\n")

    var language_program = _program(["-language=english"])
    var language = workflowEverything(language_program)
    assert_true(language.native)
    assert_false(language.compatibility_required)
    assert_equal(language.output, "")


def test_help_is_native_and_localized() raises:
    var german_program = _program(["-h"])
    var german = workflowEverything(german_program)
    assert_true(german.native)
    assert_equal(german.output.byte_length(), 12042)
    assert_true(german.output.startswith("Hauptprogramm ist reta oder reta.py\n"))

    var english_program = _program(["-language=english", "-help"])
    var english = workflowEverything(english_program)
    assert_true(english.native)
    assert_equal(english.output.byte_length(), 11409)
    assert_true(english.output.startswith("Main program is reta or reta.py.\n"))


def test_debug_and_nothing_controls_do_not_cross_python_boundary() raises:
    var debug_program = _program(["-debug"])
    assert_true(propInfoLog(debug_program))
    var debug = workflowEverything(debug_program)
    assert_true(debug.native)
    assert_false(debug.compatibility_required)
    assert_equal(debug.output, "Sprachenwahl: \ngerman\n")

    var nothing_program = _program(["-nichts"])
    var nothing = workflowEverything(nothing_program)
    assert_true(nothing.native)
    assert_false(nothing.compatibility_required)
    assert_equal(nothing.output, "")

    var debug_help_program = _program(
        ["-debug", "-language=english", "-h"]
    )
    var debug_help = workflowEverything(debug_help_program)
    assert_true(debug_help.native)
    assert_true(
        debug_help.output.startswith(
            "Sprachenwahl: english\nnot german\nMain program is reta or reta.py.\n"
        )
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
