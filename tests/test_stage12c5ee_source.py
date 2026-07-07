from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ee() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ee.sh" in current


def test_stage_script_chains_ed_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ee.sh").read_text(encoding="utf-8")
    assert "prompt execution residual compatibility fallback owner" in script
    assert "test_stage12c5ed.sh" in script
    assert "test_${test_name}_12c5ee" in script
    assert "tests/test_stage12c5ee_source.py" in script
    assert "tests/test_stage12c5ed_source.py" in script


def test_residual_compatibility_fallback_is_owned_by_prompt_execution() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert "def plan_prompt_execution_residual_compatibility_fallback(" in owner
    assert "final unowned-command compatibility boundary" in owner
    assert "plan_prompt_execution_residual_compatibility_fallback(" in controller
    assert ("residual_fallback.should_run" in controller or "residual_execution.should_execute" in controller)
    assert ("_run_fallback(profile, residual_fallback.source)" in controller or "plan_prompt_residual_fallback_process_execution" in controller)
    assert "_run_fallback(profile, line)" not in controller
    assert "test_prompt_execution_residual_compatibility_fallback_owns_last_boundary" in test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EE_PROMPT_EXECUTION_RESIDUAL_FALLBACK.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "plan_prompt_execution_residual_compatibility_fallback" in doc
    assert "Residual-Fallback" in doc
    assert "Residual-Fallback" in matrix or "Residual-Kompatibil" in matrix
