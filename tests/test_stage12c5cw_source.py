from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_cw_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_cv_and_runs_normalized_source_guards() -> None:
    source = (ROOT / "scripts/test_stage12c5cw.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cv.sh" in source
    assert "current stage source guard normalization" in source
    assert "tests/test_py_reta_truth_native_source.py" in source
    assert "tests/test_parallel_runtime_boundaries_source.py" in source
    assert "tests/test_stage12c5b*_source.py" in source
    assert "stage12c5cw current stage source guard normalization complete" in source


def test_historical_source_guards_no_longer_pin_moving_current_stage() -> None:
    stale = [
        "test_stage12c5bk.sh",
        "test_stage12c5bl.sh",
        "test_stage12c5bm.sh",
        "test_stage12c5bn.sh",
        "test_stage12c5bo.sh",
        "test_stage12c5bq.sh",
        "test_stage12c5bt.sh",
        "test_stage12c5bu.sh",
        "test_stage12c5cv.sh",
    ]
    for path in (ROOT / "tests").glob("test_*_source.py"):
        text = path.read_text(encoding="utf-8")
        for marker in stale:
            assert f'assert "{marker}" in current' not in text
            assert f"assert '{marker}' in current" not in text
    truth = (ROOT / "tests/test_py_reta_truth_native_source.py").read_text(
        encoding="utf-8"
    )
    assert 'assert "test_stage12c5" in current' in truth


def test_storage_output_guard_tracks_later_interaction_owner_split() -> None:
    source = (ROOT / "tests/test_stage12c5bx_source.py").read_text(
        encoding="utf-8"
    )
    assert 'assert "plan_inline_storage_output_command(" not in controller' in source
    assert 'assert "plan_inline_stored_output_command(" in controller' in source
    assert 'assert "var inline_output = plan_inline_storage_output_command(" in owner' in source


def test_stage_document_records_mutable_current_stage_policy() -> None:
    document = (ROOT / "STAGE12C5CW_CURRENT_STAGE_GUARD_NORMALIZATION.md").read_text(
        encoding="utf-8"
    )
    assert "test_current_stage.sh" in document
    assert "intentionally mutable" in document
    assert "historical chain" in document
