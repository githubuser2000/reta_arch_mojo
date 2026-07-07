from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_er() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5er.sh" in current
    assert "test_stage12c5eq.sh" in current


def test_stage_script_chains_eq_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5er.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot residual result owner" in script
    assert "test_stage12c5eq.sh" in script
    assert "test_${test_name}_12c5er" in script
    assert "tests/test_stage12c5er_source.py" in script
    assert "tests/test_stage12c5eq_source.py" in script


def test_one_shot_residual_result_is_prompt_execution_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "struct PromptExecutionOneShotResidualResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_residual_result(" in owner
    assert "handled_without_fallback" in owner
    assert (
        "plan_prompt_execution_one_shot_residual_result" in controller
        or "plan_prompt_execution_one_shot_residual_probe" in controller
        or "plan_prompt_execution_one_shot_final_probe_result" in controller
    )
    assert (
        "return one_shot_residual_result.handled" in controller
        or "return one_shot_residual_probe.result.handled" in controller
        or "return final_probe_result.handled" in controller
        or "return final_pipeline_gate.handled" in controller
    )
    active_controller = "\n".join(
        line for line in controller.splitlines()
        if not line.strip().startswith("#")
    )
    assert "return one_shot_residual_boundary.handled_without_fallback" not in active_controller
    assert "if one_shot_residual_boundary.stop_native_probe" not in active_controller
    assert "test_prompt_execution_one_shot_residual_result_owns_final_probe_return" in mojo_test
    assert "One-shot-Residual-Result" in matrix or "one-shot residual result" in matrix


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5ER_PROMPT_EXECUTION_ONE_SHOT_RESIDUAL_RESULT.md").read_text(encoding="utf-8")
    assert "plan_prompt_execution_one_shot_residual_result" in doc
    assert "One-shot-Residual" in doc
    assert "12c5er" in doc
