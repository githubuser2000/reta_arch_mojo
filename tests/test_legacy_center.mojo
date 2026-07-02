from std.collections import Dict, List, Set
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_center import *


def test_snapshot_covers_all_active_python_wrappers() raises:
    var snapshot = legacy_center_snapshot()
    assert_equal(len(snapshot.compatibility_names), 27)
    assert_equal(len(snapshot.npm_values), 8)
    assert_equal(snapshot.npm_values[0], 2)
    assert_equal(snapshot.npm_values[7], 9)


def test_npm_groups_match_legacy_enum() raises:
    assert_equal(gal()[0], 2)
    assert_equal(gal()[1], 3)
    assert_equal(uni()[0], 4)
    assert_equal(emo()[1], 7)
    assert_equal(groe()[1], 9)
    assert_equal(n()[3], 8)
    assert_equal(einsPn()[3], 9)


def test_row_range_aliases() raises:
    assert_true(isZeilenBruchAngabe_betweenKommas("1/2-3/4"))
    assert_true(isZeilenBruchOrGanzZahlAngabe("1-3,4/5"))
    assert_true(isZeilenBruchAngabe("1/2,3/4"))
    assert_true(isZeilenAngabe("1-4,-2"))
    assert_true(isZeilenAngabe_betweenKommas("{1,3,5}"))


def test_explicit_set_and_range_expansion() raises:
    var explicit = strAsGeneratorToListOfNumStrs("{1,3,5}")
    assert_equal(len(explicit), 3)
    assert_true(3 in explicit)
    var values = BereichToNumbers2("1-4,-2")
    assert_equal(len(values), 3)
    assert_true(1 in values)
    assert_false(2 in values)
    assert_true(4 in values)


    var include = Set[Int]()
    var exclude = Set[Int]()
    BereichToNumbers2_EinBereich("2-4", include, exclude, 20, False)
    assert_true(3 in include)
    var couple = List[String]()
    couple.append("3")
    couple.append("5")
    var around = [0]
    var direct = Set[Int]()
    BereichToNumbers2_EinBereich_Menge(couple, around, 20, direct, False)
    assert_true(5 in direct)
    var shifted = Set[Int]()
    BereichToNumbers2_EinBereich_Menge_nichtVielfache(couple, [1], 20, shifted)
    assert_true(2 in shifted)
    assert_true(6 in shifted)
    var multiplied = Set[Int]()
    var multiple_couple = List[String]()
    multiple_couple.append("2")
    multiple_couple.append("3")
    BereichToNumbers2_EinBereich_Menge_vielfache(multiple_couple, [0], 10, multiplied)
    assert_true(6 in multiplied)


def test_console_helpers() raises:
    var parts = chunks(["a", "b", "c", "d", "e"], 2)
    assert_equal(len(parts), 3)
    assert_equal(parts[2][0], "e")
    var unique = unique_everseen(["a", "b", "a", "c", "b"])
    assert_equal(len(unique), 3)
    assert_equal(unique[2], "c")
    assert_equal(cliout("  a\n  b  ", True), "a b")
    assert_equal(x("value", "42", True), "value: 42")
    assert_equal(alxp("42", True), "42")
    assert_equal(getTextWrapThings(123).shell_width, 123)


def test_help_assets_are_native_and_nonempty() raises:
    var reta_help = retaHilfe()
    var prompt_help = retaPromptHilfe()
    assert_true(reta_help.byte_length() > 10000)
    assert_true(prompt_help.byte_length() > 10000)
    assert_true("reta" in reta_help)
    assert_true("retaPrompt" in prompt_help)


def test_arithmetic_aliases() raises:
    var pairs = multiples(12)
    assert_equal(len(pairs), 3)
    assert_equal(pairs[len(pairs) - 1].first, 12)
    assert_equal(pairs[len(pairs) - 1].second, 1)
    var factors = primfaktoren(72)
    assert_equal(len(factors), 5)
    var labels = primRepeat(factors)
    assert_equal(labels[0], "2^3")
    assert_equal(labels[1], "3^2")
    var grouped = primRepeat2(factors)
    assert_equal(grouped[0].first, 2)
    assert_equal(grouped[0].second, 3)
    assert_true(textHatZiffer("abc٢"))
    assert_true(textHatZiffer("abc2"))
    var lines = moduloA([5])
    assert_equal(len(lines), 24)


def test_dictionary_inversion_and_divisors() raises:
    var source = Dict[String, List[String]]()
    source["a"] = ["2", "3"]
    source["b"] = ["3"]
    var inverted = invert_dict_B(source)
    assert_equal(len(inverted[3]), 2)
    var divisor_result = teiler("12")
    assert_true(2 in divisor_result[1])
    assert_true(6 in divisor_result[1])
    assert_false(1 in divisor_result[1])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
