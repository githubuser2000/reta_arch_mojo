from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_later_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current


def test_stage_wraps_cm_and_rebuilds_prompt_boundaries() -> None:
    source = (ROOT / "scripts/test_stage12c5cn.sh").read_text(encoding="utf-8")
    assert "test_stage12c5cm.sh" in source
    assert "external process effect flag ownership" in source
    assert "test_${test_name}_12c5cn" in source
    assert "for test_name in prompt_interaction legacy_reta_prompt table_adapters" in source


def test_external_process_plan_owns_effect_flags() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptExternalProcessDispatchPlan" in owner
    assert "var run_shell: Bool" in owner
    assert "var run_python: Bool" in owner
    assert "var run_math: Bool" in owner
    assert "var run_reta: Bool" in owner
    assert "external_process_flags=native-prompt-process-effect-flags" in owner
    assert "True,\n            False,\n            False,\n            False," in owner
    assert "False,\n            True,\n            False,\n            False," in owner
    assert "False,\n            False,\n            True,\n            False," in owner
    assert "False,\n            False,\n            False,\n            True," in owner


def test_process_controller_consumes_planned_effect_flags() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "EXTERNAL_PROMPT_SHELL," not in controller
    assert "EXTERNAL_PROMPT_PYTHON," not in controller
    assert "EXTERNAL_PROMPT_MATH," not in controller
    assert "EXTERNAL_PROMPT_RETA," not in controller
    assert "external_process.process_kind == EXTERNAL_PROMPT" not in controller
    assert "if external_process.run_shell" in controller
    assert "if external_process.run_python" in controller
    assert "if external_process.run_math" in controller
    assert "if external_process.run_reta" in controller
    assert "run_shell_prompt_payload_native(external_process.payload)" in controller
    assert "run_python_prompt_payload_native(external_process.payload)" in controller
    assert "run_math_prompt_payload_native(external_process.payload)" in controller
    assert "_run_native_reta_prompt_command(external_process.arguments)" in controller


def test_prompt_interaction_regression_covers_effect_flags() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "assert_true(shell_plan.run_shell)" in test
    assert "assert_true(python_plan.run_python)" in test
    assert "assert_true(math_plan.run_math)" in test
    assert "assert_true(reta_plan.run_reta)" in test
    assert '"external_process_flags=native-prompt-process-effect-flags"' in test
    assert "assert_equal(len(snapshot), 26)" in test
