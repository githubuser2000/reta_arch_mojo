from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_points_to_fw_and_preserves_fv_history() -> None:
    current = _read("scripts/test_current_stage.sh")
    assert "test_stage12c5fw.sh" in current
    assert "test_stage12c5fv.sh" in current
    assert "test_stage12c5fu.sh" in current
    assert current.index("test_stage12c5fw.sh") < current.index("test_stage12c5fv.sh")
    assert current.index("test_stage12c5fv.sh") < current.index("test_stage12c5fu.sh")


def test_build_all_runs_prompt_shared_runtime_smoke_after_layout_check() -> None:
    build_all = _read("scripts/build-all.sh")
    assert "build_prompt_shared.sh" in build_all
    assert "check_build_layout.sh" in build_all
    assert "test_prompt_shared_runtime.sh" in build_all
    assert build_all.index("check_build_layout.sh") < build_all.index("test_prompt_shared_runtime.sh")
    assert "RETA_SKIP_PROMPT_SHARED_RUNTIME_SMOKE" in build_all
    assert "Prompt-Shared-Runtime-Smoke übersprungen" in build_all


def test_install_layout_runs_prompt_shared_runtime_smoke_on_installed_tree() -> None:
    check = _read("scripts/check_install_layout.sh")
    assert 'RETA_TARGET_DIR="$STAGE_LIBEXECDIR"' in check
    assert 'RETA_TARGET_LIB_DIR="$STAGE_LIBEXECDIR"' in check
    assert "test_prompt_shared_runtime.sh" in check
    assert "installed-prompt-runtime.out" in check
    assert "Prompt-Shared-Runtime-Smoke bestanden" in check
    assert '"$STAGE_BINDIR/rpb" prim 60' in check
    assert '"$STAGE_BINDIR/rp"' in check
    assert "Core-/Prompt-Starter" in check
    assert 'PREFIX=${PREFIX:-/usr/local}' in check


def test_runtime_smoke_still_keeps_rpb_non_interactive() -> None:
    smoke = _read("scripts/test_prompt_shared_runtime.sh")
    loader = _read("tools/reta_prompt_loader.c")
    assert "RETA_PROMPT_INTERACTIVE_LIBRARY=/definitely/missing" in smoke
    assert '"$TARGET_DIR/rpb" prim 60' in smoke
    assert "RETA_PROMPT_LIBRARY=/definitely/missing" in smoke
    rpb_entry = loader[loader.index('{"rpb",') : loader.index('{"rp",')]
    assert "libreta_prompt_mojo.so" in rpb_entry
    assert "libreta_prompt_interactive_mojo" not in rpb_entry


def test_stage_script_collects_build_install_smoke_guards() -> None:
    stage = _read("scripts/test_stage12c5fw.sh")
    assert "prompt shared build and install runtime smoke" in stage
    assert "test_stage12c5fv.sh" in stage
    assert "test_prompt_shared_runtime.sh" in stage
    assert "build_prompt_shared.sh" in stage and "--dry-run" in stage
    assert "test_stage12c5fw_source.py" in stage
    assert "stage12c5fw prompt shared build and install smoke complete" in stage


def test_stage_is_documented() -> None:
    doc = _read("STAGE12C5FW_PROMPT_SHARED_BUILD_AND_INSTALL_SMOKE.md")
    assert "RETA_SKIP_PROMPT_SHARED_RUNTIME_SMOKE" in doc
    assert "libreta_prompt_interactive_mojo.so" in doc
    assert "rpb -> NICHT libreta_prompt_interactive_mojo.so" in doc
    assert "check_install_layout.sh" in doc
