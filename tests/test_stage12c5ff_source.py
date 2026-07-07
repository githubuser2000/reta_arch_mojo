from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_ff() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ff.sh" in current
    assert "test_stage12c5fe.sh" in current


def test_stage_script_chains_fe_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ff.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot final probe result owner" in script
    assert "test_stage12c5fe.sh" in script
    assert "test_${test_name}_12c5ff" in script
    assert "tests/test_stage12c5ff_source.py" in script
    assert "tests/test_stage12c5fe_source.py" in script
    assert "stage12c5ff prompt execution one-shot final probe result owner complete" in script


def test_one_shot_final_probe_result_owns_external_or_residual_arbitration() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotFinalProbeResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_final_probe_result(" in owner
    assert "plan_prompt_execution_one_shot_residual_probe(source)" in owner
    assert '"external_process"' in owner
    assert '"residual_probe"' in owner

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    assert "plan_prompt_execution_one_shot_final_probe_result" in active_body
    assert "return final_probe_result.handled" in active_body
    assert "return external_result.handled" not in active_body
    assert "var one_shot_residual_probe =" not in active_body
    assert "return one_shot_residual_probe.result.handled" not in active_body

    assert "test_prompt_execution_one_shot_final_probe_result_owns_last_arbitration" in mojo_test
    assert "assert_equal(external.result_owner, \"external_process\")" in mojo_test
    assert "assert_equal(residual.result_owner, \"residual_probe\")" in mojo_test


def test_residual_probe_transfers_non_implicitly_copyable_result() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    body = owner.split("def plan_prompt_execution_one_shot_residual_probe", 1)[1].split("\n\ndef ", 1)[0]
    active_body = _active(body)
    assert "var result = plan_prompt_execution_one_shot_residual_result(boundary)" in active_body
    assert "result^, fallback.should_run, fallback.source" in active_body
    assert "result, fallback.should_run, fallback.source" not in active_body


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FF_PROMPT_EXECUTION_ONE_SHOT_FINAL_PROBE_RESULT.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotFinalProbeResultPlan" in doc
    assert "plan_prompt_execution_one_shot_final_probe_result" in doc
    assert "12c5ff" in doc
