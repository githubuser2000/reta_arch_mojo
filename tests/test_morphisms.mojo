from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.schema import *
from reta_mojo.parameter_semantics import build_parameter_semantics
from reta_mojo.morphisms import *


def _fixture() -> ParameterSemanticsSheaf:
    var schema = empty_schema()
    schema.parameters_main.append(
        AliasGroup("Religionen", ["Religionen", "religionen"])
    )
    schema.parameter_entries.append(ParameterEntry(
        ["Religionen", "religionen"],
        ["Sternpolygon", "sternpolygon"],
        [4, 8],
    ))
    return build_parameter_semantics(schema)


def test_alias_morphisms_delegate_to_native_sheaf() raises:
    var morphisms = bootstrap_morphisms(_fixture())
    assert_equal(
        morphisms.alias_morphisms.resolve_main_alias("religionen"),
        "Religionen",
    )
    var pair = morphisms.alias_morphisms.canonicalize_pair(
        "religionen", "sternpolygon"
    )
    assert_true(pair.valid)
    var columns = morphisms.alias_morphisms.column_numbers_for_pair(
        "religionen", "sternpolygon"
    )
    assert_equal(len(columns), 2)
    assert_equal(columns[0], 4)
    assert_equal(columns[1], 8)


def test_range_morphism_is_sorted_and_unique() raises:
    var morphisms = bootstrap_morphisms(_fixture(), maximum=100)
    var values = morphisms.range_morphisms.parse_row_range("5,1-3,2")
    assert_equal(len(values), 4)
    assert_equal(values[0], 1)
    assert_equal(values[1], 2)
    assert_equal(values[2], 3)
    assert_equal(values[3], 5)


def test_prompt_morphism_preserves_reta_word_rule() raises:
    var morphisms = bootstrap_morphisms(_fixture())
    var words = morphisms.prompt_morphisms.split_command_words(
        "reta   -zeilen   --zeit=heute"
    )
    assert_equal(len(words), 3)
    assert_equal(words[0], "reta")
    assert_equal(words[2], "--zeit=heute")
    var segments = morphisms.prompt_morphisms.split_command_words(
        "1-3,{5,7},9"
    )
    assert_equal(len(segments), 3)
    assert_equal(segments[1], "{5,7}")


def test_renderer_morphism_resolves_alias_and_fallback() raises:
    var morphisms = bootstrap_morphisms(_fixture())
    assert_equal(
        morphisms.renderer_morphisms.canonical_output_mode("html"), "html"
    )
    assert_equal(
        morphisms.renderer_morphisms.canonical_output_mode("unknown"),
        "terminal",
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
