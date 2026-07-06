from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_by_and_rebuilds_interaction_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5bz.sh").read_text(encoding="utf-8")
    assert "test_stage12c5by.sh" in source
    assert "stored prompt default enter ownership" in source
    assert "test_${test_name}_12c5bz" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt" in source


def test_stored_default_enter_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptStoredDefaultPlan" in owner
    assert "def plan_stored_default_command(" in owner
    assert "stored_prompt_text(session)" in owner
    assert "INTERACTION_EXECUTE, stored_default.command_line" in owner
    assert "stored_default=native-empty-enter-placeholder-policy" in owner


def test_prompt_interaction_mojo_regression_covers_empty_enter() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_empty_line_executes_stored_placeholder" in test
    assert "plan_stored_default_command(" in test
    assert "assert_equal(accepted.command_line, \"prim 60\")" in test
    assert "assert_equal(len(snapshot), 13)" in test
    assert "stored_default=native-empty-enter-placeholder-policy" in test
