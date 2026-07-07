from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ew() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ew.sh" in current
    assert "test_stage12c5ev.sh" in current


def test_stage_script_chains_ev_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ew.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot compatibility result owner" in script
    assert "test_stage12c5ev.sh" in script
    assert "test_${test_name}_12c5ew" in script
    assert "tests/test_stage12c5ew_source.py" in script
    assert "tests/test_stage12c5ev_source.py" in script
    assert "stage12c5ew prompt execution one-shot compatibility result owner complete" in script


def test_one_shot_compatibility_result_is_prompt_execution_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotCompatibilityResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_compatibility_result(" in owner
    assert "boundary.handled_without_fallback" in owner
    assert (
        "plan_prompt_execution_one_shot_compatibility_result" in controller
        or "plan_prompt_execution_one_shot_native_probe_result" in controller
    )
    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = "\n".join(
        line for line in body.splitlines()
        if not line.strip().startswith("#")
    )
    assert "compatibility_boundary.stop_native_probe" not in active_body
    assert (
        "compatibility_result.stop_native_probe" in active_body
        or "native_probe_result.stop_native_probe" in active_body
        or "post_native_probe_result.should_probe_local" in active_body
    )
    assert (
        "return compatibility_result.handled" in active_body
        or "return native_probe_result.handled" in active_body
        or "return post_native_probe_result.handled" in active_body
    )
    assert "test_prompt_execution_one_shot_compatibility_result_owns_probe_return" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EW_PROMPT_EXECUTION_ONE_SHOT_COMPATIBILITY_RESULT.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotCompatibilityResultPlan" in doc
    assert "plan_prompt_execution_one_shot_compatibility_result" in doc
    assert "12c5ew" in doc
