from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_fj() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fj.sh" in current
    assert "test_stage12c5fi.sh" in current


def test_stage_script_chains_fi_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fj.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot probe pipeline gate owner" in script
    assert "test_stage12c5fi.sh" in script
    assert "test_${test_name}_12c5fj" in script
    assert "tests/test_stage12c5fj_source.py" in script
    assert "tests/test_stage12c5fi_source.py" in script
    assert "stage12c5fj prompt execution one-shot probe pipeline gate owner complete" in script


def test_one_shot_probe_pipeline_gate_normalizes_existing_phase_gates() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotProbePipelineGatePlan" in owner
    assert "continue_pipeline" in owner
    assert "next_phase" in owner
    assert "def plan_prompt_execution_one_shot_pipeline_pre_native_gate(" in owner
    assert "def plan_prompt_execution_one_shot_pipeline_post_native_gate(" in owner
    assert "def plan_prompt_execution_one_shot_pipeline_post_local_gate(" in owner
    assert "def plan_prompt_execution_one_shot_pipeline_final_gate(" in owner
    assert '"native_branch"' in owner
    assert '"local_dispatch"' in owner
    assert '"external_process"' in owner

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    assert "plan_prompt_execution_one_shot_pipeline_pre_native_gate" in active_body
    assert "plan_prompt_execution_one_shot_pipeline_post_native_gate" in active_body
    assert "plan_prompt_execution_one_shot_pipeline_post_local_gate" in active_body
    assert "plan_prompt_execution_one_shot_pipeline_final_gate" in active_body
    assert "return pre_native_pipeline_gate.handled" in active_body
    assert "return post_native_pipeline_gate.handled" in active_body
    assert "return post_local_pipeline_gate.handled" in active_body
    assert "return final_pipeline_gate.handled" in active_body
    assert "pre_native_probe_result.should_probe_native" not in active_body
    assert "post_native_probe_result.should_probe_local" not in active_body
    assert "post_local_probe_result.should_probe_external" not in active_body
    assert "return final_probe_result.handled" not in active_body

    assert "test_prompt_execution_one_shot_probe_pipeline_gate_normalizes_stage_edges" in mojo_test
    assert 'assert_equal(native_gate.next_phase, "native_branch")' in mojo_test
    assert 'assert_equal(local_gate.next_phase, "local_dispatch")' in mojo_test
    assert 'assert_equal(external_gate.next_phase, "external_process")' in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FJ_PROMPT_EXECUTION_ONE_SHOT_PROBE_PIPELINE_GATE.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotProbePipelineGatePlan" in doc
    assert "plan_prompt_execution_one_shot_pipeline_pre_native_gate" in doc
    assert "12c5fj" in doc
