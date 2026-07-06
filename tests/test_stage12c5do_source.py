from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_do() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5do.sh" in current


def test_stage_script_covers_prompt_reaction_storage_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5do.sh").read_text(encoding="utf-8")
    assert "prompt reaction storage owner" in source
    assert "test_${test_name}_12c5do" in source
    assert "tests/test_stage12c5do_source.py" in source
    assert "tests/test_stage12c5dn_source.py" in source


def test_prompt_reaction_storage_module_owns_shared_storage_plans() -> None:
    storage = (ROOT / "src/reta_mojo/prompt_reaction_storage.mojo").read_text(
        encoding="utf-8"
    )
    reaction = (ROOT / "src/reta_mojo/prompt_reaction_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    input_owner = (ROOT / "src/reta_mojo/prompt_reaction_input.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptInlineStoragePlan" in storage
    assert "struct PromptStorageOutputPlan" in storage
    assert "struct PromptStoredDefaultPlan" in storage
    assert "def plan_inline_storage_command(" in storage
    assert "def plan_inline_storage_output_command(" in storage
    assert "def plan_stored_default_command(" in storage
    assert "def prompt_reaction_storage_contract_snapshot()" in storage
    assert "struct PromptInlineStoragePlan" not in reaction
    assert "struct PromptStorageOutputPlan" not in reaction
    assert "struct PromptStoredDefaultPlan" not in reaction
    assert "def plan_inline_storage_command(" not in reaction
    assert "def plan_inline_storage_output_command(" not in reaction
    assert "def plan_stored_default_command(" not in reaction
    assert "from .prompt_reaction_storage import (" in reaction
    assert "from .prompt_reaction_storage import (" in input_owner


def test_storage_contract_is_split_from_input_and_dispatch_contracts() -> None:
    prompt_test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    legacy = (ROOT / "src/reta_mojo/legacy_reta_prompt.mojo").read_text(
        encoding="utf-8"
    )
    assert "from reta_mojo.prompt_reaction_storage import *" in prompt_test
    assert "var storage_snapshot = prompt_reaction_storage_contract_snapshot()" in prompt_test
    assert "assert_equal(len(storage_snapshot), 5)" in prompt_test
    assert "assert_equal(len(reaction_snapshot), 11)" in prompt_test
    assert "prompt_reaction_storage_contract_snapshot" in legacy
    assert "var reaction_storage = prompt_reaction_storage_contract_snapshot()" in legacy
    assert "for index in range(2, len(reaction_storage)):" in legacy


def test_storage_owner_has_no_process_or_reta_core_boundary() -> None:
    storage = (ROOT / "src/reta_mojo/prompt_reaction_storage.mojo").read_text(
        encoding="utf-8"
    )
    assert "prompt_process_dispatch" not in storage
    assert "prompt_external_commands" not in storage
    assert "run_reta" not in storage
    assert "reta_child" not in storage
    assert "PythonObject" not in storage
    assert "from std.python import" not in storage
    assert "shell_quote" not in storage


def test_document_records_storage_boundary_without_shared_lib_implementation() -> None:
    doc = (ROOT / "STAGE12C5DO_PROMPT_REACTION_STORAGE_OWNER.md").read_text(
        encoding="utf-8"
    )
    assert "libreta-prompt-reaction" in doc
    assert "prompt reaction storage" in doc
    assert "no `.so`/`.dll` split is implemented" in doc
