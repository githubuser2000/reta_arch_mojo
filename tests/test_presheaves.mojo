from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.topology import *
from reta_mojo.presheaves import *


def test_presheaf_restriction() raises:
    var presheaf = StringPresheaf("assets")
    var de_html = unrestricted_selection()
    de_html.language = restricted_dimension(["de"])
    de_html.output_modes = restricted_dimension(["html"])
    presheaf.add_section(de_html, "deutsche HTML-Sektion", "de.html")

    var en_html = unrestricted_selection()
    en_html.language = restricted_dimension(["en"])
    en_html.output_modes = restricted_dimension(["html"])
    presheaf.add_section(en_html, "english HTML section", "en.html")

    var query = unrestricted_selection()
    query.language = restricted_dimension(["de"])
    var result = presheaf.restrict(query)
    assert_equal(len(result), 1)
    assert_equal(result[0].source, "de.html")
    assert_true("html" in result[0].context.output_modes.values)


def test_presheaf_keeps_unrestricted_sections() raises:
    var presheaf = StringPresheaf("global")
    presheaf.add_section(unrestricted_selection(), "global")
    var query = unrestricted_selection()
    query.scopes = restricted_dimension(["csv"])
    var result = presheaf.restrict(query)
    assert_equal(len(result), 1)
    assert_true("csv" in result[0].context.scopes.values)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
