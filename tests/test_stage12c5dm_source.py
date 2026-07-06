from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dm() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_script_covers_prompt_reaction_dispatch_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5dm.sh").read_text(encoding="utf-8")
    assert "prompt reaction dispatch owner" in source
    assert "test_${test_name}_12c5dm" in source
    assert "tests/test_stage12c5dm_source.py" in source
    assert "tests/test_stage12c5dl_source.py" in source


def test_prompt_reaction_dispatch_module_owns_local_effect_plans() -> None:
    reaction = (ROOT / "src/reta_mojo/prompt_reaction_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    interaction = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptLoopControlDispatchPlan" in reaction
    assert "struct PromptStoredCommandDispatchPlan" in reaction
    assert "struct PromptLoggingDispatchPlan" in reaction
    assert "struct PromptOneShotLoggingDispatchPlan" in reaction
    assert "struct PromptTerminalClearDispatchPlan" in reaction
    assert "struct PromptInformationalDispatchPlan" in reaction
    assert "struct PromptSimpleOutputDispatchPlan" in reaction
    assert "struct PromptStoredOutputExecutionPlan" in reaction
    assert "struct PromptStoredDeletePlan" in reaction
    assert "struct PromptStoredDefaultPlan" in reaction
    assert "def plan_inline_storage_command(" in reaction
    assert "def plan_inline_storage_output_command(" in reaction
    assert "def plan_loop_control_dispatch(" in reaction
    assert "def plan_stored_command_dispatch(" in reaction
    assert "def plan_simple_output_dispatch(" in reaction
    assert "def prompt_reaction_dispatch_contract_snapshot()" in reaction
    assert "struct PromptLoopControlDispatchPlan" not in interaction
    assert "struct PromptStoredCommandDispatchPlan" not in interaction
    assert "struct PromptSimpleOutputDispatchPlan" not in interaction
    assert "def plan_simple_output_dispatch(" not in interaction


def test_production_imports_reaction_dispatch_directly() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    interaction = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "from reta_mojo.prompt_reaction_dispatch import (" in controller
    assert "from .prompt_reaction_input import (" in interaction
    assert "from reta_mojo.prompt_reaction_dispatch import *" in test
    assert "var reaction_snapshot = prompt_reaction_dispatch_contract_snapshot()" in test
    assert "assert_equal(len(reaction_snapshot), 14)" in test


def test_reaction_owner_has_no_external_process_or_reta_core_boundary() -> None:
    reaction = (ROOT / "src/reta_mojo/prompt_reaction_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    assert "prompt_process_dispatch" not in reaction
    assert "prompt_external_commands" not in reaction
    assert "run_reta" not in reaction
    assert "reta_child" not in reaction
    assert "PythonObject" not in reaction
    assert "from std.python import" not in reaction
    assert "shell_quote" not in reaction


def test_document_records_library_boundary_without_implementing_shared_libs() -> None:
    doc = (ROOT / "STAGE12C5DM_PROMPT_REACTION_DISPATCH_OWNER.md").read_text(
        encoding="utf-8"
    )
    assert "libreta-prompt-reaction" in doc
    assert "libreta-prompt-execution" in doc
    assert "no `.so`/`.dll` split is implemented" in doc
