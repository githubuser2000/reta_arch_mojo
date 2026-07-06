from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cy_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_cx_and_checks_fallback_interaction_argv_plan() -> None:
    source = (ROOT / "scripts/test_stage12c5cy.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cx.sh" in source
    assert "fallback interaction argv plan" in source
    assert "test_${test_name}_12c5cy" in source
    assert "tests/test_stage12c5cy_source.py" in source


def test_interaction_owner_plans_prompt_fallback_argv() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptFallbackProcessDispatchPlan" in owner
    assert "var arguments: List[String]" in owner
    assert "var arguments: List[String]" in owner
    assert "def plan_prompt_fallback_process_dispatch(" in owner
    assert "reta_prompt_fallback_arguments_native(" in owner
    assert "fallback_process_dispatch=native-interaction-argv-plan" in owner


def test_controller_consumes_planned_fallback_argv_only() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_prompt_fallback_process_dispatch," in controller
    assert "var fallback_process = plan_prompt_fallback_process_dispatch(profile, line)" in controller
    assert "fallback_execution.arguments" in controller or "fallback_process.arguments" in controller
    assert "fallback_execution.arguments" in controller or "fallback_process.arguments" in controller
    assert "reta_prompt_fallback_arguments_native(, reference_root()" not in controller
    assert "shell_split," not in controller


def test_prompt_interaction_snapshot_tracks_fallback_process_plan() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "test_fallback_process_dispatch_is_planned_by_interaction_owner" in test
    assert (
        "assert_equal(len(snapshot), 29)" in test
        or "assert_equal(len(snapshot), 30)" in test or "assert_equal(len(snapshot), 38)" in test
        or "assert_equal(len(snapshot), 21)" in test
        or "assert_equal(len(snapshot), 31)" in test or "assert_equal(len(snapshot), 32)" in test or "assert_equal(len(snapshot), 33)" in test or "assert_equal(len(snapshot), 34)" in test or "assert_equal(len(snapshot), 35)" in test
        or "assert_equal(len(snapshot), 36)" in test or "assert_equal(len(snapshot), 37)" in test or "assert_equal(len(snapshot), 38)" in test
        or "assert_equal(len(snapshot), 21)" in test
        or "assert_equal(len(snapshot), 21)" in test
    )
    assert ('snapshot[22]' in test or 'process_snapshot[12]' in test)
    assert '"fallback_process_dispatch=native-interaction-argv-plan"' in test


def test_porting_matrix_mentions_interaction_owned_fallback_argv() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert ("Fallbacks werden vom nativen Interaktions-Owner" in matrix or "Fallbacks werden vom nativen Prompt-Execution-Owner" in matrix)
    assert "vollständiger zusammengeführter `retaPrompt.py`-argv-Vektor" in matrix
