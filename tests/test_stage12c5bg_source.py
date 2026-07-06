from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_extends_12c5bf_and_has_focused_mode() -> None:
    stage = (ROOT / "scripts/test_stage12c5bg.sh").read_text(encoding="utf-8")
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ed.sh" in current:
        return
    assert 'RETA_STAGE_SKIP_PREVIOUS' in stage
    assert 'test_stage12c5bf.sh' in stage
    assert 'generate_command_parity_assets.py --check' in stage
    assert 'check_command_parity_native.py' in stage
    assert 'test_prompt_table_execution_12c5bg' in stage
    assert 'check_prompt_true_fraction_multiples.sh' in stage
    assert "test_stage12c5" in current


def test_stage_document_records_user_build_and_both_repairs() -> None:
    document = (
        ROOT / "STAGE12C5BG_DETERMINISTIC_COMMAND_PARITY_INTEGER_FRACTION_AXES.md"
    ).read_text(encoding="utf-8")
    for marker in (
        "vollständige native Build von Stage 12c5bf war erfolgreich",
        "optionale `rich`-Installation",
        "_base_projected_fraction_multiple_tokens",
        "universum motive v2/3,5",
        "RETA_STAGE_SKIP_PREVIOUS=1 scripts/test_stage12c5bg.sh",
    ):
        assert marker in document


def test_default_commit_and_public_entrypoint_are_current() -> None:
    do_script = (ROOT / "do.sh").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    assert 'COMMIT_MESSAGE=${1:-12c5bk}' in do_script
    assert "STAGE12C5BG_DETERMINISTIC_COMMAND_PARITY_INTEGER_FRACTION_AXES.md" in readme
