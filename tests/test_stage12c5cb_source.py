from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cb() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cb.sh" in current


def test_stage_wraps_ca_and_rebuilds_interaction_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5cb.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ca.sh" in source
    assert "stored delete dispatch ownership" in source
    assert "test_${test_name}_12c5cb" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source
    assert "test_table_adapters_12c5cb" in source or "test_${test_name}_12c5cb" in source


def test_stored_delete_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptStoredDeletePlan" in owner
    assert "def plan_stored_delete_command(" in owner
    assert "stored_prompt_numbered(session)" in owner
    assert "delete_stored_selection(session, selection)" in owner
    assert "stored_delete_dispatch=native-session-delete-plan" in owner


def test_process_controller_delegates_delete_dispatch() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_stored_delete_command(command, session)" in controller
    assert "var stored_delete = plan_stored_delete_command" in controller
    assert "if command.kind == KIND_DELETE_STORED:" not in controller
    assert "stored_prompt_numbered(session)" not in controller
    assert "delete_stored_selection(session, selection)" not in controller


def test_prompt_interaction_regression_covers_delete_dispatch() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_stored_delete_execution_is_planned_by_interaction_owner" in test
    assert "plan_stored_delete_command(" in test
    assert 'assert_equal(no_storage.output_lines[0], "Kein Befehl gespeichert.")' in test
    assert 'assert_equal(deleted.output_lines[0], "Gespeichert: prim multis 12")' in test
    assert "assert_equal(len(snapshot), 14)" in test
