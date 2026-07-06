from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ei() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ei.sh" in current
    assert "test_stage12c5eh.sh" in current
    assert "test_stage12c5eg.sh" in current
    assert "test_stage12c5ef.sh" in current
    assert "test_stage12c5ee.sh" in current


def test_stage_script_chains_eh_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ei.sh").read_text(encoding="utf-8")
    assert "prompt process interactive external completion owner" in script
    assert "test_stage12c5eh.sh" in script
    assert "test_${test_name}_12c5ei" in script
    assert "tests/test_stage12c5ei_source.py" in script
    assert "tests/test_stage12c5eh_source.py" in script


def test_interactive_external_completion_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "struct PromptInteractiveExternalCompletionPlan" in owner
    assert "def plan_interactive_external_process_completion(" in owner
    assert "interactive_external_completion=native-prompt-process-completion-boundary" in owner
    assert "plan_interactive_external_process_completion" in controller
    assert ("external_completion.run_reference_reta" in controller or "reference_reta_execution.should_run_reference_reta" in controller)
    assert "return external_completion.handled" in controller
    assert "test_interactive_external_completion_is_planned_by_process_execution_owner" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EI_PROMPT_PROCESS_INTERACTIVE_EXTERNAL_COMPLETION.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "plan_interactive_external_process_completion" in doc
    assert "Interactive-External" in doc
    assert "Interactive-External" in matrix or "interactive external" in matrix
