from std.collections import List, Set
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.prompt_execution_helpers import *
from reta_mojo.prompt_language import load_prompt_language_catalog


def _set(values: List[Int]) -> Set[Int]:
    var result = Set[Int]()
    for index in range(len(values)):
        result.add(values[index])
    return result^


def test_upper_maximum_matches_legacy_priority() raises:
    assert_equal(
        anotherOberesMaximum("2-7", 5, 1024),
        "--oberesmaximum=1025",
    )
    assert_equal(
        anotherOberesMaximum("2-70", 5, 12, "uppermaximum"),
        "--uppermaximum=71",
    )
    assert_equal(
        anotherOberesMaximum("", 9, 4),
        "--oberesmaximum=10",
    )


def test_parameter_filter_preserves_input_order() raises:
    var catalog = load_prompt_language_catalog("assets")
    var filtered = returnOnlyParasAsList(
        catalog,
        "deutsch",
        ["text", "-zeilen", "1-3", "-spalten", "--alles", "ende"],
    )
    assert_equal(len(filtered), 3)
    assert_equal(filtered[0], "-zeilen")
    assert_equal(filtered[1], "-spalten")
    assert_equal(filtered[2], "--alles")


def test_partition_matches_grkl_edges() raises:
    var partition = grKl(_set([1, 3, 5, 9]), _set([3, 5]))
    assert_equal(len(partition.greater), 1)
    assert_true(9 in partition.greater)
    assert_equal(len(partition.lesser), 1)
    assert_true(1 in partition.lesser)
    assert_false(3 in partition.greater)
    assert_false(5 in partition.lesser)

    var empty_bounds = grKl(_set([2, 8]), Set[Int]())
    assert_equal(len(empty_bounds.greater), 2)
    assert_equal(len(empty_bounds.lesser), 2)


def test_ordered_projection_and_value_list() raises:
    var entries = [
        OrderedStringEntry("a", "eins"),
        OrderedStringEntry("b", "zwei"),
        OrderedStringEntry("c", "drei"),
    ]
    var projected = getDictLimtedByKeyList(entries, ["c", "x", "a"])
    assert_equal(len(projected), 2)
    assert_equal(projected[0].key, "c")
    assert_equal(projected[1].key, "a")
    var values = dictToList(projected)
    assert_equal(values, ["drei", "eins"])


def test_range_selection_option_is_explicit() raises:
    assert_equal(
        vorherVonAusschnittOderZaehlung(True, "1-9"),
        "--zaehlung=1-9",
    )
    assert_equal(
        vorherVonAusschnittOderZaehlung(False, "1-9"),
        "--vorhervonausschnitt=1-9",
    )
    assert_equal(
        vorherVonAusschnittOderZaehlung(True, "4", "counting", "range"),
        "--counting=4",
    )


def test_bundle_snapshot_freezes_python_surface() raises:
    var snapshot = bootstrap_prompt_execution_helpers().snapshot()
    assert_equal(snapshot.class_name, "PromptExecutionHelpersBundle")
    assert_equal(snapshot.pure_helpers, 6)
    assert_equal(snapshot.functions[0], "anotherOberesMaximum")
    assert_equal(
        snapshot.functions[5], "vorherVonAusschnittOderZaehlung"
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
