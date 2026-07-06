from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dv() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert (
        "test_stage12c5dv.sh" in current
        or "test_stage12c5dx.sh" in current
        or "test_stage12c5dw.sh" in current
        or "test_stage12c5dy.sh" in current or "test_stage12c5dz.sh" in current
    )


def test_stage_script_covers_prompt_execution_mulpri_render_plan() -> None:
    source = (ROOT / "scripts/test_stage12c5dv.sh").read_text(encoding="utf-8")
    assert "prompt execution mulpri render plan" in source
    assert "test_stage12c5du.sh" in source
    assert "test_${test_name}_12c5dv" in source
    assert "tests/test_stage12c5dv_source.py" in source
    assert "tests/test_stage12c5du_source.py" in source


def test_prompt_execution_owns_mulpri_render_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    for symbol in (
        "struct PromptExecutionMulpriRenderPlan",
        "def plan_prompt_execution_mulpri_render(",
        "prime_comparison_lines(",
        "prime_lines(prime_command)",
        "multis_lines(",
        "prompt_execution_language_is_german(",
    ):
        assert symbol in owner
    assert (
        "plan_prompt_execution_mulpri_render(values, language, catalog)" in controller
        or "branch.mulpri_render.handled" in controller
    )
    assert "prompt_execution_has_mulpri(values, language, catalog)" not in controller
    assert "prompt_execution_integer_argument_words(values)" not in controller
    assert "prime_comparison_lines(" not in controller
    assert "prime_lines(" not in controller
    assert "multis_lines(" not in controller
    assert "command_numbers(" not in controller
    assert "KIND_PRIME" not in controller
    assert "KIND_MULTIS" not in controller
    assert "KIND_PRIME_COMPARE" not in controller


def test_mulpri_render_plan_is_documented_and_pure() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    doc = (ROOT / "STAGE12C5DV_PROMPT_EXECUTION_MULPRI_RENDER_PLAN.md").read_text(encoding="utf-8")
    assert "std.python" not in owner
    assert "PythonObject" not in owner
    assert "PromptExecutionMulpriRenderPlan" in matrix
    assert "plan_prompt_execution_mulpri_render" in matrix
    assert "PromptExecutionMulpriRenderPlan" in doc
    assert "No `.so`/`.dll` split is implemented" in doc
