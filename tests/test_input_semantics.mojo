from std.collections import List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.input_semantics import *
from reta_mojo.schema_catalog import bootstrap_reta_schema
from reta_mojo.parameter_semantics import build_parameter_semantics


def test_long_option_and_top_level_commas() raises:
    var option = parse_long_option(
        "spalten", "--religionen=sternpolygon,-gleichfoermigespolygon,{1,2}"
    )
    assert_true(option.valid)
    assert_true(option.has_equals)
    assert_equal(option.name, "religionen")
    assert_equal(len(option.values), 3)
    assert_equal(option.values[0].text, "sternpolygon")
    assert_false(option.values[0].negative)
    assert_equal(option.values[1].text, "gleichfoermigespolygon")
    assert_true(option.values[1].negative)
    assert_equal(option.values[2].text, "{1,2}")


def test_cli_keeps_section_context_and_positionals() raises:
    var parsed = parse_cli_tokens([
        "-zeilen",
        "--vorhervonausschnitt=1-9,-3",
        "-spalten",
        "--religionen=sternpolygon",
        "plain",
    ])
    assert_equal(len(parsed.sections), 2)
    assert_equal(parsed.sections[0], "zeilen")
    assert_equal(parsed.sections[1], "spalten")
    assert_equal(len(parsed.options), 2)
    assert_equal(parsed.options[0].section, "zeilen")
    assert_equal(parsed.options[1].section, "spalten")
    assert_equal(len(parsed.positional), 1)
    assert_equal(parsed.positional[0], "plain")
    assert_equal(len(parsed.diagnostics), 0)


def test_option_without_section_is_diagnosed() raises:
    var parsed = parse_cli_tokens(["--religionen=sternpolygon"])
    assert_equal(len(parsed.options), 1)
    assert_equal(len(parsed.diagnostics), 1)


def test_real_column_options_canonicalize_with_polarity() raises:
    var parsed = parse_cli_tokens([
        "-spalten",
        "--religionen=sternpolygon,-gleichfoermigespolygon",
    ])
    var selections = canonicalize_column_options(
        parsed, build_parameter_semantics(bootstrap_reta_schema())
    )
    assert_equal(len(selections), 2)
    assert_true(selections[0].valid)
    assert_equal(selections[0].main_canonical, "Religionen")
    assert_equal(selections[0].parameter_canonical, "Sternpolygon")
    assert_false(selections[0].negative)
    assert_true(selections[1].valid)
    assert_equal(selections[1].parameter_canonical, "gleichförmiges_Polygon")
    assert_true(selections[1].negative)
    var positive = positive_columns(selections)
    var negative = negative_columns(selections)
    assert_equal(len(positive), 3)
    assert_equal(positive[0], 0)
    assert_equal(positive[1], 6)
    assert_equal(positive[2], 36)
    assert_true(len(negative) > 0)


def test_unknown_parameter_remains_explicitly_invalid() raises:
    var parsed = parse_cli_tokens([
        "-spalten", "--religionen=does-not-exist"
    ])
    var selections = canonicalize_column_options(
        parsed, build_parameter_semantics(bootstrap_reta_schema())
    )
    assert_equal(len(selections), 1)
    assert_false(selections[0].valid)
    assert_equal(selections[0].source_parameter, "does-not-exist")



def test_row_range_syntax_and_input_bundle_snapshot() raises:
    var syntax = RowRangeSyntax()
    var parts = syntax.split_comma_list("1,{2,3},4")
    assert_equal(len(parts), 3)
    assert_equal(parts[1], "{2,3}")
    assert_equal(syntax.compact_comma_list("1,,{2,3},"), "1,{2,3}")
    assert_equal(
        syntax.integer_range_pattern(),
        "^(v?-?\\d+)(-\\d+)?((\\+)(\\d+))*$",
    )
    assert_equal(
        syntax.fraction_range_pattern(),
        "^(v?-?\\d+/\\d+)(-\\d+/\\d+)?((\\+)(\\d+/\\d+))*$",
    )
    assert_true(syntax.is_integer_range_token("v2-8+10"))
    assert_true(syntax.is_fraction_range_token("v1/2-3/4+5/6"))
    assert_false(syntax.is_fraction_range_token("1/2+broken"))
    # Python text[1:] removes one Unicode codepoint.  This guards the native
    # parser against byte-offset assertions for a multibyte marker.
    assert_true(is_row_range_token("ä{1,2}"))
    var translated = RowRangeSyntax("ä")
    assert_equal(translated.integer_range_pattern(), "^(ä?-?\\d+)(-\\d+)?((\\+)(\\d+))*$")

    var bundle = InputBundle.from_schema(bootstrap_reta_schema())
    var snapshot = bundle.snapshot()
    assert_equal(snapshot.row_ranges.multiple_prefix, "v")
    assert_equal(
        snapshot.row_ranges.comma_split_pattern,
        ",(?![^\\[\\]\\{\\}\\(\\)]*[\\]\\}\\)])",
    )
    assert_true(snapshot.prompt_vocabulary_builder_available)

def test_native_prompt_vocabulary_matches_complete_reference_catalog() raises:
    var sheaf = build_parameter_semantics(bootstrap_reta_schema())
    var vocabulary = build_prompt_vocabulary(sheaf)
    var snapshot = vocabulary.snapshot()
    assert_equal(snapshot.main_parameters_len, 7)
    assert_equal(snapshot.spalten_len, 4160)
    assert_equal(snapshot.spalten_dict_keys, 84)
    assert_equal(snapshot.ausgabe_paras_len, 14)
    assert_equal(snapshot.kombi_main_paras_len, 3)
    assert_equal(snapshot.zeilen_paras_len, 15)
    assert_equal(snapshot.haupt_for_neben_len, 7)
    assert_equal(snapshot.ausgabe_art_len, 7)
    assert_equal(snapshot.befehle_len, 386)
    assert_equal(snapshot.befehle2_len, 385)
    assert_equal(snapshot.gebrochen_erlaubte_zahlen_len, 21)
    assert_equal(vocabulary.spalten[0], "--Wichtigstes_zum_verstehen=")
    assert_equal(vocabulary.spalten[1], "--Wichtigstes_zum_verstehen=")
    assert_true(_test_contains(vocabulary.spalten, "--religionen="))
    assert_equal(len(vocabulary_values_for_main(vocabulary, "Licht")), 0)
    assert_equal(len(vocabulary_values_for_main(vocabulary, "licht")), 0)
    var religion_values = vocabulary_values_for_main(vocabulary, "Religionen")
    assert_true(_test_contains(religion_values, "sternpolygon"))
    assert_true(_test_contains(religion_values, "gleichfoermigespolygon"))


def _test_contains(values: List[String], expected: String) -> Bool:
    for index in range(len(values)):
        if values[index] == expected:
            return True
    return False


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
