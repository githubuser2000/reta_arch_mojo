from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_fi() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fi.sh" in current
    assert "test_stage12c5fh.sh" in current


def test_stage_script_chains_fh_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fi.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot pre-native probe owner" in script
    assert "test_stage12c5fh.sh" in script
    assert "test_${test_name}_12c5fi" in script
    assert "tests/test_stage12c5fi_source.py" in script
    assert "tests/test_stage12c5fh_source.py" in script
    assert "stage12c5fi prompt execution one-shot pre-native probe owner complete" in script


def test_one_shot_pre_native_probe_owns_native_gate() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotPreNativeProbeResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_pre_native_probe_result(" in owner
    assert "should_probe_native" in owner
    assert '"loop_control"' in owner
    assert '"native_branch"' in owner

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    assert "plan_prompt_execution_one_shot_pre_native_probe_result" in active_body
    assert "pre_native_probe_result.should_probe_native" in active_body
    assert "return pre_native_probe_result.handled" in active_body
    assert "if loop_control_result.stop_native_probe:" not in active_body
    assert "return loop_control_result.handled" not in active_body

    assert "test_prompt_execution_one_shot_pre_native_probe_result_owns_native_gate" in mojo_test
    assert 'assert_equal(stopped.result_owner, "loop_control")' in mojo_test
    assert 'assert_equal(native_gate.result_owner, "native_branch")' in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FI_PROMPT_EXECUTION_ONE_SHOT_PRE_NATIVE_PROBE.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotPreNativeProbeResultPlan" in doc
    assert "plan_prompt_execution_one_shot_pre_native_probe_result" in doc
    assert "12c5fi" in doc
