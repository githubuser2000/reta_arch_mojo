from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_ey() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ey.sh" in current
    assert "test_stage12c5ex.sh" in current


def test_stage_script_chains_ex_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ey.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot native completion result owner" in script
    assert "test_stage12c5ex.sh" in script
    assert "test_${test_name}_12c5ey" in script
    assert "tests/test_stage12c5ey_source.py" in script
    assert "tests/test_stage12c5ex_source.py" in script
    assert "stage12c5ey prompt execution one-shot native completion result owner complete" in script


def test_one_shot_native_completion_result_is_prompt_execution_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotNativeCompletionResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_native_completion_result(" in owner
    assert "PromptExecutionOneShotNativeCompletionResultPlan(" in owner
    assert "completion.handled" in owner
    assert "not completion.handled" not in owner
    assert "plan_prompt_execution_one_shot_native_completion_result" in controller

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    completion_region = active_body.split(
        "var completion = plan_prompt_execution_native_branch_completion(", 1
    )[1].split(
        "var compatibility_fallback = plan_prompt_execution_compatibility_fallback(", 1
    )[0]
    assert "if completion.handled:" not in completion_region
    assert "return True" not in completion_region
    assert "completion_result.stop_native_probe" in completion_region
    assert "return completion_result.handled" in completion_region
    assert "test_prompt_execution_one_shot_native_completion_result_owns_probe_return" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EY_PROMPT_EXECUTION_ONE_SHOT_NATIVE_COMPLETION_RESULT.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotNativeCompletionResultPlan" in doc
    assert "plan_prompt_execution_one_shot_native_completion_result" in doc
    assert "12c5ey" in doc
