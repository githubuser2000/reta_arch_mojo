from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cx_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_cw_and_checks_external_raw_payload_helper_localization() -> None:
    source = (ROOT / "scripts/test_stage12c5cx.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cw.sh" in source
    assert "external raw payload helper localization" in source
    assert "test_${test_name}_12c5cx" in source
    assert "tests/test_stage12c5cx_source.py" in source


def test_external_process_adapter_no_longer_exports_raw_line_payload_helper() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def raw_command_payload(" not in adapter
    assert "def run_shell_prompt_payload_native(" in adapter
    assert "def run_python_prompt_payload_native(" in adapter
    assert "def run_math_prompt_payload_native(" in adapter
    assert "def run_reta_arguments_native(" in adapter
    assert "def run_reta_prompt_arguments_native(" in adapter
    assert "def run_reta_prompt_fallback_arguments_native(" in adapter
    assert "def run_shell_prompt_line_native(" not in adapter
    assert "def run_reta_line_native(" not in adapter


def test_legacy_bridge_owns_historical_prompt_line_payload_rule_locally() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "def _prompt_line_payload(line: String) -> String:" in bridge
    assert "line.partition" in bridge
    assert "raw_command_payload," not in bridge
    assert "_prompt_line_payload(line), reference_root()" in bridge
    assert "external_raw_payload_helper=legacy-local" in bridge


def test_probe_keeps_raw_line_compatibility_at_probe_edge() -> None:
    probe = (ROOT / "tests/prompt_external_commands_probe.mojo").read_text(
        encoding="utf-8"
    )
    assert "def _prompt_line_payload(line: String) -> String:" in probe
    assert "raw_command_payload," not in probe
    assert "run_shell_prompt_payload_native(_prompt_line_payload(line), reference_root)" in probe
    assert "run_python_prompt_payload_native(_prompt_line_payload(line), reference_root)" in probe
    assert "run_math_prompt_payload_native(_prompt_line_payload(line), reference_root)" in probe


def test_owner_snapshot_tracks_raw_payload_helper_localization() -> None:
    test = (ROOT / "tests/test_legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "assert_equal(len(owners), 14)" in test
    assert 'assert_equal(owners[13], "external_raw_payload_helper=legacy-local")' in test


def test_porting_matrix_describes_payload_argv_only_external_adapter() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "keinen Rohzeilen-Payload-Helfer mehr" in matrix
    assert "Rohzeilen-Payloadschnitt lokal in der Legacy-Bridge" in matrix
