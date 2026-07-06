from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dq() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dq.sh" in current


def test_stage_script_covers_prompt_execution_routing_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5dq.sh").read_text(encoding="utf-8")
    assert "prompt execution routing owner" in source
    assert "test_stage12c5dp.sh" in source
    assert "test_${test_name}_12c5dq" in source
    assert "tests/test_stage12c5dq_source.py" in source
    assert "tests/test_stage12c5dp_source.py" in source


def test_prompt_execution_owns_shared_routing_front_half() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(
        encoding="utf-8"
    )
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    for symbol in (
        "struct PromptExecutionRoutingPlan",
        "def prompt_execution_contains_token(",
        "def prompt_execution_uses_historical_echo(",
        "def prompt_execution_contains_numeric_shortcut(",
        "def prompt_execution_is_pure_numeric_prompt(",
        "def prompt_execution_quiet_echo(",
        "def plan_prompt_execution_routing(",
    ):
        assert symbol in owner
    assert "PromptExecutionOwner(\"PromptVonGrosserAusgabeSonderBefehlAusgaben\", \"prompt_execution.mojo\", \"def plan_prompt_execution_routing\")" in owner
    assert "from reta_mojo.prompt_execution import (" in controller
    assert controller.count("var routing = plan_prompt_execution_routing(") == 2
    assert "def _contains_numeric_shortcut(" not in controller
    assert "def _quiet_prompt_echo(" not in controller
    assert "def _is_pure_numeric_prompt(" not in controller
    assert "def _uses_historical_prompt_echo(" not in controller


def test_prompt_main_no_longer_imports_prompt_preparation_front_half() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    language_import = controller.split("from reta_mojo.prompt_language import (", 1)[1].split(")", 1)[0]
    historical_import = controller.split("from reta_mojo.prompt_historical_ownership import (", 1)[1].split(")", 1)[0]
    for symbol in (
        "expand_compact_prompt_tokens",
        "expand_prompt_replacements",
        "prepare_prompt_tokens",
        "is_prompt_numeric_shortcut",
        "is_prompt_numeric_syntax_token",
    ):
        assert symbol not in language_import
        assert symbol not in historical_import
    assert "PromptExpansionResult" in language_import


def test_prompt_execution_routing_is_pure_native_and_documented() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(
        encoding="utf-8"
    )
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    doc = (ROOT / "STAGE12C5DQ_PROMPT_EXECUTION_ROUTING_OWNER.md").read_text(
        encoding="utf-8"
    )
    assert "std.python" not in owner
    assert "PythonObject" not in owner
    assert "PromptExecutionRoutingPlan" in matrix
    assert "PromptExecutionRoutingPlan" in doc
    assert "No `.so`/`.dll` split is implemented" in doc
