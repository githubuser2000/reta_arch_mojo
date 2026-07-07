from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_es() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5es.sh" in current
    assert "test_stage12c5er.sh" in current


def test_stage_script_chains_er_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5es.sh").read_text(encoding="utf-8")
    assert "prompt process residual fallback result owner" in script
    assert "test_stage12c5er.sh" in script
    assert "test_${test_name}_12c5es" in script
    assert "tests/test_stage12c5es_source.py" in script
    assert "tests/test_stage12c5er_source.py" in script
    assert "stage12c5es prompt process residual fallback result owner complete" in script


def test_er_stage_marker_is_corrected() -> None:
    script = (ROOT / "scripts/test_stage12c5er.sh").read_text(encoding="utf-8")
    assert "stage12c5er prompt execution one-shot residual result owner complete" in script
    assert "stage12c5eq prompt execution one-shot residual result owner complete" not in script


def test_residual_fallback_result_is_process_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")

    assert "struct PromptResidualFallbackProcessResultPlan" in owner
    assert "def plan_prompt_residual_fallback_process_result(" in owner
    assert "residual_fallback_process_result=native-prompt-residual-fallback-result-boundary" in owner
    assert "plan_prompt_residual_fallback_process_result" in controller
    assert "return residual_result.handled" in controller
    active_controller = "\n".join(
        line for line in controller.splitlines()
        if not line.strip().startswith("#")
    )
    assert "return True\n\n\ndef _run_native_one_shot" not in active_controller
    assert "test_residual_fallback_process_result_is_planned_by_process_execution_owner" in mojo_test
    assert "residual_fallback_process_result" in legacy


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5ES_PROMPT_PROCESS_RESIDUAL_FALLBACK_RESULT.md").read_text(encoding="utf-8")
    assert "plan_prompt_residual_fallback_process_result" in doc
    assert "Residual-Fallback-Result" in doc
    assert "12c5es" in doc
