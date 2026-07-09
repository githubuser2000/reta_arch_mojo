from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_fr_and_keeps_fq_history() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fr.sh" in current
    assert "test_stage12c5fq.sh" in current
    assert current.index("test_stage12c5fr.sh") < current.index("test_stage12c5fq.sh")


def test_stage_script_chains_fq_and_rebuilds_shared_library_plan_test() -> None:
    script = (ROOT / "scripts/test_stage12c5fr.sh").read_text(encoding="utf-8")
    assert "shared library architecture copyability fix" in script
    assert "test_stage12c5fq.sh" in script
    assert "test_shared_library_architecture.mojo" in script
    assert "test_shared_library_architecture_12c5fr" in script
    assert "tests/test_stage12c5fr_source.py" in script
    assert "stage12c5fr shared library architecture copyability fix complete" in script


def test_shared_library_architecture_uses_explicit_list_moves_and_copies() -> None:
    source = (ROOT / "src/reta_mojo/shared_library_architecture.mojo").read_text(
        encoding="utf-8"
    )
    assert "var thin_starter_count = len(starters)" in source
    assert "libraries^," in source
    assert "starters^," in source
    assert "thin_starter_count," in source
    assert "var target = plan.libraries[index].copy()" in source
    assert "var target = plan.libraries[index]\n" not in source
    assert "len(starters)," not in source


def test_shared_library_architecture_still_preserves_rpb_noninteractive_contract() -> None:
    source = (ROOT / "src/reta_mojo/shared_library_architecture.mojo").read_text(
        encoding="utf-8"
    )
    assert 'ThinStarterTarget("rpb", _starter_libraries_prompt(), False)' in source
    assert 'if _target_has_consumer(target, "rpb"):' in source
    assert "libreta_prompt_interactive_mojo" in source
    start = source.index("def _interactive_consumers")
    block = source[start : source.index("def _deps_core", start)]
    assert '"rp"' in block and '"rpl"' in block and '"rpe"' in block
    assert '"rpb"' not in block


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FR_SHARED_LIBRARY_ARCHITECTURE_COPYABILITY_FIX.md").read_text(
        encoding="utf-8"
    )
    assert "Copyability" in doc
    assert "libraries" in doc and "starters" in doc
    assert "libreta_core_mojo" in doc
    assert "libreta_prompt_interactive_mojo" in doc
    assert "rpb" in doc and "Nicht verwendet" in doc
