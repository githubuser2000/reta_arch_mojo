from std.collections import Dict, List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.runtime_compat import *


def test_runtime_compat_snapshot_covers_python_surface() raises:
    var snapshot = runtime_compat_snapshot()
    assert_equal(len(snapshot.callable_names), 18)
    assert_equal(len(snapshot.global_names), 13)
    assert_equal(len(snapshot.npm_values), 8)
    assert_equal(snapshot.npm_values[0], 2)
    assert_equal(snapshot.npm_values[7], 9)
    assert_equal(snapshot.multiplication_pairs[0][0], "Multiplikationen")
    assert_true("(?!" in snapshot.comma_split_pattern)
    assert_equal(snapshot.prime_cross_strings[0], "Primzahlkreuz_pro_contra")
    assert_true("Primzahl-Kreuz-Algorithmus" in snapshot.prime_cross_strings[1])


def test_runtime_compat_npm_and_padding_contract() raises:
    assert_equal(npm_galaxy(), [2, 3])
    assert_equal(npm_universe(), [4, 5])
    assert_equal(npm_emotion(), [6, 7])
    assert_equal(npm_size(), [8, 9])
    assert_equal(npm_n_values(), [2, 4, 6, 8])
    assert_equal(npm_one_plus_n_values(), [3, 5, 7, 9])

    var first: List[String] = ["a"]
    var second: List[String] = ["b", "c", "d"]
    fill_both(first, second)
    assert_equal(len(first), 3)
    assert_equal(first[1], "")
    assert_equal(len(second), 3)


def test_runtime_compat_row_range_and_console_contract() raises:
    var values = BereichToNumbers2("1-3")
    assert_equal(len(values), 3)
    assert_true(1 in values)
    assert_true(3 in values)
    assert_true(isZeilenAngabe("1-3"))
    assert_false(isZeilenAngabe("abc"))

    assert_equal(x("name", "wert", True, True), "name: wert")
    assert_equal(x("name", "wert", False, True), "")
    assert_equal(alxp("wert", True, True), "wert")
    assert_equal(cliout("a   b", True), "a b")
    assert_equal(cliout("a   b", False), "a   b")
    assert_equal(cliout("a", False, "", False), "")

    var pieces: List[String] = ["a", "b", "c"]
    var grouped = chunks(pieces, 2)
    assert_equal(len(grouped), 2)
    assert_equal(grouped[0][1], "b")
    var unique = unique_everseen(["a", "b", "a", "c", "b"])
    assert_equal(unique, ["a", "b", "c"])


def test_runtime_compat_arithmetic_contract() raises:
    var pairs = multiples(12)
    assert_true(len(pairs) >= 3)
    assert_equal(primfaktoren(12), [2, 2, 3])
    assert_true(textHatZiffer("größer ٢"))
    assert_false(textHatZiffer("ohne"))
    var repeated = primRepeat([2, 2, 3])
    assert_true(len(repeated) > 0)
    var repeated_pairs = primRepeat2([2, 2, 3])
    assert_true(len(repeated_pairs) > 0)
    var modulo = moduloA([2, 3])
    assert_true(len(modulo) > 0)


def test_runtime_compat_wrap_capabilities_are_typed() raises:
    var runtime = getTextWrapThings(42)
    assert_equal(runtime.shell_rows_amount, 42)
    assert_false(runtime.has_hyphenator)
    assert_false(runtime.has_dictionary)
    assert_true(runtime.has_fill)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
