from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_eo() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5eo.sh" in current


def test_stage_script_chains_en_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5eo.sh").read_text(encoding="utf-8")
    assert "prompt process compatibility fallback execution owner" in script
    assert "test_stage12c5en.sh" in script
    assert "test_${test_name}_12c5eo" in script
    assert "tests/test_stage12c5eo_source.py" in script
    assert "tests/test_stage12c5en_source.py" in script


def test_compatibility_fallback_execution_is_process_dispatch_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy_test = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "struct PromptCompatibilityFallbackProcessExecutionPlan" in owner
    assert "def plan_prompt_compatibility_fallback_process_execution(" in owner
    assert "compatibility_fallback_process_execution=native-prompt-compatibility-fallback-execution-boundary" in owner
    assert "PromptExecutionCompatibilityFallbackPlan" in owner
    assert "plan_prompt_fallback_process_dispatch(" in owner
    assert "plan_prompt_fallback_process_execution(dispatch)" in owner
    assert "plan_prompt_compatibility_fallback_process_execution" in controller
    assert "compatibility_execution.should_execute" in controller
    assert "compatibility_execution.arguments" in controller
    assert "test_compatibility_fallback_process_execution_is_planned_by_process_execution_owner" in mojo_test
    assert "assert_equal(len(process_snapshot), 27)" in mojo_test
    assert "assert_equal(len(scope), 46)" in legacy_test
    assert "compatibility_fallback_process_execution=native-prompt-compatibility-fallback-execution-boundary" in legacy_test
    assert "Compatibility-Fallback" in matrix or "compatibility fallback" in matrix


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EO_PROMPT_PROCESS_COMPATIBILITY_FALLBACK_EXECUTION.md").read_text(encoding="utf-8")
    assert "plan_prompt_compatibility_fallback_process_execution" in doc
    assert "Compatibility-Fallback" in doc
    assert "12c5eo" in doc
