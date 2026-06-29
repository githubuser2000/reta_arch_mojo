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


def test_fraction_and_multiple_modifiers_stay_at_boundary() raises:
    assert_false(_plan("universum 1/2").handled)
    assert_false(_plan("vielfache mond 2 1-8").handled)
    assert_false(_plan("teiler mond 12").handled)


def test_no_table_command_stays_at_boundary() raises:
    assert_false(_plan("range 1-3").handled)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
