from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_cb_and_rebuilds_table_adapter_boundary() -> None:
    source = (ROOT / "scripts/test_stage12c5cc.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cb.sh" in source
    assert "table adapter counting parity boundary" in source
    assert "test_${test_name}_12c5cc" in source
    assert "for test_name in table_adapters prompt_interaction legacy_reta_prompt" in source


def test_adapter_counting_contract_no_longer_uses_row_zero_sentinel() -> None:
    test = (ROOT / "tests/test_table_adapters.mojo").read_text(encoding="utf-8")
    assert "assert_equal(zeileWhichZaehlung(state, 1), 1)" in test
    assert "assert_equal(zeileWhichZaehlung(state, 4), 1)" in test
    assert "assert_equal(zeileWhichZaehlung(state, 5), 2)" in test
    assert "assert_equal(zeileWhichZaehlung(state, 1), 0)" not in test


def test_stage_document_records_the_broad_suite_regression() -> None:
    doc = (ROOT / "STAGE12C5CC_TABLE_ADAPTER_COUNTING_PARITY.md").read_text(
        encoding="utf-8"
    )
    assert "test_table_adapters.mojo" in doc
    assert "left: 1" in doc
    assert "right: 0" in doc
    assert "rows 1-4" in doc
