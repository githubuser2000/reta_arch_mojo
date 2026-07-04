from std.collections import List
from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.html_cell_metadata import (
    HtmlCellCatalog,
    HtmlCellMetadata,
    HtmlHeadingMetadata,
)
from reta_mojo.output_modes import *
from reta_mojo.output_syntax import (
    OutputCellRequest,
    bootstrap_output_syntax,
    output_syntax_snapshot,
)


def test_output_semantics_snapshot_matches_python_order() raises:
    var semantics = bootstrap_output_semantics("/tmp/reta")
    var snapshot = semantics.snapshot()
    assert_equal(snapshot.class_name, "RetaOutputSemantics")
    assert_equal(snapshot.available_modes[0], "bbcode")
    assert_equal(snapshot.available_modes[6], "shell")
    assert_equal(len(snapshot.mode_specs), 7)
    assert_equal(snapshot.mode_specs[3].syntax_class, "htmlSyntax")
    assert_equal(len(snapshot.mode_specs[3].aliases), 1)
    assert_equal(snapshot.mode_specs[3].aliases[0], "html")


def test_complete_lookup_and_application_surface() raises:
    var semantics = bootstrap_output_semantics()
    assert_equal(semantics.canonicalize("markdown"), "markdown")
    assert_equal(semantics.canonicalize("unbekannt"), "")
    assert_equal(semantics.create_syntax("csv").syntax_class_name, "csvSyntax")
    assert_equal(
        semantics.mode_for_output_syntax(output_mode_spec("bbcode")),
        "bbcode",
    )

    var state = default_output_runtime_state()
    state.text_width = 33
    var without_callback = semantics.apply_mode_to_tables(
        state, "csv", False
    )
    assert_true(without_callback.applied)
    assert_true(without_callback.state.one_table)
    assert_equal(without_callback.state.text_width, 33)
    assert_true(without_callback.application.force_zero_width)

    var with_callback = semantics.apply_mode_to_tables(state, "csv", True)
    assert_equal(with_callback.state.text_width, 0)
    assert_true(semantics.is_mode(with_callback.state, "csv"))

    var unknown = semantics.apply_mode_to_tables(state, "unbekannt")
    assert_false(unknown.applied)
    assert_equal(unknown.state.text_width, 33)


def test_output_syntax_bundle_owns_class_map_and_cells() raises:
    var bundle = bootstrap_output_syntax()
    var snapshot = output_syntax_snapshot()
    assert_equal(snapshot.class_name, "OutputSyntaxBundle")
    assert_equal(len(snapshot.modes), 7)
    assert_equal(snapshot.modes[0].canonical_name, "bbcode")
    assert_equal(snapshot.modes[6].syntax_class_name, "OutputSyntax")
    assert_equal(snapshot.legacy_owner, "libs.lib4tables")
    assert_equal(
        snapshot.architecture_owner,
        "reta_architecture.output_syntax",
    )
    assert_equal(bundle.class_for("html").syntax_class_name, "htmlSyntax")

    var request = OutputCellRequest(
        -2, 0, 1, "", 4, True, "german", False
    )
    var empty_catalog = HtmlCellCatalog(
        List[HtmlCellMetadata](), List[HtmlHeadingMetadata]()
    )
    assert_equal(
        bundle.generate_cell("bbcode", request, empty_catalog),
        "[td=\"background-color:#000000;color:#ffffff\"]",
    )
    assert_equal(bundle.generate_cell("markdown", request, empty_catalog), "|")
    assert_equal(bundle.generate_cell("nichts", request, empty_catalog), "")
    assert_equal(bundle.generate_cell("html", request, empty_catalog), "<td>")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
