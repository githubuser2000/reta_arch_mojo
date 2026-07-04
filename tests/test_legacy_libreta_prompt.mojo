from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.legacy_libreta_prompt import *


def test_import_time_bundle_counts_match_reference() raises:
    var facade = bootstrap_legacy_libreta_prompt()
    var snapshot = facade.snapshot()
    assert_equal(snapshot.exported_names_len, 48)
    assert_equal(snapshot.main_parameters_len, 7)
    assert_equal(snapshot.columns_len, 4160)
    assert_equal(snapshot.columns_dictionary_keys, 84)
    assert_equal(snapshot.row_parameters_len, 15)
    assert_equal(snapshot.output_parameters_len, 14)
    assert_equal(snapshot.commands_len, 386)
    assert_equal(snapshot.commands2_len, 385)
    assert_equal(snapshot.wahl15_len, 65)
    assert_equal(snapshot.wahl16_len, 9)
    assert_equal(snapshot.missing_wahl15_len, 0)
    assert_equal(facade.mainParas[0], "-zeilen")
    assert_equal(facade.mainParas[6], "-help")


def test_prompt_modes_and_helpers_are_explicit() raises:
    var facade = bootstrap_legacy_libreta_prompt()
    assert_equal(facade.promptModes.normal, 0)
    assert_equal(facade.promptModes.speichern, 1)
    assert_equal(facade.promptModes.AusgabeSelektiv, 6)
    assert_equal(custom_split("a (b c) d"), ["a", "(b c)", "d"])
    assert_true(is15or16command(facade, "15_"))
    assert_false(is15or16command(facade, "17_"))
    assert_equal(
        Primzahlkreuz_pro_contra_strs()[0],
        "Primzahlkreuz_pro_contra",
    )


def test_dictionary_shortening_keeps_first_key() raises:
    var shortened = verkuerze_dict(
        [
            LegacyPromptMapEntry("a", "one"),
            LegacyPromptMapEntry("b", "one"),
            LegacyPromptMapEntry("c", "two"),
        ]
    )
    assert_equal(
        shortened,
        [
            LegacyPromptMapEntry("a", "one"),
            LegacyPromptMapEntry("c", "two"),
        ],
    )


def test_fraction_verification_is_typed() raises:
    var verified = verifyBruchNganzZahlBetweenCommas(
        List[Bool](),
        "not-a-row-range",
        List[String](),
        "1/2-3/4",
        List[String](),
        "2-4",
        List[String](),
    )
    assert_true(verified.all_valid)
    assert_equal(verified.integer_specs, ["2-4"])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
