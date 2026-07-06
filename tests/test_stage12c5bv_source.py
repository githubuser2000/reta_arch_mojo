from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_12c5bv() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bv.sh" in current


def test_stage_wraps_bu_and_runs_storage_and_table_regressions() -> None:
    source = (ROOT / "scripts/test_stage12c5bv.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bu.sh" in source
    assert "check_prompt_inline_storage_reference.py" in source
    assert "prompt_interaction table_adapters table_rendering" in source
    assert "test_${test_name}.mojo" in source
    assert "test_${test_name}_12c5bv" in source
    assert "check_prompt_compound_clear_native.py" in source


def test_stage_document_records_the_native_contract() -> None:
    text = (ROOT / "STAGE12C5BV_INLINE_STORAGE_AND_DETERMINISTIC_TABLE_TESTS.md").read_text(encoding="utf-8")
    assert "positionsunabhängige Speicherung" in text
    assert "Doppelte identische Aliase" in text
    assert "80 Spalten" in text
