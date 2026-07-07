from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_eq() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5eq.sh" in current
    assert "test_stage12c5ep.sh" in current


def test_stage_script_chains_ep_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5eq.sh").read_text(encoding="utf-8")
    assert "prompt process one-shot external result owner" in script
    assert "test_stage12c5ep.sh" in script
    assert "test_${test_name}_12c5eq" in script
    assert "tests/test_stage12c5eq_source.py" in script
    assert "tests/test_stage12c5ep_source.py" in script


def test_one_shot_external_result_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy_test = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "struct PromptOneShotExternalResultPlan" in owner
    assert "def plan_one_shot_external_process_result(" in owner
    assert "one_shot_external_result=native-prompt-process-one-shot-result-boundary" in owner
    assert "stop_native_probe" in owner
    assert "plan_one_shot_external_process_result" in controller
    assert "return external_result.handled" in controller
    active_controller = "\n".join(
        line for line in controller.splitlines()
        if not line.strip().startswith("#")
    )
    assert "return external_boundary.handled_without_boundary" not in active_controller
    assert "if external_boundary.stop_native_probe" not in active_controller
    assert "test_one_shot_external_result_is_planned_by_process_execution_owner" in mojo_test
    assert "assert_equal(len(process_snapshot), 29)" in mojo_test
    assert "assert_equal(len(scope), 48)" in legacy_test
    assert "one_shot_external_result=native-prompt-process-one-shot-result-boundary" in legacy_test
    assert "One-shot-External-Result" in matrix or "one-shot external result" in matrix


def test_previous_stage_final_marker_was_corrected() -> None:
    script = (ROOT / "scripts/test_stage12c5ep.sh").read_text(encoding="utf-8")
    assert "stage12c5ep prompt process interactive external result owner complete" in script
    assert "stage12c5eo prompt process interactive external result owner complete" not in script


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EQ_PROMPT_PROCESS_ONE_SHOT_EXTERNAL_RESULT.md").read_text(encoding="utf-8")
    assert "plan_one_shot_external_process_result" in doc
    assert "One-shot-External-Result" in doc
    assert "12c5eq" in doc
