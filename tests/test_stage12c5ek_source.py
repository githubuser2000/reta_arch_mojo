from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ek() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ek.sh" in current
    assert "test_stage12c5ej.sh" in current
    assert "test_stage12c5ei.sh" in current
    assert "test_stage12c5eh.sh" in current
    assert "test_stage12c5eg.sh" in current


def test_stage_script_chains_ej_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ek.sh").read_text(encoding="utf-8")
    assert "prompt process interactive external execution owner" in script
    assert "test_stage12c5ej.sh" in script
    assert "test_${test_name}_12c5ek" in script
    assert "tests/test_stage12c5ek_source.py" in script
    assert "tests/test_stage12c5ej_source.py" in script


def test_interactive_external_execution_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy_test = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    assert "struct PromptInteractiveExternalExecutionPlan" in owner
    assert "def plan_interactive_external_process_execution(" in owner
    assert "interactive_external_execution=native-prompt-process-execution-boundary" in owner
    assert "dispatch.arguments.copy()" in owner
    assert "plan_interactive_external_process_execution" in controller
    assert "external_execution.should_run_shell" in controller
    assert "external_execution.should_run_python" in controller
    assert "external_execution.should_run_math" in controller
    assert "external_execution.should_run_reta" in controller
    assert "if external_process.run_shell" not in controller
    assert "if external_process.run_python" not in controller
    assert "if external_process.run_math" not in controller
    assert "test_interactive_external_execution_is_planned_by_process_execution_owner" in mojo_test
    assert ("assert_equal(len(scope), 41)" in legacy_test or "assert_equal(len(scope), 42)" in legacy_test)
    assert "interactive_external_execution=native-prompt-process-execution-boundary" in legacy_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EK_PROMPT_PROCESS_INTERACTIVE_EXTERNAL_EXECUTION.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "plan_interactive_external_process_execution" in doc
    assert "Interactive-External-Execution" in doc
    assert "Interactive-External-Execution" in matrix or "interactive external execution" in matrix
