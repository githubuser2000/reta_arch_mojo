from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ec() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5ec.sh" in current
    assert "test_stage12c5eb.sh" in current


def test_stage_script_chains_eb_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ec.sh").read_text(encoding="utf-8")
    assert "prompt execution native branch completion owner" in script
    assert "test_stage12c5eb.sh" in script
    assert "test_${test_name}_12c5ec" in script
    assert "tests/test_stage12c5ec_source.py" in script
    assert "tests/test_stage12c5eb_source.py" in script


def test_completion_plan_is_owned_by_prompt_execution() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert "struct PromptExecutionNativeBranchCompletionPlan" in owner
    assert "def plan_prompt_execution_native_branch_completion(" in owner
    assert "PromptExecutionNativeBranchCompletionPlan(" in owner
    assert "plan_prompt_execution_session_logging_update(" in owner
    assert "plan_prompt_execution_native_branch_completion(" in controller
    assert "if completion.handled:" in controller
    assert ("if completion.fallback_required:" in controller or "compatibility_fallback.should_run" in controller)
    assert "if outcome.handled:" not in controller
    assert "if outcome.fallback_required:" not in controller
    assert "completion.session_logging.update" in controller
    assert "completion.session_logging.enabled" in controller
    assert "test_prompt_execution_native_branch_completion_owns_controller_flags" in test


def test_ea_untried_fallback_contract_uses_historical_shortcut() -> None:
    ea = (ROOT / "tests/test_stage12c5ea_source.py").read_text(encoding="utf-8")
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert '\\n        "r unportedtail 2"' in ea
    assert '"r unportedtail 2", "deutsch", catalog' in test
    assert '"richtung unportedtail 2", "deutsch", catalog' not in test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EC_PROMPT_EXECUTION_BRANCH_COMPLETION.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "PromptExecutionNativeBranchCompletionPlan" in doc
    assert "handled/fallback/session" in doc
    assert "Branch-Completion" in matrix or "Completion-Entscheidung" in matrix
