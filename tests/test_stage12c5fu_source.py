from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_points_to_fu_and_preserves_prompt_history() -> None:
    current = _read("scripts/test_current_stage.sh")
    assert "test_stage12c5fu.sh" in current
    assert "test_stage12c5ft.sh" in current
    assert current.index("test_stage12c5fu.sh") < current.index("test_stage12c5ft.sh")


def test_build_all_promotes_prompt_shared_group_after_core() -> None:
    build_all = _read("scripts/build-all.sh")
    assert "build_core_shared.sh" in build_all
    assert "build_prompt_shared.sh" in build_all
    assert build_all.index("build_core_shared.sh") < build_all.index("build_prompt_shared.sh")
    assert "Core- und Prompt-Shared-Artefakte" in build_all
    assert "Core- und Prompt-Dünnstarter" in build_all


def test_build_layout_requires_prompt_shared_artifacts() -> None:
    layout = _read("scripts/check_build_layout.sh")
    assert "rp rpl rpe rpb" in layout
    assert "libreta-prompt.so" in layout
    assert "libreta-prompt-interactive.so" in layout
    assert "scripts/build_prompt_shared.sh" in layout
    assert "rpb und libreta-prompt" in layout
    assert "libreta-prompt-interactive" in layout


def test_install_layout_carries_prompt_shared_runtime() -> None:
    install = _read("scripts/install.sh")
    targets = _read("scripts/install_targets.txt")
    check = _read("scripts/check_install_layout.sh")
    for name in ("rp", "rpl", "rpe", "rpb"):
        assert f"\n{name}\n" in f"\n{targets}\n"
        assert f"target/bin/{name}" in check
    assert "for prompt_starter in rp rpl rpe rpb" in install
    assert 'require_file "$TARGETDIR/$prompt_starter"' in install
    assert "libreta-prompt.so" in install
    assert "libreta-prompt-interactive.so" in install
    assert "libreta-prompt.so" in check
    assert "libreta-prompt-interactive.so" in check


def test_public_prompt_launchers_are_thin_shared_starters() -> None:
    for name in ("rp", "rpl", "rpe", "rpb"):
        launcher = _read(f"bin/{name}")
        assert "PROMPT_STARTER=\"$ROOT/target/bin/$PROFILE\"" in launcher
        assert "exec \"$PROMPT_STARTER\" \"$@\"" in launcher
        assert "reta-prompt-native" not in launcher
        assert "mojo-real" not in launcher
        assert "mojo-runtime-exec" not in launcher
        assert "select_reference_python.sh" in launcher


def test_stage_script_proves_official_prompt_layout_source_side() -> None:
    stage = _read("scripts/test_stage12c5fu.sh")
    assert "prompt shared official build layout" in stage
    assert "test_stage12c5ft.sh" in stage
    assert "build_prompt_shared.sh" in stage and "--dry-run" in stage
    assert "test_stage12c5fu_source.py" in stage
    assert "stage12c5fu prompt shared official build layout complete" in stage
