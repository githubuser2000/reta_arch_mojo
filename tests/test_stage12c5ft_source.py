from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_ft_and_keeps_fs_history() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ft.sh" in current
    assert "test_stage12c5fs.sh" in current
    assert "test_stage12c5fr.sh" in current
    assert current.index("test_stage12c5ft.sh") < current.index("test_stage12c5fs.sh")


def test_stage_script_chains_fs_and_checks_prompt_shared_path() -> None:
    script = (ROOT / "scripts/test_stage12c5ft.sh").read_text(encoding="utf-8")
    assert "prompt shared ABI thin starters" in script
    assert "test_stage12c5fs.sh" in script
    assert "build_prompt_shared.sh" in script and "--dry-run" in script
    assert "build_shared_library_targets.sh" in script and "--dry-run" in script
    assert "test_shared_library_architecture.mojo" in script
    assert "test_shared_library_architecture_12c5ft" in script
    assert "tests/test_prompt_shared_library_source.py" in script
    assert "stage12c5ft prompt shared ABI thin starters complete" in script


def test_prompt_shared_abi_files_are_present_and_narrow() -> None:
    prompt = (ROOT / "src/reta_prompt_abi.mojo").read_text(encoding="utf-8")
    interactive = (ROOT / "src/reta_prompt_interactive_abi.mojo").read_text(
        encoding="utf-8"
    )
    for source in (prompt, interactive):
        assert "owned_c_argv" in source
        assert "run_prompt_profile_from_args" in source
        assert "UnsafePointer" in source
        signature_lines = "\n".join(
            line for line in source.splitlines() if line.startswith("def reta_prompt")
        )
        assert "List[" not in signature_lines
        assert "String" not in signature_lines


def test_prompt_loader_routes_rpb_away_from_interactive_library() -> None:
    loader = (ROOT / "tools/reta_prompt_loader.c").read_text(encoding="utf-8")
    assert '{"rpb", "rpb", "libreta-prompt.so"' in loader
    assert "libreta-prompt-interactive.so" in loader
    rpb_entry = loader[loader.index('{"rpb"') : loader.index('{"rp"')]
    assert "libreta-prompt-interactive" not in rpb_entry
    assert "reta_prompt_entry" in rpb_entry
    assert "reta_prompt_interactive_entry" not in rpb_entry


def test_prompt_shared_build_is_documented_and_promoted_after_ft() -> None:
    build = (ROOT / "scripts/build_prompt_shared.sh").read_text(encoding="utf-8")
    assert "libreta-prompt.so" in build
    assert "libreta-prompt-interactive.so" in build
    assert "target/bin/rpb" in build
    assert "target/bin/rp" in build
    assert "stamp_mojo_binary.sh" in build
    assert "sanitize_mojo_runpath.py" in build
    build_all = (ROOT / "scripts/build-all.sh").read_text(encoding="utf-8")
    assert "build_prompt_shared.sh" in build_all


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FT_PROMPT_SHARED_ABI_THIN_STARTERS.md").read_text(
        encoding="utf-8"
    )
    assert "libreta-prompt.so" in doc
    assert "libreta-prompt-interactive.so" in doc
    assert "rpb" in doc and "nicht" in doc
    assert "run_prompt_profile_from_args" in doc
