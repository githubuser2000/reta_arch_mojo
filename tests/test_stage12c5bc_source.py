from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_chains_positive_first_fraction_runtime_gate() -> None:
    current = _text("scripts/test_current_stage.sh")
    newest = _text("scripts/test_stage12c5bd.sh")
    stage = _text("scripts/test_stage12c5bc.sh")
    assert "test_stage12c5" in current
    assert '"$ROOT/scripts/test_stage12c5bc.sh"' in newest
    assert '"$ROOT/scripts/test_stage12c5bb.sh"' in stage
    assert "tests/test_install_layout.py" in stage
    assert "tests/test_installed_launcher_fallback_source.py" in stage


def test_stage_document_records_source_tree_and_installed_tree_behavior() -> None:
    document = _text("STAGE12C5BC_INSTALLED_LAUNCHER_MISSING_TARGET.md")
    assert "run_source_or_missing" in document
    assert "Exitstatus 127" in document
    assert "src/table_main.mojo" in document
    assert "universum v1/4,-2/3" in document
