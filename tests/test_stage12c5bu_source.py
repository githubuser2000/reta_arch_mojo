from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STAGE = ROOT / "scripts/test_stage12c5bu.sh"
DOC = ROOT / "STAGE12C5BU_NATIVE_COMPOUND_CLEAR.md"
CURRENT = ROOT / "scripts/test_current_stage.sh"


def test_stage_chains_from_bt_and_runs_native_clear_contracts() -> None:
    source = STAGE.read_text(encoding="utf-8")
    assert "test_stage12c5" in source
    assert "check_prompt_companion_effects.py" in source
    assert "tests/test_prompt_historical_ownership.mojo" in source
    assert "tests/test_terminal_geometry.mojo" in source
    assert "check_prompt_compound_clear_native.py" in source
    assert 'RETA_PROMPT_NATIVE="$PROMPT"' in source


def test_document_freezes_rows_plus_one_standalone_distinction_and_test_fix() -> None:
    source = DOC.read_text(encoding="utf-8")
    assert "os.get_terminal_size().lines + 1" in source
    assert "LINES=3" in source
    assert "vier führende Leerzeilen" in source
    assert "ESC[2J ESC[H" in source
    assert "assert_true(first == second)" in source
    assert "MOJO-FIXED-072" in source
    assert "TEST-FIXED-069" in source


def test_current_stage_points_to_bu() -> None:
    source = CURRENT.read_text(encoding="utf-8")
    assert "test_stage12c5" in source
