from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _prompt_execution_import_block(controller: str) -> str:
    marker = "from reta_mojo.prompt_execution import ("
    assert marker in controller
    return controller.split(marker, 1)[1].split("\n)", 1)[0]


def test_current_stage_points_to_fa() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fa.sh" in current
    assert "test_stage12c5ez.sh" in current


def test_stage_script_chains_ez_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fa.sh").read_text(encoding="utf-8")
    assert "prompt execution one-shot result import coverage" in script
    assert "test_stage12c5ez.sh" in script
    assert "test_${test_name}_12c5fa" in script
    assert "tests/test_stage12c5fa_source.py" in script
    assert "tests/test_stage12c5ez_source.py" in script
    assert "stage12c5fa prompt execution one-shot result import coverage complete" in script


def test_prompt_execution_plan_usages_are_imported_by_prompt_main() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    import_block = _prompt_execution_import_block(controller)

    defined = set(re.findall(r"\bdef (plan_prompt_execution_[A-Za-z0-9_]+)\(", owner))
    used = set(re.findall(r"\b(plan_prompt_execution_[A-Za-z0-9_]+)\(", controller))
    missing = sorted(name for name in used if name in defined and name not in import_block)
    assert missing == []

    # Regression for the failed 12c5ez full build: this plan was defined and used
    # but not imported into the native prompt controller.
    assert "def plan_prompt_execution_one_shot_native_completion_result(" in owner
    assert "plan_prompt_execution_one_shot_native_completion_result" in controller
    assert "plan_prompt_execution_one_shot_native_completion_result" in import_block


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FA_PROMPT_EXECUTION_ONE_SHOT_RESULT_IMPORTS.md").read_text(encoding="utf-8")
    assert "plan_prompt_execution_one_shot_native_completion_result" in doc
    assert "prompt_main.mojo" in doc
    assert "12c5fa" in doc
