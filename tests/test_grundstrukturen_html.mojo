from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.grundstrukturen_html import *


def test_supported_languages() raises:
    assert_true(is_supported_grundstrukturen_language(""))
    assert_true(is_supported_grundstrukturen_language("german"))
    assert_true(is_supported_grundstrukturen_language("english"))
    assert_true(is_supported_grundstrukturen_language("vietnamese"))
    assert_true(is_supported_grundstrukturen_language("chinese"))
    assert_true(is_supported_grundstrukturen_language("korean"))
    assert_false(is_supported_grundstrukturen_language("esperanto"))


def test_catalog_shape() raises:
    assert_equal(grundstrukturen_record_count("german"), 151)
    assert_equal(grundstrukturen_leaf_count("german"), 84)
    assert_equal(grundstrukturen_record_count("english"), 151)
    assert_equal(grundstrukturen_leaf_count("english"), 84)


def test_localized_main_label() raises:
    assert_equal(basic_structures_label("german"), "Grundstrukturen")
    assert_equal(basic_structures_label("english"), "basic_structures")
    assert_equal(basic_structures_label("chinese"), "basic_structures")


def test_reference_output_lengths() raises:
    assert_equal(
        render_grundstrukturen_html(False, "german").byte_length(), 13780
    )
    assert_equal(
        render_grundstrukturen_html(True, "german").byte_length(), 27357
    )
    assert_equal(
        render_grundstrukturen_html(False, "english").byte_length(), 13583
    )
    assert_equal(
        render_grundstrukturen_html(True, "english").byte_length(), 26944
    )


def test_blank_and_normal_prefixes() raises:
    var blank = render_grundstrukturen_html(True, "german")
    var normal = render_grundstrukturen_html(False, "german")
    var blank_prefix = (
        '<div style="white-space: normal; border-left: 40px solid rgba(0, 0,'
        " 0, .0);\" id='grundstrukturenDiv'>"
    )
    var normal_prefix = (
        '<div style="white-space: normal; border-left: 40px solid rgba(0, 0, 0,'
        ' .0);" >'
    )
    assert_equal(
        String(StringSlice(blank)[byte = 0 : blank_prefix.byte_length()]),
        blank_prefix,
    )
    assert_equal(
        String(StringSlice(normal)[byte = 0 : normal_prefix.byte_length()]),
        normal_prefix,
    )


def test_reference_output_suffix() raises:
    var rendered = render_grundstrukturen_html(True, "english")
    assert_equal(String(StringSlice(rendered)[byte= -13:]), "</div></div>\n")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
