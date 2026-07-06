from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ce() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ce.sh" in current


def test_stage_wraps_cd_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5ce.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cd.sh" in source
    assert "bare logging dispatch ownership" in source
    assert "test_${test_name}_12c5ce" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_logging_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptLoggingDispatchPlan" in owner
    assert "def plan_logging_dispatch(" in owner
    assert "session.logging_enabled = True" in owner
    assert "session.logging_enabled = False" in owner
    assert '"Logging ist eingeschaltet."' in owner
    assert '"Logging ist ausgeschaltet."' in owner
    assert "logging_dispatch=native-session-logging-plan" in owner


def test_process_controller_delegates_interactive_logging_dispatch() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    interactive = controller.split("def _run_command(", 1)[1].split(
        "def _run_native_one_shot", 1
    )[0]
    assert "plan_logging_dispatch(command, session)" in interactive
    assert "var logging_dispatch = plan_logging_dispatch" in interactive
    assert "if command.kind == KIND_LOG_ON" not in interactive
    assert "if command.kind == KIND_LOG_OFF" not in interactive
    dispatch = interactive.split("var logging_dispatch = plan_logging_dispatch", 1)[1].split("var stored_output =", 1)[0]
    assert "session.logging_enabled = True" not in dispatch
    assert "session.logging_enabled = False" not in dispatch


def test_prompt_interaction_regression_covers_bare_logging_dispatch() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_logging_dispatch_is_planned_by_interaction_owner" in test
    assert "plan_logging_dispatch(" in test
    assert '"Logging ist eingeschaltet."' in test
    assert '"Logging ist ausgeschaltet."' in test
    assert "assert_equal(len(snapshot), 16)" in test
