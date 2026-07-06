from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dr_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert (
        "test_stage12c5dr.sh" in current
        or "test_stage12c5ds.sh" in current
        or "test_stage12c5dt.sh" in current
        or "test_stage12c5du.sh" in current
        or "test_stage12c5dv.sh" in current
        or "test_stage12c5dx.sh" in current
    )


def test_stage_script_covers_prompt_execution_table_ownership_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5dr.sh").read_text(encoding="utf-8")
    assert "prompt execution table ownership owner" in source
    assert "test_stage12c5dq.sh" in source
    assert "test_${test_name}_12c5dr" in source
    assert "tests/test_stage12c5dr_source.py" in source
    assert "tests/test_stage12c5dq_source.py" in source


def test_prompt_execution_owns_table_and_mulpri_ownership_decision() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(
        encoding="utf-8"
    )
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    for symbol in (
        "struct PromptExecutionTableOwnershipPlan",
        "def prompt_execution_integer_argument_words(",
        "def prompt_execution_has_mulpri(",
        "def plan_prompt_execution_table_ownership(",
    ):
        assert symbol in owner
    assert "plan_prompt_table_commands(" in owner
    assert "historical_prompt_execution_supported(" in owner
    assert "from reta_mojo.prompt_execution import (" in controller
    assert controller.count("var ownership = plan_prompt_execution_table_ownership(") == 2 or "plan_prompt_execution_native_branch" in controller
    assert "def _integer_argument_words(" not in controller
    assert "def _has_mulpri(" not in controller
    assert "plan_prompt_table_commands(" not in controller
    assert "historical_prompt_execution_supported(" not in controller


def test_table_ownership_plan_preserves_atomic_fallback_shape() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(
        encoding="utf-8"
    )
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "var fallback_required = (table_candidate or mulpri_candidate)" in owner
    assert "if table_plan.handled and not owns_table:" in owner
    assert "raw_tokens, planning_tokens, language, catalog" in owner
    assert "if ownership.fallback_required:" in controller or "if native_branch.fallback_required:" in controller
    assert "ownership.table_plan" in controller
    assert "ownership.owns_table or ownership.owns_mulpri" in controller or "native_branch.should_try_native" in controller


def test_prompt_execution_table_ownership_is_documented_and_pure() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(
        encoding="utf-8"
    )
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    doc = (ROOT / "STAGE12C5DR_PROMPT_EXECUTION_TABLE_OWNERSHIP_OWNER.md").read_text(
        encoding="utf-8"
    )
    assert "std.python" not in owner
    assert "PythonObject" not in owner
    assert "PromptExecutionTableOwnershipPlan" in matrix
    assert "PromptExecutionTableOwnershipPlan" in doc
    assert "No `.so`/`.dll` split is implemented" in doc
