from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dc_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_db_and_builds_prompt_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5dc.sh").read_text(encoding="utf-8")
    assert "test_stage12c5db.sh" in source
    assert "fallback profile argument expectation" in source
    assert "test_${test_name}_12c5dc" in source
    assert "tests/test_stage12c5dc_source.py" in source


def test_fallback_profile_arguments_match_rpe_profile() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert 'var profile = parse_prompt_startup("rpe", []).profile.copy()' in test
    assert "assert_equal(len(plan.arguments), 5)" in test
    assert 'assert_equal(plan.arguments[0], "-vi")' in test
    assert 'assert_equal(plan.arguments[1], "-e")' in test
    assert 'assert_equal(plan.arguments[2], "-befehl")' in test
    assert "assert_equal(len(plan.arguments), 2)" not in test


def test_runtime_profile_owner_explains_the_three_arguments() -> None:
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    body = runtime.split("def fallback_profile_arguments", 1)[1].split("\ndef emacs_wrapped_command", 1)[0]
    assert "if profile.vi_mode:" in body
    assert 'result.append("-vi")' in body
    assert "if profile.force_e_command:" in body
    assert 'result.append("-e")' in body
    assert 'result.append("-befehl")' in body


def test_previous_stage_guard_accepts_later_current_stage() -> None:
    source = (ROOT / "tests/test_stage12c5db_source.py").read_text(encoding="utf-8")
    assert "test_current_stage_points_to_db_or_later" in source
    assert 'assert "test_stage12c5" in current' in source
    assert 'assert "test_stage12c5db.sh" in current' not in source


def test_stage_document_records_expectation_fix() -> None:
    document = (ROOT / "STAGE12C5DC_FALLBACK_PROFILE_ARGUMENT_EXPECTATION.md").read_text(encoding="utf-8")
    assert "-vi -e -befehl" in document
    assert "PromptFallbackProcessDispatchPlan" in document
    assert "No process boundary is widened" in document
