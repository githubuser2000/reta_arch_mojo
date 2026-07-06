from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_later_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current


def test_stage_wraps_ci_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cj.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ci.sh" in source
    assert "one-shot logging dispatch ownership" in source
    assert "test_${test_name}_12c5cj" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_loop_control_import_is_compile_visible() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    import_block = owner.split("from .prompt_runtime import (", 1)[1].split(")", 1)[0]
    assert "KIND_EMPTY," in import_block
    assert "KIND_EXIT," in import_block
    assert "if command.kind == KIND_EMPTY" in owner
    assert "loop_control=native-empty-exit-loop-plan" in owner


def test_one_shot_logging_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptOneShotLoggingDispatchPlan" in owner
    assert "def plan_one_shot_logging_dispatch(" in owner
    assert "_logging_output_lines(command)" in owner
    assert "one_shot_logging_dispatch=native-stateless-logging-plan" in owner


def test_process_controller_delegates_one_shot_logging() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_one_shot_logging_dispatch(command)" in controller
    assert "KIND_LOG_ON," not in controller
    assert "KIND_LOG_OFF," not in controller
    assert "if command.kind == KIND_LOG_ON" not in controller
    assert "if command.kind == KIND_LOG_OFF" not in controller

    one_shot = controller.split("def _run_native_one_shot(", 1)[1]
    terminal_clear = one_shot.index(
        "var terminal_clear = plan_terminal_clear_dispatch(command)"
    )
    logging = one_shot.index(
        "var one_shot_logging = plan_one_shot_logging_dispatch(command)"
    )
    simple = one_shot.index(
        "var simple_output = plan_simple_output_dispatch(command, profile.language)"
    )
    assert terminal_clear < logging < simple
    dispatch_block = one_shot.split(
        "var one_shot_logging = plan_one_shot_logging_dispatch(command)", 1
    )[1].split(
        "var simple_output = plan_simple_output_dispatch(command, profile.language)", 1
    )[0]
    assert "_print_lines(one_shot_logging.output_lines)" in dispatch_block


def test_prompt_interaction_regression_covers_one_shot_logging() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_one_shot_logging_dispatch_is_planned_by_interaction_owner" in test
    assert "plan_one_shot_logging_dispatch(" in test
    assert '"one_shot_logging_dispatch=native-stateless-logging-plan"' in test
    assert "one_shot_logging_dispatch=native-stateless-logging-plan" in test
