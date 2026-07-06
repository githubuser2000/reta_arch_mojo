from std.collections import List, Set
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.table_adapters import *


def test_snapshot_covers_the_complete_python_facade() raises:
    var snapshot = table_adapters_snapshot()
    assert_equal(len(snapshot.module_functions), 4)
    assert_equal(len(snapshot.prepare_methods), 17)
    assert_equal(len(snapshot.concat_methods), 34)
    assert_equal(snapshot.module_functions[0].legacy_name, "setShellRowsAmount")
    assert_equal(snapshot.prepare_methods[0].legacy_name, "setZaehlungen")
    assert_equal(snapshot.prepare_methods[16].legacy_name, "cellWork")
    assert_equal(snapshot.concat_methods[0].legacy_name, "concatLovePolygon")
    assert_equal(snapshot.concat_methods[33].legacy_name, "readConcatCsv_SetHtmlParamaters")
    assert_equal(len(snapshot.prepare_state_sections), 8)
    assert_equal(len(snapshot.concat_state_sections), 13)


def test_prepare_constructor_and_property_aliases() raises:
    var state = create_prepare_adapter_state(20, 12, 80)
    assert_equal(len(state.original_lines), 24)
    assert_equal(state.row_filter.highest_main, 20)
    assert_equal(state.row_filter.highest_multiple, 12)
    assert_equal(state.shell_rows_amount, 80)
    assert_equal(textWidth(state), 21)
    set_textWidth(state, 33)
    set_breitenn(state, True)
    set_nummeriere(state, True)
    assert_equal(textWidth(state), 33)
    assert_true(breitenn(state))
    assert_true(nummeriere(state))
    setShellRowsAmount(state, 100)
    assert_equal(state.shell_rows_amount, 100)
    assert_equal(state.wrapping_runtime.shell_rows_amount, 100)


def test_module_helpers_preserve_adapter_semantics() raises:
    var grouped = chunks(["a", "b", "c", "d", "e"], 2)
    assert_equal(len(grouped), 3)
    assert_equal(grouped[0], ["a", "b"])
    assert_equal(grouped[2], ["e"])
    assert_equal(splitMoreIfNotSmall(["abcdef", "xy"], 3), ["abc", "def", "xy"])
    assert_equal(fromUntil([7]), (1, 7))
    assert_equal(fromUntil([3, 9]), (3, 9))
    assert_equal(fromUntil(List[Int]()), (1, 1))


def test_prepare_row_helpers_delegate_to_native_owners() raises:
    var state = create_prepare_adapter_state(20, 12, 80)
    var rows = Set[Int]()
    rows.add(1)
    rows.add(2)
    rows.add(3)
    rows.add(4)
    var moons = moonsun(rows, True)
    assert_true(1 not in moons)
    assert_true(4 in moons)
    var suns = moonsun(rows, False)
    assert_true(1 in suns)
    assert_true(4 not in suns)
    var first = Set[Int]()
    first.add(1)
    first.add(2)
    first.add(3)
    var second = Set[Int]()
    second.add(3)
    second.add(4)
    var clean = deleteDoublesInSets(first, second)
    assert_true(1 in clean[0])
    assert_true(2 in clean[0])
    assert_true(4 in clean[1])
    assert_true(3 not in clean[0])
    assert_true(3 not in clean[1])
    setZaehlungen(state)
    assert_true(state.counted)
    # Python reference assigns rows 1-4 to the first counting group;
    # the earlier facade contract accidentally expected the uninitialized
    # sentinel row-0 group here.
    assert_equal(zeileWhichZaehlung(state, 1), 1)
    assert_equal(zeileWhichZaehlung(state, 4), 1)
    assert_equal(zeileWhichZaehlung(state, 5), 2)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
