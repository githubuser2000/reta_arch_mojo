from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_fp() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fp.sh" in current
    assert "test_stage12c5fo.sh" in current


def test_stage_script_chains_fo_and_checks_core_shared_abi() -> None:
    script = (ROOT / "scripts/test_stage12c5fp.sh").read_text(encoding="utf-8")
    assert "core shared ABI thin starter" in script
    assert "test_stage12c5fo.sh" in script
    assert "build_core_shared.sh" in script and "--dry-run" in script
    assert "test_shared_library_architecture.mojo" in script
    assert "tests/test_core_shared_library_source.py" in script
    assert "tests/test_stage12c5fp_source.py" in script
    assert "stage12c5fp core shared ABI thin starter complete" in script


def test_core_abi_source_owns_reta_and_grundstrukhtml_entries() -> None:
    source = (ROOT / "src/reta_core_abi.mojo").read_text(encoding="utf-8")
    assert "comptime RETA_CORE_ABI_VERSION = 1" in source
    assert "def reta_core_abi_version()" in source
    assert "def reta_core_reta_entry(" in source
    assert "def reta_core_grundstrukhtml_entry(" in source
    assert "owned_c_argv" in source
    assert "run_native_reta" in source
    assert "csv_resource(\"religion.csv\")" in source
    assert "render_grundstrukturen_html" in source
    assert "String" not in "\n".join(
        line for line in source.splitlines() if line.startswith("def reta_core_")
    )


def test_core_loader_dispatches_only_core_consumers() -> None:
    source = (ROOT / "tools/reta_core_loader.c").read_text(encoding="utf-8")
    assert "libreta-core.so" in source
    assert "libreta-core.dll" in source
    assert "reta_core_abi_version" in source
    assert "reta_core_reta_entry" in source
    assert "reta_core_grundstrukhtml_entry" in source
    assert "RETA_CORE_LIBRARY" in source
    assert "libreta-prompt" not in source
    assert "libreta-prompt-interactive" not in source


def test_core_build_script_keeps_old_native_executables_and_adds_thin_starters() -> None:
    script = (ROOT / "scripts/build_core_shared.sh").read_text(encoding="utf-8")
    assert "libreta-core.so" in script
    assert "src/reta_core_abi.mojo" in script
    assert "reta-native" in script
    assert "grundStrukHtml-native" in script
    assert '"$TARGET_DIR/reta"' in script
    assert '"$TARGET_DIR/grundStrukHtml"' in script
    assert "--dry-run" in script
    assert "libreta-prompt-interactive" not in script


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FP_CORE_SHARED_ABI_THIN_STARTERS.md").read_text(
        encoding="utf-8"
    )
    assert "libreta-core" in doc
    assert "reta" in doc
    assert "grundStrukHtml" in doc
    assert "dünne Starter" in doc
    assert "rp/rpl/rpe/rpb" in doc
    assert "nicht" in doc.lower()
