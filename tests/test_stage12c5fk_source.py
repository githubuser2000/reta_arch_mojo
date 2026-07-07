from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_fk() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fk.sh" in current
    assert "test_stage12c5fj.sh" in current


def test_stage_script_chains_fj_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fk.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot probe pipeline state owner" in script
    assert "test_stage12c5fj.sh" in script
    assert "test_${test_name}_12c5fk" in script
    assert "tests/test_stage12c5fk_source.py" in script
    assert "tests/test_stage12c5fj_source.py" in script
    assert "stage12c5fk prompt execution one-shot probe pipeline state owner complete" in script


def test_one_shot_probe_pipeline_state_consumes_existing_gates() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotProbePipelineStatePlan" in owner
    assert "def plan_prompt_execution_one_shot_pipeline_initial_state(" in owner
    assert "def plan_prompt_execution_one_shot_pipeline_apply_gate(" in owner
    assert "var phase: String" in owner
    assert "var stopped: Bool" in owner

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    assert "var one_shot_pipeline_state = plan_prompt_execution_one_shot_pipeline_initial_state" in active_body
    assert active_body.count("plan_prompt_execution_one_shot_pipeline_apply_gate") == 4
    assert "if one_shot_pipeline_state.stopped:" in active_body
    assert "return one_shot_pipeline_state.handled" in active_body
    assert "return pre_native_pipeline_gate.handled" not in active_body
    assert "return post_native_pipeline_gate.handled" not in active_body
    assert "return post_local_pipeline_gate.handled" not in active_body
    assert "return final_pipeline_gate.handled" not in active_body

    assert "test_prompt_execution_one_shot_probe_pipeline_state_consumes_gates" in mojo_test
    assert "plan_prompt_execution_one_shot_pipeline_initial_state" in mojo_test
    assert "plan_prompt_execution_one_shot_pipeline_apply_gate" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FK_PROMPT_EXECUTION_ONE_SHOT_PROBE_PIPELINE_STATE.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotProbePipelineStatePlan" in doc
    assert "plan_prompt_execution_one_shot_pipeline_apply_gate" in doc
    assert "12c5fk" in doc
