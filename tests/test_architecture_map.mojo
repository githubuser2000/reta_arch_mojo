from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.architecture_map import *


def test_snapshot_counts() raises:
    var bundle = bootstrap_architecture_map()
    assert_equal(len(bundle.capsules), 11)
    assert_equal(len(bundle.containment), 34)
    assert_equal(len(bundle.flows), 53)
    assert_equal(len(bundle.legacy_mappings), 34)
    assert_equal(len(bundle.stage_steps), 42)


def test_capsule_lookup_and_content() raises:
    var bundle = bootstrap_architecture_map()
    var root = capsule_named(bundle, "RetaArchitectureRoot")
    assert_equal(root.layer, "0 root / facade")
    assert_equal(len(root.contains), 10)
    var compatibility = capsule_named(bundle, "CompatibilityCapsule")
    assert_true(len(compatibility.code_owners) >= 8)
    assert_true(capsule_index(bundle, "missing") < 0)


def test_markdown_audit_and_count_line() raises:
    var bundle = bootstrap_architecture_map()
    assert_true(bundle.markdown_audit.source_package.byte_length() > 0)
    assert_true("capsules=11" in architecture_map_count_line(bundle))
    assert_true("stage_steps=42" in architecture_map_count_line(bundle))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
