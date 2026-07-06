from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ea() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ea.sh" in current


def test_stage_script_chains_dz_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ea.sh").read_text(encoding="utf-8")
    assert "prompt execution branch fallback outcome owner" in script
    assert "test_stage12c5dz.sh" in script
    assert "test_${test_name}_12c5ea" in script
    assert "tests/test_stage12c5ea_source.py" in script
    assert "tests/test_stage12c5dz_source.py" in script


def test_outcome_plan_owns_unattempted_fallbacks() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert "A rejected compound candidate must cross the compatibility boundary" in owner
    assert "branch.fallback_required," in owner
    assert "(not native_handled) and branch.fallback_required" not in owner
    assert controller.count("var native_handled = False") == 2
    assert controller.count("if native_branch.fallback_required:") == 0
    assert "test_prompt_execution_native_branch_outcome_owns_untried_fallback" in test
    assert 'plan_prompt_execution_routing(\n        "r shell echo 2"' in test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EA_PROMPT_EXECUTION_BRANCH_FALLBACK_OUTCOME.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "unattempted fallback" in doc
    assert "PromptExecutionNativeBranchOutcomePlan" in doc
    assert "unversuchte Fallback" in matrix or "unversuchte Fallbacks" in matrix
