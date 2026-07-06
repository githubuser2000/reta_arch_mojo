from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dk() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dk.sh" in current


def test_stage_wraps_dj_and_builds_prompt_boundary_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5dk.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dj.sh" in source
    assert "prompt process dispatch owner" in source
    assert "test_${test_name}_12c5dk" in source
    assert "tests/test_stage12c5dk_source.py" in source
    assert "tests/test_stage12c5dj_source.py" in source


def test_process_dispatch_has_dedicated_prompt_execution_owner() -> None:
    interaction = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    dispatch = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptExternalProcessDispatchPlan" in dispatch
    assert "struct PromptFallbackProcessDispatchPlan" in dispatch
    assert "def plan_external_process_dispatch(" in dispatch
    assert "def plan_prompt_fallback_process_dispatch(" in dispatch
    assert "prompt_process_dispatch_contract_snapshot" in dispatch
    assert "def plan_external_process_dispatch(" not in interaction
    assert "def plan_prompt_fallback_process_dispatch(" not in interaction
    assert "struct PromptExternalProcessDispatchPlan" not in interaction
    assert "struct PromptFallbackProcessDispatchPlan" not in interaction
    assert "external_dispatch_owner=prompt-execution-process-plan" in dispatch


def test_prompt_main_imports_process_dispatch_from_new_owner() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    interaction_import = controller.split(
        "from reta_mojo.prompt_interaction import (", 1
    )[1].split("\n)\n", 1)[0]
    assert "plan_external_process_dispatch" not in interaction_import
    assert "plan_prompt_fallback_process_dispatch" not in interaction_import
    assert "from reta_mojo.prompt_process_dispatch import (" in controller
    assert "plan_external_process_dispatch," in controller
    assert "plan_prompt_fallback_process_dispatch," in controller


def test_prompt_interaction_test_imports_process_dispatch_owner() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "from reta_mojo.prompt_process_dispatch import *" in test
    assert "plan_external_process_dispatch(shell_command)" in test
    assert "plan_prompt_fallback_process_dispatch(" in test
    assert "external_dispatch_owner=prompt-execution-process-plan" in test
    assert "assert_equal(len(snapshot), 38)" in test


def test_stage_document_records_future_library_boundary() -> None:
    document = (ROOT / "STAGE12C5DK_PROMPT_PROCESS_DISPATCH_OWNER.md").read_text(
        encoding="utf-8"
    )
    assert "prompt-process" not in document.lower() or "prompt_process_dispatch" in document
    assert "prompt-execution" in document
    assert "prompt-reaction" in document
    assert ".so" in document and ".dll" in document
    assert "keine `.so` oder `.dll`" in document
