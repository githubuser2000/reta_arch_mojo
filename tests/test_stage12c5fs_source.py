from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_fs_and_keeps_fr_history() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fs.sh" in current
    assert "test_stage12c5fr.sh" in current
    assert "test_stage12c5fq.sh" in current
    assert current.index("test_stage12c5fs.sh") < current.index("test_stage12c5fr.sh")


def test_stage_script_chains_fr_and_checks_public_launcher_contract() -> None:
    script = (ROOT / "scripts/test_stage12c5fs.sh").read_text(encoding="utf-8")
    assert "public core launchers" in script
    assert "test_stage12c5fr.sh" in script
    assert "build_core_shared.sh" in script and "--dry-run" in script
    assert "build_shared_library_targets.sh" in script and "--dry-run" in script
    assert "tests/test_stage12c5fs_source.py" in script
    assert "tests/test_core_shared_library_source.py" in script
    assert "stage12c5fs public core launchers complete" in script


def test_reta_public_launcher_is_only_a_core_thin_wrapper() -> None:
    launcher = (ROOT / "bin/reta").read_text(encoding="utf-8")
    assert 'CORE_STARTER="$ROOT/target/bin/reta"' in launcher
    assert 'exec "$CORE_STARTER" "$@"' in launcher
    assert "scripts/build_core_shared.sh oder scripts/build-all.sh" in launcher
    assert "reta-mojo-compat" not in launcher
    assert "reta-native" not in launcher
    assert "RETA_NATIVE" not in launcher
    assert "RETA_FORCE_REFERENCE" not in launcher
    assert "mojo-real" not in launcher


def test_grundstrukhtml_public_launcher_is_only_a_core_thin_wrapper() -> None:
    launcher = (ROOT / "bin/grundStrukHtml").read_text(encoding="utf-8")
    assert 'CORE_STARTER="$ROOT/target/bin/grundStrukHtml"' in launcher
    assert 'exec "$CORE_STARTER" "$@"' in launcher
    assert "scripts/build_core_shared.sh oder scripts/build-all.sh" in launcher
    assert "grundStrukHtml-native" not in launcher
    assert "mojo-real" not in launcher
    assert "mojo-runtime-exec" not in launcher


def test_install_script_installs_core_library_for_public_thin_launchers() -> None:
    script = (ROOT / "scripts/install.sh").read_text(encoding="utf-8")
    assert 'require_file "$TARGETDIR/reta"' in script
    assert 'require_file "$TARGETDIR/grundStrukHtml"' in script
    assert 'CORE_LIBRARY="$TARGETLIBDIR/libreta-core.so"' in script
    assert 'require_file "$CORE_LIBRARY"' in script
    assert 'require_file "$CORE_LIBRARY.reta-source-id"' in script
    assert 'require_file "$TARGETDIR/reta.reta-source-id"' in script
    assert 'require_file "$TARGETDIR/grundStrukHtml.reta-source-id"' in script
    assert 'install_shared_library "$CORE_LIBRARY" scripts/build_core_shared.sh' in script
    assert '$source_library.reta-source-id' in script
    assert 'install_shared_library "$CORE_LIBRARY" scripts/build_core_shared.sh' in script
    assert 'INSTALLED_LIBRARIES=$((INSTALLED_LIBRARIES + 1))' in script


def test_install_layout_checks_core_launcher_and_no_reference_for_public_reta() -> None:
    script = (ROOT / "scripts/check_install_layout.sh").read_text(encoding="utf-8")
    assert '[ -L "$STAGE_BINDIR/reta" ]' in script
    assert '[ -L "$STAGE_BINDIR/grundStrukHtml" ]' in script
    assert '[ -x "$STAGE_LIBEXECDIR/reta" ]' in script
    assert '[ -x "$STAGE_LIBEXECDIR/grundStrukHtml" ]' in script
    assert '[ -f "$STAGE_LIBEXECDIR/libreta-core.so" ]' in script
    assert '"$STAGE_BINDIR/reta" "$@" >"$TMP/core-launcher.out"' in script
    assert 'cmp "$TMP/reference.out" "$TMP/core-launcher.out"' in script
    assert "RETA_FORCE_REFERENCE=1" not in script
    assert "Core-Starter" in script
    assert 'PREFIX=${PREFIX:-/usr/local}' in script


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FS_PUBLIC_CORE_LAUNCHERS.md").read_text(
        encoding="utf-8"
    )
    assert "bin/reta" in doc
    assert "bin/grundStrukHtml" in doc
    assert "target/bin/reta" in doc
    assert "target/lib/reta/libreta-core.so" in doc
    assert "scripts/install.sh" in doc
    assert "reta-mojo-compat" in doc
    assert "rpb" in doc and "does not depend" in doc
