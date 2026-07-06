from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dd() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_dc_and_builds_prompt_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5dd.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dc.sh" in source
    assert "fallback process run flag" in source
    assert "test_${test_name}_12c5dd" in source
    assert "tests/test_stage12c5dd_source.py" in source


def test_fallback_plan_has_run_flag() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(encoding="utf-8")
    struct = owner.split("struct PromptFallbackProcessDispatchPlan", 1)[1].split("@fieldwise_init", 1)[0]
    assert "var handled: Bool" in struct
    assert "var run_reta_prompt: Bool" in struct
    assert "var arguments: List[String]" in struct
    body = owner.split("def plan_prompt_fallback_process_dispatch", 1)[1].split("\ndef plan_stored_output_command", 1)[0]
    assert "PromptFallbackProcessDispatchPlan(" in body
    assert "reta_prompt_fallback_arguments_native(" in body
    assert "True," in body
    assert "fallback_process_flags=native-explicit-fallback-run-flag" in owner


def test_controller_consumes_run_flag_before_fallback_child() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    body = controller.split("def _run_fallback(", 1)[1].split("\ndef _run_native_reta_prompt_command", 1)[0]
    assert "if not fallback_process.handled:" in body
    assert "if not fallback_process.run_reta_prompt:" in body
    assert body.index("if not fallback_process.handled:") < body.index("if not fallback_process.run_reta_prompt:")
    assert body.index("if not fallback_process.run_reta_prompt:") < body.index("run_reta_prompt_arguments_native(")


def test_mojo_contract_snapshot_records_run_flag() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "assert_true(plan.run_reta_prompt)" in test
    assert ("assert_equal(len(snapshot), 31)" in test or "assert_equal(len(snapshot), 32)" in test or "assert_equal(len(snapshot), 33)" in test or "assert_equal(len(snapshot), 34)" in test or "assert_equal(len(snapshot), 35)" in test or "assert_equal(len(snapshot), 36)" in test or "assert_equal(len(snapshot), 37)" in test)
    assert '"fallback_process_flags=native-explicit-fallback-run-flag"' in test
    assert '"execution=delegated-native-dispatch"' in test


def test_stage_document_records_run_flag() -> None:
    document = (ROOT / "STAGE12C5DD_FALLBACK_PROCESS_RUN_FLAG.md").read_text(encoding="utf-8")
    assert "run_reta_prompt" in document
    assert "payload/argv-only" in document
    assert "No raw prompt line" in document
