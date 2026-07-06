from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cr_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5c" in current


def test_stage_wraps_cq_and_rebuilds_bridge_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cr.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cq.sh" in source
    assert "legacy bridge payload entrypoints" in source
    assert "test_${test_name}_12c5cr" in source
    assert "for test_name in legacy_mojo_bridge prompt_interaction legacy_reta_prompt" in source


def test_legacy_bridge_convenience_functions_use_payload_entrypoints() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "run_shell_prompt_payload_native" in bridge
    assert "run_python_prompt_payload_native" in bridge
    assert "run_math_prompt_payload_native" in bridge
    assert 'return run_shell_prompt_payload_native(line, reference_root())' in bridge
    assert 'return run_python_prompt_payload_native(code, reference_root())' in bridge
    assert 'return run_math_prompt_payload_native(expression, reference_root())' in bridge
    assert 'return run_shell_prompt_line_native("shell " + line, reference_root())' not in bridge
    assert 'return run_python_prompt_line_native("python " + code, reference_root())' not in bridge
    assert 'return run_math_prompt_line_native("math " + expression, reference_root())' not in bridge


def test_line_based_legacy_prompt_adapters_are_still_present() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "def run_shell_prompt_line(line: String) raises -> Int:" in bridge
    assert "def run_python_prompt_line(line: String) raises -> Int:" in bridge
    assert "def run_math_prompt_line(line: String) raises -> Int:" in bridge
    assert (
        "raw_command_payload(line), reference_root()" in bridge
        or "_prompt_line_payload(line), reference_root()" in bridge
    )
    assert "return run_shell_prompt_payload_native(" in bridge
    assert "return run_python_prompt_payload_native(" in bridge
    assert "return run_math_prompt_payload_native(" in bridge
    assert "return run_shell_prompt_line_native(line, reference_root())" not in bridge
    assert "return run_python_prompt_line_native(line, reference_root())" not in bridge
    assert "return run_math_prompt_line_native(line, reference_root())" not in bridge
