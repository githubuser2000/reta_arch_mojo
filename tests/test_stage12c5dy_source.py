from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dy() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5dy.sh" in current or "test_stage12c5dz.sh" in current or "test_stage12c5ea.sh" in current


def test_stage_script_chains_dx_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5dy.sh").read_text(encoding="utf-8")
    assert "prompt execution branch owns mulpri render" in script
    assert "test_stage12c5dx.sh" in script
    assert "test_${test_name}_12c5dy" in script
    assert "tests/test_stage12c5dy_source.py" in script
    assert "tests/test_stage12c5dx_source.py" in script


def test_native_branch_plan_now_owns_mulpri_render_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "var mulpri_render: PromptExecutionMulpriRenderPlan" in owner
    assert "var mulpri_render = PromptExecutionMulpriRenderPlan(False, List[String]())" in owner
    assert "mulpri_render = plan_prompt_execution_mulpri_render(" in owner
    assert "mulpri_render^," in owner
    assert "branch.mulpri_render.handled" in controller
    assert "branch.mulpri_render.output_lines" in controller
    assert "plan_prompt_execution_mulpri_render" not in controller
    assert "def _run_native_mulpri(" not in controller


def test_prompt_execution_mulpri_test_uses_prime_contract() -> None:
    test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert 'plan_prompt_execution_routing("p 17", "deutsch", catalog)' in test
    assert 'assert_true(len(plan.output_lines) >= 2)' in test
    assert 'assert_true(_has_substring(plan.output_lines, "15"))' not in test


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5DY_PROMPT_EXECUTION_BRANCH_MULPRI_RENDER.md").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    assert "PromptExecutionNativeBranchPlan" in doc
    assert "mulpri_render" in doc
    assert "PromptExecutionNativeBranchPlan" in matrix
    assert "mulpri_render" in matrix
