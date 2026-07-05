from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_stage_bp_remains_in_chain_but_is_marked_as_corrected() -> None:
    stage = _text("scripts/test_stage12c5bp.sh")
    document = _text("STAGE12C5BP_FRACTION_MULTIPLE_SCOPE.md")
    assert '"$ROOT/scripts/test_stage12c5bo.sh"' in stage
    assert "RETA_STAGE_SKIP_PREVIOUS" in stage
    assert "Korrigiert durch Stage 12c5bq" in document
    assert "Kompaktes Präfix-v ist kommalokal" not in document
    assert "v1/4,-1/8,2/3" in document
    assert "v 1/4,-1/8,2/3" in document
    assert "STAGE12C5BQ_POSITION_INDEPENDENT_MULTIPLE_SCOPE.md" in document


def test_bp_runner_uses_the_current_shared_fraction_checker() -> None:
    stage = _text("scripts/test_stage12c5bp.sh")
    assert "check_prompt_true_fraction_multiples.sh" in stage
    assert "tests/test_prompt_fraction_multiple_scope_source.py" in stage
