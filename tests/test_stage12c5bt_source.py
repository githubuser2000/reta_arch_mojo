from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STAGE = ROOT / "scripts/test_stage12c5bt.sh"
DOC = ROOT / "STAGE12C5BT_INFORMATIONAL_PROMPT_COMPANION_EFFECTS.md"
CURRENT = ROOT / "scripts/test_current_stage.sh"


def test_stage_chains_from_bs_and_runs_focused_contracts() -> None:
    source = STAGE.read_text(encoding="utf-8")
    assert "test_stage12c5bs.sh" in source
    assert "check_prompt_companion_effects.py" in source
    assert "tests/test_prompt_historical_ownership.mojo" in source
    assert "tests/test_prompt_table_execution_regressions.mojo" in source
    assert "test_prompt_companion_effects_source.py" in source
    assert "test_prompt_table_execution_regressions_source.py" in source


def test_document_freezes_order_boundary_and_user_regressions() -> None:
    source = DOC.read_text(encoding="utf-8")
    assert "Kurzbefehle" in source
    assert "Befehle" in source
    assert "Hilfe" in source
    assert "Tabellenwirkung" in source
    assert "leeren" in source
    assert "0,1" in source
    assert "3-6" in source
    assert "492,1004,496,1008,500,1012,504,508" in source
    assert "MOJO-FIXED-070" in source
    assert "TEST-FIXED-067" in source
    assert "TEST-FIXED-068" in source
    assert "MOJO-FIXED-071" in source


def test_current_stage_points_to_bt() -> None:
    source = CURRENT.read_text(encoding="utf-8")
    assert "test_stage12c5bt.sh" in source
