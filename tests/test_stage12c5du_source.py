from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_du() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5du.sh" in current or "test_stage12c5dv.sh" in current or "test_stage12c5dx.sh" in current or "test_stage12c5dy.sh" in current


def test_stage_script_covers_prompt_execution_historical_effect_plan() -> None:
    source = (ROOT / "scripts/test_stage12c5du.sh").read_text(encoding="utf-8")
    assert "prompt execution historical effect plan" in source
    assert "test_stage12c5dt.sh" in source
    assert "test_${test_name}_12c5du" in source
    assert "tests/test_stage12c5du_source.py" in source
    assert "tests/test_stage12c5dt_source.py" in source


def test_prompt_execution_owns_historical_effect_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    for symbol in (
        "struct PromptExecutionHistoricalEffectPlan",
        "def plan_prompt_execution_historical_effects(",
        "historical_prompt_companion_effects(",
        "historical_prompt_logging_update(",
        "logging_update == PROMPT_LOG_ENABLED",
        "logging_update == PROMPT_LOG_DISABLED",
    ):
        assert symbol in owner
    assert "plan_prompt_execution_historical_effects" in controller or "plan_prompt_execution_native_branch" in controller
    assert "from reta_mojo.prompt_historical_ownership import" not in controller
    assert "historical_prompt_companion_effects" not in controller
    assert "historical_prompt_logging_update" not in controller
    assert "PROMPT_LOG_ENABLED" not in controller
    assert "PROMPT_LOG_DISABLED" not in controller


def test_historical_effect_plan_is_documented_and_pure() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    doc = (ROOT / "STAGE12C5DU_PROMPT_EXECUTION_HISTORICAL_EFFECT_PLAN.md").read_text(encoding="utf-8")
    assert "std.python" not in owner
    assert "PythonObject" not in owner
    assert "PromptExecutionHistoricalEffectPlan" in matrix
    assert "plan_prompt_execution_historical_effects" in matrix
    assert "PromptExecutionHistoricalEffectPlan" in doc
    assert "No `.so`/`.dll` split is implemented" in doc
