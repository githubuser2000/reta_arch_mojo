from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_cc_and_rebuilds_relevant_mojo_targets() -> None:
    source = (ROOT / "scripts/test_stage12c5cd.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cc.sh" in source
    assert "single storage dispatch ownership" in source
    assert "test_${test_name}_12c5cd" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_single_storage_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptStoredCommandDispatchPlan" in owner
    assert "def plan_stored_command_dispatch(" in owner
    assert "session.store_next = True" in owner
    assert "store_prompt_text(session, payload)" in owner
    assert "stored_command_dispatch=native-session-store-plan" in owner


def test_process_controller_delegates_single_storage_dispatch() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_stored_command_dispatch(command, session)" in controller
    assert "var stored_dispatch = plan_stored_command_dispatch" in controller
    assert "if command.kind == KIND_STORE_NEXT" not in controller
    assert "if command.kind == KIND_STORE_PREVIOUS" not in controller
    assert "session.store_next = True" not in controller
    assert "store_prompt_text(session, payload)" not in controller


def test_prompt_interaction_regression_covers_single_storage_dispatch() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_single_storage_dispatch_is_planned_by_interaction_owner" in test
    assert "plan_stored_command_dispatch(" in test
    assert '"Der nächste Befehl wird gespeichert."' in test
    assert 'assert_equal(save_previous_plan.output_lines[0], "Gespeichert: prim 60")' in test
    assert "assert_equal(len(empty_previous_plan.output_lines), 0)" in test
    assert "assert_equal(len(snapshot)," in test
