from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_targets_bp_and_chains_bo() -> None:
    current = _text("scripts/test_current_stage.sh")
    stage = _text("scripts/test_stage12c5bp.sh")
    assert "test_stage12c5bp.sh" in current
    assert '"$ROOT/scripts/test_stage12c5bo.sh"' in stage
    assert "RETA_STAGE_SKIP_PREVIOUS" in stage
    assert "check_prompt_true_fraction_multiples.sh" in stage
    assert "tests/test_prompt_fraction_multiple_scope_source.py" in stage


def test_stage_document_and_defect_record_the_parser_scope_fix() -> None:
    document = _text("STAGE12C5BP_FRACTION_MULTIPLE_SCOPE.md")
    defects = _text("KNOWN_DEFECTS.md")
    assert "v1/4,-1/8,2/3" in document
    assert "vielfache 1/4,-1/8,2/3" in document
    assert "19" in document
    assert "MOJO-FIXED-067" in defects
    assert "compact_v_fraction_scope_loss" in _text("KNOWN_DEFECTS.json")
