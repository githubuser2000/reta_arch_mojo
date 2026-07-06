from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dt() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert (
        "test_stage12c5dt.sh" in current
        or "test_stage12c5du.sh" in current
        or "test_stage12c5dv.sh" in current
        or "test_stage12c5dx.sh" in current
        or "test_stage12c5dw.sh" in current
        or "test_stage12c5dy.sh" in current
    )


def test_stage_script_covers_prompt_execution_compact_announcement_plan() -> None:
    source = (ROOT / "scripts/test_stage12c5dt.sh").read_text(encoding="utf-8")
    assert "prompt execution compact announcement plan" in source
    assert "test_stage12c5ds.sh" in source
    assert "test_${test_name}_12c5dt" in source
    assert "tests/test_stage12c5dt_source.py" in source
    assert "tests/test_stage12c5ds_source.py" in source


def test_prompt_execution_owns_compact_announcement_line_plan() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    for symbol in (
        "struct PromptExecutionCompactAnnouncementPlan",
        "def plan_prompt_execution_compact_announcement(",
        "routing.compact_expansion.compact",
        "routing.quiet_echo",
        "compact_prompt_announcement_line(visible_tokens, source, language)",
    ):
        assert symbol in owner
    assert "plan_prompt_execution_compact_announcement" in controller or "plan_prompt_execution_native_branch" in controller
    assert "compact_prompt_announcement_line" not in controller
    assert "PromptExpansionResult," in controller
    assert "def _print_compact_announcement_if_needed(" in controller or "def _print_compact_announcement(" in controller
    assert "expansion: PromptExpansionResult" not in controller
    assert "prepared_tokens: List[String]" not in controller
    assert "quiet: Bool" not in controller


def test_compact_announcement_plan_is_documented_and_pure() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    doc = (ROOT / "STAGE12C5DT_PROMPT_EXECUTION_COMPACT_ANNOUNCEMENT_PLAN.md").read_text(encoding="utf-8")
    assert "std.python" not in owner
    assert "PythonObject" not in owner
    assert "PromptExecutionCompactAnnouncementPlan" in matrix
    assert "plan_prompt_execution_compact_announcement" in matrix
    assert "PromptExecutionCompactAnnouncementPlan" in doc
    assert "No `.so`/`.dll` split is implemented" in doc

def test_prompt_main_keeps_native_mulpri_runner_after_owner_split() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert (
        "def _run_native_mulpri(" in controller
        or "branch.mulpri_render.handled" in controller
    )
    assert (
        "var handled_mulpri = _run_native_mulpri(" in controller
        or "branch.mulpri_render.output_lines" in controller
    )
    assert (
        "prompt_execution_has_mulpri(values, language, catalog)" in controller
        or "plan_prompt_execution_mulpri_render(values, language, catalog)" in controller
        or "branch.mulpri_render.handled" in controller
    )
    assert (
        "prompt_execution_integer_argument_words(values)" in controller
        or "plan_prompt_execution_mulpri_render(values, language, catalog)" in controller
        or "branch.mulpri_render.output_lines" in controller
    )
    assert "def _integer_argument_words(" not in controller
    assert "def _has_mulpri(" not in controller
