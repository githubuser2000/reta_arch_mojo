from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.architecture_map import bootstrap_architecture_map, capsule_index
from reta_mojo.architecture_boundaries import *


def test_snapshot_counts() raises:
    var bundle = bootstrap_architecture_boundaries()
    assert_equal(len(bundle.module_ownership), 161)
    assert_equal(len(bundle.import_edges), 279)
    assert_equal(len(bundle.capsule_edges), 37)
    assert_equal(len(bundle.capsule_boundaries), 11)
    assert_equal(len(bundle.validation.checks), 5)


def test_validation_and_known_ownership() raises:
    var bundle = bootstrap_architecture_boundaries()
    assert_true(boundary_validation_passed(bundle))
    assert_equal(bundle.validation.status, "passed")
    var reta_index = ownership_index(bundle, "reta.py")
    assert_true(reta_index >= 0)
    assert_equal(bundle.module_ownership[reta_index].capsule, "CompatibilityCapsule")
    var prompt_index = ownership_index(bundle, "reta_architecture/prompt_execution.py")
    assert_true(prompt_index >= 0)
    assert_equal(bundle.module_ownership[prompt_index].capsule, "InputPromptCapsule")


def test_capsule_boundaries_reflect_map() raises:
    var map_bundle = bootstrap_architecture_map()
    var boundaries = bootstrap_architecture_boundaries()
    for index in range(len(boundaries.capsule_boundaries)):
        assert_true(capsule_index(map_bundle, boundaries.capsule_boundaries[index].capsule) >= 0)
    assert_true(capsule_boundary_index(boundaries, "CategoricalMetaCapsule") >= 0)
    assert_true(boundary_check_index(boundaries, "ModuleOwnershipCoverageCheck") >= 0)


def test_count_line() raises:
    var bundle = bootstrap_architecture_boundaries()
    var line = architecture_boundaries_count_line(bundle)
    assert_true("module_ownership=161" in line)
    assert_true("import_edges=279" in line)
    assert_true("checks=5" in line)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
