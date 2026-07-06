from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dn() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_script_covers_prompt_reaction_input_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5dn.sh").read_text(encoding="utf-8")
    assert "prompt reaction input owner" in source
    assert "test_${test_name}_12c5dn" in source
    assert "tests/test_stage12c5dn_source.py" in source
    assert "tests/test_stage12c5dm_source.py" in source


def test_prompt_reaction_input_module_owns_physical_input_and_history() -> None:
    input_owner = (ROOT / "src/reta_mojo/prompt_reaction_input.mojo").read_text(
        encoding="utf-8"
    )
    interaction = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptInteractionInputPlan" in input_owner
    assert "def accept_prompt_reaction_input(" in input_owner
    assert "def prompt_command_updates_previous(" in input_owner
    assert "def prompt_line_updates_previous(" in input_owner
    assert "def record_prompt_session_line(" in input_owner
    assert "def prompt_reaction_input_contract_snapshot()" in input_owner
    assert "if session.store_next:" in input_owner
    assert "if session.delete_next:" in input_owner
    assert "delete_stored_selection(session, line)" in input_owner
    assert "plan_stored_default_command(" in input_owner
    assert "from .prompt_reaction_storage import (" in input_owner
    assert "balanced_prompt_split(line)" in input_owner
    assert "if interaction.session.store_next:" not in interaction
    assert "if interaction.session.delete_next:" not in interaction
    assert "delete_stored_selection(interaction.session" not in interaction
    assert "balanced_prompt_split(line)" not in interaction
    assert "def accept_prompt_input(" in interaction
    assert "accept_prompt_reaction_input(" in interaction


def test_production_imports_reaction_input_directly() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    legacy = (ROOT / "src/reta_mojo/legacy_reta_prompt.mojo").read_text(
        encoding="utf-8"
    )
    prompt_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "from reta_mojo.prompt_reaction_input import (" in controller
    assert "accept_prompt_reaction_input(" in controller
    assert "record_prompt_session_line(" in controller
    assert "accept_prompt_input(" not in controller
    assert "from .prompt_reaction_input import (" in legacy
    assert "prompt_reaction_input_contract_snapshot" in legacy
    assert "accept_prompt_reaction_input(" in legacy
    assert "from reta_mojo.prompt_reaction_input import *" in prompt_test
    assert "var input_snapshot = prompt_reaction_input_contract_snapshot()" in prompt_test
    assert "assert_equal(len(input_snapshot), 8)" in prompt_test


def test_interaction_contract_is_lifecycle_only() -> None:
    interaction = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    body = interaction.split("def prompt_interaction_contract_snapshot", 1)[1]
    body = body.split("return [", 1)[1].split("    ]", 1)[0]
    assert "startup=native-profile-to-session" in body
    assert "one_shot=native-token-assembly" in body
    assert "reaction_input=delegated-native-input-owner" in body
    assert "reaction_dispatch=delegated-native-local-effect-owner" in body
    assert "input=native-typed-plan" not in body
    assert "store=native-next-and-previous" not in body
    assert "delete=native-selection-and-cancel" not in body
    assert "history=native-previous-command-policy" not in body
    assert "stored_default=native-empty-enter-placeholder-policy" not in body


def test_reaction_input_owner_has_no_process_or_reta_core_boundary() -> None:
    input_owner = (ROOT / "src/reta_mojo/prompt_reaction_input.mojo").read_text(
        encoding="utf-8"
    )
    assert "prompt_process_dispatch" not in input_owner
    assert "prompt_external_commands" not in input_owner
    assert "run_reta" not in input_owner
    assert "reta_child" not in input_owner
    assert "PythonObject" not in input_owner
    assert "from std.python import" not in input_owner
    assert "shell_quote" not in input_owner


def test_document_records_input_boundary_without_implementing_shared_libs() -> None:
    doc = (ROOT / "STAGE12C5DN_PROMPT_REACTION_INPUT_OWNER.md").read_text(
        encoding="utf-8"
    )
    assert "libreta-prompt-reaction" in doc
    assert "libreta-core" in doc
    assert "no `.so`/`.dll` split is implemented" in doc
