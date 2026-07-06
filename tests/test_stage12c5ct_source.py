from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ct_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5c" in current
    assert ".sh" in current


def test_stage_wraps_cs_and_checks_prompt_line_payload_boundary() -> None:
    source = (ROOT / "scripts/test_stage12c5ct.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cs.sh" in source
    assert "legacy bridge prompt line payload ownership" in source
    assert "test_${test_name}_12c5ct" in source
    assert "for test_name in legacy_mojo_bridge prompt_interaction legacy_reta_prompt" in source
    assert "tests/test_stage12c5ct_source.py" in source


def test_legacy_bridge_prompt_line_adapters_use_payload_owner() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "def _prompt_line_payload(line: String) -> String:" in bridge
    assert "run_shell_prompt_line_native," not in bridge
    assert "run_python_prompt_line_native," not in bridge
    assert "run_math_prompt_line_native," not in bridge
    shell_function = bridge.split(
        "def run_shell_prompt_line(line: String) raises -> Int:", 1
    )[1].split("def run_python_prompt_line", 1)[0]
    python_function = bridge.split(
        "def run_python_prompt_line(line: String) raises -> Int:", 1
    )[1].split("def run_math_prompt_line", 1)[0]
    math_function = bridge.split(
        "def run_math_prompt_line(line: String) raises -> Int:", 1
    )[1].split("def generate_html_document", 1)[0]
    assert "run_shell_prompt_payload_native(" in shell_function
    assert "_prompt_line_payload(line), reference_root()" in shell_function
    assert "run_python_prompt_payload_native(" in python_function
    assert "_prompt_line_payload(line), reference_root()" in python_function
    assert "run_math_prompt_payload_native(" in math_function
    assert "_prompt_line_payload(line), reference_root()" in math_function


def test_prompt_external_line_wrappers_are_not_bridge_owned() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def raw_command_payload(line: String) -> String:" not in adapter
    assert "def run_shell_prompt_payload_native(" in adapter
    assert "def run_python_prompt_payload_native(" in adapter
    assert "def run_math_prompt_payload_native(" in adapter
    if "def run_shell_prompt_line_native(" in adapter:
        assert "return run_shell_prompt_payload_native(" in adapter
        assert "return run_python_prompt_payload_native(" in adapter
        assert "return run_math_prompt_payload_native(" in adapter


def test_legacy_bridge_owner_snapshot_tracks_prompt_line_payload_boundary() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    test = (ROOT / "tests/test_legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert '"prompt_line_bridge=payload-owner"' in bridge
    assert "assert_equal(len(owners), 14)" in test or "assert_equal(len(owners), 13)" in test or "assert_equal(len(owners), 12)" in test or "assert_equal(len(owners), 11)" in test
    assert 'assert_equal(owners[10], "prompt_line_bridge=payload-owner")' in test
