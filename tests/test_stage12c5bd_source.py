from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_chains_installed_launcher_and_fraction_runtime() -> None:
    current = _text("scripts/test_current_stage.sh")
    stage = _text("scripts/test_stage12c5bd.sh")
    assert "test_stage12c5bk.sh" in current
    assert '"$ROOT/scripts/test_stage12c5bc.sh"' in stage
    assert "tests/test_presheaves_complete.mojo" in stage
    assert "tests/test_prompt_reciprocal_collision_source.py" in stage


def test_stage_document_records_both_corrected_contracts() -> None:
    document = _text(
        "STAGE12C5BD_PRESHEAF_INHERITANCE_RECIPROCAL_COLLISION.md"
    )
    assert "16 explizite `cn-*`-CSV-Sektionen" in document
    assert "16 sprachneutrale CSV-Sektionen" in document
    assert "universum v1/4,-1/8,2/3" in document
    assert "13 native Tabellenaufrufe" in document
