from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ci() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ci.sh" in current


def test_stage_wraps_ch_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5ci.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ch.sh" in source
    assert "bare loop control dispatch ownership" in source
    assert "test_${test_name}_12c5ci" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_loop_control_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptLoopControlDispatchPlan" in owner
    assert "def plan_loop_control_dispatch(" in owner
    assert "KIND_EMPTY" in owner
    assert "KIND_EXIT" in owner
    assert "continue_loop: Bool" in owner
    assert "loop_control=native-empty-exit-loop-plan" in owner


def test_process_controller_delegates_empty_and_exit_controls() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_loop_control_dispatch(command)" in controller
    for forbidden in (
        "if command.kind == KIND_EMPTY",
        "if command.kind == KIND_EXIT",
        "command.kind == KIND_EMPTY or command.kind == KIND_EXIT",
        "KIND_EMPTY,",
        "KIND_EXIT,",
    ):
        assert forbidden not in controller

    interactive = controller.split("def _run_command(", 1)[1].split(
        "def _run_native_one_shot", 1
    )[0]
    one_shot = controller.split("def _run_native_one_shot(", 1)[1]
    for block in (interactive, one_shot):
        loop_control = block.index("var loop_control = plan_loop_control_dispatch(command)")
        stored_or_historical = (
            block.index("var stored_dispatch = plan_stored_command_dispatch(command, session)")
            if "var stored_dispatch = plan_stored_command_dispatch(command, session)" in block
            else block.index("var historical_echo = _uses_historical_prompt_echo")
        )
        assert loop_control < stored_or_historical

    assert "return loop_control.continue_loop" in interactive
    assert "if loop_control.handled:\n        return True" in one_shot


def test_prompt_interaction_regression_covers_loop_control() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_loop_control_dispatch_is_planned_by_interaction_owner" in test
    assert "plan_loop_control_dispatch(" in test
    assert '"loop_control=native-empty-exit-loop-plan"' in test
    assert "assert_equal(len(snapshot), 20)" in test
