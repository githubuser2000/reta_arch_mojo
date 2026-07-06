from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_chains_the_complete_previous_runtime_gate() -> None:
    current = _text("scripts/test_current_stage.sh")
    newest = _text("scripts/test_stage12c5bd.sh")
    installed_stage = _text("scripts/test_stage12c5bc.sh")
    stage = _text("scripts/test_stage12c5bb.sh")
    assert "test_stage12c5" in current
    assert '"$ROOT/scripts/test_stage12c5bc.sh"' in newest
    assert '"$ROOT/scripts/test_stage12c5bb.sh"' in installed_stage
    assert '"$ROOT/scripts/test_stage12c5ba.sh"' in stage
    assert "tests/test_prompt_positive_first_fraction_multiple_source.py" in stage
    assert "tests/test_prompt_mixed_fraction_multiple_source.py" in stage


def test_positive_first_owner_is_narrow_and_order_sensitive() -> None:
    source = _text("src/reta_mojo/prompt_table_execution.mojo")
    assert "def _positive_reciprocal_multiple_with_excluded_true_fractions(" in source
    assert "if pair.numerator == 1:" in source
    assert "if pair.numerator != 1 or not pair.multiple:" in source
    assert "has_positive_reciprocal_multiple and has_excluded_true_fraction" in source
    assert "if _positive_reciprocal_multiple_with_excluded_true_fractions(pairs):" in source


def test_stage_document_records_owned_and_deliberately_unowned_variants() -> None:
    document = _text(
        "STAGE12C5BB_POSITIVE_RECIPROCAL_EXCLUDED_TRUE_FRACTIONS.md"
    )
    assert "universum v1/4,-2/3" in document
    assert "universum v1/2,-2/3" in document
    assert "emotion v1/4,-2/3" in document
    assert "universum v1/4,-2/3 teiler" in document
    assert "universum v1/4,-1/8,2/3" in document
    assert "atomarer Fallback" in document
