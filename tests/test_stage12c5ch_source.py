from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_later_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current


def test_stage_wraps_cg_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5ch.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cg.sh" in source
    assert "bare deterministic prompt output dispatch ownership" in source
    assert "test_${test_name}_12c5ch" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_simple_output_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptSimpleOutputDispatchPlan" in owner
    assert "def plan_simple_output_dispatch(" in owner
    assert "prime_lines(command" in owner
    assert "multis_lines(command" in owner
    assert "modulo_lines(command" in owner
    assert "abc_line(command" in owner
    assert "simple_output_dispatch=native-deterministic-prompt-output-plan" in owner


def test_process_controller_delegates_deterministic_output_commands() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_simple_output_dispatch(command, profile.language)" in controller
    for forbidden in (
        "if command.kind == KIND_PRIME:",
        "if command.kind == KIND_PRIME24:",
        "if command.kind == KIND_MULTIS:",
        "if command.kind == KIND_MULTIS3:",
        "if command.kind == KIND_MODULO:",
        "if command.kind == KIND_DISTANCE:",
        "if command.kind == KIND_DISTANCE_PRIME:",
        "if command.kind == KIND_ABC:",
    ):
        assert forbidden not in controller
    interactive = controller.split("def _run_command(", 1)[1].split(
        "def _run_native_one_shot", 1
    )[0]
    one_shot = controller.split("def _run_native_one_shot(", 1)[1]
    for block in (interactive, one_shot):
        clear_dispatch = block.index(
            "var terminal_clear = plan_terminal_clear_dispatch(command)"
        )
        simple_dispatch = block.index(
            "var simple_output = plan_simple_output_dispatch(command, profile.language)",
            clear_dispatch,
        )
        assert clear_dispatch < simple_dispatch
        after_simple = block.split(
            "var simple_output = plan_simple_output_dispatch(command, profile.language)",
            1,
        )[1]
        if "if command.kind == KIND_SHELL" in after_simple:
            dispatch_block = after_simple.split("if command.kind == KIND_SHELL", 1)[0]
        else:
            dispatch_block = after_simple.split("if _run_native_reta_prompt_command", 1)[0]
        assert "_print_lines(simple_output.output_lines)" in dispatch_block


def test_prompt_interaction_regression_covers_simple_output_commands() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_simple_output_dispatch_is_planned_by_interaction_owner" in test
    assert "plan_simple_output_dispatch(" in test
    assert '"simple_output_dispatch=native-deterministic-prompt-output-plan"' in test
    assert "assert_equal(len(snapshot)," in test
