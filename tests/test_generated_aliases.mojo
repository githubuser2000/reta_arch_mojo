from std.testing import assert_equal, TestSuite
from reta_mojo.generated_aliases import *


def test_german_modal_alias() raises:
    var catalog = load_generated_alias_catalog("assets/generated_aliases.tsv")
    var entries = resolve_generated_aliases(catalog, "german", "grundstrukturen", "liebe")
    assert_equal(len(entries), 1)
    assert_equal(entries[0].bucket, "modal")
    var concept = modal_concept_from_entry(entries[0])
    assert_equal(concept.first, 121)
    assert_equal(concept.second, 122)


def test_english_generated_command_alias() raises:
    var catalog = load_generated_alias_catalog("assets/generated_aliases.tsv")
    var entries = resolve_generated_aliases(catalog, "english", "meaning", "primecross")
    assert_equal(len(entries), 1)
    assert_equal(entries[0].bucket, "generated_command")
    assert_equal(entries[0].payload, "primzahlkreuzprocontra")


def test_prime_effect_alias_payload() raises:
    var catalog = load_generated_alias_catalog("assets/generated_aliases.tsv")
    var entries = resolve_generated_aliases(catalog, "english", "prime_effect", "intentions")
    assert_equal(len(entries), 1)
    assert_equal(entries[0].bucket, "prime_effect")
    assert_equal(entries[0].payload, "10")


def test_effective_alias_uses_last_matrix_entry() raises:
    var catalog = load_generated_alias_catalog("assets/generated_aliases.tsv")
    var entries = resolve_generated_aliases(
        catalog, "english", "multiplications", "motifStar"
    )
    assert_equal(len(entries), 1)
    assert_equal(entries[0].bucket, "generated_command")
    assert_equal(entries[0].payload, "primMotivSternGebr")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
