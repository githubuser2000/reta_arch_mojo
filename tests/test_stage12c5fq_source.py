from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_fq_and_keeps_history() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fq.sh" in current
    assert "test_stage12c5fp.sh" in current
    assert current.index("test_stage12c5fq.sh") < current.index("test_stage12c5fp.sh")


def test_stage_script_chains_fp_and_checks_core_layout_contract() -> None:
    script = (ROOT / "scripts/test_stage12c5fq.sh").read_text(encoding="utf-8")
    assert "core shared official build layout" in script
    assert "test_stage12c5fp.sh" in script
    assert "build_core_shared.sh" in script and "--dry-run" in script
    assert "build_shared_library_targets.sh" in script and "--dry-run" in script
    assert "tests/test_stage12c5fq_source.py" in script
    assert "tests/test_core_shared_library_source.py" in script
    assert "stage12c5fq core shared official build layout complete" in script


def test_build_all_invokes_core_shared_before_layout_check() -> None:
    script = (ROOT / "scripts/build-all.sh").read_text(encoding="utf-8")
    assert "die offiziellen Core-Shared-Artefakte" in script
    assert '"$ROOT/scripts/build-heavy.sh" -- "$@"' in script
    assert '"$ROOT/scripts/build.sh" -- "$@"' in script
    assert '"$ROOT/scripts/build_core_shared.sh" -- "$@"' in script
    assert '"$ROOT/scripts/check_build_layout.sh"' in script
    assert script.index('"$ROOT/scripts/build.sh" -- "$@"') < script.index(
        '"$ROOT/scripts/build_core_shared.sh" -- "$@"'
    )
    assert script.index('"$ROOT/scripts/build_core_shared.sh" -- "$@"') < script.index(
        '"$ROOT/scripts/check_build_layout.sh"'
    )


def test_build_layout_requires_core_library_and_thin_starters() -> None:
    script = (ROOT / "scripts/check_build_layout.sh").read_text(encoding="utf-8")
    assert "expected='reta grundStrukHtml" in script
    assert "CORE_LIBRARY=\"$TARGET_LIB_DIR/libreta_core_mojo.so\"" in script
    assert "scripts/build_core_shared.sh" in script
    assert "erwartete Core-Shared-Library fehlt" in script
    assert "ELF-Core-Shared-Library" in script
    assert "Core-Dünnstarter und libreta_core_mojo haben verschiedene Source-IDs" in script
    assert '"$TARGET_DIR/reta" "$TARGET_DIR/grundStrukHtml" "$CORE_LIBRARY"' in script


def test_shared_library_targets_builds_active_core_group_only() -> None:
    script = (ROOT / "scripts/build_shared_library_targets.sh").read_text(
        encoding="utf-8"
    )
    assert "libreta_core_mojo.so ist inzwischen der erste aktiv kompilierte ABI-Build" in script
    assert "build_core_shared.sh" in script
    assert "Prompt-Shared-Libraries bleiben Plan" in script
    assert "libreta_prompt_interactive_mojo" in script
    assert "rpb           -> libreta_prompt_mojo + libreta_core_mojo" in script
    assert "mojo build" not in script


def test_install_target_inventory_knows_core_thin_starters() -> None:
    inventory = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8")
    assert "# core shared build_core_shared.sh targets" in inventory
    assert "\nreta\n" in inventory
    assert "\ngrundStrukHtml\n" in inventory
    assert inventory.index("reta\n") < inventory.index("# regular build.sh targets")
    assert inventory.index("grundStrukHtml\n") < inventory.index("# regular build.sh targets")


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FQ_CORE_SHARED_OFFICIAL_BUILD_LAYOUT.md").read_text(
        encoding="utf-8"
    )
    assert "libreta_core_mojo.so" in doc
    assert "target/bin/reta" in doc
    assert "target/bin/grundStrukHtml" in doc
    assert "scripts/build-all.sh" in doc
    assert "scripts/check_build_layout.sh" in doc
    assert "Source-ID" in doc
    assert "rpb" in doc and "keine interaktive" in doc
