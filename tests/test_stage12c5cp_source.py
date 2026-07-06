from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cp_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current


def test_stage_wraps_co_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cp.sh").read_text(encoding="utf-8")
    assert "test_stage12c5co.sh" in source
    assert "external process raw line elimination" in source
    assert "test_${test_name}_12c5cp" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_external_process_plan_no_longer_carries_raw_line() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(encoding="utf-8")
    plan = owner.split("struct PromptExternalProcessDispatchPlan", 1)[1].split("@fieldwise_init", 1)[0]
    assert "var raw: String" not in plan
    assert "var payload: String" in plan
    assert "var arguments: List[String]" in plan
    assert "external_raw_line=eliminated-from-external-process-plan" in owner


def test_process_controller_consumes_only_payloads_and_arguments() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "external_process.raw" not in controller
    assert "run_shell_prompt_payload_native(external_process.payload)" in controller
    assert "run_python_prompt_payload_native(external_process.payload)" in controller
    assert "run_math_prompt_payload_native(external_process.payload)" in controller
    assert "run_reta_arguments_native(\n                external_process.arguments, reference_root()" in controller


def test_prompt_interaction_regression_covers_raw_line_elimination() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "shell_plan.raw" not in test
    assert '"external_raw_line=eliminated-from-external-process-plan"' in test
    assert ("assert_equal(len(snapshot), 27)" in test or "assert_equal(len(snapshot), 28)" in test or "assert_equal(len(snapshot), 29)" in test or "assert_equal(len(snapshot), 30)" in test)


def test_source_guards_track_raw_line_elimination() -> None:
    source = (ROOT / "tests/test_prompt_interaction_source.py").read_text(encoding="utf-8")
    assert 'assert "var raw: String" not in owner' in source
    assert 'assert "external_process.raw" not in controller' in source
