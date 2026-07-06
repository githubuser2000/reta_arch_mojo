from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_el_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert ("test_stage12c5el.sh" in current or "test_stage12c5em.sh" in current)


def test_stage_script_chains_ek_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5el.sh").read_text(encoding="utf-8")
    assert "prompt process one-shot external execution owner" in script
    assert "test_stage12c5ek.sh" in script
    assert "test_${test_name}_12c5el" in script
    assert "tests/test_stage12c5el_source.py" in script
    assert "tests/test_stage12c5ek_source.py" in script


def test_one_shot_external_execution_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy_test = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    assert "struct PromptOneShotExternalExecutionPlan" in owner
    assert "def plan_one_shot_external_process_execution(" in owner
    assert "one_shot_external_execution=native-prompt-process-one-shot-execution-boundary" in owner
    assert "dispatch.arguments.copy()" in owner
    assert "plan_one_shot_external_process_execution" in controller
    assert "one_shot_external_execution.should_try_reta_native" in controller
    assert "one_shot_external_execution.arguments" in controller
    assert "if external_process.run_reta" not in controller
    assert "external_process.arguments" not in controller
    assert "test_one_shot_external_execution_is_planned_by_process_execution_owner" in mojo_test
    assert ("assert_equal(len(scope), 42)" in legacy_test or "assert_equal(len(scope), 43)" in legacy_test)
    assert "one_shot_external_execution=native-prompt-process-one-shot-execution-boundary" in legacy_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EL_PROMPT_PROCESS_ONE_SHOT_EXTERNAL_EXECUTION.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "plan_one_shot_external_process_execution" in doc
    assert "One-shot-External-Execution" in doc
    assert "One-shot-External-Execution" in matrix or "one-shot external execution" in matrix
