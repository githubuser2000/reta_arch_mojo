from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cs_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_cr_and_rebuilds_bridge_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cs.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cr.sh" in source
    assert "legacy bridge reta argument ownership" in source
    assert "test_${test_name}_12c5cs" in source
    assert "for test_name in legacy_mojo_bridge prompt_interaction legacy_reta_prompt" in source
    assert "tests/test_prompt_external_source.py" in source


def test_legacy_bridge_reta_line_uses_argument_owner() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    function = bridge.split("def run_reta_line(line: String) raises -> Int:", 1)[1].split(
        "def run_reta_prompt_line_encoded", 1
    )[0]
    assert "run_reta_arguments_native" in function
    assert "reta_child_arguments_native(shell_split(line))" in function
    assert "run_reta_line_native" not in bridge
    assert "shell_split," in bridge
    assert "reta_line_bridge=native-argv-owner" in bridge


def test_legacy_bridge_owner_snapshot_tracks_reta_argument_boundary() -> None:
    test = (ROOT / "tests/test_legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "assert_equal(len(owners)," in test
    assert 'assert_equal(owners[9], "reta_line_bridge=native-argv-owner")' in test
    assert 'assert_equal(owners[10], "prompt_line_bridge=payload-owner")' in test


def test_prompt_external_source_guards_accept_payload_and_argument_ownership() -> None:
    source = (ROOT / "tests/test_prompt_external_source.py").read_text(
        encoding="utf-8"
    )
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert ("run_shell_prompt_payload_native(external_process.payload)" in source or "run_shell_prompt_arguments_native(external_process.arguments)" in source)
    assert "run_python_prompt_arguments_native(external_process.arguments)" in source
    assert "run_math_prompt_arguments_native(external_process.arguments)" in source
    assert "run_reta_arguments_native" in source
    assert "run_reta_line_native(command.raw)" not in controller
