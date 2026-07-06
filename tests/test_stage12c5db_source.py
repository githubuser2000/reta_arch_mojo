from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_db_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_da_and_builds_prompt_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5db.sh").read_text(encoding="utf-8")
    assert "test_stage12c5da.sh" in source
    assert "fallback process handled flag" in source
    assert "test_${test_name}_12c5db" in source
    assert "tests/test_stage12c5db_source.py" in source


def test_fallback_plan_has_explicit_handled_effect_flag() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(encoding="utf-8")
    struct = owner.split("struct PromptFallbackProcessDispatchPlan", 1)[1].split("@fieldwise_init", 1)[0]
    assert "var handled: Bool" in struct
    assert ("var run_reta_prompt: Bool" in struct or "fallback_process_flags=native-explicit-fallback-run-flag" not in owner)
    assert "var arguments: List[String]" in struct
    assert "var arguments: List[String]" in struct
    body = owner.split("def plan_prompt_fallback_process_dispatch", 1)[1].split("\ndef plan_stored_output_command", 1)[0]
    assert "PromptFallbackProcessDispatchPlan(" in body
    assert "reta_prompt_fallback_arguments_native(" in body
    assert "True," in body
    assert "fallback_process_handled=native-explicit-fallback-effect-flag" in owner


def test_controller_consumes_the_handled_flag_before_process_execution() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    body = controller.split("def _run_fallback(", 1)[1].split("\ndef _run_native_reta_prompt_command", 1)[0]
    assert "var fallback_process = plan_prompt_fallback_process_dispatch(profile, line)" in body
    assert "if not fallback_process.handled:" in body
    assert "run_reta_prompt_arguments_native(" in body
    assert body.index("if not fallback_process.handled:") < body.index("run_reta_prompt_arguments_native(")


def test_prompt_interaction_snapshot_and_runtime_test_cover_handled_flag() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "assert_true(plan.handled)" in test
    assert "assert_equal(len(plan.arguments), 5)" in test
    assert 'assert_equal(plan.arguments[0], "-vi")' in test
    assert 'assert_equal(plan.arguments[1], "-e")' in test
    assert 'assert_equal(plan.arguments[2], "-befehl")' in test
    assert ("assert_equal(len(snapshot), 30)" in test or "assert_equal(len(snapshot), 31)" in test or "assert_equal(len(snapshot), 32)" in test)
    assert '"fallback_process_handled=native-explicit-fallback-effect-flag"' in test
    assert (
        'assert_equal(snapshot[29], "execution=delegated-native-dispatch")' in test
        or 'assert_equal(snapshot[30], "execution=delegated-native-dispatch")' in test or 'assert_equal(snapshot[31], "execution=delegated-native-dispatch")' in test
    )


def test_stage_document_records_boundary_change() -> None:
    document = (ROOT / "STAGE12C5DB_FALLBACK_PROCESS_HANDLED_FLAG.md").read_text(encoding="utf-8")
    assert "PromptFallbackProcessDispatchPlan" in document
    assert "handled" in document
    assert "native-explicit-fallback-effect-flag" in document
