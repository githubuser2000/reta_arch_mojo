from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _active(text: str) -> str:
    return "\n".join(
        line for line in text.splitlines()
        if not line.strip().startswith("#")
    )


def test_current_stage_points_to_fb() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fb.sh" in current
    assert "test_stage12c5ez.sh" in current


def test_stage_script_chains_ez_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fb.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot local dispatch result owner" in script
    assert "test_stage12c5ez.sh" in script
    assert "test_${test_name}_12c5fb" in script
    assert "tests/test_stage12c5fb_source.py" in script
    assert "tests/test_stage12c5ez_source.py" in script
    assert "tests/test_stage12c5ey_source.py" in script
    assert "stage12c5fb prompt execution one-shot local dispatch result owner complete" in script


def test_one_shot_local_dispatch_result_is_prompt_execution_owned() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")

    assert "struct PromptExecutionOneShotLocalDispatchResultPlan" in owner
    assert "def plan_prompt_execution_one_shot_local_dispatch_result(" in owner
    assert "PromptExecutionOneShotLocalDispatchResultPlan(" in owner
    assert '"informational"' in owner
    assert '"terminal_clear"' in owner
    assert '"one_shot_logging"' in owner
    assert '"simple_output"' in owner
    assert "plan_prompt_execution_one_shot_local_dispatch_result" in controller

    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]
    active_body = _active(body)
    local_region = active_body.split("var local_info_handled = False", 1)[1].split(
        "var external_process = plan_external_process_dispatch(command)", 1
    )[0]
    assert "return info_result.handled" not in local_region
    assert "return terminal_result.handled" not in local_region
    assert "return logging_result.handled" not in local_region
    assert "return simple_result.handled" not in local_region
    assert "local_dispatch_result.stop_native_probe" in local_region
    assert "return local_dispatch_result.handled" in local_region
    assert local_region.count("return ") == 1
    assert "test_prompt_execution_one_shot_local_dispatch_result_owns_combined_return" in mojo_test


def test_prompt_main_imports_used_one_shot_execution_plans() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    import_block = controller.split("from reta_mojo.prompt_execution import (", 1)[1].split(")", 1
    )[0]
    body = controller.split("def _run_native_one_shot", 1)[1].split("\ndef main", 1)[0]

    defined = set(re.findall(r"def (plan_prompt_execution_one_shot_[a-z0-9_]+)\(", owner))
    used = set(re.findall(r"\b(plan_prompt_execution_one_shot_[a-z0-9_]+)\(", body))
    missing = sorted(name for name in used if name in defined and name not in import_block)
    assert missing == []


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FB_PROMPT_EXECUTION_ONE_SHOT_LOCAL_DISPATCH_RESULT.md").read_text(encoding="utf-8")
    assert "PromptExecutionOneShotLocalDispatchResultPlan" in doc
    assert "plan_prompt_execution_one_shot_local_dispatch_result" in doc
    assert "12c5fb" in doc
