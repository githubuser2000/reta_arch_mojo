from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cq_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current


def test_stage_wraps_cp_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cq.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cp.sh" in source
    assert "external process kind elimination" in source
    assert "test_${test_name}_12c5cq" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_external_process_plan_no_longer_carries_kind_enum() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(encoding="utf-8")
    plan = owner.split("struct PromptExternalProcessDispatchPlan", 1)[1].split("@fieldwise_init", 1)[0]
    assert "var process_kind: Int" not in plan
    assert "EXTERNAL_PROMPT_" not in owner
    assert "var run_shell: Bool" in plan
    assert "var run_python: Bool" in plan
    assert "var run_math: Bool" in plan
    assert "var run_reta: Bool" in plan
    assert "external_process_kind=eliminated-from-external-process-plan" in owner


def test_process_controller_still_consumes_only_effect_flags() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "external_process.process_kind" not in controller
    assert "EXTERNAL_PROMPT_" not in controller
    assert "if external_process.run_shell" in controller
    assert "if external_process.run_python" in controller
    assert "if external_process.run_math" in controller
    assert "if external_process.run_reta" in controller


def test_prompt_interaction_regression_covers_kind_elimination() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert ".process_kind" not in test
    assert "EXTERNAL_PROMPT_" not in test
    assert '"external_process_kind=eliminated-from-external-process-plan"' in test
    assert "assert_equal(len(snapshot), 28)" in test or "assert_equal(len(snapshot), 29)" in test or "assert_equal(len(snapshot), 30)" in test
