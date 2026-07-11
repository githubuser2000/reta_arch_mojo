from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PUBLIC_COMMANDS = ("reta", "rp", "rpl", "rpe", "rpb", "generate_html", "grundStrukHtml")
NEEDED_LIBRARIES = (
    "libreta_core_mojo.so",
    "libreta_prompt_mojo.so",
    "libreta_prompt_interactive_mojo.so",
)
RUNTIME_LIBRARIES = (
    "libKGENCompilerRTShared.so",
    "libAsyncRTMojoBindings.so",
    "libMSupportGlobals.so",
    "libAsyncRTRuntimeGlobals.so",
    "libNVPTX.so",
)
FORBIDDEN_COMMANDS = (
    "reta-native",
    "generate-html-native",
    "reta-prompt-native",
    "reta-prompt-complete",
    "reta-mojo",
    "reta-mojo-compat",
    "reta-mojo-diagnostics",
    "reta-mojo-boundaries",
    "reta-mojo-semantics",
    "mojo-runtime-exec",
)


def _current_source_id() -> str:
    return subprocess.run(
        [str(ROOT / "scripts/current_source_id.sh")],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        check=True,
    ).stdout.strip() + "\n"


def _write_stub_target(path: Path, source_id: str | None = None) -> None:
    if source_id is None:
        source_id = _current_source_id()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    path.chmod(0o755)
    path.with_name(path.name + ".reta-source-id").write_text(source_id, encoding="utf-8")


def _write_stub_library(path: Path, source_id: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("fake shared library\n", encoding="utf-8")
    path.with_name(path.name + ".reta-source-id").write_text(source_id, encoding="utf-8")


def _layout_target_dir(tmp_path: Path) -> Path:
    target_root = tmp_path / "layout-targets-root"
    target_dir = target_root / "bin"
    target_lib = target_root / "lib" / "reta"
    source_id = _current_source_id()
    for name in ("reta", "grundStrukHtml", "rp", "rpl", "rpe", "rpb", "generate-html-native"):
        _write_stub_target(target_dir / name, source_id)
    for library in NEEDED_LIBRARIES:
        _write_stub_library(target_lib / library, source_id)
    return target_dir


def _install(tmp_path: Path, prefix: str = "/usr/local") -> Path:
    stage = tmp_path / "stage"
    result = subprocess.run(
        [str(ROOT / "scripts" / "install.sh")],
        cwd=ROOT,
        env={
            **os.environ,
            "DESTDIR": str(stage),
            "PREFIX": prefix,
            "RETA_INSTALL_MOJO_RUNTIME": "0",
            "RETA_TARGET_DIR": str(_layout_target_dir(tmp_path)),
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    return stage


def _assert_public_only(prefix: Path) -> None:
    for command in PUBLIC_COMMANDS:
        assert (prefix / "bin" / command).is_file(), command
        assert not (prefix / "bin" / command).is_symlink()
    for command in FORBIDDEN_COMMANDS:
        assert not (prefix / "bin" / command).exists(), command


def test_fhs_usr_local_layout_uses_share_for_csv_assets_and_public_commands(tmp_path: Path) -> None:
    stage = _install(tmp_path)
    prefix = stage / "usr" / "local"
    private = prefix / "lib" / "reta"
    shared = prefix / "share" / "reta"

    assert (shared / "csv" / "religion.csv").is_file()
    assert (shared / "assets" / "parameter_aliases.tsv").is_file()
    assert (shared / "assets" / "input_semantics_catalog.tsv").is_file()
    for manpage in ("generate_html.1", "grundStrukHtml.1", "reta.1", "rp.1", "rpl.1", "rpe.1", "rpb.1"):
        assert (prefix / "share" / "man" / "man1" / manpage).is_file()
    assert not (private / "python_reference").exists()
    assert (shared / "python_reference" / "csv").is_dir()
    assert not (shared / "python_reference" / "csv").is_symlink()
    assert (shared / "python_reference" / "csv" / "religion.csv").is_file()
    assert not (private / "assets").exists()
    assert not (private / "bin").exists()
    assert not (private / "scripts").exists()
    assert not private.exists()
    _assert_public_only(prefix)
    assert not list(prefix.rglob("*.reta-source-id"))
    assert not [p for p in prefix.rglob("*") if p.is_symlink()]

    layout = (shared / "INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "csvdir=/usr/local/share/reta/csv" in layout
    assert "assetdir=/usr/local/share/reta/assets" in layout
    assert "referencedir=/usr/local/share/reta/python_reference" in layout
    assert "binarydir=/usr/local/bin" in layout
    assert "libdir=/usr/local/lib" in layout
    assert "sharedlibdir=/usr/local/lib" in layout
    assert "installed_public_commands=reta,rp,rpl,rpe,rpb,generate_html,grundStrukHtml" in layout


def test_default_prefix_is_usr_local(tmp_path: Path) -> None:
    stage = _install(tmp_path)
    assert (stage / "usr" / "local" / "share" / "reta" / "csv" / "religion.csv").is_file()
    for command in PUBLIC_COMMANDS:
        assert (stage / "usr" / "local" / "bin" / command).is_file()


def test_user_local_prefix_keeps_data_below_home_share(tmp_path: Path) -> None:
    stage = _install(tmp_path, prefix="/home/alex/.local")
    prefix = stage / "home" / "alex" / ".local"
    private = prefix / "lib" / "reta"
    shared = prefix / "share" / "reta"

    assert (shared / "csv" / "religion.csv").is_file()
    assert (shared / "assets" / "parameter_aliases.tsv").is_file()
    assert not (private / "python_reference").exists()
    assert not (private / "bin").exists()
    assert not (private / "scripts").exists()
    assert (shared / "python_reference" / "csv" / "religion.csv").is_file()
    _assert_public_only(prefix)
    assert not list(prefix.rglob("*.reta-source-id"))
    assert not [p for p in prefix.rglob("*") if p.is_symlink()]
    assert not private.exists()
    layout = (shared / "INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "binarydir=/home/alex/.local/bin" in layout
    assert "libdir=/home/alex/.local/lib" in layout


def test_shared_libraries_install_flat_below_libdir_and_are_not_executable(tmp_path: Path) -> None:
    stage = _install(tmp_path)
    prefix = stage / "usr" / "local"
    for library in NEEDED_LIBRARIES:
        installed = prefix / "lib" / library
        assert installed.is_file()
        assert not os.access(installed, os.X_OK)
        assert not (prefix / "lib" / "reta" / library).exists()
        assert not (prefix / "lib" / f"{library}.reta-source-id").exists()
    assert not (prefix / "lib" / "libreta_diagnostics_mojo.so").exists()


def test_uninstall_removes_current_and_legacy_reta_layout(tmp_path: Path) -> None:
    stage = _install(tmp_path)
    prefix = stage / "usr" / "local"
    unrelated = prefix / "share" / "keep-me"
    unrelated.parent.mkdir(parents=True, exist_ok=True)
    unrelated.write_text("unrelated", encoding="utf-8")
    # Simulate leftovers from the older broad install.
    for command in FORBIDDEN_COMMANDS:
        path = prefix / "bin" / command
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text("old", encoding="utf-8")
        path.chmod(0o755)

    result = subprocess.run(
        [str(ROOT / "scripts" / "uninstall.sh")],
        cwd=ROOT,
        env={**os.environ, "DESTDIR": str(stage), "PREFIX": "/usr/local"},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert not (prefix / "lib" / "reta").exists()
    assert not (prefix / "share" / "reta").exists()
    for command in PUBLIC_COMMANDS + FORBIDDEN_COMMANDS:
        assert not (prefix / "bin" / command).exists(), command
    for manpage in ("generate_html.1", "grundStrukHtml.1", "reta.1", "rp.1", "rpl.1", "rpe.1", "rpb.1"):
        assert not (prefix / "share" / "man" / "man1" / manpage).exists()
    assert unrelated.read_text(encoding="utf-8") == "unrelated"


def test_fedora_libexec_override_keeps_shared_data_in_usr_share(tmp_path: Path) -> None:
    stage = tmp_path / "stage"
    result = subprocess.run(
        [str(ROOT / "scripts" / "install.sh")],
        cwd=ROOT,
        env={
            **os.environ,
            "DESTDIR": str(stage),
            "PREFIX": "/usr",
            "LIBEXECDIR": "/usr/libexec/reta",
            "RETA_INSTALL_MOJO_RUNTIME": "0",
            "RETA_TARGET_DIR": str(_layout_target_dir(tmp_path)),
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    private = stage / "usr" / "libexec" / "reta"
    shared = stage / "usr" / "share" / "reta"
    for command in PUBLIC_COMMANDS:
        assert (stage / "usr" / "bin" / command).is_file()
    assert not (private / "python_reference").exists()
    assert not (private / "bin").exists()
    assert not (private / "scripts").exists()
    assert (shared / "python_reference" / "csv" / "religion.csv").is_file()
    assert not list((stage / "usr").rglob("*.reta-source-id"))
