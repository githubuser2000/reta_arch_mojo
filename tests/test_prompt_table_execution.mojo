from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import split_prompt_words
from reta_mojo.prompt_table_execution import *


def _plan(text: String, language: String = "deutsch") raises -> PromptTablePlan:
    var catalog = load_prompt_language_catalog("assets")
    return plan_prompt_table_commands(
        split_prompt_words(text), language, catalog
    )


def _tokens(plan: PromptTablePlan, invocation: Int = 0) -> String:
    return "|".join(plan.invocations[invocation].tokens)


def test_moon_plan_preserves_output_parameters() raises:
    var plan = _plan("mond 1-3 --art=csv --nocolor")
    assert_true(plan.handled)
    assert_equal(len(plan.invocations), 1)
    assert_equal(
        _tokens(plan),
        "-zeilen|--vorhervonausschnitt=1-3|--oberesmaximum=1025|-spalten|--Bedeutung=gestirn|--breite=0|-ausgabe|--spaltenreihenfolgeundnurdiese=3-6|--art=csv|--nocolor",
    )


def test_prime_cross_uses_historical_minimum() raises:
    var plan = _plan("primzahlkreuz 1-2")
    assert_true(plan.handled)
    assert_equal(
        _tokens(plan),
        "-zeilen|--vorhervonausschnitt=1-2|--oberesmaximum=1029|-spalten|--Bedeutung=primzahlkreuz|--breite=0|-ausgabe",
    )


def test_range_and_inversion_modifiers() raises:
    var plan = _plan("range invertieren mond 2-4")
    assert_true(plan.handled)
    assert_equal(
        _tokens(plan),
        "-zeilen|--zaehlung=2-4|--oberesmaximum=1025|--invertieren|-spalten|--Bedeutung=gestirn|--breite=0|-ausgabe|--spaltenreihenfolgeundnurdiese=3-6",
    )


def test_multiple_domain_commands_make_multiple_invocations() raises:
    var plan = _plan("mond richtung 1-2")
    assert_true(plan.handled)
    assert_equal(len(plan.invocations), 2)
    assert_true("--Bedeutung=gestirn" in _tokens(plan, 0))
    assert_true("--Primzahlwirkung=Galaxieabsicht" in _tokens(plan, 1))


def test_more_integer_table_families() raises:
    var plan = _plan("thomas emotion geist netzwerk komplex motive universum 3")
    assert_true(plan.handled)
    assert_equal(len(plan.invocations), 7)
    assert_true("--galaxie=thomas" in _tokens(plan, 0))
    assert_true("--grundstrukturen=emotion" in _tokens(plan, 1))
    assert_true("--grundstrukturen=geist" in _tokens(plan, 2))
    assert_true("--universum=netzwerk" in _tokens(plan, 3))
    assert_true("--universum=komplex" in _tokens(plan, 4))
    assert_true("--menschliches=motive" in _tokens(plan, 5))
    assert_true("--universum=transzendentalien" in _tokens(plan, 6))


def test_remaining_integer_n_families() raises:
    var plan = _plan("wirklichkeit triebe impulse bewusstsein groesse 2")
    assert_true(plan.handled)
    assert_equal(len(plan.invocations), 6)
    assert_true(
        "--grundstrukturen=Wirklichkeiten_Wahrheit_Wahrnehmung_(10)"
        in _tokens(plan, 0)
    )
    assert_true("--grundstrukturen=trieb,System" in _tokens(plan, 1))
    assert_true("--grundstrukturen=Impulse_(5)" in _tokens(plan, 2))
    assert_true("Model_of_Hierarchical_Complexity" in _tokens(plan, 3))
    assert_true("--strukturgroesse=organisation" in _tokens(plan, 4))
    assert_true("--strukturgroesse=groesse" in _tokens(plan, 5))


def test_universe_column_suppression_matches_legacy_conditions() raises:
    assert_true(
        "--spaltenreihenfolgeundnurdiese=1,4" in _tokens(_plan("universum 2"))
    )
    assert_true(
        "--spaltenreihenfolgeundnurdiese=1"
        in _tokens(_plan("universum 2 --keineueberschriften"))
    )
    assert_true(
        "--spaltenreihenfolgeundnurdiese=1"
        in _tokens(_plan("universum mond richtung 2"), 2)
    )
    assert_true(
        "--spaltenreihenfolgeundnurdiese=1"
        in _tokens(_plan("universe 2 --noheadings", "english"))
    )


def test_english_aliases_route_to_native_table() raises:
    var plan = _plan("moon 1-2 --type=csv", "english")
    assert_true(plan.handled)
    assert_equal(
        _tokens(plan),
        "-language=english|-zeilen|--vorhervonausschnitt=1-2|--oberesmaximum=1025|-spalten|--Bedeutung=gestirn|--breite=0|-ausgabe|--spaltenreihenfolgeundnurdiese=3-6|--type=csv",
    )


def test_integer_row_modifiers_are_native() raises:
    var multiples = _plan("vielfache mond 2 1-8")
    assert_true(multiples.handled)
    assert_true("--vielfachevonzahlen=2,1-8" in _tokens(multiples))
    assert_true("--vorhervonausschnitt=2,1-8,v2,v1-8" in _tokens(multiples))

    var divisor_plan = _plan("teiler mond 12")
    assert_true(divisor_plan.handled)
    assert_true("--vorhervonausschnitt=2,3,4,6,12,12" in _tokens(divisor_plan))

    var single = _plan("einzeln mond 2")
    assert_true(single.handled)
    assert_true("--vorhervonausschnitt=2" in _tokens(single))


def test_reciprocal_and_proper_fraction_axes_are_native() raises:
    var reciprocal = _plan("universum 1/2")
    assert_true(reciprocal.handled)
    assert_equal(len(reciprocal.invocations), 1)
    assert_true("--vorhervonausschnitt=2" in _tokens(reciprocal))
    assert_true("--universum=transzendentaliereziproke" in _tokens(reciprocal))
    assert_true("--spaltenreihenfolgeundnurdiese=1,2" in _tokens(reciprocal))

    var proper = _plan("emotion 2/3")
    assert_true(proper.handled)
    assert_equal(len(proper.invocations), 1)
    assert_true("--vorhervonausschnitt=3" in _tokens(proper))
    assert_true("--gebrochen-rational_Gefuehle_n/m=2" in _tokens(proper))


def test_fraction_reduction_keeps_all_legacy_axes() raises:
    var reduced = _plan("emotion 2/4")
    assert_true(reduced.handled)
    assert_equal(len(reduced.invocations), 2)
    assert_true("--grundstrukturen=emotion" in _tokens(reduced, 0))
    assert_true("--vorhervonausschnitt=2" in _tokens(reduced, 0))
    assert_true("--gebrochen-rational_Gefuehle_n/m=2" in _tokens(reduced, 1))
    assert_true("--vorhervonausschnitt=4" in _tokens(reduced, 1))

    var whole = _plan("universum 4/2")
    assert_true(whole.handled)
    assert_equal(len(whole.invocations), 2)
    assert_true("--oberesmaximum=1025" in _tokens(whole, 0))
    assert_true("--vorhervonausschnitt=2" in _tokens(whole, 0))
    assert_true("--gebrochen-rational_Universum_n/m=4" in _tokens(whole, 1))


def test_equal_fraction_adds_universe_equality_axis() raises:
    var plan = _plan("universum 3/3")
    assert_true(plan.handled)
    assert_equal(len(plan.invocations), 4)
    assert_true("--universum=verhaeltnisgleicherzahl" in _tokens(plan, 3))
    assert_true("--vorhervonausschnitt=3" in _tokens(plan, 3))


def test_fraction_divisors_and_reciprocal_multiples_are_native() raises:
    var divisors_plan = _plan("universum teiler 2/6")
    assert_true(divisors_plan.handled)
    assert_equal(len(divisors_plan.invocations), 2)
    assert_true("--vorhervonausschnitt=3" in _tokens(divisors_plan, 0))
    assert_true("--vorhervonausschnitt=6" in _tokens(divisors_plan, 1))

    var multiples_plan = _plan("universum vielfache 1/2")
    assert_true(multiples_plan.handled)
    assert_equal(len(multiples_plan.invocations), 1)
    assert_true("--vorhervonausschnitt=2,4,6,8,10" in _tokens(multiples_plan))
    assert_true(",1018,1020,1022" in _tokens(multiples_plan))

    # The Python reference itself raises IndexError for true v-n/m expansion.
    assert_false(_plan("universum v2/3").handled)
    assert_false(_plan("mond 1/2").handled)



def test_legacy_fraction_rectangles_and_offsets_are_native() raises:
    var rectangle = _plan("universum 1/2-3/3")
    assert_true(rectangle.handled)
    assert_equal(len(rectangle.invocations), 5)
    assert_true("--gebrochen-rational_Universum_n/m=2" in _tokens(rectangle, 2))
    assert_true("--gebrochen-rational_Universum_n/m=3" in _tokens(rectangle, 3))
    assert_true("--universum=verhaeltnisgleicherzahl" in _tokens(rectangle, 4))

    var offset = _plan("motive 4/5+2/2")
    assert_true(offset.handled)
    assert_equal(len(offset.invocations), 3)
    assert_true("--vorhervonausschnitt=2" in _tokens(offset, 0))
    assert_true("--gebrochen-rational_Galaxie_n/m=2" in _tokens(offset, 1))
    assert_true("--gebrochen-rational_Galaxie_n/m=6" in _tokens(offset, 2))


def test_fraction_exclusions_and_prefixed_reciprocals_are_native() raises:
    var negative_only = _plan("universum -1/2")
    assert_true(negative_only.handled)
    assert_equal(len(negative_only.invocations), 0)

    var mixed = _plan("universum 1/2,-1/4")
    assert_true(mixed.handled)
    assert_equal(len(mixed.invocations), 1)
    assert_true("--vorhervonausschnitt=2,-4" in _tokens(mixed))

    var proper = _plan("universum 2/3,-2/4")
    assert_true(proper.handled)
    assert_equal(len(proper.invocations), 1)
    assert_true("--gebrochen-rational_Universum_n/m=2" in _tokens(proper))
    assert_true("3" in _tokens(proper))
    assert_true("-4" in _tokens(proper))

    # Exact cancellation and negative-only reciprocal selectors open the
    # Python all-row edge path and therefore still fall back.
    assert_false(_plan("universum 2/4,-2/4").handled)
    assert_false(_plan("emotion 2/3,-1/4").handled)
    assert_false(_plan("universum 2/4,-1/2").handled)

    var prefixed = _plan("universum v1/4,-1/8")
    assert_true(prefixed.handled)
    assert_equal(len(prefixed.invocations), 1)
    assert_true("--vorhervonausschnitt=4,516,12,524" in _tokens(prefixed))
    assert_true(",500,1012,508" in _tokens(prefixed))


def test_no_table_command_stays_at_boundary() raises:
    assert_false(_plan("range 1-3").handled)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
