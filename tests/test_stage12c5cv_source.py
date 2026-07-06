from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cv() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current


def test_stage_wraps_cu_and_checks_fallback_argument_ownership() -> None:
    source = (ROOT / "scripts/test_stage12c5cv.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cu.sh" in source
    assert "prompt fallback argument ownership" in source
    assert "test_${test_name}_12c5cv" in source
    assert "tests/test_stage12c5cv_source.py" in source


def test_external_adapter_accepts_fallback_arguments_not_raw_lines() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def run_reta_prompt_fallback_arguments_native(" in adapter
    assert "command_arguments: List[String]" in adapter
    assert "for index in range(len(command_arguments)):" in adapter
    assert "arguments.append(command_arguments[index])" in adapter
    assert "def run_reta_prompt_fallback_native(" not in adapter
    fallback_body = adapter.split(
        "def run_reta_prompt_fallback_arguments_native(", 1
    )[1]
    assert "shell_split(line)" not in fallback_body
    assert "line: String" not in fallback_body.split(") raises -> Int:", 1)[0]


def test_prompt_controller_uses_fallback_argument_owner_before_process_adapter() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "run_reta_prompt_fallback_arguments_native," in controller
    assert "plan_prompt_fallback_process_dispatch," in controller
    assert "run_reta_prompt_fallback_native" not in controller
    assert "fallback_profile_arguments(profile), shell_split(line), reference_root()" not in controller
    assert "fallback_process.profile_arguments" in controller
    assert "fallback_process.command_arguments" in controller


def test_legacy_bridge_fallback_uses_same_argv_owner() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "run_reta_prompt_fallback_arguments_native," in bridge
    assert "run_reta_prompt_fallback_native" not in bridge
    assert "flags, shell_split(raw_line), reference_root()" in bridge
    assert "fallback_bridge=native-argv-owner" in bridge


def test_probe_and_snapshot_track_fallback_argument_boundary() -> None:
    probe = (ROOT / "tests/prompt_external_commands_probe.mojo").read_text(
        encoding="utf-8"
    )
    assert "run_reta_prompt_fallback_arguments_native," in probe
    assert "flags, shell_split(line), reference_root" in probe
    test = (ROOT / "tests/test_legacy_mojo_bridge.mojo").read_text(
        encoding="utf-8"
    )
    assert "assert_equal(len(owners)," in test
    assert 'assert_equal(owners[12], "fallback_bridge=native-argv-owner")' in test
