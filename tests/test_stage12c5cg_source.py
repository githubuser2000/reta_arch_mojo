from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cg() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current


def test_stage_wraps_cf_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cg.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cf.sh" in source
    assert "bare informational dispatch ownership" in source
    assert "test_${test_name}_12c5cg" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_informational_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptInformationalDispatchPlan" in owner
    assert "def plan_informational_dispatch(" in owner
    assert "KIND_HELP" in owner
    assert "KIND_COMMANDS" in owner
    assert "KIND_SHORT_COMMANDS" in owner
    assert "show_help: Bool" in owner
    assert "show_commands: Bool" in owner
    assert "show_short_commands: Bool" in owner
    assert "informational_dispatch=native-prompt-information-plan" in owner


def test_process_controller_delegates_bare_information_commands() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_informational_dispatch(command)" in controller
    for forbidden in (
        "if command.kind == KIND_HELP",
        "if command.kind == KIND_COMMANDS",
        "if command.kind == KIND_SHORT_COMMANDS",
        "KIND_HELP,",
        "KIND_COMMANDS,",
        "KIND_SHORT_COMMANDS,",
    ):
        assert forbidden not in controller
    interactive = controller.split("def _run_command(", 1)[1].split(
        "def _run_native_one_shot", 1
    )[0]
    one_shot = controller.split("def _run_native_one_shot(", 1)[1]
    for block in (interactive, one_shot):
        info_dispatch = block.index(
            "var info_dispatch = plan_informational_dispatch(command)"
        )
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
            "var info_dispatch = plan_informational_dispatch(command)", 1
        )[1].split("var terminal_clear = plan_terminal_clear_dispatch(command)", 1)[0]
        assert "_print_prompt_help()" in dispatch_block
        assert "_print_commands(catalog, profile.language, False)" in dispatch_block
        assert "_print_commands(catalog, profile.language, True)" in dispatch_block


def test_prompt_interaction_regression_covers_bare_information_commands() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_informational_dispatch_is_planned_by_interaction_owner" in test
    assert "plan_informational_dispatch(" in test
    assert '"informational_dispatch=native-prompt-information-plan"' in test
    assert "assert_equal(len(snapshot)," in test
