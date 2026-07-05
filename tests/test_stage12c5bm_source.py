from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "STAGE12C5BM_MULTI_DOMAIN_PROPERTY_NUMERIC_AXES.md"


def test_current_stage_extends_bl_and_forwards_compiler_options() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5bm.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bm.sh" in current
    assert 'test_stage12c5bl.sh" -- "$@"' in stage
    assert 'check_prompt_true_fraction_multiples.sh" -- "$@"' in stage
    assert "check_prompt_multi_domain_extensions_reference.py" in stage
    assert "mojo_validate_build_options" in stage


def test_stage_document_freezes_owned_and_atomic_boundaries() -> None:
    document = DOC.read_text(encoding="utf-8")
    assert "EIGN/EIGR" in document
    assert "16 vor 15" in document
    assert "27 Aufrufe" in document
    assert "28 Aufrufe" in document
    assert "klassischen Ganzzahlfamilie" in document
    assert "atomarer Fallback" in document


def test_stage_runs_new_source_contract_and_ledgers() -> None:
    stage = (ROOT / "scripts/test_stage12c5bm.sh").read_text(encoding="utf-8")
    assert "tests/test_prompt_multi_domain_extensions_source.py" in stage
    assert "tests/test_stage12c5bm_source.py" in stage
    assert "tools/check_known_defects.py" in stage
    assert "tools/porting_metrics.py" in stage
