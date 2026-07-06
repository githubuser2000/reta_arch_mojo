from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dh_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5d" in current
    assert ".sh" in current


def test_stage_wraps_dg_and_builds_prompt_boundary_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5dh.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dg.sh" in source
    assert "prompt external shell argv plan" in source
    assert "test_${test_name}_12c5dh" in source
    assert "tests/test_stage12c5dh_source.py" in source
    assert "tests/test_stage12c5dg_source.py" in source


def test_shell_prompt_process_plan_owns_argv_not_payload() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    body = owner.split("def plan_external_process_dispatch", 1)[1].split(
        "def plan_prompt_fallback_process_dispatch", 1
    )[0]
    shell_block = body.split("if command.kind == KIND_SHELL:", 1)[1].split(
        "if command.kind == KIND_PYTHON:", 1
    )[0]
    assert "command_shell_arguments(command)" in shell_block
    assert '"",' not in shell_block
    assert "List[String]()," not in shell_block
    assert "external_shell_arguments=native-prompt-shell-argv-plan" in owner


def test_prompt_main_dispatches_shell_by_arguments() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "run_shell_prompt_arguments_native," in controller
    assert ("run_shell_prompt_arguments_native(external_process.arguments)" in controller or "run_shell_prompt_arguments_native(external_execution.arguments)" in controller)
    assert "run_shell_prompt_payload_native" not in controller
    assert "run_shell_prompt_payload_native(external_process.payload)" not in controller
    assert ("run_python_prompt_arguments_native(external_process.arguments)" in controller or "run_python_prompt_arguments_native(external_execution.arguments)" in controller)
    assert ("run_math_prompt_arguments_native(external_process.arguments)" in controller or "run_math_prompt_arguments_native(external_execution.arguments)" in controller)


def test_process_adapter_exposes_argument_shell_runner_and_legacy_payload_wrapper() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def run_shell_prompt_arguments_native(" in adapter
    assert "def run_shell_prompt_payload_native(" in adapter
    argument_body = adapter.split("def run_shell_prompt_arguments_native", 1)[1].split(
        "def run_shell_prompt_payload_native", 1
    )[0]
    assert "shell_split(" not in argument_body
    assert "shell_quote(arguments[index])" in argument_body
    payload_body = adapter.split("def run_shell_prompt_payload_native", 1)[1].split(
        "def run_python_prompt_payload_native", 1
    )[0]
    assert "shell_split(payload)" in payload_body
    assert "run_shell_prompt_arguments_native(" in payload_body


def test_mojo_test_contract_records_shell_arguments_owner() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "assert_equal(len(shell_plan.arguments), 2)" in test
    assert '"external_shell_arguments=native-prompt-shell-argv-plan"' in test
    assert ("assert_equal(len(snapshot), 37)" in test or "assert_equal(len(snapshot), 38)" in test or "assert_equal(len(snapshot), 21)" in test)


def test_stage_document_records_shell_argv_plan() -> None:
    document = (ROOT / "STAGE12C5DH_PROMPT_EXTERNAL_SHELL_ARGV_PLAN.md").read_text(
        encoding="utf-8"
    )
    assert "run_shell_prompt_arguments_native" in document
    assert "native-prompt-shell-argv-plan" in document
    assert ".so" in document and ".dll" in document
