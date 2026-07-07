from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_current_stage_points_to_fv_and_preserves_prompt_history() -> None:
    current = _read("scripts/test_current_stage.sh")
    assert "test_stage12c5fv.sh" in current
    assert "test_stage12c5fu.sh" in current
    assert current.index("test_stage12c5fv.sh") < current.index("test_stage12c5fu.sh")


def test_runtime_smoke_script_proves_rpb_does_not_load_interactive_library() -> None:
    smoke = _read("scripts/test_prompt_shared_runtime.sh")
    assert "RETA_PROMPT_INTERACTIVE_LIBRARY=/definitely/missing" in smoke
    assert "\"$TARGET_DIR/rpb\" prim 60" in smoke
    assert "60: 2^2 3 5" in smoke
    assert "RETA_PROMPT_LIBRARY=/definitely/missing" in smoke
    assert "rpb lief trotz fehlender libreta-prompt.so" in smoke


def test_runtime_smoke_script_exercises_interactive_starters() -> None:
    smoke = _read("scripts/test_prompt_shared_runtime.sh")
    assert "printf 'prim 29\\nq\\n' | \"$TARGET_DIR/rp\"" in smoke
    assert "grep -F '29: 29'" in smoke
    assert "for name in rpl rpe" in smoke
    assert "Prompt-Shared-Runtime-Smoke bestanden." in smoke


def test_prompt_loader_loads_common_prompt_library_before_interactive_boundary() -> None:
    loader = _read("tools/reta_prompt_loader.c")
    assert "COMMON_PROMPT_LIBRARY" in loader
    assert "if (command->interactive)" in loader
    assert "RTLD_NOW | RTLD_GLOBAL" in loader
    assert "RTLD_NOW | RTLD_LOCAL" in loader
    rpb_entry = loader[loader.index('{"rpb",'):loader.index('{"rp",')]
    assert "libreta-prompt-interactive" not in rpb_entry


def test_stage_script_runs_runtime_smoke_after_build_all() -> None:
    stage = _read("scripts/test_stage12c5fv.sh")
    assert "prompt shared runtime smoke" in stage
    assert "test_stage12c5fu.sh" in stage
    assert "test_prompt_shared_runtime.sh" in stage
    assert "--dry-run" in stage
    assert "stage12c5fv prompt shared runtime smoke complete" in stage
