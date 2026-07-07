from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_fe() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fe.sh" in current
    assert "test_stage12c5fd.sh" in current


def test_stage_script_chains_fd_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fe.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot native probe result owner" in script
    assert "test_stage12c5fd.sh" in script
    assert "test_${test_name}_12c5fe" in script
    assert "tests/test_stage12c5fe_source.py" in script
    assert "tests/test_stage12c5fd_source.py" in script
    assert "stage12c5fe prompt execution one-shot native probe result owner complete" in script


def test_one_shot_native_probe_result_owns_completion_and_boundary() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotNativeProbeResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_native_probe_result(" in owner
    assert "plan_prompt_execution_one_shot_native_completion_result(" in owner
    assert "plan_prompt_execution_compatibility_fallback(" in owner
    assert "plan_prompt_execution_one_shot_compatibility_boundary(" in owner
    assert "plan_prompt_execution_one_shot_compatibility_result(" in owner
    assert '"native_completion"' in owner
    assert '"compatibility_boundary"' in owner
    assert '"local_dispatch"' in owner

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    assert "plan_prompt_execution_one_shot_native_probe_result" in active_body
    assert (
        "return native_probe_result.handled" in active_body
        or "return post_native_probe_result.handled" in active_body
            or "return post_native_pipeline_gate.handled" in active_body
    )
    assert "var completion_result =" not in active_body
    assert "var compatibility_fallback =" not in active_body
    assert "var compatibility_boundary =" not in active_body
    assert "var compatibility_result =" not in active_body
    assert "plan_prompt_execution_one_shot_compatibility_result(" not in active_body
    assert "plan_prompt_execution_one_shot_compatibility_boundary(" not in active_body

    assert "test_prompt_execution_one_shot_native_probe_result_owns_completion_and_boundary" in mojo_test
    assert "assert_equal(owned_probe.result_owner, \"native_completion\")" in mojo_test
    assert "assert_equal(fallback_probe.result_owner, \"compatibility_boundary\")" in mojo_test


def test_residual_probe_transfers_non_implicitly_copyable_result() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    body = owner.split("def plan_prompt_execution_one_shot_residual_probe", 1)[1].split("\n\ndef ", 1)[0]
    active_body = _active(body)
    assert "var result = plan_prompt_execution_one_shot_residual_result(boundary)" in active_body
    assert "result^, fallback.should_run, fallback.source" in active_body
    assert "result, fallback.should_run, fallback.source" not in active_body


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FE_PROMPT_EXECUTION_ONE_SHOT_NATIVE_PROBE_RESULT.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotNativeProbeResultPlan" in doc
    assert "plan_prompt_execution_one_shot_native_probe_result" in doc
    assert "12c5fe" in doc
