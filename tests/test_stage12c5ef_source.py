from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ef() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ef.sh" in current
    assert "test_stage12c5ee.sh" in current


def test_stage_script_chains_ee_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ef.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot residual fallback owner" in script
    assert "test_stage12c5ee.sh" in script
    assert "test_${test_name}_12c5ef" in script
    assert "tests/test_stage12c5ef_source.py" in script
    assert "tests/test_stage12c5ee_source.py" in script


def test_one_shot_residual_fallback_uses_prompt_execution_owner() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert (
        "one_shot_residual_fallback = plan_prompt_execution_residual_compatibility_fallback" in controller
        or "one_shot_residual_probe = plan_prompt_execution_one_shot_residual_probe" in controller
    )
    assert (
        "one_shot_residual_fallback.should_run" in controller
        or "one_shot_residual_boundary.stop_native_probe" in controller
        or "one_shot_residual_probe.result.handled" in controller
    )
    assert "return False" in controller or "return one_shot_residual_probe.result.handled" in controller
    assert "test_prompt_execution_residual_compatibility_fallback_is_shared_by_one_shot" in test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EF_PROMPT_EXECUTION_ONE_SHOT_RESIDUAL_FALLBACK.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "one-shot residual" in doc
    assert "one_shot_residual_fallback" in doc
    assert "One-shot-Residual" in matrix or "one-shot" in matrix
