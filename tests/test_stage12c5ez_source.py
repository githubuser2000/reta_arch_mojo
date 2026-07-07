from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_ez() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ez.sh" in current
    assert "test_stage12c5ey.sh" in current


def test_stage_script_chains_ey_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ez.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot loop control result owner" in script
    assert "test_stage12c5ey.sh" in script
    assert "test_${test_name}_12c5ez" in script
    assert "tests/test_stage12c5ez_source.py" in script
    assert "tests/test_stage12c5ey_source.py" in script
    assert "stage12c5ez prompt execution one-shot loop control result owner complete" in script


def test_one_shot_loop_control_result_is_prompt_execution_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotLoopControlResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_loop_control_result(" in owner
    assert "PromptExecutionOneShotLoopControlResultPlan(" in owner
    assert "loop_control_handled" in owner
    assert "plan_prompt_execution_one_shot_loop_control_result" in controller

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    loop_region = active_body.split(
        "var loop_control = plan_loop_control_dispatch(command)", 1
    )[1].split(
        "var native_branch = plan_prompt_execution_native_branch(", 1
    )[0]
    assert "if loop_control.handled:" not in loop_region
    assert "return True" not in loop_region
    direct_result_shape = (
        "loop_control_result.stop_native_probe" in loop_region
        and "return loop_control_result.handled" in loop_region
    )
    pre_native_gate_shape = (
        "plan_prompt_execution_one_shot_pre_native_probe_result" in loop_region
        and "pre_native_probe_result.should_probe_native" in loop_region
        and "return pre_native_probe_result.handled" in loop_region
    )
    assert direct_result_shape or pre_native_gate_shape
    assert "test_prompt_execution_one_shot_loop_control_result_owns_probe_return" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EZ_PROMPT_EXECUTION_ONE_SHOT_LOOP_CONTROL_RESULT.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotLoopControlResultPlan" in doc
    assert "plan_prompt_execution_one_shot_loop_control_result" in doc
    assert "12c5ez" in doc
