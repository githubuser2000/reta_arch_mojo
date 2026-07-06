from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_bw_and_checks_storage_output_boundary() -> None:
    source = (ROOT / "scripts/test_stage12c5bx.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bw.sh" in source
    assert "check_prompt_storage_output_reference.py" in source
    assert "tests/test_prompt_interaction.mojo" in source
    assert "test_prompt_interaction_12c5bx" in source


def test_storage_output_position_plan_is_owned_by_prompt_interaction() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "struct PromptStorageOutputPlan" in owner
    assert "def plan_inline_storage_output_command(" in owner
    assert "KIND_OUTPUT_STORED" in owner
    assert "len(distinct_payload_tokens) <= 1" in owner
    assert "plan_inline_storage_output_command(tokens, language, catalog).handled" in owner
    assert "storage_output=native-position-independent-addition-policy" in owner
    assert "def plan_inline_stored_output_command(" in owner
    assert "var inline_output = plan_inline_storage_output_command(" in owner
    assert "var inline_output = plan_inline_stored_output_command" in controller
    assert "stored += \" \" + inline_output.payload" not in controller
    assert "plan_inline_storage_output_command(" not in controller
    assert "plan_inline_stored_output_command(" in controller


def test_python_bug_and_stage_document_are_registered() -> None:
    text = (
        ROOT / "STAGE12C5BX_NATIVE_STORAGE_OUTPUT_OWNERSHIP.md"
    ).read_text(encoding="utf-8")
    assert "PY-OPEN-007" in text
    assert "TypeError" in text
    ledger = (ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8")
    assert '"id": "PY-OPEN-007"' in ledger
    assert "prompt_storage_output_list_string_type_error" in ledger
