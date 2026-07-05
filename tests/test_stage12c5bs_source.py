from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STAGE = ROOT / "scripts/test_stage12c5bs.sh"
DOC = ROOT / "STAGE12C5BS_POSITION_INDEPENDENT_PROMPT_EFFECTS.md"


def test_stage_chains_from_br_and_runs_reference_and_mojo_contracts() -> None:
    source = STAGE.read_text(encoding="utf-8")
    assert "test_stage12c5br.sh" in source
    assert "check_prompt_position_independent_effects.py" in source
    assert "tests/test_prompt_runtime.mojo" in source
    assert "tests/test_prompt_historical_ownership.mojo" in source
    assert "test_prompt_position_independent_effects_source.py" in source
    assert "test_prompt_historical_ownership_source.py" in source


def test_stage_document_freezes_effect_order_and_precedence() -> None:
    source = DOC.read_text(encoding="utf-8")
    assert "abc Haus" in source
    assert "Haus abc" in source
    assert "2/2" in source
    assert "4/4" in source
    assert "erst nach" in source
    assert "loggen" in source
    assert "nichtloggen" in source
    assert "MOJO-FIXED-069" in source
