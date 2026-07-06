from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_eb() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5eb.sh" in current
    assert "test_stage12c5ea.sh" in current


def test_stage_script_chains_ea_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5eb.sh").read_text(encoding="utf-8")
    assert "prompt execution native branch output session owner" in script
    assert "test_stage12c5ea.sh" in script
    assert "test_${test_name}_12c5eb" in script
    assert "tests/test_stage12c5eb_source.py" in script
    assert "tests/test_stage12c5ea_source.py" in script


def test_output_and_session_plans_are_owned_by_prompt_execution() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert "struct PromptExecutionNativeBranchOutputPlan" in owner
    assert "def plan_prompt_execution_native_branch_output(" in owner
    assert "table_handled or mulpri_handled" in owner
    assert "struct PromptExecutionSessionLoggingPlan" in owner
    assert "def plan_prompt_execution_session_logging_update(" in owner
    assert "return PromptExecutionSessionLoggingPlan(True, True)" in owner
    assert "return PromptExecutionSessionLoggingPlan(True, False)" in owner
    assert "return handled_table or branch.mulpri_render.handled" not in controller
    assert "plan_prompt_execution_native_branch_output(" in controller
    assert "if outcome.enable_logging:" not in controller
    assert "elif outcome.disable_logging:" not in controller
    assert (
        "plan_prompt_execution_session_logging_update(" in controller
        or "plan_prompt_execution_native_branch_completion(" in controller
    )
    assert "test_prompt_execution_native_branch_output_plan_owns_handled_algebra" in test
    assert "test_prompt_execution_session_logging_update_owns_mutation_value" in test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EB_PROMPT_EXECUTION_BRANCH_OUTPUT_SESSION.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "PromptExecutionNativeBranchOutputPlan" in doc
    assert "PromptExecutionSessionLoggingPlan" in doc
    assert "Output-/Session" in matrix or "Output-/Session-Entscheidung" in matrix
