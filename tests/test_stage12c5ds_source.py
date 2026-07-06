from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ds_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert (
        "test_stage12c5ds.sh" in current
        or "test_stage12c5dt.sh" in current
        or "test_stage12c5du.sh" in current
        or "test_stage12c5dv.sh" in current
        or "test_stage12c5dx.sh" in current
        or "test_stage12c5dy.sh" in current
    )


def test_stage_script_covers_prompt_execution_compact_announcement_owner() -> None:
    source = (ROOT / "scripts/test_stage12c5ds.sh").read_text(encoding="utf-8")
    assert "prompt execution compact announcement owner" in source
    assert "test_stage12c5dr.sh" in source
    assert "test_${test_name}_12c5ds" in source
    assert "tests/test_stage12c5ds_source.py" in source
    assert "tests/test_stage12c5dr_source.py" in source


def test_prompt_execution_owns_compact_announcement_tokens() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(
        encoding="utf-8"
    )
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    assert "def prompt_execution_compact_announcement_tokens(" in owner
    assert "primfaktorenvergleich" in owner
    assert "prompt_execution_has_mulpri(prepared_tokens, language, catalog)" in owner
    assert "if not prompt_execution_contains_token(result, translated):" in owner
    assert (
        "prompt_execution_compact_announcement_tokens" in controller
        or "plan_prompt_execution_compact_announcement" in controller
        or "plan_prompt_execution_native_branch" in controller
    )
    assert "def _compact_announcement_tokens(" not in controller
    assert "def _contains_token(" not in controller
    assert "prompt_execution_contains_token" not in controller


def test_compact_announcement_owner_is_documented_and_pure() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(
        encoding="utf-8"
    )
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    doc = (ROOT / "STAGE12C5DS_PROMPT_EXECUTION_COMPACT_ANNOUNCEMENT_OWNER.md").read_text(
        encoding="utf-8"
    )
    assert "std.python" not in owner
    assert "PythonObject" not in owner
    assert "prompt_execution_compact_announcement_tokens" in matrix
    assert "prompt_execution_compact_announcement_tokens" in doc
    assert "No `.so`/`.dll` split is implemented" in doc
