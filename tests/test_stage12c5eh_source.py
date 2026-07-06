from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_eh() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5eh.sh" in current
    assert "test_stage12c5eg.sh" in current
    assert "test_stage12c5ef.sh" in current


def test_stage_script_chains_eg_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5eh.sh").read_text(encoding="utf-8")
    assert "prompt process one-shot external boundary owner" in script
    assert "test_stage12c5eg.sh" in script
    assert "test_${test_name}_12c5eh" in script
    assert "tests/test_stage12c5eh_source.py" in script
    assert "tests/test_stage12c5eg_source.py" in script


def test_one_shot_external_boundary_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "struct PromptOneShotExternalBoundaryPlan" in owner
    assert "def plan_one_shot_external_process_boundary(" in owner
    assert "one_shot_external_boundary=native-prompt-process-probe-boundary" in owner
    assert "plan_one_shot_external_process_boundary" in controller
    assert "external_boundary.stop_native_probe" in controller
    assert "return external_boundary.handled_without_boundary" in controller
    assert "test_one_shot_external_boundary_is_planned_by_process_execution_owner" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EH_PROMPT_PROCESS_ONE_SHOT_EXTERNAL_BOUNDARY.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "plan_one_shot_external_process_boundary" in doc
    assert "One-shot-External" in doc
    assert "One-shot-External" in matrix or "one-shot external" in matrix
