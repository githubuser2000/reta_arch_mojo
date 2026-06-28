from std.collections import List
from std.testing import assert_equal, TestSuite
from reta_mojo.compat_text import *
from reta_mojo.runtime_compat import *


def test_local_text_fallbacks_are_identity_morphisms() raises:
    var source = "[b]<em>Reta</em>[/b]"
    assert_equal(bbcode_format(source), source)
    assert_equal(render_bbcode_html(source), source)
    assert_equal(html_to_text(source), source)


def test_npm_enum_groups_match_python() raises:
    var galaxy = npm_galaxy()
    assert_equal(galaxy[0], 2)
    assert_equal(galaxy[1], 3)
    var n_values = npm_n_values()
    assert_equal(len(n_values), 4)
    assert_equal(n_values[3], 8)
    var one_plus = npm_one_plus_n_values()
    assert_equal(one_plus[0], 3)
    assert_equal(one_plus[3], 9)


def test_fill_both_pads_with_empty_strings() raises:
    var first: List[String] = ["a"]
    var second: List[String] = ["x", "y", "z"]
    fill_both(first, second)
    assert_equal(len(first), 3)
    assert_equal(first[1], "")
    assert_equal(first[2], "")
    assert_equal(len(second), 3)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
