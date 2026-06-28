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


def test_native_prompt_vocabulary_is_schema_derived() raises:
    var sheaf = build_parameter_semantics(bootstrap_reta_schema())
    var vocabulary = build_prompt_vocabulary(sheaf)
    assert_equal(len(vocabulary.main_parameters), 7)
    assert_true(len(vocabulary.column_options) >= 90)
    assert_equal(len(vocabulary.values_by_main), 33)
    assert_equal(len(vocabulary.output_modes), 7)
    assert_true(_test_contains(vocabulary.column_options, "--religionen="))
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
