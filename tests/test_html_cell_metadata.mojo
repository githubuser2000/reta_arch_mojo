from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.csv_table import parse_semicolon_csv
from reta_mojo.html_cell_metadata import *
from reta_mojo.table_rendering import render_html_table_with_context


def test_physical_and_generated_catalog_sizes() raises:
    var catalog = load_html_cell_catalog()
    assert_equal(len(catalog.entries), 1496)
    assert_equal(len(catalog.headings), 1626)


def test_physical_heading_is_reindexed() raises:
    var catalog = load_html_cell_catalog()
    var opening = html_cell_open(catalog, "german", 6, 3, True, "")
    assert_true(" r_3 " in opening)
    assert_true("p3_0_Sternpolygon" in opening)


def test_physical_alias_can_use_semantic_heading_metadata() raises:
    var catalog = load_html_cell_catalog()
    var opening = html_cell_open(
        catalog,
        "german",
        153,
        2,
        True,
        "Manipulation (1)",
    )
    assert_true(" r_2 " in opening)
    assert_true("p3_0_Manipulation" in opening)
    assert_true("Wichtigstes_zum_gedanklich_einordnen" not in opening)


def test_generated_heading_metadata_uses_semantic_key() raises:
    var catalog = load_html_cell_catalog()
    var opening = html_cell_open(
        catalog,
        "german",
        -999999,
        2,
        True,
        "Primzahlwirkung (7, Richtung) Galaxie n",
    )
    assert_true(" r_2 " in opening)
    assert_true("p3_1_Galaxieabsicht" in opening)


def test_duplicate_heading_prefers_exact_all_columns_position() raises:
    var catalog = load_html_cell_catalog()
    var human_open = html_cell_open(
        catalog, "german", -999999, 162, True, "Moral-Thema"
    )
    var love_open = html_cell_open(
        catalog, "german", -999999, 167, True, "Moral-Thema"
    )
    assert_true("p3_0_Moral" in human_open)
    assert_true("p3_0_Liebe_(7)" in love_open)


def test_all_columns_position_map_overrides_mismatched_source_identity() raises:
    var catalog = load_html_cell_catalog()
    var opening = html_cell_open(
        catalog,
        "german",
        46,
        43,
        True,
        "intentionally different",
        True,
    )
    assert_true("p3_0_alpha_beta" in opening)


def test_html_preserves_deliberate_tags_and_escapes_comparisons() raises:
    var table = parse_semicolon_csv(
        "Meta für n;Text;Generated\n"
        + "\"<ul><li>A < 5 & B > 0 & \"\"quoted\"\"</li></ul><br>End\";"
        + "\"A < 5 & B > 0 & \"\"quoted\"\"\";"
        + "\"<ul><li>A -> B & \"\"quoted\"\"</li></ul>\"\n"
    )
    var rendered = render_html_table_with_context(
        table,
        table,
        [0, 1],
        [0, 1, 746],
        "german",
        False,
        0,
    )
    assert_true(
        "<ul><li>A &lt; 5 &amp; B &gt; 0 &amp; &quot;quoted&quot;</li></ul><br>End"
        in rendered
    )
    assert_true("A &lt; 5 &amp; B &gt; 0 &amp; &quot;quoted&quot;" in rendered)
    assert_true("<ul><li>A -> B &amp; \"quoted\"</li></ul>" in rendered)
    assert_true("p3_0_meta" in rendered)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
