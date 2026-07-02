from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.presheaves import *
from reta_mojo.topology import *


def test_generated_catalog_and_bundle_counts() raises:
    var catalog = load_presheaf_catalog()
    assert_equal(presheaf_catalog_count(catalog, "csv"), 79)
    assert_equal(presheaf_catalog_count(catalog, "translations"), 27)
    assert_equal(presheaf_catalog_count(catalog, "assets"), 163)
    var bundle = PresheafBundle.discover()
    var snapshot = bundle.snapshot()
    assert_equal(snapshot.csv_sections, 79)
    assert_equal(snapshot.translation_sections, 27)
    assert_equal(snapshot.asset_sections, 163)
    assert_equal(snapshot.prompt_sections, 0)


def test_filesystem_sections_preserve_context_and_payload() raises:
    var bundle = PresheafBundle.discover()
    var query = unrestricted_selection()
    query.language = restricted_dimension(["cn"])
    query.scopes = restricted_dimension(["csv"])
    var sections = bundle.csv.restrict(query)
    assert_true(len(sections) > 0)
    assert_true("csv/cn-" in sections[0].payload)
    assert_true(sections[0].source.endswith(".csv"))
    assert_true("cn" in sections[0].context.language.values)


def test_prompt_state_replaces_previous_section() raises:
    var prompt = PromptStatePresheaf()
    prompt.update_default("reta -zeilen", ["reta", "-zeilen"])
    assert_equal(len(prompt.sections()), 1)
    assert_true("reta -zeilen" in prompt.snapshot_json())
    prompt.update_default("reta -spalten", ["reta", "-spalten"])
    assert_equal(len(prompt.sections()), 1)
    assert_true("-spalten" in prompt.snapshot_json())


def test_restriction_composes_on_local_sections() raises:
    var presheaf = Presheaf("local")
    var context = unrestricted_selection()
    context.language = restricted_dimension(["de"])
    context.scopes = restricted_dimension(["md", "org"])
    presheaf.add_section(context, "{\"kind\":\"doc\"}", "README.md")
    var first = unrestricted_selection()
    first.language = restricted_dimension(["de"])
    var second = unrestricted_selection()
    second.scopes = restricted_dimension(["md"])
    var once = presheaf.restrict(refine_selection(first, second))
    var intermediate = presheaf.restrict(first)
    var temporary = Presheaf("temporary")
    for index in range(len(intermediate)):
        temporary.add_section(
            intermediate[index].context,
            intermediate[index].payload,
            intermediate[index].source,
        )
    var twice = temporary.restrict(second)
    assert_equal(len(once), len(twice))
    assert_equal(once[0].source, twice[0].source)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
