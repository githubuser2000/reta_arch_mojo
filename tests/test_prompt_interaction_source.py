from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_prompt_interaction_has_a_dedicated_native_owner() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    reaction_owner = (ROOT / "src/reta_mojo/prompt_reaction_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    storage_owner = (ROOT / "src/reta_mojo/prompt_reaction_storage.mojo").read_text(
        encoding="utf-8"
    )
    input_owner = (ROOT / "src/reta_mojo/prompt_reaction_input.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct NativePromptInteraction" in owner
    assert "struct PromptInteractionInputPlan" in input_owner
    assert "def new_prompt_interaction(" in owner
    assert "def accept_prompt_input(" in owner
    assert "accept_prompt_reaction_input(" in owner
    assert "def accept_prompt_reaction_input(" in input_owner
    assert "def record_prompt_command(" in owner
    assert "def prompt_line_updates_previous(" in input_owner
    assert "def record_prompt_line(" in owner
    assert "struct PromptInlineStoragePlan" in storage_owner
    assert "struct PromptLoopControlDispatchPlan" in reaction_owner
    assert "def plan_loop_control_dispatch(" in reaction_owner
    assert "def plan_inline_storage_command(" in storage_owner
    assert "def apply_inline_storage_command(" in storage_owner
    assert "struct PromptStorageOutputPlan" in storage_owner
    assert "def plan_inline_storage_output_command(" in storage_owner
    assert "struct PromptStoredCommandDispatchPlan" in storage_owner
    assert "def plan_stored_command_dispatch(" in storage_owner
    assert "struct PromptLoggingDispatchPlan" in reaction_owner
    assert "def plan_logging_dispatch(" in reaction_owner
    assert "struct PromptOneShotLoggingDispatchPlan" in reaction_owner
    assert "def plan_one_shot_logging_dispatch(" in reaction_owner
    assert "struct PromptTerminalClearDispatchPlan" in reaction_owner
    assert "def plan_terminal_clear_dispatch(" in reaction_owner
    assert "struct PromptInformationalDispatchPlan" in reaction_owner
    assert "def plan_informational_dispatch(" in reaction_owner
    assert "struct PromptSimpleOutputDispatchPlan" in reaction_owner
    assert "def plan_simple_output_dispatch(" in reaction_owner
    process_owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    assert "struct PromptExternalProcessDispatchPlan" in process_owner
    assert "struct PromptFallbackProcessDispatchPlan" in process_owner
    assert "var handled: Bool" in process_owner
    assert "var run_reta_prompt: Bool" in process_owner
    assert "var raw: String" not in owner
    assert "var raw: String" not in reaction_owner
    assert "var raw: String" not in input_owner
    assert "var process_kind: Int" not in owner
    assert "var process_kind: Int" not in reaction_owner
    assert "var process_kind: Int" not in input_owner
    assert "EXTERNAL_PROMPT_" not in owner
    assert "EXTERNAL_PROMPT_" not in reaction_owner
    assert "EXTERNAL_PROMPT_" not in input_owner
    assert "var arguments: List[String]" in process_owner
    assert "var run_shell: Bool" in process_owner
    assert "var run_python: Bool" in process_owner
    assert "var run_math: Bool" in process_owner
    assert "var run_reta: Bool" in process_owner
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    assert "def command_raw_payload(" in runtime
    assert "def command_argument_tail(" in runtime
    assert "def command_raw_payload_arguments(" in runtime
    assert "def command_shell_arguments(" in runtime
    assert "def _prompt_command_payload(" not in owner
    assert "def _prompt_command_payload(" not in reaction_owner
    assert "def _prompt_command_payload(" not in input_owner
    assert "def _prompt_command_arguments(" not in owner
    assert "def _prompt_command_arguments(" not in reaction_owner
    assert "def _prompt_command_arguments(" not in input_owner
    assert "def plan_external_process_dispatch(" in process_owner
    assert "def plan_prompt_fallback_process_dispatch(" in process_owner
    assert "reta_prompt_fallback_arguments_native(" in process_owner
    assert "def plan_external_process_dispatch(" not in owner
    assert "def plan_prompt_fallback_process_dispatch(" not in owner
    assert "struct PromptStoredOutputExecutionPlan" in storage_owner
    assert "def plan_stored_output_command(" in storage_owner
    assert "def plan_inline_stored_output_command(" in storage_owner
    assert "struct PromptStoredDeletePlan" in storage_owner
    assert "def plan_stored_delete_command(" in storage_owner
    assert "struct PromptStoredDefaultPlan" in storage_owner
    assert "def plan_stored_default_command(" in storage_owner
    assert "def prompt_interaction_contract_snapshot(" in owner

    interaction_contract = owner.split("def prompt_interaction_contract_snapshot", 1)[1]
    interaction_contract = interaction_contract.split("return [", 1)[1].split("    ]", 1)[0]
    assert "input=native-typed-plan" not in interaction_contract
    assert "store=native-next-and-previous" not in interaction_contract
    assert "history=native-previous-command-policy" not in interaction_contract
    assert "reaction_input=delegated-native-input-owner" in interaction_contract
    assert "external_process_dispatch=native-prompt-process-edge-plan" not in interaction_contract
    assert "fallback_process_dispatch=native-interaction-argv-plan" not in interaction_contract
    assert "external_dispatch_owner=prompt-execution-process-plan" not in interaction_contract
    assert "from std.python import" not in owner
    assert "from std.python import" not in reaction_owner
    assert "from std.python import" not in storage_owner
    assert "from std.python import" not in input_owner
    assert "PythonObject" not in owner
    assert "PythonObject" not in reaction_owner
    assert "PythonObject" not in storage_owner
    assert "PythonObject" not in input_owner


def test_production_prompt_activates_the_interaction_owner() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "from reta_mojo.prompt_interaction import" in controller
    assert "from reta_mojo.prompt_reaction_input import" in controller
    assert "from reta_mojo.prompt_reaction_dispatch import" in controller
    assert "from reta_mojo.prompt_reaction_storage import" in controller
    assert "new_prompt_interaction(startup)" in controller
    assert "accept_prompt_reaction_input(" in controller
    assert "record_prompt_session_line(" in controller
    assert "accept_prompt_input(" not in controller
    assert "record_prompt_line(" not in controller
    assert "record_prompt_command(" not in controller
    assert "apply_inline_storage_command(" in controller
    assert "plan_loop_control_dispatch(" in controller
    assert "plan_stored_command_dispatch(" in controller
    assert "plan_logging_dispatch(" in controller
    assert "plan_one_shot_logging_dispatch(" in controller
    assert "plan_terminal_clear_dispatch(" in controller
    assert "plan_informational_dispatch(" in controller
    assert "plan_simple_output_dispatch(" in controller
    assert "from reta_mojo.prompt_process_dispatch import" in controller
    assert "plan_external_process_dispatch(" in controller
    assert "plan_prompt_fallback_process_dispatch(" in controller
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
    assert "run_shell_prompt_arguments_native(external_process.arguments)" in controller
    assert "run_python_prompt_arguments_native(external_process.arguments)" in controller
    assert "run_math_prompt_arguments_native(external_process.arguments)" in controller
    assert "run_shell_prompt_line_native(external_process.raw)" not in controller
    assert "run_python_prompt_line_native(external_process.raw)" not in controller
    assert "run_math_prompt_line_native(external_process.raw)" not in controller
    assert "_run_native_reta_prompt_command(external_process.arguments)" in controller
    assert "run_reta_arguments_native(\n                external_process.arguments" in controller
    assert "run_reta_line_native(external_process.raw)" not in controller
    assert "external_process.raw" not in controller
    assert "fallback_profile_arguments(profile), shell_split(line), reference_root()" not in controller
    assert "fallback_process.arguments" in controller
    assert "fallback_process.profile_arguments" not in controller
    assert "fallback_process.command_arguments" not in controller
    assert "if not fallback_process.handled:" in controller
    assert "if not fallback_process.run_reta_prompt:" in controller
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
