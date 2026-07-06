from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dz() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5dz.sh" in current or "test_stage12c5ea.sh" in current


def test_stage_script_chains_dy_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5dz.sh").read_text(encoding="utf-8")
    assert "prompt execution native branch outcome plan" in script
    assert "test_stage12c5dy.sh" in script
    assert "test_${test_name}_12c5dz" in script
    assert "tests/test_stage12c5dz_source.py" in script
    assert "tests/test_stage12c5dy_source.py" in script


def test_native_branch_outcome_plan_owns_post_execution_decisions() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "struct PromptExecutionNativeBranchOutcomePlan" in owner
    assert "def plan_prompt_execution_native_branch_outcome" in owner
    assert "native_handled and branch.historical_effects.enable_logging" in owner
    assert "native_handled and branch.historical_effects.disable_logging" in owner
    assert "branch.fallback_required" in owner
    assert "(not native_handled) and branch.fallback_required" not in owner
    assert "plan_prompt_execution_native_branch_outcome" in controller
    assert (
        "if outcome.enable_logging" in controller
        or "plan_prompt_execution_session_logging_update" in controller
        or "plan_prompt_execution_native_branch_completion" in controller
    )
    assert "if native_branch.historical_effects.enable_logging" not in controller


def test_mulpri_render_contract_no_longer_requires_unstable_prime_word() -> None:
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    assert 'plan_prompt_execution_routing("p 17", "deutsch", catalog)' in test
    assert 'assert_true(len(plan.output_lines) >= 2)' in test
    assert 'assert_true(_has_substring(plan.output_lines, "Primzahl"))' not in test
    assert '("[]" in multi_output[index])' in owner


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5DZ_PROMPT_EXECUTION_NATIVE_BRANCH_OUTCOME.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "PromptExecutionNativeBranchOutcomePlan" in doc
    assert "plan_prompt_execution_native_branch_outcome" in doc
    assert "PromptExecutionNativeBranchOutcomePlan" in matrix
