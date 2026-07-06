from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cu_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5c" in current
    assert ".sh" in current


def test_stage_wraps_ct_and_checks_external_wrapper_elimination() -> None:
    source = (ROOT / "scripts/test_stage12c5cu.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ct.sh" in source
    assert "external line wrapper elimination" in source
    assert "test_${test_name}_12c5cu" in source
    assert "tests/test_stage12c5cu_source.py" in source


def test_external_process_adapter_exposes_payload_and_argument_boundaries_only() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def raw_command_payload(line: String) -> String:" not in adapter
    assert "def run_shell_prompt_payload_native(" in adapter
    assert "def run_python_prompt_payload_native(" in adapter
    assert "def run_math_prompt_payload_native(" in adapter
    assert "def run_reta_arguments_native(" in adapter
    assert "def run_reta_prompt_arguments_native(" in adapter
    assert "def run_reta_prompt_fallback_arguments_native(" in adapter
    assert "def run_shell_prompt_line_native(" not in adapter
    assert "def run_python_prompt_line_native(" not in adapter
    assert "def run_math_prompt_line_native(" not in adapter
    assert "def run_reta_line_native(" not in adapter


def test_prompt_external_probe_uses_owned_payloads_and_argv() -> None:
    probe = (ROOT / "tests/prompt_external_commands_probe.mojo").read_text(
        encoding="utf-8"
    )
    assert "run_shell_prompt_payload_native(_prompt_line_payload(line), reference_root)" in probe
    assert "run_python_prompt_payload_native(_prompt_line_payload(line), reference_root)" in probe
    assert "run_math_prompt_payload_native(_prompt_line_payload(line), reference_root)" in probe
    assert "run_reta_arguments_native(" in probe
    assert "reta_child_arguments_native(shell_split(line))" in probe
    assert "run_shell_prompt_line_native" not in probe
    assert "run_python_prompt_line_native" not in probe
    assert "run_math_prompt_line_native" not in probe
    assert "run_reta_line_native" not in probe


def test_legacy_bridge_keeps_public_line_compatibility_locally() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "def run_shell_prompt_line(line: String) raises -> Int:" in bridge
    assert "def run_python_prompt_line(line: String) raises -> Int:" in bridge
    assert "def run_math_prompt_line(line: String) raises -> Int:" in bridge
    assert "_prompt_line_payload(line), reference_root()" in bridge
    assert "external_line_wrappers=removed-payload-argv-only" in bridge
    assert "run_shell_prompt_line_native" not in bridge
    assert "run_python_prompt_line_native" not in bridge
    assert "run_math_prompt_line_native" not in bridge
    assert "run_reta_line_native" not in bridge


def test_owner_snapshot_tracks_external_line_wrapper_removal() -> None:
    test = (ROOT / "tests/test_legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "assert_equal(len(owners)," in test
    assert 'assert_equal(owners[11], "external_line_wrappers=removed-payload-argv-only")' in test
