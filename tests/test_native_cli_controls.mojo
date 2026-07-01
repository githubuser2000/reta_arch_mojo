from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.native_cli_controls import normalize_native_cli_controls


def test_debug_is_removed_and_prefix_matches_reference() raises:
    var german = normalize_native_cli_controls(["-debug"])
    assert_true(german.had_control)
    assert_true(german.debug)
    assert_equal(len(german.tokens), 0)
    assert_equal(german.debug_prefix, "Sprachenwahl: \ngerman\n")

    var english = normalize_native_cli_controls(
        ["-debug", "-language=english"]
    )
    assert_equal(english.tokens, ["-language=english"])
    assert_equal(
        english.debug_prefix,
        "Sprachenwahl: english\nnot german\n",
    )

    var first = normalize_native_cli_controls(
        ["-language=german", "-debug", "-language=english"]
    )
    assert_equal(first.debug_prefix, "Sprachenwahl: german\ngerman\n")


def test_nothing_is_silent_control_only() raises:
    var result = normalize_native_cli_controls(["-nichts"])
    assert_true(result.had_control)
    assert_true(result.control_only_nothing)
    assert_equal(len(result.tokens), 0)
    assert_equal(result.debug_prefix, "")


def test_nothing_is_ignored_inside_real_table_vector() raises:
    var result = normalize_native_cli_controls(
        [
            "-nichts",
            "-zeilen",
            "--vorhervonausschnitt=1",
            "-spalten",
            "--religionen=sternpolygon",
        ]
    )
    assert_equal(
        result.tokens,
        [
            "-zeilen",
            "--vorhervonausschnitt=1",
            "-spalten",
            "--religionen=sternpolygon",
        ],
    )
    assert_false(result.control_only_nothing)


def test_explicit_output_mode_wins_independently_of_order() raises:
    var first = normalize_native_cli_controls(
        ["-nichts", "-ausgabe", "--art=csv"]
    )
    var second = normalize_native_cli_controls(
        ["-ausgabe", "--art=csv", "-nichts"]
    )
    var english = normalize_native_cli_controls(
        ["-output", "--type=html", "-nothing"]
    )
    assert_false(first.control_only_nothing)
    assert_false(second.control_only_nothing)
    assert_false(english.control_only_nothing)
    assert_equal(first.tokens, ["-ausgabe", "--art=csv"])
    assert_equal(second.tokens, ["-ausgabe", "--art=csv"])
    assert_equal(english.tokens, ["-output", "--type=html"])


def test_help_is_not_suppressed_by_nothing() raises:
    var result = normalize_native_cli_controls(["-nichts", "-h"])
    assert_equal(result.tokens, ["-h"])
    assert_false(result.control_only_nothing)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
