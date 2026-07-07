from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ev() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ev.sh" in current
    assert "test_stage12c5eu.sh" in current


def test_stage_script_chains_eu_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ev.sh").read_text(encoding="utf-8")
    assert "prompt process native reta child result owner" in script
    assert "test_stage12c5eu.sh" in script
    assert "test_${test_name}_12c5ev" in script
    assert "tests/test_stage12c5ev_source.py" in script
    assert "tests/test_stage12c5eu_source.py" in script
    assert "stage12c5ev prompt process native reta child result owner complete" in script


def test_native_reta_child_result_is_process_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    matrix_generator = (ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8")

    assert "struct PromptNativeRetaChildResultPlan" in owner
    assert "def plan_prompt_native_reta_child_result(" in owner
    assert "native_reta_child_result=native-prompt-reta-child-result-boundary" in owner
    assert "plan_prompt_native_reta_child_result" in controller
    body = controller.split("def _run_native_reta_prompt_command", 1)[1].split("\ndef _run_native_table_plan", 1)[0]
    active_body = "\n".join(
        line for line in body.splitlines()
        if not line.strip().startswith("#")
    )
    assert "startup_result.print_startup_output" in active_body
    assert "table_result.print_native_reta_output" in active_body
    assert "return True" not in active_body
    assert "return False" not in active_body
    assert "test_native_reta_child_result_is_planned_by_process_execution_owner" in mojo_test
    assert "native_reta_child_result" in legacy
    assert "native reta-Kindprozess-Ergebnisprojektion" in matrix_generator


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EV_PROMPT_PROCESS_NATIVE_RETA_CHILD_RESULT.md").read_text(encoding="utf-8")
    assert "PromptNativeRetaChildResultPlan" in doc
    assert "plan_prompt_native_reta_child_result" in doc
    assert "12c5ev" in doc
