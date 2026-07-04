from std.testing import assert_equal, assert_true, TestSuite

from reta_mojo.architecture_probe_assets import (
    architecture_probe_asset_filename,
    architecture_probe_command_count,
    load_architecture_probe_asset,
    load_architecture_snapshot_json,
)


def test_command_catalog_and_extensions() raises:
    assert_equal(architecture_probe_command_count(), 63)
    assert_equal(
        architecture_probe_asset_filename("architecture-map-json"),
        "architecture-map-json.json",
    )
    assert_equal(
        architecture_probe_asset_filename("architecture-diagram-md"),
        "architecture-diagram-md.md",
    )
    assert_equal(architecture_probe_asset_filename("unknown"), "")


def test_snapshot_asset_is_complete_and_path_resolved() raises:
    var payload = load_architecture_snapshot_json()
    assert_true(payload.startswith('{"schema":'))
    assert_true(payload.find('"architecture_progress":') >= 0)
    assert_true(payload.find('"parallel_execution":') >= 0)
    assert_true(payload.find("@@RETA_REFERENCE_ROOT@@") < 0)
    assert_true(payload.byte_length() > 1_000_000)


def test_markdown_asset_is_native_runtime_data() raises:
    var payload = load_architecture_probe_asset("architecture-contracts-md")
    assert_true(payload.startswith("# Reta Stage-29 Architekturverträge"))
    assert_true(payload.find("## Mermaid") >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
