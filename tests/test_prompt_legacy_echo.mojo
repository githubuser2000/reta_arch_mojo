from std.testing import assert_equal, TestSuite
from reta_mojo.prompt_legacy_echo import *


def _assert_tokens(actual: List[String], expected: List[String]) raises:
    assert_equal(len(actual), len(expected))
    for index in range(len(expected)):
        assert_equal(actual[index], expected[index])


def test_compact_announcement_german() raises:
    assert_equal(
        compact_prompt_announcement(["absicht", "15"], "a15", "deutsch"),
        "'absicht 15' ergibt sich aus 'a15' und ergibt danach reta-Befehl:",
    )


def test_compact_announcement_english() raises:
    assert_equal(
        compact_prompt_announcement(["intention", "15"], "i15", "english"),
        "'intention 15' results from 'i15' and results reta command after:",
    )


def test_legacy_motive_and_basic_case_spellings() raises:
    _assert_tokens(
        legacy_table_echo_tokens(
            [
                "-spalten",
                "--menschliches=motive",
                "--grundstrukturen=emotion",
                "--universum=transzendentalien",
                "--galaxie=thomas",
            ]
        ),
        [
            "-spalten",
            "--Menschliches=motivation",
            "--Grundstrukturen=emotion",
            "--Universum=transzendentalien",
            "--Galaxie=thomas",
        ],
    )


def test_legacy_drive_spelling() raises:
    _assert_tokens(
        legacy_table_echo_tokens(["--grundstrukturen=trieb,System"]),
        ["--Grundstrukturen=Triebe_und_Bedürfnisse_(6),System"],
    )


def test_execution_tokens_are_not_mutated() raises:
    var source = List[String]()
    source.append("--menschliches=motive")
    source.append("--breite=0")
    _ = legacy_table_echo_tokens(source)
    _assert_tokens(source, ["--menschliches=motive", "--breite=0"])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
