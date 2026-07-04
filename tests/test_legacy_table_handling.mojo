from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_table_handling import (
    NichtsSyntax,
    OutputSyntax,
    bbCodeSyntax,
    bootstrap_table_handling,
    couldBePrimeNumberPrimzahlkreuz,
    csvSyntax,
    divisorGenerator,
    emacsSyntax,
    htmlSyntax,
    markdownSyntax,
    moonNumber,
    primCreativity,
    primFak,
    primMultiple,
    setShellRowsAmount,
    shellRowsAmount,
    table_handling_cliout,
    table_handling_snapshot,
)


def test_snapshot_matches_python_all_surface() raises:
    var runtime = bootstrap_table_handling()
    var snapshot = table_handling_snapshot(runtime)
    assert_equal(len(snapshot.exported_names), 27)
    assert_equal(snapshot.exported_names[0], "BreakoutException")
    assert_equal(snapshot.exported_names[26], "output")
    assert_equal(len(snapshot.native_owners), 5)
    assert_equal(len(snapshot.output_modes), 7)


def test_explicit_runtime_replaces_module_globals() raises:
    var runtime = bootstrap_table_handling(128, 33, True, False)
    assert_equal(runtime.table_state.highest_rows[1024], 128)
    assert_equal(runtime.output_state.text_width, 33)
    assert_true(runtime.info_log)
    assert_false(runtime.output_enabled)
    setShellRowsAmount(runtime, 77)
    assert_equal(shellRowsAmount(runtime), 77)
    assert_equal(table_handling_cliout(runtime, "hidden"), "")


def test_output_syntax_reexports_are_typed() raises:
    assert_equal(OutputSyntax().canonical_name, "shell")
    assert_equal(NichtsSyntax().canonical_name, "nichts")
    assert_equal(csvSyntax().canonical_name, "csv")
    assert_equal(emacsSyntax().canonical_name, "emacs")
    assert_equal(markdownSyntax().canonical_name, "markdown")
    assert_equal(bbCodeSyntax().canonical_name, "bbcode")
    assert_equal(htmlSyntax().canonical_name, "html")


def test_number_theory_reexports_delegate_to_native_owners() raises:
    assert_equal(len(moonNumber(8)[0]), 1)
    assert_equal(primFak(12), [2, 2, 3])
    assert_equal(divisorGenerator(12), [1, 2, 3, 4, 6, 12])
    assert_true(len(primMultiple(12)) > 0)
    assert_true(primCreativity(5) > 0)
    assert_true(couldBePrimeNumberPrimzahlkreuz(5))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
