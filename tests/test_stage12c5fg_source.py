from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_fg() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fg.sh" in current
    assert "test_stage12c5ff.sh" in current


def test_stage_script_chains_ff_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fg.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot post-local probe owner" in script
    assert "test_stage12c5ff.sh" in script
    assert "test_${test_name}_12c5fg" in script
    assert "tests/test_stage12c5fg_source.py" in script
    assert "tests/test_stage12c5ff_source.py" in script
    assert "stage12c5fg prompt execution one-shot post-local probe owner complete" in script


def test_one_shot_post_local_probe_owns_external_gate() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotPostLocalProbeResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_post_local_probe_result(" in owner
    assert "should_probe_external" in owner
    assert '"local_dispatch"' in owner
    assert '"external_process"' in owner

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    assert "plan_prompt_execution_one_shot_post_local_probe_result" in active_body
    assert (
        "post_local_probe_result.should_probe_external" in active_body
        or "post_local_pipeline_gate.stop_native_probe" in active_body
        or "one_shot_pipeline_state.stopped" in active_body
    )
    assert (
        "return post_local_probe_result.handled" in active_body
        or "return post_local_pipeline_gate.handled" in active_body
        or "return one_shot_pipeline_state.handled" in active_body
    )
    assert "if local_dispatch_result.stop_native_probe:" not in active_body
    assert "return local_dispatch_result.handled" not in active_body

    assert "test_prompt_execution_one_shot_post_local_probe_result_owns_external_gate" in mojo_test
    assert 'assert_equal(local_gate.result_owner, "local_dispatch")' in mojo_test
    assert 'assert_equal(external_gate.result_owner, "external_process")' in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FG_PROMPT_EXECUTION_ONE_SHOT_POST_LOCAL_PROBE.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotPostLocalProbeResultPlan" in doc
    assert "plan_prompt_execution_one_shot_post_local_probe_result" in doc
    assert "12c5fg" in doc
