from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.prompt_historical_ownership import *
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_runtime import split_prompt_words
from reta_mojo.prompt_table_execution import plan_prompt_table_commands


def _supported(
    planning: List[String], language: String = "deutsch"
) raises -> Bool:
    var catalog = load_prompt_language_catalog("assets")
    return historical_prompt_execution_supported(
        planning.copy(), planning.copy(), language, catalog
    )


def test_family_catalog_matches_every_native_table_planner_surface() raises:
    var families = historical_prompt_table_families()
    assert_equal(len(families), 33)
    assert_equal(families[0], "mond")
    assert_equal(families[32], "u")
    var expected: List[String] = [
        "mond",
        "primzahlkreuz",
        "alles",
        "freiheit",
        "gleichheit",
        "kugeln",
        "kreise",
        "netzwerk",
        "komplex",
    ]
    for index in range(len(expected)):
        assert_true(expected[index] in families)


def test_previously_conservative_classic_families_are_owned() raises:
    var families: List[String] = [
        "mond",
        "primzahlkreuz",
        "alles",
        "freiheit",
        "gleichheit",
        "kugeln",
        "kreise",
        "netzwerk",
        "komplex",
    ]
    for index in range(len(families)):
        var planning: List[String] = [
            "richtung",
            families[index],
            "2",
            "--art=csv",
            "--nocolor",
        ]
        assert_true(_supported(planning^))



def test_each_newly_owned_family_has_a_typed_native_plan() raises:
    var catalog = load_prompt_language_catalog("assets")
    var families: List[String] = [
        "mond",
        "primzahlkreuz",
        "alles",
        "freiheit",
        "gleichheit",
        "kugeln",
        "kreise",
        "netzwerk",
        "komplex",
    ]
    for index in range(len(families)):
        var words = split_prompt_words(
            "r " + families[index] + " 2 --art=csv --nocolor"
        )
        var plan = plan_prompt_table_commands(words^, "deutsch", catalog)
        assert_true(plan.handled)
        assert_true(len(plan.invocations) >= 1)

def test_localized_families_and_output_parameters_are_owned() raises:
    var english: List[String] = [
        "direction",
        "moon",
        "2",
        "--type=csv",
        "--nocolor",
    ]
    assert_true(_supported(english^, "english"))
    var compound: List[String] = [
        "range",
        "invertieren",
        "mond",
        "2-4",
        "--breite=0",
        "--keineueberschriften",
    ]
    assert_true(_supported(compound^))


def test_complete_output_parameter_surface_is_owned_in_every_language() raises:
    var catalog = load_prompt_language_catalog("assets")
    var supported = historical_prompt_output_parameters()
    assert_equal(len(supported), 13)
    var seen = 0
    for index in range(len(catalog.vocabulary)):
        var entry = catalog.vocabulary[index].copy()
        if entry.domain != "output":
            continue
        assert_true(entry.canonical in supported)
        assert_true(
            historical_prompt_parameter_supported(
                "--" + entry.translated + "=probe", entry.language, catalog
            )
        )
        seen += 1
    assert_equal(seen, 65)
    assert_true(historical_prompt_parameter_supported("-ausgabe", "deutsch", catalog))
    assert_true(historical_prompt_parameter_supported("-output", "english", catalog))


def test_extended_output_parameters_no_longer_force_atomic_fallback() raises:
    var german: List[String] = [
        "richtung",
        "2",
        "--justtext",
        "--onetable",
        "--endlessscreen",
        "--endless",
        "--dontwrap",
        "--breiten=5,7",
    ]
    assert_true(_supported(german^))
    var english: List[String] = [
        "direction",
        "2",
        "--justtext",
        "--onetable",
        "--endlessscreen",
        "--endless",
        "--dontwrap",
        "--widths=5,7",
    ]
    assert_true(_supported(english^, "english"))


def test_logging_effects_are_position_independent_and_post_command() raises:
    var catalog = load_prompt_language_catalog("assets")
    var prefix: List[String] = ["loggen", "emotion", "1"]
    var middle: List[String] = ["emotion", "nichtloggen", "1"]
    var suffix: List[String] = ["emotion", "1", "loggen"]
    assert_true(_supported(prefix^))
    assert_true(_supported(middle^))
    assert_true(_supported(suffix^))
    assert_equal(
        historical_prompt_logging_update(prefix^, "deutsch", catalog),
        PROMPT_LOG_ENABLED,
    )
    assert_equal(
        historical_prompt_logging_update(middle^, "deutsch", catalog),
        PROMPT_LOG_DISABLED,
    )
    assert_equal(
        historical_prompt_logging_update(suffix^, "deutsch", catalog),
        PROMPT_LOG_ENABLED,
    )
    var both: List[String] = [
        "nichtloggen", "emotion", "1", "loggen"
    ]
    assert_equal(
        historical_prompt_logging_update(both^, "deutsch", catalog),
        PROMPT_LOG_ENABLED,
    )
    var english: List[String] = [
        "emotion", "1", "logging_no"
    ]
    assert_true(_supported(english^, "english"))
    assert_equal(
        historical_prompt_logging_update(english^, "english", catalog),
        PROMPT_LOG_DISABLED,
    )


def test_atomic_rejection_keeps_unowned_effects_out_of_partial_execution() raises:
    var shell: List[String] = ["richtung", "shell", "echo", "2"]
    assert_false(_supported(shell^))
    var storage: List[String] = [
        "richtung", "BefehlSpeichernDanach", "mond", "2"
    ]
    assert_false(_supported(storage^))
    var unknown_parameter: List[String] = [
        "richtung", "mond", "2", "--unbekannt=ja"
    ]
    assert_false(_supported(unknown_parameter^))


def test_numeric_syntax_contract_is_explicit() raises:
    var accepted: List[String] = [
        "2", "-2", "1/3", "1-4", "[1,2]", "{2;3}"
    ]
    for index in range(len(accepted)):
        assert_true(is_prompt_numeric_syntax_token(accepted[index]))
    var rejected: List[String] = ["", "2a", "mond", "--art=csv"]
    for index in range(len(rejected)):
        assert_false(is_prompt_numeric_syntax_token(rejected[index]))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
