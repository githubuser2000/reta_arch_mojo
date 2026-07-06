from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_em() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5em.sh" in current


def test_stage_script_chains_el_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5em.sh").read_text(encoding="utf-8")
    assert "prompt process interactive reference reta execution owner" in script
    assert "test_stage12c5el.sh" in script
    assert "test_${test_name}_12c5em" in script
    assert "tests/test_stage12c5em_source.py" in script
    assert "tests/test_stage12c5el_source.py" in script


def test_reference_reta_execution_boundary_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy_test = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "struct PromptInteractiveReferenceRetaExecutionPlan" in owner
    assert "def plan_interactive_reference_reta_process_execution(" in owner
    assert "interactive_reference_reta_execution=native-prompt-process-reference-reta-boundary" in owner
    assert "completion.run_reference_reta" in owner
    assert "execution.arguments.copy()" in owner
    assert "plan_interactive_reference_reta_process_execution" in controller
    assert "reference_reta_execution.should_run_reference_reta" in controller
    assert "reference_reta_execution.arguments" in controller
    assert "if external_completion.run_reference_reta" not in controller
    assert "external_execution.arguments, reference_root()" not in controller
    assert "test_interactive_reference_reta_execution_is_planned_by_process_execution_owner" in mojo_test
    assert "assert_equal(len(process_snapshot), 25)" in mojo_test
    assert "assert_equal(len(scope), 43)" in legacy_test
    assert "interactive_reference_reta_execution=native-prompt-process-reference-reta-boundary" in legacy_test
    assert "Reference-reta" in matrix or "reference reta" in matrix


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EM_PROMPT_PROCESS_INTERACTIVE_REFERENCE_RETA_EXECUTION.md").read_text(encoding="utf-8")
    assert "plan_interactive_reference_reta_process_execution" in doc
    assert "Reference-reta" in doc
    assert "12c5em" in doc
