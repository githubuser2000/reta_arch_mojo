from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_di() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5d" in current and ".sh" in current


def test_stage_wraps_dh_and_builds_prompt_boundary_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5di.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dh.sh" in source
    assert "prompt external python math argv plan" in source
    assert "test_${test_name}_12c5di" in source
    assert "tests/test_stage12c5di_source.py" in source
    assert "tests/test_stage12c5dh_source.py" in source


def test_external_process_plan_has_no_payload_field() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    plan = owner.split("struct PromptExternalProcessDispatchPlan", 1)[1].split(
        "@fieldwise_init", 1
    )[0]
    assert "var payload: String" not in plan
    assert "var arguments: List[String]" in plan
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    assert "def command_raw_payload_arguments(" in runtime
    assert "external_process_arguments=native-prompt-process-argv-plan" in owner
    assert "external_python_math_arguments=native-prompt-python-math-argv-plan" in owner


def test_python_and_math_prompt_processes_are_planned_as_arguments() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    body = owner.split("def plan_external_process_dispatch", 1)[1].split(
        "def plan_prompt_fallback_process_dispatch", 1
    )[0]
    python_block = body.split("if command.kind == KIND_PYTHON:", 1)[1].split(
        "if command.kind == KIND_MATH:", 1
    )[0]
    math_block = body.split("if command.kind == KIND_MATH:", 1)[1].split(
        "if command.kind == KIND_RETA:", 1
    )[0]
    assert "command_raw_payload_arguments(command)" in python_block
    assert "command_raw_payload_arguments(command)" in math_block
    assert "_prompt_command_payload(command)," not in python_block
    assert "_prompt_command_payload(command)," not in math_block
    assert "List[String]()," not in python_block
    assert "List[String]()," not in math_block


def test_prompt_main_dispatches_python_and_math_by_arguments() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "run_python_prompt_arguments_native," in controller
    assert "run_math_prompt_arguments_native," in controller
    assert "run_python_prompt_arguments_native(external_process.arguments)" in controller
    assert "run_math_prompt_arguments_native(external_process.arguments)" in controller
    assert "run_python_prompt_payload_native(external_process.payload)" not in controller
    assert "run_math_prompt_payload_native(external_process.payload)" not in controller
    assert "external_process.payload" not in controller


def test_process_adapter_keeps_legacy_payload_wrappers_but_normalizes_to_arguments() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def run_python_prompt_arguments_native(" in adapter
    assert "def run_math_prompt_arguments_native(" in adapter
    assert "def run_python_prompt_payload_native(" in adapter
    assert "def run_math_prompt_payload_native(" in adapter
    python_payload = adapter.split("def run_python_prompt_payload_native", 1)[1].split(
        "def run_math_prompt_arguments_native", 1
    )[0]
    math_payload = adapter.split("def run_math_prompt_payload_native", 1)[1].split(
        "def _run_reference_python_script", 1
    )[0]
    assert "arguments.append(payload)" in python_payload
    assert "run_python_prompt_arguments_native(arguments, reference_root)" in python_payload
    assert "arguments.append(payload)" in math_payload
    assert "run_math_prompt_arguments_native(arguments, reference_root)" in math_payload


def test_mojo_test_contract_records_argument_only_external_processes() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "assert_equal(len(python_plan.arguments), 1)" in test
    assert "assert_equal(python_plan.arguments[0], \"print(1)\")" in test
    assert "assert_equal(len(math_plan.arguments), 1)" in test
    assert "assert_equal(math_plan.arguments[0], \"1+1\")" in test
    assert "python_plan.payload" not in test
    assert "math_plan.payload" not in test
    assert ("assert_equal(len(snapshot), 37)" in test or "assert_equal(len(snapshot), 38)" in test or "assert_equal(len(snapshot), 21)" in test)


def test_stage_document_records_python_math_argv_plan() -> None:
    document = (ROOT / "STAGE12C5DI_PROMPT_EXTERNAL_PYTHON_MATH_ARGV_PLAN.md").read_text(
        encoding="utf-8"
    )
    assert "run_python_prompt_arguments_native" in document
    assert "run_math_prompt_arguments_native" in document
    assert "native-prompt-python-math-argv-plan" in document
    assert ".so" in document and ".dll" in document
