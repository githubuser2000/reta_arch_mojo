from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.schema import *
from reta_mojo.parameter_semantics import build_parameter_semantics
from reta_mojo.morphisms import *
from reta_mojo.output_modes import default_output_runtime_state


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


def test_complete_bundle_snapshot_and_shared_topology() raises:
    var morphisms = bootstrap_morphisms(_fixture())
    var snapshot = morphisms.snapshot()
    assert_equal(len(snapshot.available), 4)
    assert_equal(snapshot.available[0], "alias")
    assert_equal(snapshot.available[3], "renderers")
    assert_true(not morphisms.alias_morphisms.topology_context.scopes.restricted)
    assert_true(not morphisms.range_morphisms.topology_context.scopes.restricted)


def test_range_morphism_really_deduplicates_after_sorting() raises:
    var morphisms = bootstrap_morphisms(_fixture(), maximum=100)
    var values = morphisms.range_morphisms.parse_row_range("5,1-3,2,2,5")
    assert_equal(len(values), 4)
    assert_equal(values[0], 1)
    assert_equal(values[3], 5)


def test_prompt_expansion_callback_boundary_is_typed() raises:
    var morphisms = bootstrap_morphisms(_fixture())
    var request = morphisms.prompt_morphisms.expand_shorthand(
        2, "15_", "--zeit=heute"
    )
    assert_equal(request.prompt_mode, 2)
    assert_equal(request.prompt_text, "15_")
    assert_equal(request.additional_text, "--zeit=heute")


def test_renderer_morphisms_apply_native_output_state() raises:
    var morphisms = bootstrap_morphisms(_fixture())
    var state = default_output_runtime_state()
    var html = morphisms.renderer_morphisms.apply_output_mode(state, "html")
    assert_equal(
        morphisms.renderer_morphisms.output_mode_for_tables(html), "html"
    )
    assert_true(html.marks_html_or_bbcode)
    var csv = morphisms.renderer_morphisms.apply_output_mode(state, "csv")
    assert_equal(csv.canonical_name, "csv")
    assert_true(csv.one_table)
    assert_equal(csv.text_width, 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
