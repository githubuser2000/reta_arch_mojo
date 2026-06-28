from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.topology import *


def test_unrestricted_and_empty_are_distinct() raises:
    var unrestricted = unrestricted_selection()
    assert_false(selection_is_empty(unrestricted))
    var empty_values = List[String]()
    unrestricted.language = restricted_dimension(empty_values)
    assert_true(selection_is_empty(unrestricted))


def test_refinement_intersects_restricted_dimensions() raises:
    var left = unrestricted_selection()
    left.language = restricted_dimension(["de", "en"])
    var right = unrestricted_selection()
    right.language = restricted_dimension(["de", "fr"])
    right.output_modes = restricted_dimension(["html"])
    var refined = refine_selection(left, right)
    assert_equal(len(refined.language.values), 1)
    assert_true("de" in refined.language.values)
    assert_true("html" in refined.output_modes.values)
    assert_false(selection_is_empty(refined))


def test_disjoint_refinement_is_empty() raises:
    var left = unrestricted_selection()
    left.scopes = restricted_dimension(["zeilen"])
    var right = unrestricted_selection()
    right.scopes = restricted_dimension(["spalten"])
    assert_true(selection_is_empty(refine_selection(left, right)))


def test_alias_canonicalization_and_open() raises:
    var dimension = new_context_dimension("language")
    include_dimension_value(dimension, "de", ["deutsch", "ger"])
    include_dimension_value(dimension, "en", ["english"])
    assert_equal(canonicalize_dimension(dimension, "deutsch"), "de")
    assert_equal(canonicalize_dimension(dimension, "unknown"), "")
    var opened = open_for("language", ["deutsch", "unknown"], dimension)
    assert_true("de" in opened.language.values)
    assert_true("unknown" in opened.language.values)


def test_cover_for_main() raises:
    var cover = cover_for_main("zeilen")
    assert_equal(len(cover), 2)
    assert_true("zeilen" in cover[0].main_parameters.values)
    assert_true("spalten" in cover[1].scopes.values)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
