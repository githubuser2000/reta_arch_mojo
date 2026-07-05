from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_targets_bq_and_chains_bp() -> None:
    current = _text("scripts/test_current_stage.sh")
    stage = _text("scripts/test_stage12c5bq.sh")
    assert "test_stage12c5bq.sh" in current
    assert '"$ROOT/scripts/test_stage12c5bp.sh"' in stage
    assert "RETA_STAGE_SKIP_PREVIOUS" in stage
    assert "check_prompt_true_fraction_multiples.sh" in stage
    assert "tests/test_python_fraction_multiple_scope_reference.py" in stage


def test_stage_document_binds_local_and_global_v_semantics() -> None:
    document = _text("STAGE12C5BQ_POSITION_INDEPENDENT_MULTIPLE_SCOPE.md")
    assert "Kompaktes Präfix-v ist kommalokal" in document
    assert "Ein eigenständiges `v` oder `vielfache` ist global" in document
    assert "v universum 1/4,-1/8,2/3" in document
    assert "universum 1/4,-1/8,2/3 v" in document
    assert "2 Aufrufe" in document
    assert "13 Aufrufe" in document
    assert "4 Aufrufe" in document
    assert "19 Aufrufe" in document


def test_defect_067_records_scope_overreach_not_scope_loss() -> None:
    defects = _text("KNOWN_DEFECTS.json")
    assert '"id": "MOJO-FIXED-067"' in defects
    assert '"classification": "compact_v_fraction_scope_overreach"' in defects
    assert '"python_status": "correct_reference"' in defects
    assert "compact_v_fraction_scope_loss" not in defects


def test_python_architecture_progress_detects_the_project_git_root() -> None:
    source = _text("python_reference/tests/test_architecture_refactor.py")
    assert '(REPO_ROOT.parent / ".git").exists()' in source
    assert '(REPO_ROOT / ".git").exists()' not in source


def test_python_program_workflow_snapshot_uses_the_real_step_name() -> None:
    source = _text("python_reference/tests/test_architecture_refactor.py")
    assert 'self.assertIn("load_religion_table", snapshot["orchestration_steps"])' in source
    assert "load_/religion_table" not in source


def test_stage_reports_a_stale_tracked_tmp_with_an_exact_cleanup_command() -> None:
    stage = _text("scripts/test_stage12c5bq.sh")
    assert "git ls-files --error-unmatch" in stage
    assert "tests/test_prompt_runtime.mojo.tmp" in stage
    assert "git rm --cached --ignore-unmatch" in stage
