from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ed() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current


def test_stage_script_chains_ec_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ed.sh").read_text(encoding="utf-8")
    assert "prompt execution compatibility fallback boundary owner" in script
    assert "test_stage12c5ec.sh" in script
    assert "test_${test_name}_12c5ed" in script
    assert "tests/test_stage12c5ed_source.py" in script
    assert "tests/test_stage12c5ec_source.py" in script


def test_compatibility_fallback_plan_is_owned_by_prompt_execution() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert "struct PromptExecutionCompatibilityFallbackPlan" in owner
    assert "def plan_prompt_execution_compatibility_fallback(" in owner
    assert "PromptExecutionCompatibilityFallbackPlan(" in owner
    assert "plan_prompt_execution_compatibility_fallback(" in controller
    assert "compatibility_fallback.should_run" in controller
    assert "_run_fallback(profile, compatibility_fallback.source)" in controller
    assert "if completion.fallback_required:" not in controller
    assert "test_prompt_execution_compatibility_fallback_plan_owns_source_boundary" in test


def test_untried_fallback_uses_real_unowned_tail_not_shell_alias() -> None:
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    ea = (ROOT / "tests/test_stage12c5ea_source.py").read_text(encoding="utf-8")
    ec = (ROOT / "tests/test_stage12c5ec_source.py").read_text(encoding="utf-8")
    assert '"r unportedtail 2", "deutsch", catalog' in test
    assert '"r shell echo 2", "deutsch", catalog' not in test
    assert '"r unportedtail 2"' in ea
    assert '"r unportedtail 2"' in ec


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5ED_PROMPT_EXECUTION_COMPATIBILITY_FALLBACK.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "PromptExecutionCompatibilityFallbackPlan" in doc
    assert "unportedtail" in doc
    assert "Compatibility-Fallback" in matrix or "Kompatibilitäts-Fallback" in matrix
