from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.native_cli_startup import native_cli_startup



def test_empty_invocation_is_native_hint() raises:
    var result = native_cli_startup(List[String]())
    assert_true(result.owned)
    assert_equal(result.language, "german")
    assert_equal(result.help_count, 0)
    assert_equal(result.output, "Versuche Parameter -h\n")


def test_language_only_vectors_are_owned_empty_streams() raises:
    for value in ["english", "german", "deutsch"]:
        var result = native_cli_startup(["-language=" + value])
        assert_true(result.owned)
        assert_equal(result.output, "")
        assert_equal(result.help_count, 0)
    var first_wins = native_cli_startup(
        ["-language=english", "-language=german"]
    )
    assert_true(first_wins.owned)
    assert_equal(first_wins.language, "english")
    assert_equal(first_wins.output, "")


def test_localized_help_assets_are_exact() raises:
    var german = native_cli_startup(["-h"])
    assert_true(german.owned)
    assert_equal(german.help_count, 1)
    assert_equal(german.output.byte_length(), 12042)
    assert_true(german.output.startswith("Hauptprogramm ist reta oder reta.py\n"))
    assert_true(german.output.endswith("\n"))

    var english = native_cli_startup(
        ["-language=english", "-help"]
    )
    assert_true(english.owned)
    assert_equal(english.language, "english")
    assert_equal(english.output.byte_length(), 11409)
    assert_true(english.output.startswith("Main program is reta or reta.py.\n"))
    assert_true(english.output.endswith("\n"))


def test_help_repetition_and_first_language_selector() raises:
    var duplicate = native_cli_startup(["-help", "-h"])
    assert_true(duplicate.owned)
    assert_equal(duplicate.help_count, 2)
    assert_equal(duplicate.output.byte_length(), 24084)

    var english_first = native_cli_startup(
        [
            "-h",
            "-language=english",
            "-language=german",
        ]
    )
    assert_true(english_first.owned)
    assert_equal(english_first.language, "english")
    assert_equal(english_first.output.byte_length(), 11409)


def test_unknown_startup_tokens_are_not_claimed() raises:
    assert_false(native_cli_startup(["-sprache=english", "-h"]).owned)
    assert_false(native_cli_startup(["-language=french", "-h"]).owned)
    assert_false(native_cli_startup(["-h", "--unknown"]).owned)
    assert_false(native_cli_startup(["-zeilen"]).owned)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
