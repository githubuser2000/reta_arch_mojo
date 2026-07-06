from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_later_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5c" in current


def test_stage_wraps_ce_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cf.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ce.sh" in source
    assert "bare terminal clear dispatch ownership" in source
    assert "test_${test_name}_12c5cf" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_terminal_clear_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptTerminalClearDispatchPlan" in owner
    assert "def plan_terminal_clear_dispatch(" in owner
    assert "KIND_CLEAR" in owner
    assert "clear_terminal: Bool" in owner
    assert "terminal_clear_dispatch=native-terminal-clear-plan" in owner


def test_process_controller_delegates_bare_terminal_clear() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_terminal_clear_dispatch(command)" in controller
    assert "if command.kind == KIND_CLEAR" not in controller
    assert "KIND_CLEAR," not in controller
    interactive = controller.split("def _run_command(", 1)[1].split(
        "def _run_native_one_shot", 1
    )[0]
    one_shot = controller.split("def _run_native_one_shot(", 1)[1]
    for block in (interactive, one_shot):
        info_dispatch = block.index("var info_dispatch = plan_informational_dispatch(command)")
        clear_dispatch = block.index(
            "var terminal_clear = plan_terminal_clear_dispatch(command)",
            info_dispatch,
        )
        next_dispatch = block.index(
            "var simple_output = plan_simple_output_dispatch(command, profile.language)",
            clear_dispatch,
        )
        assert info_dispatch < clear_dispatch < next_dispatch
        dispatch_block = block.split(
            "var terminal_clear = plan_terminal_clear_dispatch(command)", 1
        )[1].split(
            "var simple_output = plan_simple_output_dispatch(command, profile.language)",
            1,
        )[0]
        assert "_clear_terminal_native()" in dispatch_block


def test_prompt_interaction_regression_covers_bare_terminal_clear() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_terminal_clear_dispatch_is_planned_by_interaction_owner" in test
    assert "plan_terminal_clear_dispatch(" in test
    assert '"terminal_clear_dispatch=native-terminal-clear-plan"' in test
    assert "assert_equal(len(snapshot)," in test
