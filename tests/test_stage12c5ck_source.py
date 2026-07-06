from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_later_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current


def test_stage_wraps_cj_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5ck.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cj.sh" in source
    assert "external process dispatch ownership" in source
    assert "test_${test_name}_12c5ck" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_external_process_dispatch_has_dedicated_native_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptExternalProcessDispatchPlan" in owner
    assert "def plan_external_process_dispatch(" in owner
    assert "var run_shell: Bool" in owner
    assert "var run_python: Bool" in owner
    assert "var run_math: Bool" in owner
    assert "var run_reta: Bool" in owner
    assert "KIND_SHELL" in owner
    assert "KIND_PYTHON" in owner
    assert "KIND_MATH" in owner
    assert "KIND_RETA" in owner
    assert "external_process_dispatch=native-prompt-process-edge-plan" in owner


def test_process_controller_delegates_external_process_routing() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "plan_external_process_dispatch(command)" in controller
    assert "KIND_SHELL," not in controller
    assert "KIND_PYTHON," not in controller
    assert "KIND_MATH," not in controller
    assert "if command.kind == KIND_SHELL" not in controller
    assert "if command.kind == KIND_PYTHON" not in controller
    assert "if command.kind == KIND_MATH" not in controller

    interactive = controller.split("def _run_command(", 1)[1].split(
        "def _run_native_one_shot", 1
    )[0]
    one_shot = controller.split("def _run_native_one_shot(", 1)[1]
    for block in (interactive, one_shot):
        simple = block.index(
            "var simple_output = plan_simple_output_dispatch(command, profile.language)"
        )
        external = block.index("var external_process = plan_external_process_dispatch(command)")
        assert simple < external
    assert (
        "run_shell_prompt_line_native(external_process.raw)" in interactive
        or "run_shell_prompt_payload_native(external_process.payload)" in interactive
        or "run_shell_prompt_arguments_native(external_process.arguments)" in interactive
    )
    assert (
        "run_python_prompt_line_native(external_process.raw)" in interactive
        or "run_python_prompt_arguments_native(external_process.arguments)" in interactive
    )
    assert (
        "run_math_prompt_line_native(external_process.raw)" in interactive
        or "run_math_prompt_arguments_native(external_process.arguments)" in interactive
    )
    assert (
        "run_reta_line_native(external_process.raw)" in interactive
        or "run_reta_arguments_native(\n                external_process.arguments" in interactive
    )


def test_prompt_interaction_regression_covers_external_process_dispatch() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "def test_external_process_dispatch_is_planned_by_interaction_owner" in test
    assert "plan_external_process_dispatch(" in test
    assert '"external_process_dispatch=native-prompt-process-edge-plan"' in test
    assert "assert_equal(len(snapshot)," in test
