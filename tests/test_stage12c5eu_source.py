from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_eu() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5eu.sh" in current
    assert "test_stage12c5et.sh" in current


def test_stage_script_chains_et_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5eu.sh").read_text(encoding="utf-8")
    assert "prompt process explicit fallback result owner" in script
    assert "test_stage12c5et.sh" in script
    assert "test_${test_name}_12c5eu" in script
    assert "tests/test_stage12c5eu_source.py" in script
    assert "tests/test_stage12c5et_source.py" in script
    assert "stage12c5eu prompt process explicit fallback result owner complete" in script


def test_explicit_fallback_result_is_process_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")

    assert "struct PromptFallbackProcessResultPlan" in owner
    assert "def plan_prompt_fallback_process_result(" in owner
    assert "fallback_process_result=native-prompt-fallback-result-boundary" in owner
    assert "plan_prompt_fallback_process_result" in controller
    fallback_body = controller.split("def _run_fallback(", 1)[1].split("\ndef _run_native_reta_prompt_command", 1)[0]
    active_fallback = "\n".join(
        line for line in fallback_body.splitlines()
        if not line.strip().startswith("#")
    )
    assert "if not fallback_execution.should_execute:" not in active_fallback
    assert "fallback_result.process_executed" in active_fallback
    assert "test_fallback_process_result_is_planned_by_process_execution_owner" in mojo_test
    assert "fallback_process_result" in legacy
    assert "Fallback-Result" in matrix or "fallback result" in matrix


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EU_PROMPT_PROCESS_EXPLICIT_FALLBACK_RESULT.md").read_text(encoding="utf-8")
    assert "plan_prompt_fallback_process_result" in doc
    assert "Fallback-Result" in doc
    assert "12c5eu" in doc
