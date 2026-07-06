from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dx() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dx.sh" in current or "test_stage12c5dy.sh" in current or "test_stage12c5dz.sh" in current


def test_native_branch_plan_lives_in_prompt_execution_owner() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    assert "struct PromptExecutionNativeBranchPlan" in owner
    assert "def plan_prompt_execution_native_branch(" in owner
    assert "var ownership = plan_prompt_execution_table_ownership(" in owner
    assert "var announcement = PromptExecutionCompactAnnouncementPlan(" in owner
    assert "var effects = PromptExecutionHistoricalEffectPlan(" in owner
    assert "routing.planning_tokens.copy()" in owner
    assert "var mulpri_render: PromptExecutionMulpriRenderPlan" in owner


def test_prompt_main_uses_native_branch_plan_in_both_entry_points() -> None:
    source = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_prompt_execution_native_branch" in source
    assert source.count("plan_prompt_execution_native_branch(") == 2
    assert "plan_prompt_execution_table_ownership" not in source
    assert "plan_prompt_execution_historical_effects" not in source
    assert "plan_prompt_execution_compact_announcement" not in source
    assert "def _execute_owned_prompt_branch(" in source


def test_stage_script_chains_previous_and_current_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5dx.sh").read_text(encoding="utf-8")
    assert "prompt execution native branch plan" in script
    assert "test_stage12c5dw.sh" in script
    assert "test_${test_name}_12c5dx" in script
    assert "tests/test_stage12c5dx_source.py" in script
    assert "tests/test_stage12c5dw_source.py" in script
