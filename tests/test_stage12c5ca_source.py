from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_bz_and_rebuilds_interaction_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5ca.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bz.sh" in source
    assert "stored output dispatch ownership" in source
    assert "test_${test_name}_12c5ca" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt" in source


def test_stored_output_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_reaction_storage.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptStoredOutputExecutionPlan" in owner
    assert "def plan_stored_output_command(" in owner
    assert "def plan_inline_stored_output_command(" in owner
    assert "storage_payload(command)" in owner
    assert "Kein Befehl gespeichert." in owner
    assert "stored_output_dispatch=native-session-output-execution-plan" in owner


def test_process_controller_delegates_stored_output_dispatch() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_stored_output_command(command, session)" in controller
    assert "plan_inline_stored_output_command(" in controller
    assert "var inline_output = plan_inline_stored_output_command" in controller
    assert "var stored_output = plan_stored_output_command" in controller
    assert "var inline_output = plan_inline_storage_output_command" not in controller
    assert "if command.kind == KIND_OUTPUT_STORED:" not in controller


def test_prompt_interaction_regression_covers_stored_output_execution() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_stored_output_execution_is_planned_by_interaction_owner" in test
    assert "def test_inline_stored_output_execution_is_planned_by_interaction_owner" in test
    assert "plan_stored_output_command(" in test
    assert "plan_inline_stored_output_command(" in test
    assert "assert_equal(no_storage.output_lines[0], \"Kein Befehl gespeichert.\")" in test
    assert "assert_equal(with_addition.command_line, \"prim 60 multis 12\")" in test
    assert "assert_equal(suffix.command_line, \"multis 12 prim 60\")" in test
    assert "stored_default=native-empty-enter-placeholder-policy" in test
