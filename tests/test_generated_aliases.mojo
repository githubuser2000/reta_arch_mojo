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


def test_meta_alias_payload_and_subset_order() raises:
    var catalog = load_generated_alias_catalog("assets/generated_aliases.tsv")
    var entries = resolve_generated_aliases(
        catalog, "german", "universummetakonkret", "praxis"
    )
    assert_equal(len(entries), 1)
    assert_equal(entries[0].bucket, "meta")
    var request = meta_request_from_entry(entries[0])
    assert_equal(request.metavariable, 3)
    assert_equal(request.side, 1)
    var requests: List[MetaColumnRequest] = [
        MetaColumnRequest(2, 0),
        MetaColumnRequest(2, 1),
        MetaColumnRequest(3, 0),
        MetaColumnRequest(3, 1),
    ]
    sort_meta_requests_by_python_set(requests)
    assert_equal(requests[0].metavariable, 3)
    assert_equal(requests[0].side, 1)
    assert_equal(requests[1].metavariable, 2)
    assert_equal(requests[1].side, 0)


def test_fraction_alias_uses_selected_parameter_not_payload_fanout() raises:
    var catalog = load_generated_alias_catalog("assets/generated_aliases.tsv")
    var entries = resolve_generated_aliases(
        catalog, "german", "gebrochenuniversum", "2"
    )
    assert_equal(len(entries), 22)
    var request = fraction_request_from_entry(entries[0])
    assert_equal(request.domain, "universe")
    assert_equal(request.denominator, 2)
    var requests = List[FractionColumnRequest]()
    for index in range(len(entries)):
        append_unique_fraction_request(
            requests, fraction_request_from_entry(entries[index])
        )
    assert_equal(len(requests), 1)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
