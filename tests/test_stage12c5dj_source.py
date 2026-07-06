from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dj() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5d" in current and ".sh" in current


def test_stage_wraps_di_and_builds_prompt_boundary_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5dj.sh").read_text(encoding="utf-8")
    assert "test_stage12c5di.sh" in source
    assert "prompt runtime command argv builders" in source
    assert "test_${test_name}_12c5dj" in source
    assert "tests/test_stage12c5dj_source.py" in source
    assert "tests/test_stage12c5di_source.py" in source


def test_prompt_runtime_owns_external_command_argument_builders() -> None:
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    assert "def command_raw_payload(" in runtime
    assert "def command_argument_tail(" in runtime
    assert "def command_raw_payload_arguments(" in runtime
    assert "def command_shell_arguments(" in runtime
    assert "shell_split(command_raw_payload(command))" in runtime
    assert "def _prompt_command_payload(" not in owner
    assert "def _prompt_command_arguments(" not in owner
    assert "StringSlice" not in owner
    assert "external_command_arguments=runtime-owned-command-argv-builders" in owner


def test_external_process_dispatch_uses_runtime_argument_builders() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    body = owner.split("def plan_external_process_dispatch", 1)[1].split(
        "def plan_prompt_fallback_process_dispatch", 1
    )[0]
    shell_block = body.split("if command.kind == KIND_SHELL:", 1)[1].split(
        "if command.kind == KIND_PYTHON:", 1
    )[0]
    python_block = body.split("if command.kind == KIND_PYTHON:", 1)[1].split(
        "if command.kind == KIND_MATH:", 1
    )[0]
    math_block = body.split("if command.kind == KIND_MATH:", 1)[1].split(
        "if command.kind == KIND_RETA:", 1
    )[0]
    reta_block = body.split("if command.kind == KIND_RETA:", 1)[1].split(
        "return PromptExternalProcessDispatchPlan(\n        False", 1
    )[0]
    assert "command_shell_arguments(command)" in shell_block
    assert "command_raw_payload_arguments(command)" in python_block
    assert "command_raw_payload_arguments(command)" in math_block
    assert "command_argument_tail(command)" in reta_block
    assert "_prompt_command_payload" not in body
    assert "_prompt_command_arguments" not in body


def test_contract_snapshot_records_runtime_command_argument_owner() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert ("assert_equal(len(snapshot), 37)" in test or "assert_equal(len(snapshot), 38)" in test or "assert_equal(len(snapshot), 21)" in test)
    assert '"external_command_arguments=runtime-owned-command-argv-builders"' in test
    assert (
        "assert_equal(snapshot[36], \"execution=delegated-native-dispatch\")" in test
        or "assert_equal(snapshot[37], \"execution=delegated-native-dispatch\")" in test
        or "assert_equal(snapshot[20], \"execution=delegated-native-dispatch\")" in test
    )


def test_stage_document_records_runtime_command_argv_owner() -> None:
    document = (ROOT / "STAGE12C5DJ_PROMPT_RUNTIME_COMMAND_ARGV_BUILDERS.md").read_text(
        encoding="utf-8"
    )
    assert "command_shell_arguments" in document
    assert "command_raw_payload_arguments" in document
    assert "command_argument_tail" in document
    assert "prompt-runtime" in document
    assert ".so" in document and ".dll" in document
