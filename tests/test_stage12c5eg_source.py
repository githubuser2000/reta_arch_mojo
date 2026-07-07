from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_eg() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5eg.sh" in current
    assert "test_stage12c5ef.sh" in current
    assert "test_stage12c5ee.sh" in current


def test_stage_script_chains_ef_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5eg.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot compatibility boundary owner" in script
    assert "test_stage12c5ef.sh" in script
    assert "test_${test_name}_12c5eg" in script
    assert "tests/test_stage12c5eg_source.py" in script
    assert "tests/test_stage12c5ef_source.py" in script


def test_one_shot_compatibility_boundary_is_prompt_execution_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert "struct PromptExecutionOneShotCompatibilityBoundaryPlan" in owner
    assert "def plan_prompt_execution_one_shot_compatibility_boundary(" in owner
    assert "stop_native_probe" in owner
    assert "handled_without_fallback" in owner
    assert (
        "plan_prompt_execution_one_shot_compatibility_boundary" in controller
        or "plan_prompt_execution_one_shot_native_probe_result" in controller
    )
    assert (
        "compatibility_boundary.stop_native_probe" in controller
        or "PromptExecutionOneShotNativeProbeResultPlan" in owner
    )
    assert (
        "one_shot_residual_boundary.stop_native_probe" in controller
        or "plan_prompt_execution_one_shot_residual_probe" in controller
    )
    assert (
        "return one_shot_residual_boundary.handled_without_fallback" in controller
        or "return one_shot_residual_probe.result.handled" in controller
        or "return final_probe_result.handled" in controller
        or "return final_pipeline_gate.handled" in controller
    )
    assert "test_prompt_execution_one_shot_compatibility_boundary_owns_probe_exit" in test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EG_PROMPT_EXECUTION_ONE_SHOT_COMPATIBILITY_BOUNDARY.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "plan_prompt_execution_one_shot_compatibility_boundary" in doc
    assert "One-shot-Kompatibil" in doc
    assert "One-shot-Kompatibil" in matrix or "one-shot compatibility" in matrix
