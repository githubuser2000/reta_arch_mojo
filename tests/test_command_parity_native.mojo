from std.testing import assert_equal, TestSuite
from reta_mojo.command_parity import *


def test_command_matrix_is_exactly_the_historical_four_cases() raises:
    var cases = load_command_parity_cases()
    var snapshot = command_parity_snapshot(cases)
    assert_equal(snapshot.cases, 4)
    assert_equal(snapshot.exact_cases, 3)
    assert_equal(snapshot.html_cases, 1)
    assert_equal(snapshot.total_tokens, 24)
    assert_equal(cases[0].label, "shell-religion-basic")
    assert_equal(cases[1].label, "markdown-religion-basic")
    assert_equal(cases[2].label, "html-religion-basic")
    assert_equal(cases[3].label, "shell-fractional-csv-gluing")


def test_html_normalization_matches_legacy_contract() raises:
    assert_equal(
        normalize_command_parity_html("  p4_5,4,0,3  x\n y  "),
        "p4_0,3,4,5 x y",
    )


def test_every_representative_fixture_is_packaged() raises:
    var cases = load_command_parity_cases()
    for index in range(len(cases)):
        var expected = expected_command_parity_output(cases[index])
        assert_equal(expected.byte_length() > 0, True)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
