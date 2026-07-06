from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "STAGE12C5BN_COMBINED_OUTER_AXES.md"


def test_current_stage_extends_bm_and_forwards_compiler_options() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5bn.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert 'test_stage12c5bm.sh" -- "$@"' in stage
    assert 'check_prompt_true_fraction_multiples.sh" -- "$@"' in stage
    assert "check_prompt_combined_outer_order_reference.py" in stage
    assert "mojo_validate_build_options" in stage


def test_stage_document_records_complete_order_and_corrected_rectangles() -> None:
    document = DOC.read_text(encoding="utf-8")
    assert "Thomas" in document
    assert "EIGN vor EIGR" in document
    assert "Familie 16" in document
    assert "Familie 15" in document
    assert "34 Aufrufe" in document
    assert "35 Aufrufe" in document
    assert "fehlerhafte historische gemeinsame n/m-Rechteck" in document


def test_stage_runs_new_source_contract_and_ledgers() -> None:
    stage = (ROOT / "scripts/test_stage12c5bn.sh").read_text(encoding="utf-8")
    assert "tests/test_prompt_combined_outer_order_source.py" in stage
    assert "tests/test_stage12c5bn_source.py" in stage
    assert "tools/check_known_defects.py" in stage
    assert "tools/porting_metrics.py" in stage
