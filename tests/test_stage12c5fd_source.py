from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_fd() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fd.sh" in current
    assert "test_stage12c5fc.sh" in current


def test_stage_script_chains_fc_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fd.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot residual probe owner" in script
    assert "test_stage12c5fc.sh" in script
    assert "test_${test_name}_12c5fd" in script
    assert "tests/test_stage12c5fd_source.py" in script
    assert "tests/test_stage12c5fc_source.py" in script
    assert "stage12c5fd prompt execution one-shot residual probe owner complete" in script


def test_one_shot_residual_probe_owns_final_boundary() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotResidualProbePlan" in owner
    assert "def plan_prompt_execution_one_shot_residual_probe(" in owner
    assert "plan_prompt_execution_residual_compatibility_fallback(source)" in owner
    assert "plan_prompt_execution_one_shot_compatibility_boundary(" in owner
    assert "plan_prompt_execution_one_shot_residual_result(boundary)" in owner

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    assert (
        "plan_prompt_execution_one_shot_residual_probe" in active_body
        or "plan_prompt_execution_one_shot_final_probe_result" in active_body
    )
    assert (
        "return one_shot_residual_probe.result.handled" in active_body
        or "return final_probe_result.handled" in active_body
        or "return final_pipeline_gate.handled" in active_body
        or "return one_shot_pipeline_state.handled" in active_body
        or "return one_shot_pipeline_state.handled" in active_body
    )
    assert "var one_shot_residual_fallback =" not in active_body
    assert "var one_shot_residual_boundary =" not in active_body
    assert "plan_prompt_execution_one_shot_residual_result(" not in active_body
    assert "one_shot_residual_boundary.stop_native_probe" not in active_body
    assert "one_shot_residual_boundary.handled_without_fallback" not in active_body

    assert "test_prompt_execution_one_shot_residual_probe_owns_final_boundary" in mojo_test
    assert "assert_true(probe.fallback_required)" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FD_PROMPT_EXECUTION_ONE_SHOT_RESIDUAL_PROBE.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotResidualProbePlan" in doc
    assert "plan_prompt_execution_one_shot_residual_probe" in doc
    assert "12c5fd" in doc
