from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_lib4tables import *


def test_export_snapshot_matches_python_all() raises:
    var snapshot = legacy_lib4tables_snapshot()
    assert_equal(len(snapshot.exported_names), 18)
    assert_equal(snapshot.exported_names[0], "math")
    assert_equal(snapshot.exported_names[17], "couldBePrimeNumberPrimzahlkreuz_fuer_aussen")


def test_syntax_aliases() raises:
    assert_equal(OutputSyntax().syntax_class_name, "OutputSyntax")
    assert_equal(NichtsSyntax().syntax_class_name, "NichtsSyntax")
    assert_equal(csvSyntax().canonical_name, "csv")
    assert_true(csvSyntax().force_one_table)
    assert_equal(bbCodeSyntax().begin_table, "[table]")
    assert_equal(htmlSyntax().end_table, "</table>\n")
    assert_equal(emacsSyntax().begin_cell, "|")
    assert_equal(markdownSyntax().begin_cell, "|")


def test_number_theory_aliases() raises:
    var factors = primFak(360)
    assert_equal(len(factors), 6)
    var divisors = divisorGenerator(36)
    assert_equal(len(divisors), 9)
    assert_equal(divisors[0], 1)
    assert_equal(divisors[8], 36)
    var grouped = primRepeat(primFak(72))
    assert_equal(grouped[0].first, 2)
    assert_equal(grouped[0].second, 3)
    assert_equal(primCreativity(36), 3)
    var multiples = primMultiple(12)
    assert_equal(multiples[0].first, 1)
    assert_true(isPrimMultiple(12, [6]))
    assert_false(isPrimMultiple(12, [7]))
    var match_vector = isPrimMultipleMatches(12, [6, 7, 3])
    assert_equal(len(match_vector), 9)
    assert_false(match_vector[0])
    assert_true(match_vector[1])
    assert_false(match_vector[2])
    assert_false(match_vector[8])


def test_prime_cross_aliases() raises:
    assert_true(couldBePrimeNumberPrimzahlkreuz(29))
    assert_true(couldBePrimeNumberPrimzahlkreuz_fuer_innen(29))
    assert_false(couldBePrimeNumberPrimzahlkreuz_fuer_aussen(29))
    var moon = moonNumber(64)
    assert_equal(len(moon[0]), 3)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
