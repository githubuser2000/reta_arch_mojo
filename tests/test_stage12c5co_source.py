from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_co_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current


def test_stage_wraps_cn_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5co.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cn.sh" in source
    assert "external reta child argument ownership" in source
    assert "test_${test_name}_12c5co" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_prompt_controller_uses_planned_reta_child_arguments() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "run_reta_arguments_native" in controller
    assert "run_reta_arguments_native(\n                external_process.arguments, reference_root()" in controller
    assert "run_reta_line_native(external_process.raw)" not in controller
    assert "run_reta_line_native," not in controller
    assert "_run_native_reta_prompt_command(external_process.arguments)" in controller
    assert "run_shell_prompt_payload_native(external_process.payload)" in controller
    assert "run_python_prompt_payload_native(external_process.payload)" in controller
    assert "run_math_prompt_payload_native(external_process.payload)" in controller


def test_external_plan_records_direct_reta_child_ownership() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "external_reta_child=native-prompt-reta-child-argv" in owner
    assert "external_reta_arguments=native-prompt-reta-argv-plan" in owner
    assert "external_process_flags=native-prompt-process-effect-flags" in owner


def test_prompt_interaction_regression_covers_direct_reta_child_marker() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert '"external_reta_child=native-prompt-reta-child-argv"' in test
    assert ("assert_equal(len(snapshot), 26)" in test or "assert_equal(len(snapshot), 27)" in test or "assert_equal(len(snapshot), 28)" in test)


def test_previous_payload_and_effect_stage_guards_accept_stronger_reta_boundary() -> None:
    cm = (ROOT / "tests/test_stage12c5cm_source.py").read_text(encoding="utf-8")
    ck = (ROOT / "tests/test_stage12c5ck_source.py").read_text(encoding="utf-8")
    assert "run_reta_arguments_native" in cm
    assert "external_process.arguments" in cm
    assert "run_reta_arguments_native" in ck
    assert "external_process.arguments" in ck
