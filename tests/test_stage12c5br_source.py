from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STAGE = ROOT / "scripts/test_stage12c5br.sh"
DOC = ROOT / "STAGE12C5BR_COMPLETE_PROMPT_OUTPUT_PARAMETERS.md"


def test_stage_chains_from_bq_and_runs_the_new_runtime_probe() -> None:
    source = STAGE.read_text(encoding="utf-8")
    assert "test_stage12c5bq.sh" in source
    assert "check_prompt_output_parameters.sh" in source
    assert "check_prompt_true_fraction_multiples.sh" in source
    assert "test_prompt_output_parameter_ownership_source.py" in source
    assert "test_architecture_probe_assets_source.py" in source
    assert "test_stage12c5bq_source.py" in source


def test_stage_document_states_complete_output_ownership_and_set_order() -> None:
    source = DOC.read_text(encoding="utf-8")
    assert "13/13" in source
    assert "65/65" in source
    assert "list(set(...))" in source
    assert "7/7" in source
    assert "MOJO-FIXED-068" in source
