from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ej() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ej.sh" in current
    assert "test_stage12c5ei.sh" in current
    assert "test_stage12c5eh.sh" in current
    assert "test_stage12c5eg.sh" in current
    assert "test_stage12c5ef.sh" in current


def test_stage_script_chains_ei_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ej.sh").read_text(encoding="utf-8")
    assert "prompt process fallback execution boundary owner" in script
    assert "test_stage12c5ei.sh" in script
    assert "test_${test_name}_12c5ej" in script
    assert "tests/test_stage12c5ej_source.py" in script
    assert "tests/test_stage12c5ei_source.py" in script


def test_fallback_execution_boundary_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "struct PromptFallbackProcessExecutionPlan" in owner
    assert "def plan_prompt_fallback_process_execution(" in owner
    assert "fallback_process_execution=native-prompt-fallback-execution-boundary" in owner
    assert "plan_prompt_fallback_process_execution" in controller
    assert "fallback_execution.should_execute" in controller
    assert "fallback_execution.arguments" in controller
    assert "if not fallback_process.handled" not in controller
    assert "if not fallback_process.run_reta_prompt" not in controller
    assert "test_fallback_process_execution_is_planned_by_process_execution_owner" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EJ_PROMPT_PROCESS_FALLBACK_EXECUTION_BOUNDARY.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "plan_prompt_fallback_process_execution" in doc
    assert "Fallback-Execution" in doc
    assert "Fallback-Execution" in matrix or "fallback execution" in matrix
