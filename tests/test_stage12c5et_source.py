from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_et() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5et.sh" in current
    assert "test_stage12c5es.sh" in current


def test_stage_script_chains_es_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5et.sh").read_text(encoding="utf-8")
    assert "prompt process compatibility fallback result owner" in script
    assert "test_stage12c5es.sh" in script
    assert "test_${test_name}_12c5et" in script
    assert "tests/test_stage12c5et_source.py" in script
    assert "tests/test_stage12c5es_source.py" in script
    assert "stage12c5et prompt process compatibility fallback result owner complete" in script


def test_compatibility_fallback_result_is_process_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    legacy = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")

    assert "struct PromptCompatibilityFallbackProcessResultPlan" in owner
    assert "def plan_prompt_compatibility_fallback_process_result(" in owner
    assert "compatibility_fallback_process_result=native-prompt-compatibility-fallback-result-boundary" in owner
    assert "plan_prompt_compatibility_fallback_process_result" in controller
    assert "if compatibility_result.handled:" in controller
    active_controller = "\n".join(
        line for line in controller.splitlines()
        if not line.strip().startswith("#")
    )
    assert "compatibility_execution.arguments, reference_root()\n        )\n        return True" not in active_controller
    assert "test_compatibility_fallback_process_result_is_planned_by_process_execution_owner" in mojo_test
    assert "compatibility_fallback_process_result" in legacy
    assert "Compatibility-Fallback-Result" in matrix or "compatibility fallback result" in matrix


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5ET_PROMPT_PROCESS_COMPATIBILITY_FALLBACK_RESULT.md").read_text(encoding="utf-8")
    assert "plan_prompt_compatibility_fallback_process_result" in doc
    assert "Compatibility-Fallback-Result" in doc
    assert "12c5et" in doc
