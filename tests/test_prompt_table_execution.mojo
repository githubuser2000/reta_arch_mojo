from std.testing import assert_equal, assert_true, assert_false, TestSuite
from std.os import getenv
from reta_mojo.prompt_language import (
    load_prompt_language_catalog,
    prepare_prompt_tokens,
)
from reta_mojo.prompt_runtime import split_prompt_words
from reta_mojo.prompt_table_execution import *


def _plan(text: String, language: String = "deutsch") raises -> PromptTablePlan:
    var catalog = load_prompt_language_catalog("assets")
    return plan_prompt_table_commands(
        split_prompt_words(text), language, catalog
    )


def _tokens(plan: PromptTablePlan, invocation: Int = 0) -> String:
    return "|".join(plan.invocations[invocation].tokens)


def _emit_mixed_reciprocal_reference(text: String) raises:
    if String(getenv("RETA_EMIT_MIXED_RECIPROCAL_PLANS", "")) != "1":
        return
    var plan = _plan(text)
    if not plan.handled:
        print("MIXED_RECIPROCAL_PLAN\tFALLBACK")
        return
    assert_equal(len(plan.invocations), 1)
    print("MIXED_RECIPROCAL_PLAN\t" + _tokens(plan))


def _emit_true_fraction_multiple_plan(text: String) raises:
    if String(getenv("RETA_EMIT_TRUE_FRACTION_MULTIPLE_PLANS", "")) != "1":
        return
    print(
        "TRUE_FRACTION_MULTIPLE_PLAN\t"
        + text
        + "\t"
        + serialize_prompt_table_plan(_plan(text))
    )


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
    assert_true("--Universum=transzendentalien" in _tokens(plan, 6))


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
    assert_true(
        "--spaltenreihenfolgeundnurdiese=1,4"
        in _tokens(_plan("universum teiler 2"))
    )
    assert_true(
        "--spaltenreihenfolgeundnurdiese=1"
        in _tokens(_plan("universum range invertieren 2"))
    )
    assert_true(
        "--spaltenreihenfolgeundnurdiese=1"
        in _tokens(_plan("universum mond teiler 2"), 1)
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
    assert_true("--vielfachevonzahlen=1-8,2" in _tokens(multiples))
    assert_true("--vorhervonausschnitt=1-8,2,v1-8,v2" in _tokens(multiples))

    var divisor_plan = _plan("teiler mond 12")
    assert_true(divisor_plan.handled)
    assert_true("--vorhervonausschnitt=2,3,4,6,12,12" in _tokens(divisor_plan))

    var single = _plan("einzeln mond 2")
    assert_true(single.handled)
    assert_true("--vorhervonausschnitt=2" in _tokens(single))


def test_integer_zero_negative_order_and_collision_are_native() raises:
    var zero = _plan("universum 0")
    assert_true(zero.handled)
    assert_equal(len(zero.invocations), 1)
    assert_true("--vorhervonausschnitt=0" in _tokens(zero))

    var negative = _plan("universum -2")
    assert_true(negative.handled)
    assert_equal(len(negative.invocations), 0)

    var collision = _plan("universum 2,-2")
    assert_true(collision.handled)
    assert_equal(len(collision.invocations), 1)
    assert_true("--vorhervonausschnitt=-2,2" in _tokens(collision))

    var reordered = _plan("universum 3 1")
    assert_true(reordered.handled)
    assert_true("--vorhervonausschnitt=1,3" in _tokens(reordered))

    var range_exclusion = _plan("universum 1-3,-2")
    assert_true(range_exclusion.handled)
    assert_true("--vorhervonausschnitt=-2,1-3" in _tokens(range_exclusion))


def test_integer_divisor_zero_and_exclusion_algebra_is_native() raises:
    var zero = _plan("universum teiler 0")
    assert_true(zero.handled)
    assert_equal(len(zero.invocations), 0)

    var collision = _plan("universum teiler 2,-2")
    assert_true(collision.handled)
    assert_true("--vorhervonausschnitt=,-2,2" in _tokens(collision))

    var partial = _plan("universum teiler 3,-2")
    assert_true(partial.handled)
    assert_true("--vorhervonausschnitt=3,-2,3" in _tokens(partial))

    var range_exclusion = _plan("universum teiler 1-3,-2")
    assert_true(range_exclusion.handled)
    assert_true("--vorhervonausschnitt=3,-2,1-3" in _tokens(range_exclusion))

    var zero_exclusion = _plan("universum teiler 0,-2")
    assert_true(zero_exclusion.handled)
    assert_true("--vorhervonausschnitt=,-2,0" in _tokens(zero_exclusion))


def test_reciprocal_and_proper_fraction_axes_are_native() raises:
    var reciprocal = _plan("universum 1/2")
    assert_true(reciprocal.handled)
    assert_equal(len(reciprocal.invocations), 1)
    assert_true("--vorhervonausschnitt=2" in _tokens(reciprocal))
    assert_true("--Universum=transzendentaliereziproke" in _tokens(reciprocal))
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

    var pure_reciprocal_divisor = _plan("universum teiler 1/2")
    assert_true(pure_reciprocal_divisor.handled)
    assert_equal(len(pure_reciprocal_divisor.invocations), 1)
    assert_true("--vorhervonausschnitt=2," in _tokens(pure_reciprocal_divisor))

    var multiples_plan = _plan("universum vielfache 1/2")
    assert_true(multiples_plan.handled)
    assert_equal(len(multiples_plan.invocations), 1)
    assert_true("--vorhervonausschnitt=2,4,6,8,10" in _tokens(multiples_plan))
    assert_true(",1018,1020,1022" in _tokens(multiples_plan))
    assert_false("--oberesmaximum=" in _tokens(multiples_plan))

    # Python raises IndexError here.  Mojo intentionally supplies the corrected
    # rectangular contract, clipped to the real Universe CSV (numerators 2..20,
    # denominators 1..21) rather than inheriting the crash.
    var true_multiple = _plan("universum v2/3")
    assert_true(true_multiple.handled)
    assert_equal(len(true_multiple.invocations), 13)
    assert_true(
        "--vorhervonausschnitt=2,1,4,6,3" in _tokens(true_multiple, 0)
    )
    assert_true(
        "--vorhervonausschnitt=1,2,3,6,9" in _tokens(true_multiple, 1)
    )
    assert_true(
        "--gebrochen-rational_Universum_n/m=2" in _tokens(true_multiple, 2)
    )
    assert_true(
        "--vorhervonausschnitt=9,18,21,6,15,3,12"
        in _tokens(true_multiple, 2)
    )
    assert_true(
        "--gebrochen-rational_Universum_n/m=20"
        in _tokens(true_multiple, 11)
    )
    assert_false("_n/m=22" in serialize_prompt_table_plan(true_multiple))
    assert_true(
        "--vorhervonausschnitt=6,12,18" in _tokens(true_multiple, 12)
    )

    # Proper fractions are a stable historical no-op for the five classic
    # integer-backed families.  Owning that no-op avoids an unnecessary
    # Python fallback without inventing a table invocation.
    var classic_moon = _plan("mond 1/2")
    assert_true(classic_moon.handled)
    assert_equal(len(classic_moon.invocations), 0)
    assert_equal(len(_plan("richtung 2/3").invocations), 0)
    assert_equal(len(_plan("primzahlkreuz 2/4").invocations), 0)
    assert_equal(len(_plan("alles -1/2").invocations), 0)
    assert_equal(len(_plan("thomas 1/2,-1/4").invocations), 0)


def test_divisor_union_preserves_cpython_set_merge_order() raises:
    var multi = _plan("teiler mond 6 10")
    assert_true(multi.handled)
    assert_true("--vorhervonausschnitt=2,3,5,6,10,10,6" in _tokens(multi))

    var mixed_multi = _plan("vielfache teiler mond 6 10")
    assert_true(mixed_multi.handled)
    assert_true(
        "--vorhervonausschnitt=2,3,5,6,10,10,6,v10,v6" in _tokens(mixed_multi)
    )

    var range_plan = _plan("teiler mond 2-4")
    assert_true("--vorhervonausschnitt=2,3,4,2-4" in _tokens(range_plan))

    # 24 is the smallest common case where CPython's nested set-merge order
    # differs from a sorted divisor list: 24 precedes 12.
    var collision = _plan("teiler mond 24")
    assert_true(
        "--vorhervonausschnitt=2,3,4,6,8,24,12,24" in _tokens(collision)
    )


def test_combined_integer_divisors_and_multiples_are_native() raises:
    var german = _plan("vielfache teiler mond 12")
    assert_true(german.handled)
    assert_equal(len(german.invocations), 1)
    assert_false("--vielfachevonzahlen=12" in _tokens(german))
    assert_true("--vorhervonausschnitt=2,3,4,6,12,12,v12" in _tokens(german))
    assert_false("--oberesmaximum=" in _tokens(german))

    var compact = _plan("v w mond 12")
    assert_true(compact.handled)
    assert_equal(_tokens(compact), _tokens(german))

    var catalog = load_prompt_language_catalog("assets")
    var english = plan_prompt_table_commands(
        ["multiple", "divider", "moon", "12"],
        "english",
        catalog,
    )
    assert_true(english.handled)
    assert_equal(len(english.invocations), 1)
    assert_true("-language=english" in _tokens(english))
    assert_true("--vorhervonausschnitt=2,3,4,6,12,12,v12" in _tokens(english))

    # Stable reciprocal multiples compose with ``teiler`` natively.  The
    # modifier contributes to the legacy command count, narrowing Universe to
    # column 1.
    var reciprocal = _plan("vielfache teiler universum 1/2")
    assert_true(reciprocal.handled)
    assert_equal(len(reciprocal.invocations), 1)
    assert_true("--vorhervonausschnitt=2,4,6,8,10" in _tokens(reciprocal))
    assert_true(",1018,1020,1022" in _tokens(reciprocal))
    assert_true("--spaltenreihenfolgeundnurdiese=1" in _tokens(reciprocal))
    assert_false("--spaltenreihenfolgeundnurdiese=1,2" in _tokens(reciprocal))
    assert_false("--oberesmaximum=" in _tokens(reciprocal))

    var prefixed = _plan("universum v1/2 teiler")
    assert_true(prefixed.handled)
    assert_equal(_tokens(prefixed), _tokens(reciprocal))

    var excluded = _plan("universum vielfache teiler 1/2,-1/4")
    assert_true(excluded.handled)
    assert_true("--vorhervonausschnitt=2,6,10,14,18" in _tokens(excluded))
    assert_true(",1010,1014,1018,1022" in _tokens(excluded))
    assert_false(",4," in _tokens(excluded))

    var english_reciprocal = plan_prompt_table_commands(
        ["universe", "multiple", "divider", "1/2"],
        "english",
        catalog,
    )
    assert_true(english_reciprocal.handled)
    assert_equal(len(english_reciprocal.invocations), 1)
    assert_true("-language=english" in _tokens(english_reciprocal))
    assert_true(
        "--spaltenreihenfolgeundnurdiese=1" in _tokens(english_reciprocal)
    )
    assert_false("--oberesmaximum=" in _tokens(english_reciprocal))

    var true_fraction = _plan("vielfache teiler universum 2/3")
    assert_true(true_fraction.handled)
    assert_equal(len(true_fraction.invocations), 13)
    assert_true("--spaltenreihenfolgeundnurdiese=1" in _tokens(true_fraction, 0))
    assert_false(
        "--spaltenreihenfolgeundnurdiese=1,4" in _tokens(true_fraction, 0)
    )
    var compact_true_fraction = _plan("universum v2/3 teiler")
    assert_true(compact_true_fraction.handled)
    assert_equal(
        serialize_prompt_table_plan(compact_true_fraction),
        serialize_prompt_table_plan(true_fraction),
    )

    # A machine-readable stream lets the shell parity test compare the complete
    # native token plans with the instrumented Python reference, not only
    # selected boundary assertions.  All handled cases have one invocation.
    _emit_mixed_reciprocal_reference("universum teiler 1/2")
    _emit_mixed_reciprocal_reference("universum vielfache 1/2")
    _emit_mixed_reciprocal_reference("universum vielfache teiler 1/2")
    _emit_mixed_reciprocal_reference("universum v1/2 teiler")
    _emit_mixed_reciprocal_reference("universum vielfache teiler 1/2,-1/4")


def test_true_fraction_multiples_follow_each_csv_rectangle() raises:
    var compact = _plan("universum v2/3")
    var spelled = _plan("universum vielfache 2/3")
    assert_equal(
        serialize_prompt_table_plan(compact), serialize_prompt_table_plan(spelled)
    )

    var emotion = _plan("emotion v2/3")
    assert_true(emotion.handled)
    assert_equal(len(emotion.invocations), 6)
    assert_true("_Gefuehle_n/m=8" in _tokens(emotion, 5))
    assert_false("_Gefuehle_n/m=10" in serialize_prompt_table_plan(emotion))

    var size = _plan("groesse v2/3")
    assert_true(size.handled)
    assert_equal(len(size.invocations), 12)
    assert_true("_Strukturgroesse_n/m=16" in _tokens(size, 11))
    assert_false("_Strukturgroesse_n/m=18" in serialize_prompt_table_plan(size))

    var motives = _plan("motive v2/3")
    assert_true(motives.handled)
    assert_equal(len(motives.invocations), 13)
    assert_true("_Galaxie_n/m=22" in _tokens(motives, 12))
    assert_false("_Galaxie_n/m=24" in serialize_prompt_table_plan(motives))

    assert_true("_Gefuehle_n/m=8" in _tokens(_plan("emotion v8/3")))
    assert_true("_Strukturgroesse_n/m=17" in _tokens(_plan("groesse v17/3")))
    assert_true("_Galaxie_n/m=22" in _tokens(_plan("motive v22/3")))
    assert_true("_Universum_n/m=20" in _tokens(_plan("universum v20/3")))

    # Different data rectangles remain atomic.  Mixed reciprocal and true
    # fraction multiples now split their bounds: 1/n uses rows below 1024,
    # while n/m remains clipped to the selected physical CSV rectangle.
    assert_false(_plan("universum motive v2/3").handled)
    var mixed_axes = _plan("universum v1/2,2/3")
    assert_true(mixed_axes.handled)
    assert_equal(len(mixed_axes.invocations), 13)
    assert_true(
        "--vorhervonausschnitt=2,1,4,6,3" in _tokens(mixed_axes, 0)
    )
    assert_true(
        "--vorhervonausschnitt=1,2,3,4,6,8,9,10"
        in _tokens(mixed_axes, 1)
    )
    assert_true(",1018,1020,1022" in _tokens(mixed_axes, 1))
    assert_true(
        "--gebrochen-rational_Universum_n/m=20"
        in _tokens(mixed_axes, 11)
    )
    var mixed_spelled = _plan("universum vielfache 1/2,2/3")
    assert_equal(
        serialize_prompt_table_plan(mixed_spelled),
        serialize_prompt_table_plan(mixed_axes),
    )
    var mixed_english = _plan("universe multiple 1/2,2/3", "english")
    assert_true(mixed_english.handled)
    assert_equal(len(mixed_english.invocations), 13)
    assert_true("-language=english" in _tokens(mixed_english, 0))
    assert_false(_plan("universum v-1/4,2/3").handled)
    assert_false(_plan("universum v-2/3").handled)

    _emit_true_fraction_multiple_plan("universum v2/3")
    _emit_true_fraction_multiple_plan("universum vielfache 2/3")
    _emit_true_fraction_multiple_plan("universum v2/3 teiler")
    _emit_true_fraction_multiple_plan("emotion v2/3")
    _emit_true_fraction_multiple_plan("groesse v2/3")
    _emit_true_fraction_multiple_plan("motive v2/3")
    _emit_true_fraction_multiple_plan("emotion v8/3")
    _emit_true_fraction_multiple_plan("groesse v17/3")
    _emit_true_fraction_multiple_plan("motive v22/3")
    _emit_true_fraction_multiple_plan("universum v20/3")
    _emit_true_fraction_multiple_plan("universum motive v2/3")
    _emit_true_fraction_multiple_plan("universum v1/2,2/3")


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

    var exact = _plan("universum 2/4,-2/4")
    assert_true(exact.handled)
    assert_equal(len(exact.invocations), 1)
    assert_true("--vorhervonausschnitt=4,-4" in _tokens(exact))

    var empty_positive = _plan("emotion 2/3,-1/4")
    assert_true(empty_positive.handled)
    assert_equal(len(empty_positive.invocations), 2)
    assert_true("--vorhervonausschnitt=,-4" in _tokens(empty_positive, 0))
    assert_true("--vorhervonausschnitt=3" in _tokens(empty_positive, 1))

    var reduced_collision = _plan("universum 2/4,-1/2")
    assert_true(reduced_collision.handled)
    assert_equal(len(reduced_collision.invocations), 2)
    assert_true("--vorhervonausschnitt=2,-2" in _tokens(reduced_collision, 0))
    assert_true("--vorhervonausschnitt=4" in _tokens(reduced_collision, 1))

    var reciprocal_collision = _plan("universum 1/2,-1/2")
    assert_true(reciprocal_collision.handled)
    assert_equal(len(reciprocal_collision.invocations), 1)
    assert_true("--vorhervonausschnitt=2,-2" in _tokens(reciprocal_collision))

    var equal_literal_collision = _plan("universum 2/2,-2/2")
    assert_true(equal_literal_collision.handled)
    assert_equal(len(equal_literal_collision.invocations), 1)
    assert_true(
        "--vorhervonausschnitt=-2,2" in _tokens(equal_literal_collision)
    )

    var prefixed = _plan("universum v1/4,-1/8")
    assert_true(prefixed.handled)
    assert_equal(len(prefixed.invocations), 1)
    assert_true("--vorhervonausschnitt=4,516,12,524" in _tokens(prefixed))
    assert_true(",500,1012,508" in _tokens(prefixed))


def test_eign_properties_are_native_in_full_python_set_order() raises:
    var plan = _plan("EIGNgut EIGNehrlich 2 --art=csv --nocolor")
    assert_true(plan.handled)
    assert_equal(len(plan.invocations), 1)
    assert_true("--vorhervonausschnitt=2" in _tokens(plan))
    assert_true("--konzept=ehrlich,gut" in _tokens(plan))
    assert_true("--art=csv" in _tokens(plan))
    assert_true("--nocolor" in _tokens(plan))

    var reduced_whole = _plan("EIGNgut 4/2")
    assert_true(reduced_whole.handled)
    assert_equal(len(reduced_whole.invocations), 1)
    assert_true("--vorhervonausschnitt=2" in _tokens(reduced_whole))

    var proper_only = _plan("EIGNgut 2/3")
    assert_true(proper_only.handled)
    assert_equal(len(proper_only.invocations), 0)


def test_eigr_properties_use_the_explicit_legacy_argv_contract() raises:
    var integer = _plan("EIGRwerte 2 --art=csv --nocolor")
    assert_true(integer.handled)
    assert_equal(len(integer.invocations), 1)
    assert_true("--vorhervonausschnitt=0" in _tokens(integer))
    assert_true("--konzept2=werte" in _tokens(integer))
    assert_true(
        "-zeilen|--vorhervonausschnitt=2|--oberesmaximum=1025"
        in _tokens(integer)
    )

    var reciprocal = _plan("EIGRwerte 1/2")
    assert_true(reciprocal.handled)
    assert_equal(len(reciprocal.invocations), 1)
    assert_true("--vorhervonausschnitt=2" in _tokens(reciprocal))
    assert_true("--konzept2=werte" in _tokens(reciprocal))

    var proper_only = _plan("EIGRwerte 2/3")
    assert_true(proper_only.handled)
    assert_equal(len(proper_only.invocations), 0)


def test_every_catalogued_eign_eigr_command_has_a_native_plan() raises:
    var catalog = load_prompt_language_catalog("assets")
    var count = 0
    for entry_index in range(len(catalog.completions)):
        var entry = catalog.completions[entry_index].copy()
        if entry.language != "deutsch" or entry.scope != "root":
            continue
        for value_index in range(len(entry.values)):
            var value = entry.values[value_index]
            if not (value.startswith("EIGN") or value.startswith("EIGR")):
                continue
            var plan = plan_prompt_table_commands(
                [value, "2"], "deutsch", catalog
            )
            assert_true(plan.handled)
            assert_equal(len(plan.invocations), 1)
            if value.startswith("EIGN"):
                assert_true("--konzept=" in _tokens(plan))
            else:
                assert_true("--konzept2=" in _tokens(plan))
            count += 1
    assert_equal(count, 165)


def test_pure_numeric_default_compositions_are_native() raises:
    var catalog = load_prompt_language_catalog("assets")

    var zero_default = prepare_prompt_tokens(
        catalog, "deutsch", ["0"], False, True
    )
    var zero_plan = plan_prompt_table_commands(
        zero_default.tokens, "deutsch", catalog
    )
    assert_true(zero_plan.handled)
    assert_equal(len(zero_plan.invocations), 1)
    assert_true("--vorhervonausschnitt=0" in _tokens(zero_plan))
    assert_true("--galaxie=thomas" in _tokens(zero_plan))
    assert_false("--oberesmaximum=" in _tokens(zero_plan))
    assert_false("--menschliches=motive" in _tokens(zero_plan))

    var integer_default = prepare_prompt_tokens(
        catalog, "deutsch", ["15"], False, True
    )
    var integer_plan = plan_prompt_table_commands(
        integer_default.tokens, "deutsch", catalog
    )
    assert_true(integer_plan.handled)
    assert_equal(len(integer_plan.invocations), 2)
    assert_true("--galaxie=thomas" in _tokens(integer_plan, 0))
    assert_true("--menschliches=motive" in _tokens(integer_plan, 1))

    var reciprocal_default = prepare_prompt_tokens(
        catalog, "deutsch", ["1/2"], False, True
    )
    var reciprocal_plan = plan_prompt_table_commands(
        reciprocal_default.tokens, "deutsch", catalog
    )
    assert_true(reciprocal_plan.handled)
    assert_equal(len(reciprocal_plan.invocations), 7)
    assert_true(
        "--Universum=transzendentaliereziproke" in _tokens(reciprocal_plan, 6)
    )

    var proper_default = prepare_prompt_tokens(
        catalog, "deutsch", ["3/2"], False, True
    )
    var proper_plan = plan_prompt_table_commands(
        proper_default.tokens, "deutsch", catalog
    )
    assert_true(proper_plan.handled)
    assert_equal(len(proper_plan.invocations), 4)
    assert_true(
        "--gebrochen-rational_Universum_n/m=3" in _tokens(proper_plan, 3)
    )


def test_numeric_shortcut_families_are_native() raises:
    var basic = _plan("15_13 13")
    assert_true(basic.handled)
    assert_equal(len(basic.invocations), 1)
    assert_true(
        "--Grundstrukturen=Paradigmen_sind_Absichten_(13)" in _tokens(basic)
    )

    var multi = _plan("16_2 2")
    assert_true(multi.handled)
    assert_equal(len(multi.invocations), 1)
    assert_true(
        "--Multiversum=Strukturalien_bzw_Meta-Paradigmen_bzw_Transzendentalien_(15),Model_of_Hierarchical_Complexity"
        in _tokens(multi)
    )

    var both = _plan("15_13 16_2 2")
    assert_true(both.handled)
    assert_equal(len(both.invocations), 2)
    assert_true("--Multiversum=" in _tokens(both, 0))
    assert_true("--Grundstrukturen=" in _tokens(both, 1))


def test_numeric_shortcut_set_order_and_empty_selection() raises:
    var catalog = load_prompt_language_catalog("assets")
    var prepared = prepare_prompt_tokens(
        catalog,
        "deutsch",
        split_prompt_words("15_5 15_2 15_13 2-3"),
    )
    var ordered = plan_prompt_table_commands(
        prepared.tokens, "deutsch", catalog
    )
    assert_true(ordered.handled)
    assert_true(
        "--Grundstrukturen=Konkreta_und_Focus_(2),Paradigmen_sind_Absichten_(13),Impulse_(5)"
        in _tokens(ordered)
    )

    var empty = _plan("15_13")
    assert_true(empty.handled)
    assert_equal(len(empty.invocations), 0)

    # 16_15 is the historical alias for family 15/key 15.  Repeating it
    # preserves both bundles in the echoed invocation while the generated
    # column itself is deduplicated by the native table registry, like Python.
    var repeated = _plan("15_ 16_15 15")
    assert_true(repeated.handled)
    assert_equal(len(repeated.invocations), 1)
    var bundle = (
        "Strukturalien_bzw_Meta-Paradigmen_bzw_Transzendentalien_(15),"
        + "Geist_(15),Model_of_Hierarchical_Complexity,"
        + "Biologischer_Baum_(15),Teilchen_anderes_Universum,"
        + "nachvollziehen_emotional_oder_geistig_durch_"
        + "Primzahl-Kreuz-Algorithmus_(15)"
    )
    assert_true(
        "--Grundstrukturen=" + bundle + "," + bundle in _tokens(repeated)
    )


def test_english_numeric_shortcut_option_names() raises:
    var basic = _plan("15_13 13", "english")
    assert_true(basic.handled)
    assert_true(
        "--basic_structures=paradigms_are_intentions_(13)" in _tokens(basic)
    )
    var multi = _plan("16_2 2", "english")
    assert_true(multi.handled)
    assert_true("--multiverse=" in _tokens(multi))


def test_every_addressable_numeric_catalog_entry_has_a_native_plan() raises:
    var catalog = load_prompt_language_catalog("assets")
    assert_equal(len(catalog.numeric_shortcuts), 370)
    var addressable = 0
    for index in range(len(catalog.numeric_shortcuts)):
        var entry = catalog.numeric_shortcuts[index].copy()
        # The legacy grammar reserves 16_15 for Grundstrukturen family 15,
        # making Multiversum key 15 unreachable in all five languages.
        if entry.family == "16" and entry.key == "15":
            continue
        addressable += 1
        var words = List[String]()
        words.append(entry.family + "_" + entry.key)
        words.append("2")
        var plan = plan_prompt_table_commands(words, entry.language, catalog)
        assert_true(plan.handled)
        assert_equal(len(plan.invocations), 1)
        var expected_name = (
            "Grundstrukturen" if entry.language == "deutsch"
            and entry.family
            == "15" else "Multiversum" if entry.language
            == "deutsch" else "basic_structures" if entry.family
            == "15" else "multiverse"
        )
        assert_true("--" + expected_name + "=" in _tokens(plan))
    assert_equal(addressable, 365)


def test_no_table_command_stays_at_boundary() raises:
    assert_false(_plan("range 1-3").handled)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
