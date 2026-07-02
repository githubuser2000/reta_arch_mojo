from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.prompt_language import *
from reta_mojo.completion_nested import nested_completion_candidates_from_catalog


def _catalog() raises -> PromptLanguageCatalog:
    return load_prompt_language_catalog("assets")


def test_balanced_prompt_split() raises:
    var values = balanced_prompt_split("reta (1 2) [3 4] {5 6} ende")
    assert_equal(len(values), 5)
    assert_equal(values[0], "reta")
    assert_equal(values[1], "(1 2)")
    assert_equal(values[2], "[3 4]")
    assert_equal(values[3], "{5 6}")
    assert_equal(values[4], "ende")


def test_balanced_delimiter_split() raises:
    var values = balanced_prompt_split_delimiter("1,(2,3),[4,5],6", ",")
    assert_equal(len(values), 4)
    assert_equal(values[0], "1")
    assert_equal(values[1], "(2,3)")
    assert_equal(values[2], "[4,5]")
    assert_equal(values[3], "6")


def test_multilingual_dispatch_aliases() raises:
    var catalog = _catalog()
    assert_equal(localized_prompt_kind(catalog, "deutsch", "prim"), 8)
    assert_equal(localized_prompt_kind(catalog, "english", "prime"), 8)
    assert_equal(localized_prompt_kind(catalog, "english", "commands"), 3)
    assert_equal(localized_prompt_canonical(catalog, "english", "CommandClearSaves"), "BefehlSpeicherungLöschen")


def test_shortcut_replacements() raises:
    var catalog = _catalog()
    assert_equal(expand_prompt_shortcut(catalog, "deutsch", "a"), "absicht")
    assert_equal(expand_prompt_shortcut(catalog, "english", "i"), "intent")
    assert_equal(expand_prompt_shortcut(catalog, "english", "unknown"), "unknown")


def test_numeric_shortcuts() raises:
    var catalog = _catalog()
    assert_true(is_prompt_numeric_shortcut(catalog, "deutsch", "15_13_10"))
    assert_true(is_prompt_numeric_shortcut(catalog, "english", "16_15_13_10"))
    assert_true(is_prompt_numeric_shortcut(catalog, "korean", "16_5"))
    assert_false(is_prompt_numeric_shortcut(catalog, "deutsch", "15_999"))


def test_root_completion() raises:
    var catalog = _catalog()
    var values = nested_completion_candidates_from_catalog(catalog, "deutsch", "pri")
    assert_true("prim" in values)
    assert_true("prim24" in values)


def test_main_and_parameter_completion() raises:
    var catalog = _catalog()
    var mains = nested_completion_candidates_from_catalog(catalog, "deutsch", "reta ")
    assert_true("-zeilen" in mains)
    assert_true("-spalten" in mains)
    var params = nested_completion_candidates_from_catalog(catalog, "english", "reta -output ")
    assert_true("--type=" in params)
    assert_true("--width=" in params)


def test_nested_value_completion() raises:
    var catalog = _catalog()
    var output_values = nested_completion_candidates_from_catalog(catalog, "english", "reta -output --type=h")
    assert_equal(len(output_values), 3)
    assert_equal(output_values[0], "html")
    assert_equal(output_values[1], "shell")
    assert_equal(output_values[2], "nothing")
    var comma_values = nested_completion_candidates_from_catalog(catalog, "deutsch", "reta -zeilen --typ=sonne,mo")
    assert_true("mond" in comma_values)
    var combination_values = nested_completion_candidates_from_catalog(catalog, "english", "reta -combination --galaxy=ani")
    assert_true(len(combination_values) > 0)


def test_completion_word_pool_is_multilingual() raises:
    var catalog = _catalog()
    var german = prompt_completion_word_pool(catalog, "deutsch")
    var english = prompt_completion_word_pool(catalog, "english")
    assert_true(len(german) > 1000)
    assert_true(len(english) > 1000)
    assert_true("prim" in german)
    assert_true("prime" in english)



def _assert_tokens(actual: List[String], expected: List[String]) raises:
    assert_equal(len(actual), len(expected))
    for index in range(len(expected)):
        assert_equal(actual[index], expected[index])


def test_compact_prompt_expansion_german() raises:
    var catalog = _catalog()
    var a15 = expand_compact_prompt_tokens(catalog, "deutsch", ["a15"])
    assert_true(a15.compact)
    _assert_tokens(a15.tokens, ["a", "15"])

    var ap15 = expand_compact_prompt_tokens(catalog, "deutsch", ["ap15"])
    assert_true(ap15.compact)
    _assert_tokens(ap15.tokens, ["mulpri", "a", "15"])

    var pure = expand_compact_prompt_tokens(catalog, "deutsch", ["15"])
    assert_true(pure.compact)
    _assert_tokens(
        pure.tokens,
        [
            "15",
            "mulpri",
            "a",
            "t",
            "w",
            "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
        ],
    )


def test_compact_prompt_brackets_and_controls() raises:
    var catalog = _catalog()
    var bracket = expand_compact_prompt_tokens(
        catalog, "deutsch", ["(1 2)"]
    )
    assert_true(bracket.compact)
    assert_equal(bracket.tokens[0], "[1 2]")
    assert_equal(bracket.tokens[1], "mulpri")

    var ee = expand_compact_prompt_tokens(catalog, "deutsch", ["ee"])
    assert_false(ee.compact)
    _assert_tokens(ee.tokens, ["-ausgabe", "--keineueberschriften"])

    var reta = expand_compact_prompt_tokens(
        catalog, "deutsch", ["reta", "-h"]
    )
    assert_false(reta.compact)
    _assert_tokens(reta.tokens, ["reta", "-h"])


def test_compact_prompt_fraction_defaults_and_replacements() raises:
    var catalog = _catalog()
    var fraction = expand_compact_prompt_tokens(
        catalog, "deutsch", ["3/2"], False, True
    )
    assert_true(fraction.compact)
    assert_true("u" in fraction.tokens)
    assert_true("B" in fraction.tokens)
    assert_true("G" in fraction.tokens)
    assert_true("E" in fraction.tokens)
    assert_true("groesse" in fraction.tokens)
    assert_equal(fraction.tokens[len(fraction.tokens) - 2], "-ausgabe")
    assert_equal(fraction.tokens[len(fraction.tokens) - 1], "--keineueberschriften")

    var expanded = expand_prompt_replacements(
        catalog, "deutsch", ["a", "15"]
    )
    _assert_tokens(expanded, ["absicht", "15"])


def test_compact_prompt_expansion_english() raises:
    var catalog = _catalog()
    var i15 = expand_compact_prompt_tokens(catalog, "english", ["i15"])
    assert_true(i15.compact)
    _assert_tokens(i15.tokens, ["i", "15"])
    var replaced = expand_prompt_replacements(catalog, "english", i15.tokens)
    _assert_tokens(replaced, ["intent", "15"])

    var pure = expand_compact_prompt_tokens(catalog, "english", ["15"])
    assert_true(pure.compact)
    assert_true("mulpri" in pure.tokens)
    assert_true("noOneCharacterLinePlusNoOutputWhichCommandItWas" in pure.tokens)



def test_prompt_preparation_set_order() raises:
    var catalog = _catalog()
    var a15 = prepare_prompt_tokens(catalog, "deutsch", ["a15"])
    _assert_tokens(a15.tokens, ["absicht", "15"])
    var ap15 = prepare_prompt_tokens(catalog, "deutsch", ["ap15"])
    _assert_tokens(ap15.tokens, ["absicht", "15", "mulpri"])
    var pure = prepare_prompt_tokens(catalog, "deutsch", ["15"])
    _assert_tokens(
        pure.tokens,
        [
            "keineEinZeichenZeilenPlusKeineAusgabeWelcherBefehlEsWar",
            "absicht",
            "15",
            "thomas",
            "teiler",
            "mulpri",
        ],
    )
    var direct = prepare_prompt_tokens(catalog, "deutsch", ["reta", "-h"])
    _assert_tokens(direct.tokens, ["reta", "-h"])


def test_prompt_preparation_fraction_and_shell_order() raises:
    var catalog = _catalog()
    var fraction = prepare_prompt_tokens(catalog, "deutsch", ["uv3/2"])
    _assert_tokens(fraction.tokens, ["vielfache", "3/2", "universum"])
    var shell = prepare_prompt_tokens(catalog, "deutsch", ["shell", "echo", "hi"])
    _assert_tokens(shell.tokens, ["hi", "shell", "echo"])



def test_prompt_preparation_unicode_control_alias() raises:
    var catalog = _catalog()
    # The historical CPython-set hash must consume UTF-8 bytes rather than
    # slicing in the middle of the ö in BefehlSpeicherungLöschen.
    var prepared = prepare_prompt_tokens(catalog, "deutsch", ["a2l"])
    assert_true(prepared.compact)
    assert_equal(len(prepared.tokens), 3)
    assert_true("absicht" in prepared.tokens)
    assert_true("2" in prepared.tokens)
    assert_true("BefehlSpeicherungLöschen" in prepared.tokens)



def test_legacy_prompt_parameter_surface() raises:
    var catalog = _catalog()
    assert_true(prompt_is_reta_parameter(catalog, "deutsch", "-zeilen"))
    assert_true(prompt_is_reta_parameter(catalog, "deutsch", "--zeit=heute"))
    assert_true(prompt_is_reta_parameter(catalog, "deutsch", "--breite=0"))
    assert_true(prompt_is_reta_parameter(catalog, "deutsch", "--Religionen=sternpolygon"))
    assert_false(prompt_is_reta_parameter(catalog, "deutsch", "-1"))
    assert_false(prompt_is_reta_parameter(catalog, "deutsch", "-1-3"))
    assert_false(prompt_is_reta_parameter(catalog, "deutsch", "-1/2"))
    assert_false(prompt_is_reta_parameter(catalog, "deutsch", "--unbekannt=2"))

    assert_true(isReTaParameter(catalog, "english", "-lines"))
    assert_true(isReTaParameter(catalog, "english", "--time=today"))
    assert_true(isReTaParameter(catalog, "english", "--type=html"))
    assert_false(isReTaParameter(catalog, "english", "-4"))


def test_legacy_prompt_language_aliases() raises:
    var catalog = _catalog()
    _assert_tokens(custom_split("reta (1 2)  ende"), ["reta", "(1 2)", "", "ende"])
    _assert_tokens(custom_split2("1,(2,3),4", ","), ["1", "(2,3)", "4"])
    assert_true(is15or16command(catalog, "deutsch", "15_13_10"))
    assert_true(is15or16command(catalog, "english", "16_15_13_10"))
    assert_false(is15or16command(catalog, "deutsch", "16_999"))


def test_prompt_language_snapshot() raises:
    var catalog = _catalog()
    var german = prompt_language_snapshot(catalog, "deutsch")
    assert_equal(german.language, "deutsch")
    assert_equal(german.class_name, "PromptLanguageBundle")
    assert_equal(german.not_parameter_values_len, 4199)
    assert_equal(german.parameter_bases_len, 119)
    assert_equal(german.commands_len, 386)
    assert_equal(german.allowed_fraction_numbers_len, 21)
    assert_equal(german.wahl15_len, 65)
    assert_equal(german.wahl16_len, 9)
    assert_true(len(german.short_command_letters) > 10)

    var english = prompt_language_snapshot(catalog, "english")
    assert_equal(english.not_parameter_values_len, 2715)
    assert_equal(english.parameter_bases_len, 98)
    assert_equal(english.commands_len, 367)
    assert_equal(english.allowed_fraction_numbers_len, 21)
    assert_equal(english.wahl15_len, 65)
    assert_equal(english.wahl16_len, 9)

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
