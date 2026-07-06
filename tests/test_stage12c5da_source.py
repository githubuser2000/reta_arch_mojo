from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_da() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5da.sh" in current


def test_stage_wraps_cz_and_builds_prompt_interaction() -> None:
    source = (ROOT / "scripts/test_stage12c5da.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cz.sh" in source
    assert "prompt profile explicit copy" in source
    assert "test_${test_name}_12c5da" in source
    assert "tests/test_stage12c5da_source.py" in source


def test_prompt_interaction_uses_explicit_profile_copy() -> None:
    source = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert 'parse_prompt_startup("rpe", []).profile.copy()' in source
    assert 'parse_prompt_startup("rpe", []).profile\n' not in source
    assert "test_fallback_process_dispatch_is_planned_by_interaction_owner" in source


def test_previous_current_stage_guard_allows_later_stages() -> None:
    source = (ROOT / "tests/test_stage12c5cz_source.py").read_text(
        encoding="utf-8"
    )
    assert "test_current_stage_points_to_cz_or_later" in source
    assert 'assert "test_stage12c5" in current' in source
    assert 'assert "test_stage12c5cz.sh" in current' not in source


def test_stage_document_records_no_runtime_boundary_change() -> None:
    document = (ROOT / "STAGE12C5DA_PROMPT_PROFILE_EXPLICIT_COPY.md").read_text(
        encoding="utf-8"
    )
    assert "PromptProfile" in document
    assert "not `ImplicitlyCopyable`" in document
    assert "interaction owner plans fallback process argv" in document
