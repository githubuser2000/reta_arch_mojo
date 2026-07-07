from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_fc() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fc.sh" in current
    assert "test_stage12c5fb.sh" in current


def test_stage_script_chains_fb_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fc.sh").read_text(encoding="utf-8")
    assert "prompt process one-shot external probe result owner" in script
    assert "test_stage12c5fb.sh" in script
    assert "test_${test_name}_12c5fc" in script
    assert "tests/test_stage12c5fc_source.py" in script
    assert "tests/test_stage12c5fb_source.py" in script
    assert "stage12c5fc prompt process one-shot external probe result owner complete" in script


def test_one_shot_external_probe_result_owns_continue_gate() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")

    assert "struct PromptOneShotExternalResultPlan" in owner
    assert "continue_native_probe" in owner
    assert "def plan_one_shot_external_process_result(" in owner
    assert "False, True, False, boundary.reta_native_handled" in owner
    assert "True, False, False, boundary.reta_native_handled" in owner
    assert "False,\n        False,\n        True," in owner

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    external_region = active_body.split(
        "var external_process = plan_external_process_dispatch(command)", 1
    )[1].split("var one_shot_residual_probe", 1)[0]
    assert "if external_process.handled:" not in external_region
    assert "plan_one_shot_external_process_execution" in external_region
    assert "plan_one_shot_external_process_boundary" in external_region
    assert "plan_one_shot_external_process_result" in external_region
    assert "external_result.continue_native_probe" in external_region
    assert (
        "return external_result.handled" in external_region
        or "plan_prompt_execution_one_shot_final_probe_result" in external_region
    )
    assert external_region.count("return ") == 1

    assert "assert_true(unhandled_result.continue_native_probe)" in mojo_test
    assert "assert_false(shell_result.continue_native_probe)" in mojo_test
    assert "assert_false(accepted_result.continue_native_probe)" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FC_PROMPT_PROCESS_ONE_SHOT_EXTERNAL_PROBE_RESULT.md").read_text(encoding="utf-8")
    assert "PromptOneShotExternalResultPlan" in doc
    assert "continue_native_probe" in doc
    assert "12c5fc" in doc
