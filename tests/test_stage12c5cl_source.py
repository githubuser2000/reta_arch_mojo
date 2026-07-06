from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_later_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current


def test_stage_wraps_ck_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cl.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ck.sh" in source
    assert "external reta argument ownership" in source
    assert "test_${test_name}_12c5cl" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_external_process_plan_owns_reta_arguments() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptExternalProcessDispatchPlan" in owner
    assert "var arguments: List[String]" in owner
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    assert "def command_argument_tail(" in runtime
    assert "return result^" in runtime
    assert "var process_kind: Int" not in owner
    assert "command.raw" in runtime
    assert "command_argument_tail(command)" in owner
    assert "external_reta_arguments=native-prompt-reta-argv-plan" in owner


def test_process_controller_consumes_planned_reta_arguments() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "KIND_RETA," not in controller
    assert "if command.kind != KIND_RETA" not in controller
    assert "if command.kind == KIND_RETA" not in controller
    assert "def _run_native_reta_prompt_command(tokens: List[String])" in controller
    assert "native_cli_startup(tokens)" in controller
    assert "native_reta_tokens_supported(tokens, csv_path)" in controller
    assert "run_native_reta(tokens, csv_path)" in controller
    assert "_run_native_reta_prompt_command(external_process.arguments)" in controller
    assert "_run_native_reta_prompt_command(command)" not in controller


def test_prompt_interaction_regression_covers_reta_arguments() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_external_process_dispatch_is_planned_by_interaction_owner" in test
    assert "assert_equal(len(reta_plan.arguments), 1)" in test
    assert 'assert_equal(reta_plan.arguments[0], "-h")' in test
    assert '"external_reta_arguments=native-prompt-reta-argv-plan"' in test
    assert "external_reta_arguments=native-prompt-reta-argv-plan" in test
