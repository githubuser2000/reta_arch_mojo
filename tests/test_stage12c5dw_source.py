from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dw() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dw.sh" in current or "test_stage12c5dx.sh" in current or "test_stage12c5dy.sh" in current


def test_stage_script_covers_compact_announcement_regression() -> None:
    source = (ROOT / "scripts/test_stage12c5dw.sh").read_text(encoding="utf-8")
    assert "prompt execution compact announcement regression fix" in source
    assert "test_stage12c5dv.sh" in source
    assert "test_${test_name}_12c5dw" in source
    assert "tests/test_stage12c5dw_source.py" in source
    assert "tests/test_stage12c5dv_source.py" in source


def test_compact_announcement_tests_match_runtime_quiet_contract() -> None:
    test_source = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert 'plan_prompt_execution_routing("a1", "deutsch", catalog)' in test_source
    assert 'assert_true(_has_token(announcement.visible_tokens, "absicht"))' in test_source
    assert 'assert_true("ergibt sich aus \'a1\'" in announcement.line)' in test_source
    assert 'var quiet_routing = plan_prompt_execution_routing("15", "deutsch", catalog)' in test_source
    assert 'assert_true(quiet_routing.quiet_echo)' in test_source
    assert 'assert_false(hidden.should_print)' in test_source


def test_compact_announcement_plan_keeps_numeric_quiet_suppression() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    assert "def plan_prompt_execution_compact_announcement(" in owner
    assert "if not routing.compact_expansion.compact or routing.quiet_echo:" in owner
    assert "PromptExecutionCompactAnnouncementPlan(" in owner
