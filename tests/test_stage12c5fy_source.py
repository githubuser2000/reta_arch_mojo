from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_points_to_fy_and_preserves_release_history() -> None:
    current = _read("scripts/test_current_stage.sh")
    assert "test_stage12c5fy.sh" in current
    assert "test_stage12c5fx.sh" in current
    assert "test_stage12c5fw.sh" in current
    assert current.index("test_stage12c5fy.sh") < current.index("test_stage12c5fx.sh")
    assert current.index("test_stage12c5fx.sh") < current.index("test_stage12c5fw.sh")


def test_prompt_runtime_smoke_accepts_missing_library_or_stamp_diagnostics() -> None:
    smoke = _read("scripts/test_prompt_shared_runtime.sh")
    assert "RETA_PROMPT_LIBRARY=/definitely/missing" in smoke
    assert "Prompt-Bibliothek konnte nicht geladen werden" in smoke
    assert "Prompt-Starter und Shared Library stammen nicht aus demselben Quellstand" in smoke
    assert "bekannten Diagnose" in smoke
    assert "cat \"$TMP/rpb-missing.err\"" in smoke


def test_prompt_runtime_smoke_reports_command_output_mismatches() -> None:
    smoke = _read("scripts/test_prompt_shared_runtime.sh")
    assert "rpb lieferte nicht die erwartete Primfaktor-Ausgabe" in smoke
    assert "Erwartet: 60: 2^2 3 5" in smoke
    assert "cat \"$TMP/rpb-prim\"" in smoke
    assert "rp lieferte im interaktiven Prompt-Smoke keine Primzahl-Ausgabe" in smoke
    assert "cat \"$TMP/rp\"" in smoke


def test_build_all_keeps_runtime_smoke_but_now_has_non_silent_failures() -> None:
    build_all = _read("scripts/build-all.sh")
    smoke = _read("scripts/test_prompt_shared_runtime.sh")
    assert "test_prompt_shared_runtime.sh" in build_all
    assert "RETA_SKIP_PROMPT_SHARED_RUNTIME_SMOKE" in build_all
    assert "set -e" in smoke
    assert "rpb scheiterte bei fehlender libreta_prompt_mojo.so nicht" in smoke


def test_stage_script_collects_fy_regression_guards() -> None:
    stage = _read("scripts/test_stage12c5fy.sh")
    assert "prompt shared missing library diagnostic fix" in stage
    assert "test_stage12c5fx.sh" in stage
    assert "test_prompt_shared_runtime.sh" in stage and "--dry-run" in stage
    assert "test_stage12c5fy_source.py" in stage
    assert "stage12c5fy prompt shared runtime missing-library diagnostic fix complete" in stage


def test_stage_is_documented() -> None:
    doc = _read("STAGE12C5FY_PROMPT_SHARED_RUNTIME_DIAGNOSTIC_FIX.md")
    assert "Exitstatus 1" in doc
    assert "RETA_PROMPT_LIBRARY=/definitely/missing" in doc
    assert "Stempelprüfung" in doc
    assert "Prompt-Bibliothek konnte nicht geladen werden" in doc
