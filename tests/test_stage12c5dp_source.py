from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dp_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_script_covers_prompt_reaction_storage_dispatch_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5dp.sh").read_text(encoding="utf-8")
    assert "prompt reaction storage dispatch owner" in source
    assert "test_stage12c5do.sh" in source
    assert "test_${test_name}_12c5dp" in source
    assert "tests/test_stage12c5dp_source.py" in source
    assert "tests/test_stage12c5do_source.py" in source


def test_storage_owner_absorbs_all_storage_dispatch_plans() -> None:
    storage = (ROOT / "src/reta_mojo/prompt_reaction_storage.mojo").read_text(
        encoding="utf-8"
    )
    reaction = (ROOT / "src/reta_mojo/prompt_reaction_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    for symbol in (
        "PromptStoredCommandDispatchPlan",
        "PromptStoredOutputExecutionPlan",
        "PromptStoredDeletePlan",
        "apply_inline_storage_command",
        "plan_stored_command_dispatch",
        "plan_inline_stored_output_command",
        "plan_stored_output_command",
        "plan_stored_delete_command",
    ):
        assert symbol in storage
        assert symbol not in reaction
    assert "stored_command_dispatch=native-session-store-plan" in storage
    assert "stored_output_dispatch=native-session-output-execution-plan" in storage
    assert "stored_delete_dispatch=native-session-delete-plan" in storage
    assert "stored_command_dispatch=native-session-store-plan" not in reaction
    assert "stored_output_dispatch=native-session-output-execution-plan" not in reaction
    assert "stored_delete_dispatch=native-session-delete-plan" not in reaction


def test_user_reported_ambiguous_warning_is_removed() -> None:
    storage = (ROOT / "src/reta_mojo/prompt_reaction_storage.mojo").read_text(
        encoding="utf-8"
    )
    assert "ambiguous = True\n                ambiguous = True" not in storage
    assert storage.count("ambiguous = True") == 2


def test_controller_imports_storage_dispatch_directly() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    dispatch_import = controller.split("from reta_mojo.prompt_reaction_dispatch import (", 1)[1].split(")", 1)[0]
    storage_import = controller.split("from reta_mojo.prompt_reaction_storage import (", 1)[1].split(")", 1)[0]
    for symbol in (
        "apply_inline_storage_command",
        "plan_stored_command_dispatch",
        "plan_inline_stored_output_command",
        "plan_stored_output_command",
        "plan_stored_delete_command",
    ):
        assert symbol in storage_import
        assert symbol not in dispatch_import
    for symbol in (
        "plan_loop_control_dispatch",
        "plan_logging_dispatch",
        "plan_one_shot_logging_dispatch",
        "plan_terminal_clear_dispatch",
        "plan_informational_dispatch",
        "plan_simple_output_dispatch",
    ):
        assert symbol in dispatch_import


def test_contracts_record_storage_dispatch_split() -> None:
    prompt_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "assert_equal(len(storage_snapshot), 8)" in prompt_test
    assert 'assert_equal(storage_snapshot[5], "stored_command_dispatch=native-session-store-plan")' in prompt_test
    assert 'assert_equal(storage_snapshot[6], "stored_output_dispatch=native-session-output-execution-plan")' in prompt_test
    assert 'assert_equal(storage_snapshot[7], "stored_delete_dispatch=native-session-delete-plan")' in prompt_test
    assert "assert_equal(len(reaction_snapshot), 8)" in prompt_test


def test_storage_owner_still_has_no_process_or_reta_core_boundary() -> None:
    storage = (ROOT / "src/reta_mojo/prompt_reaction_storage.mojo").read_text(
        encoding="utf-8"
    )
    assert "prompt_process_dispatch" not in storage
    assert "prompt_external_commands" not in storage
    assert "run_reta" not in storage
    assert "reta_child" not in storage
    assert "PythonObject" not in storage
    assert "from std.python import" not in storage
    assert "shell_quote" not in storage


def test_document_records_storage_dispatch_boundary_without_shared_lib_implementation() -> None:
    doc = (ROOT / "STAGE12C5DP_PROMPT_REACTION_STORAGE_DISPATCH_OWNER.md").read_text(
        encoding="utf-8"
    )
    assert "libreta_prompt_mojo-reaction" in doc
    assert "prompt_reaction_storage.mojo" in doc
    assert "No `.so`/`.dll` split is implemented" in doc
