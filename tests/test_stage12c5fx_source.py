from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_points_to_fx_and_preserves_recent_history() -> None:
    current = _read("scripts/test_current_stage.sh")
    assert "test_stage12c5fx.sh" in current
    assert "test_stage12c5fw.sh" in current
    assert "test_stage12c5fv.sh" in current
    assert current.index("test_stage12c5fx.sh") < current.index("test_stage12c5fw.sh")
    assert current.index("test_stage12c5fw.sh") < current.index("test_stage12c5fv.sh")


def test_release_check_runs_install_layout_after_build_layout() -> None:
    release = _read("scripts/release_check.sh")
    assert "check_build_layout.sh" in release
    assert "check_install_layout.sh" in release
    assert release.index("check_build_layout.sh") < release.index("check_install_layout.sh")
    assert "FHS-/usr-Installation inklusive dünner Starter prüfen" in release
    assert "Alle Release-Prüfungen bestanden, inklusive FHS-/usr-Installation" in release


def test_release_check_has_dry_run_and_build_option_passthrough() -> None:
    release = _read("scripts/release_check.sh")
    assert "--dry-run" in release
    assert "Release-Prüfplan ausgegeben; keine Kommandos ausgeführt." in release
    assert '"$ROOT/scripts/build-all.sh" -- "$@"' in release
    assert "Mojo-Buildoptionen nach -- werden nur an scripts/build-all.sh weitergereicht." in release


def test_release_check_keeps_prompt_runtime_coverage_via_build_and_install() -> None:
    release = _read("scripts/release_check.sh")
    build_all = _read("scripts/build-all.sh")
    install_check = _read("scripts/check_install_layout.sh")
    assert "test_prompt_shared_runtime.sh" in build_all
    assert "test_prompt_shared_runtime.sh" in install_check
    assert "check_install_layout.sh" in release
    assert "rpb" in install_check and "RETA_PROMPT_INTERACTIVE_LIBRARY=/definitely/missing" in install_check


def test_stage_script_collects_release_check_guards() -> None:
    stage = _read("scripts/test_stage12c5fx.sh")
    assert "release check install layout gate" in stage
    assert "test_stage12c5fw.sh" in stage
    assert "release_check.sh" in stage and "--dry-run" in stage
    assert "test_stage12c5fx_source.py" in stage
    assert "stage12c5fx release check install layout gate complete" in stage


def test_stage_is_documented() -> None:
    doc = _read("STAGE12C5FX_RELEASE_CHECK_INSTALL_LAYOUT_GATE.md")
    assert "scripts/release_check.sh" in doc
    assert "scripts/check_install_layout.sh" in doc
    assert "libreta_prompt_interactive_mojo.so" in doc
    assert "rpb" in doc and "libreta_prompt_interactive_mojo.so" in doc
