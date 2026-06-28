from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.native_reta_cli import *


def test_plan_resolves_rows_columns_and_output() raises:
    var plan = build_native_reta_plan(
        ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--religionen=sternpolygon", "-ausgabe", "--art=csv"],
        746,
        1024,
    )
    assert_equal(plan.output_mode, "csv")
    assert_equal(plan.positive_rows, ["_a_1-3"])
    assert_equal(plan.columns, [0, 6, 36])


def test_generated_only_selection_does_not_add_physical_default() raises:
    var plan = build_native_reta_plan(
        ["-spalten", "--bedeutung=primzahlkreuz"],
        746,
        1024,
    )
    assert_equal(len(plan.columns), 0)
    assert_equal(plan.generated_commands, ["primzahlkreuzprocontra"])


def test_modal_alias_resolves_concept_pair() raises:
    var plan = build_native_reta_plan(
        ["-spalten", "--grundstrukturen=liebe"],
        746,
        1024,
    )
    assert_equal(plan.columns, [8, 9, 28, 208, 221, 330, 580])
    assert_equal(len(plan.modal_concepts), 1)
    assert_equal(plan.modal_concepts[0].first, 121)
    assert_equal(plan.modal_concepts[0].second, 122)


def test_prime_effect_alias_becomes_generated_command() raises:
    var plan = build_native_reta_plan(
        ["-spalten", "--primzahlwirkung=absicht"],
        746,
        1024,
    )
    assert_equal(len(plan.columns), 0)
    assert_equal(plan.generated_commands, ["prime_effect:10"])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
