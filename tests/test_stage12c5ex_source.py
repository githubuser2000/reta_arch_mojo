from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_ex() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ex.sh" in current
    assert "test_stage12c5ew.sh" in current


def test_stage_script_chains_ew_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5ex.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot local result owner" in script
    assert "test_stage12c5ew.sh" in script
    assert "test_${test_name}_12c5ex" in script
    assert "tests/test_stage12c5ex_source.py" in script
    assert "tests/test_stage12c5ew_source.py" in script
    assert "stage12c5ex prompt execution one-shot local result owner complete" in script


def test_one_shot_local_result_is_prompt_execution_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotLocalResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_local_result(" in owner
    assert "local_handled, not local_handled, source" in owner
    assert "plan_prompt_execution_one_shot_local_result" in controller
    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    # Later stage 12c5fb combines the four local result projections into one
    # local-dispatch result.  Accept either the original per-dispatch shape or
    # the newer combined owner so this historical guard keeps checking the
    # absence of raw ``return True`` without blocking later consolidation.
    if "plan_prompt_execution_one_shot_local_dispatch_result" in active_body:
        assert (
            "local_dispatch_result.stop_native_probe" in active_body
            or "plan_prompt_execution_one_shot_post_local_probe_result" in active_body
        )
        assert (
            "return local_dispatch_result.handled" in active_body
            or "return post_local_probe_result.handled" in active_body
        )
    else:
        for result_name in (
            "info_result",
            "terminal_result",
            "logging_result",
            "simple_result",
        ):
            assert f"return {result_name}.handled" in active_body
    for old_return in (
        "if info_dispatch.handled:",
        "if terminal_clear.handled:",
        "if one_shot_logging.handled:",
        "if simple_output.handled:",
    ):
        assert old_return in active_body
    local_region = active_body.split("var info_dispatch = plan_informational_dispatch(command)", 1)[1].split(
        "var external_process = plan_external_process_dispatch(command)", 1
    )[0]
    assert "return True" not in local_region
    assert "test_prompt_execution_one_shot_local_result_owns_dispatch_return" in mojo_test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5EX_PROMPT_EXECUTION_ONE_SHOT_LOCAL_RESULT.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotLocalResultPlan" in doc
    assert "plan_prompt_execution_one_shot_local_result" in doc
    assert "12c5ex" in doc
