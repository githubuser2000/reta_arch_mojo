from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ep() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ep.sh" in current


def test_stage_script_chains_eo_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ep.sh").read_text(encoding="utf-8")
    assert "prompt process interactive external result owner" in script
    assert "test_stage12c5eo.sh" in script
    assert "test_${test_name}_12c5ep" in script
    assert "tests/test_stage12c5ep_source.py" in script
    assert "tests/test_stage12c5eo_source.py" in script


def test_interactive_external_result_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy_test = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "struct PromptInteractiveExternalResultPlan" in owner
    assert "def plan_interactive_external_process_result(" in owner
    assert "interactive_external_result=native-prompt-process-result-boundary" in owner
    assert "reference_reta_requested" in owner
    assert "plan_interactive_external_process_result" in controller
    assert "return external_result.handled" in controller
    active_controller = "\n".join(
        line for line in controller.splitlines()
        if not line.strip().startswith("#")
    )
    assert "return external_completion.handled" not in active_controller
    assert "test_interactive_external_result_is_planned_by_process_execution_owner" in mojo_test
    assert "assert_equal(len(process_snapshot), 28)" in mojo_test
    assert "assert_equal(len(scope), 47)" in legacy_test
    assert "interactive_external_result=native-prompt-process-result-boundary" in legacy_test
    assert "Interactive-External-Result" in matrix or "interactive external result" in matrix


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EP_PROMPT_PROCESS_INTERACTIVE_EXTERNAL_RESULT.md").read_text(encoding="utf-8")
    assert "plan_interactive_external_process_result" in doc
    assert "Interactive-External-Result" in doc
    assert "12c5ep" in doc
