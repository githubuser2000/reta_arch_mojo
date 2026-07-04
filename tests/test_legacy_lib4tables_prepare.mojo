from std.collections import List, Set
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import CsvTable
from reta_mojo.legacy_lib4tables_prepare import *
from reta_mojo.table_preparation import make_parallel_row_preparation_context


def _set(values: List[Int]) -> Set[Int]:
    var result = Set[Int]()
    for value in values:
        result.add(value)
    return result^


def test_snapshot_matches_legacy_surface() raises:
    var runtime = create_legacy_prepare_module_runtime(80)
    var snapshot = legacy_prepare_snapshot(runtime)
    assert_equal(len(snapshot.module_functions), 5)
    assert_equal(len(snapshot.prepare_methods), 20)
    assert_equal(snapshot.prepare_methods[0].legacy_name, "setZaehlungen")
    assert_equal(snapshot.prepare_methods[19].legacy_name, "cellWork")
    assert_equal(snapshot.shell_rows_amount, 80)
    assert_equal(len(snapshot.state_sections), 11)


def test_module_helpers_and_explicit_runtime() raises:
    var runtime = create_legacy_prepare_module_runtime(40)
    setShellRowsAmount(runtime, 100)
    assert_equal(runtime.wrapping_runtime.shell_rows_amount, 100)
    assert_equal(chunks(["a", "b", "c"], 2), [["a", "b"], ["c"]])
    assert_equal(splitMoreIfNotSmall(["abcd"], 2), ["ab", "cd"])
    assert_equal(alxwrap(runtime, "abcd", 2), ["ab", "cd"])


def test_prepare_state_properties_and_ranges() raises:
    var prepare = create_legacy_prepare(32, 16, 80)
    prepare.set_breitenn(True)
    prepare.set_nummeriere(True)
    prepare.set_textWidth(33)
    assert_true(prepare.breitenn())
    assert_true(prepare.nummeriere())
    assert_equal(prepare.textWidth(), 33)
    assert_equal(prepare.fromUntil([7]), (1, 7))
    assert_equal(prepare.fromUntil([3, 9]), (3, 9))
    var ranges = prepare.parametersCmdWithSomeBereich("2-4,-6", "a", "")
    assert_true("_a_2-4" in ranges)
    assert_true("_a_-6" not in ranges)


def test_prepare_filter_wrapping_and_row_preparation() raises:
    var prepare = create_legacy_prepare(16, 12, 80)
    prepare.state.rows_were_set = True
    var filtered = prepare.FilterOriginalLines(
        _set([0, 1, 2, 3, 4, 5]), ["_a_2-4"]
    )
    assert_true(2 in filtered)
    assert_true(4 in filtered)
    assert_true(1 not in filtered)
    assert_equal(prepare.cellWork("abcdef", 3), ["abc", "def"])

    var rows_as_numbers = _set([0, 1])
    var unlimited_context = make_parallel_row_preparation_context(
        rows_as_numbers, text_width=3
    )
    var unlimited = prepare.prepare4out_LoopBody(
        2, ["abcdef", "xy"], unlimited_context
    )
    assert_equal(unlimited.cells[0], ["abcdef"])

    var context = make_parallel_row_preparation_context(
        rows_as_numbers, shell_rows_amount=80, text_width=3
    )
    var prepared = prepare.prepare4out_LoopBody(
        2, ["abcdef", "xy"], context
    )
    assert_equal(prepared.index, 2)
    assert_equal(prepared.cells[0], ["abc", "def"])
    assert_equal(prepared.cells[1], ["xy"])


def test_selection_keeps_header() raises:
    var prepare = create_legacy_prepare(4, 4, 80)
    prepare.state.rows_were_set = True
    var table = CsvTable(
        [["h"], ["1"], ["2"], ["3"], ["4"]], 1
    )
    var selection = prepare.prepare4out_beforeForLoop_SpaltenZeilenBestimmen(
        table, ["_a_2-3"], List[String]()
    )
    assert_equal(selection.rows, [0, 2, 3])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
