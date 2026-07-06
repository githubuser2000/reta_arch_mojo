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
    assert "struct PromptLoopControlDispatchPlan" in owner
    assert "def plan_loop_control_dispatch(" in owner
    assert "def plan_inline_storage_command(" in owner
    assert "def apply_inline_storage_command(" in owner
    assert "struct PromptStorageOutputPlan" in owner
    assert "def plan_inline_storage_output_command(" in owner
    assert "struct PromptStoredCommandDispatchPlan" in owner
    assert "def plan_stored_command_dispatch(" in owner
    assert "struct PromptLoggingDispatchPlan" in owner
    assert "def plan_logging_dispatch(" in owner
    assert "struct PromptOneShotLoggingDispatchPlan" in owner
    assert "def plan_one_shot_logging_dispatch(" in owner
    assert "struct PromptTerminalClearDispatchPlan" in owner
    assert "def plan_terminal_clear_dispatch(" in owner
    assert "struct PromptInformationalDispatchPlan" in owner
    assert "def plan_informational_dispatch(" in owner
    assert "struct PromptSimpleOutputDispatchPlan" in owner
    assert "def plan_simple_output_dispatch(" in owner
    assert "struct PromptExternalProcessDispatchPlan" in owner
    assert "var raw: String" not in owner
    assert "var process_kind: Int" not in owner
    assert "EXTERNAL_PROMPT_" not in owner
    assert "var payload: String" in owner
    assert "var arguments: List[String]" in owner
    assert "var run_shell: Bool" in owner
    assert "var run_python: Bool" in owner
    assert "var run_math: Bool" in owner
    assert "var run_reta: Bool" in owner
    assert "def _prompt_command_payload(" in owner
    assert "def _prompt_command_arguments(" in owner
    assert "def plan_external_process_dispatch(" in owner
    assert "struct PromptStoredOutputExecutionPlan" in owner
    assert "def plan_stored_output_command(" in owner
    assert "def plan_inline_stored_output_command(" in owner
    assert "struct PromptStoredDeletePlan" in owner
    assert "def plan_stored_delete_command(" in owner
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
    assert "plan_loop_control_dispatch(" in controller
    assert "plan_stored_command_dispatch(" in controller
    assert "plan_logging_dispatch(" in controller
    assert "plan_one_shot_logging_dispatch(" in controller
    assert "plan_terminal_clear_dispatch(" in controller
    assert "plan_informational_dispatch(" in controller
    assert "plan_simple_output_dispatch(" in controller
    assert "plan_external_process_dispatch(" in controller
    assert "plan_inline_stored_output_command(" in controller
    assert "plan_stored_output_command(" in controller
    assert "plan_stored_delete_command(" in controller
    assert "plan_inline_storage_output_command(" not in controller
    assert "prompt_interaction_one_shot_line(startup)" in controller
    assert "plan_stored_default_command(" not in controller

    # These lifecycle decisions used to be open-coded in the process entry
    # point.  Store-next/store-previous dispatch, physical input modes and
    # one-shot assembly now have one typed owner.
    assert "if session.store_next:" not in controller
    assert "if session.delete_next:" not in controller
    assert "if command.kind == KIND_STORE_NEXT" not in controller
    assert "if command.kind == KIND_STORE_PREVIOUS" not in controller
    assert "if command.kind == KIND_CLEAR" not in controller
    assert "if command.kind == KIND_EMPTY" not in controller
    assert "if command.kind == KIND_EXIT" not in controller
    assert "KIND_EMPTY," not in controller
    assert "KIND_EXIT," not in controller
    assert "KIND_LOG_ON," not in controller
    assert "KIND_LOG_OFF," not in controller
    assert "if command.kind == KIND_LOG_ON" not in controller
    assert "if command.kind == KIND_LOG_OFF" not in controller
    assert "if command.kind == KIND_SHELL" not in controller
    assert "if command.kind == KIND_PYTHON" not in controller
    assert "if command.kind == KIND_MATH" not in controller
    assert "KIND_SHELL," not in controller
    assert "KIND_PYTHON," not in controller
    assert "KIND_MATH," not in controller
    assert "KIND_RETA," not in controller
    assert "if command.kind != KIND_RETA" not in controller
    assert "if command.kind == KIND_RETA" not in controller
    assert "run_shell_prompt_payload_native(external_process.payload)" in controller
    assert "run_python_prompt_payload_native(external_process.payload)" in controller
    assert "run_math_prompt_payload_native(external_process.payload)" in controller
    assert "run_shell_prompt_line_native(external_process.raw)" not in controller
    assert "run_python_prompt_line_native(external_process.raw)" not in controller
    assert "run_math_prompt_line_native(external_process.raw)" not in controller
    assert "_run_native_reta_prompt_command(external_process.arguments)" in controller
    assert "run_reta_arguments_native(\n                external_process.arguments" in controller
    assert "run_reta_line_native(external_process.raw)" not in controller
    assert "external_process.raw" not in controller
    assert "external_process.process_kind == EXTERNAL_PROMPT" not in controller
    assert "external_process.process_kind" not in controller
    assert "EXTERNAL_PROMPT_SHELL," not in controller
    assert "EXTERNAL_PROMPT_PYTHON," not in controller
    assert "EXTERNAL_PROMPT_MATH," not in controller
    assert "EXTERNAL_PROMPT_RETA," not in controller
    assert "if external_process.run_shell" in controller
    assert "if external_process.run_python" in controller
    assert "if external_process.run_math" in controller
    assert "if external_process.run_reta" in controller
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
