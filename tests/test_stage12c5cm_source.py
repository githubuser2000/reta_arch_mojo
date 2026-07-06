from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_later_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current


def test_stage_wraps_cl_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cm.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cl.sh" in source
    assert "external process payload ownership" in source
    assert "test_${test_name}_12c5cm" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_external_process_plan_owns_payload_boundary() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptExternalProcessDispatchPlan" in owner
    assert "var arguments: List[String]" in owner
    assert "def _prompt_command_payload(" in owner
    assert "StringSlice(text)[byte=start:end]" in owner
    assert "_prompt_command_payload(command)" in owner
    assert "external_process_arguments=native-prompt-process-argv-plan" in owner
    assert "external_reta_arguments=native-prompt-reta-argv-plan" in owner


def test_process_controller_consumes_planned_payloads() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert ("run_shell_prompt_payload_native(external_process.payload)" in controller or "run_shell_prompt_arguments_native(external_process.arguments)" in controller)
    assert "run_python_prompt_arguments_native(external_process.arguments)" in controller
    assert "run_math_prompt_arguments_native(external_process.arguments)" in controller
    assert "run_shell_prompt_line_native(external_process.raw)" not in controller
    assert "run_python_prompt_line_native(external_process.raw)" not in controller
    assert "run_math_prompt_line_native(external_process.raw)" not in controller
    assert (
        "run_reta_line_native(external_process.raw)" in controller
        or "run_reta_arguments_native(\n                external_process.arguments" in controller
    )


def test_payload_helpers_are_the_external_process_boundary() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def run_shell_prompt_payload_native(" in adapter
    assert "def run_python_prompt_payload_native(" in adapter
    assert "def run_math_prompt_payload_native(" in adapter
    assert "def run_shell_prompt_payload_native(" in adapter
    assert "def run_python_prompt_payload_native(" in adapter
    assert "def run_math_prompt_payload_native(" in adapter
    if "def run_shell_prompt_line_native(" in adapter:
        assert "return run_shell_prompt_payload_native(" in adapter


def test_prompt_interaction_regression_covers_payloads() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_external_process_dispatch_is_planned_by_interaction_owner" in test
    assert 'assert_equal(shell_plan.arguments[0], "echo")' in test
    assert 'assert_equal(python_plan.payload, "print(1)")' in test
    assert 'assert_equal(math_plan.payload, "1+1")' in test
    assert "external_process_arguments=native-prompt-process-argv-plan" in test
    assert "assert_equal(len(snapshot)," in test
