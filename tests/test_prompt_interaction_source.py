from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_prompt_interaction_has_a_dedicated_native_owner() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct NativePromptInteraction" in owner
    assert "struct PromptInteractionInputPlan" in owner
    assert "def new_prompt_interaction(" in owner
    assert "def accept_prompt_input(" in owner
    assert "def record_prompt_command(" in owner
    assert "def prompt_line_updates_previous(" in owner
    assert "def record_prompt_line(" in owner
    assert "struct PromptInlineStoragePlan" in owner
    assert "def plan_inline_storage_command(" in owner
    assert "def apply_inline_storage_command(" in owner
    assert "struct PromptStorageOutputPlan" in owner
    assert "def plan_inline_storage_output_command(" in owner
    assert "struct PromptStoredDefaultPlan" in owner
    assert "def plan_stored_default_command(" in owner
    assert "def prompt_interaction_contract_snapshot(" in owner
    assert "from std.python import" not in owner
    assert "PythonObject" not in owner


def test_production_prompt_activates_the_interaction_owner() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "from reta_mojo.prompt_interaction import" in controller
    assert "new_prompt_interaction(startup)" in controller
    assert "accept_prompt_input(" in controller
    assert "record_prompt_line(" in controller
    assert "record_prompt_command(" not in controller
    assert "apply_inline_storage_command(" in controller
    assert "plan_inline_storage_output_command(" in controller
    assert "prompt_interaction_one_shot_line(startup)" in controller
    assert "plan_stored_default_command(" not in controller

    # These lifecycle decisions used to be open-coded in the process entry
    # point.  Storage command dispatch remains there, but physical input modes
    # and one-shot assembly now have one typed owner.
    assert "if session.store_next:" not in controller
    assert "if session.delete_next:" not in controller
    assert "effective_one_shot_tokens" not in controller


def test_public_prompt_launchers_select_the_native_controller() -> None:
    launchers = (
        "retaPrompt",
        "retaPrompt.english",
        "rp",
        "rpl",
        "rpb",
        "rpe",
    )
    for launcher in launchers:
        source = (ROOT / "bin" / launcher).read_text(encoding="utf-8")
        assert "target/bin/reta-prompt-native" in source
        assert "src/prompt_main.mojo" in source
        assert "python_reference/retaPrompt.py" not in source


def test_prompt_interaction_is_recorded_in_the_porting_matrix_generator() -> None:
    generator = (ROOT / "tools/generate_porting_matrix.py").read_text(
        encoding="utf-8"
    )
    assert '"reta_architecture/prompt_interaction.py": ("nativ"' in generator
    assert '"retaPrompt.py": ("nativ"' in generator
    assert '"libs/LibRetaPrompt.py": ("nativ"' in generator
