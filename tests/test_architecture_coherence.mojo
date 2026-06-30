from reta_mojo.architecture_coherence import (
    bootstrap_architecture_coherence,
    coherent_capsule_index,
    coherence_snapshot_validation_passed,
    functorial_route_index,
    law_coherence_index,
    naturality_coherence_index,
)


def assert_true(value: Bool, message: String) raises:
    if not value:
        raise Error(message)


def main() raises:
    var bundle = bootstrap_architecture_coherence()
    assert_true(len(bundle.capsule_coherence) == 11, "capsule coherence count")
    assert_true(len(bundle.functorial_routes) == 53, "route count")
    assert_true(len(bundle.naturality_coherence) == 42, "naturality count")
    assert_true(len(bundle.law_coherence) == 22, "law count")
    assert_true(coherence_snapshot_validation_passed(bundle), "coherence validation")
    assert_true(coherent_capsule_index(bundle, "InputPromptCapsule") >= 0, "known capsule")
    assert_true(naturality_coherence_index(bundle, "RawToCanonicalParameterTransformation") >= 0, "known transformation")
    assert_true(law_coherence_index(bundle, "RawCanonicalNaturalityLaw") >= 0, "known law")
    var route_index = functorial_route_index(bundle, "SchemaTopologyCapsule", "LocalSectionCapsule")
    assert_true(route_index >= 0, "known route")
    assert_true(coherent_capsule_index(bundle, "missing") == -1, "missing capsule")
    print("architecture coherence tests: 10/10")
