from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_bv_and_builds_the_interaction_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5bw.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bv.sh" in source
    assert "check_prompt_inline_storage_history_reference.py" in source
    assert "tests/test_prompt_interaction.mojo" in source
    assert "test_prompt_interaction_12c5bw" in source


def test_history_policy_is_owned_by_prompt_interaction() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "def prompt_line_updates_previous(" in owner
    assert "plan_inline_storage_command(tokens, language, catalog).handled" in owner
    assert "def record_prompt_line(" in owner
    assert "record_prompt_line(" in controller
    assert "record_prompt_command(interaction, line, executed.kind)" not in controller


def test_stage_document_and_defect_entry_exist() -> None:
    text = (
        ROOT / "STAGE12C5BW_INLINE_STORAGE_HISTORY_OWNERSHIP.md"
    ).read_text(encoding="utf-8")
    assert "vorherigen Befehl" in text
    assert "MOJO-FIXED-073" in text
    ledger = (ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8")
    assert '"id": "MOJO-FIXED-073"' in ledger
    assert '"id": "TEST-FIXED-070"' in ledger
