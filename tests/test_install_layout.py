from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def _current_source_id() -> str:
    return subprocess.run(
        [str(ROOT / "scripts/current_source_id.sh")],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        check=True,
    ).stdout.strip() + "\n"


def _write_stub_target(path: Path) -> None:
    path.write_text("#!/bin/sh\nexit 0\n", encoding="utf-8")
    path.chmod(0o755)
    path.with_name(path.name + ".reta-source-id").write_text(
        _current_source_id(), encoding="utf-8"
    )


def _layout_target_dir(tmp_path: Path) -> Path:
    # FHS layout tests must not depend on foreign or locally compiled Mojo
    # binaries.  The installer only requires these three mandatory artifacts;
    # their runtime semantics are covered by dedicated native tests.
    target_dir = tmp_path / "layout-targets"
    target_dir.mkdir(parents=True, exist_ok=True)
    for name in ("reta-native", "reta-mojo-compat-bin", "generate-html-native"):
        _write_stub_target(target_dir / name)
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


def test_fhs_usr_local_layout_uses_share_for_csv_and_assets(tmp_path: Path) -> None:
    stage = _install(tmp_path)
    prefix = stage / "usr" / "local"
    libdir = prefix / "lib"
    libdir = prefix / "lib"
    private = prefix / "lib" / "reta"
    shared = prefix / "share" / "reta"

    assert (shared / "csv" / "religion.csv").is_file()
    assert (shared / "assets" / "parameter_aliases.tsv").is_file()
    assert (shared / "assets" / "input_semantics_catalog.tsv").is_file()
    for manpage in ("generate_html.1", "reta.1", "rp.1", "rpl.1", "rpe.1", "rpb.1"):
        assert (prefix / "share" / "man" / "man1" / manpage).is_file()
    assert not (private / "python_reference").exists()
    assert (shared / "python_reference" / "csv").is_dir()
    assert not (shared / "python_reference" / "csv").is_symlink()
    assert (shared / "python_reference" / "csv" / "religion.csv").is_file()
    assert not (private / "assets").exists()
    assert not (private / "bin").exists()
    assert not (private / "scripts").exists()

    # Minimal staged tests only provide three compiled targets. Those real
    # binaries go directly to bin; no fallback launcher depot is created below
    # lib/reta.
    assert not (prefix / "bin" / "reta").exists()
    assert (prefix / "bin" / "reta-native").is_file()
    assert not (private / "reta-native").exists()
    assert (prefix / "bin" / "mojo-runtime-exec").is_file()
    assert not list(prefix.rglob("*.reta-source-id"))
    assert not [p for p in prefix.rglob("*") if p.is_symlink()]
    for wrapper in ("generate_html", "generate4readme", "reta-extract-html-classes", "reta-mojo", "reta-mojo-compat"):
        assert (prefix / "bin" / wrapper).is_file()
        assert not (prefix / "bin" / wrapper).is_symlink()

    assert not private.exists()
    layout = (shared / "INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "csvdir=/usr/local/share/reta/csv" in layout
    assert "assetdir=/usr/local/share/reta/assets" in layout
    assert "referencedir=/usr/local/share/reta/python_reference" in layout
    assert "mandir=/usr/local/share/man" in layout
    assert "binarydir=/usr/local/bin" in layout
    assert "libdir=/usr/local/lib" in layout
    assert "legacy_libexecdir=/usr/local/lib/reta" in layout
    assert "sharedlibdir=/usr/local/lib" in layout
    assert "installed_source_id_sidecars=0" in layout

    help_result = subprocess.run(
        [str(prefix / "bin" / "generate_html"), "--help"],
        cwd=tmp_path,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert help_result.returncode == 0, help_result.stderr
    assert "--middle-file" in help_result.stdout


def test_default_prefix_is_usr_local(tmp_path: Path) -> None:
    stage = tmp_path / "stage"
    result = subprocess.run(
        [str(ROOT / "scripts" / "install.sh")],
        cwd=ROOT,
        env={
            **os.environ,
            "DESTDIR": str(stage),
            "RETA_INSTALL_MOJO_RUNTIME": "0",
            "RETA_TARGET_DIR": str(_layout_target_dir(tmp_path)),
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert (stage / "usr" / "local" / "share" / "reta" / "csv" / "religion.csv").is_file()
    assert (stage / "usr" / "local" / "bin" / "reta-native").is_file()
    assert not (stage / "usr" / "local" / "lib" / "reta" / "reta-native").exists()
    assert not list((stage / "usr" / "local").rglob("*.reta-source-id"))



def test_user_local_prefix_keeps_data_below_home_share(tmp_path: Path) -> None:
    stage = _install(tmp_path, prefix="/home/alex/.local")
    prefix = stage / "home" / "alex" / ".local"
    libdir = prefix / "lib"
    private = prefix / "lib" / "reta"
    shared = prefix / "share" / "reta"

    assert (shared / "csv" / "religion.csv").is_file()
    assert (shared / "assets" / "parameter_aliases.tsv").is_file()
    assert (shared / "assets" / "input_semantics_catalog.tsv").is_file()
    assert not (private / "python_reference").exists()
    assert not (private / "bin").exists()
    assert not (private / "scripts").exists()
    assert (shared / "python_reference" / "csv").is_dir()
    assert not (shared / "python_reference" / "csv").is_symlink()
    assert (shared / "python_reference" / "csv" / "religion.csv").is_file()
    assert not (prefix / "bin" / "reta").exists()
    assert (prefix / "bin" / "reta-native").is_file()
    assert not (private / "reta-native").exists()
    assert not list(prefix.rglob("*.reta-source-id"))
    assert not [p for p in prefix.rglob("*") if p.is_symlink()]

    csv_info = subprocess.run(
        [str(prefix / "bin" / "reta-mojo"), "--mojo-csv-info"],
        cwd=tmp_path,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    installed_table = prefix / "bin" / "reta-mojo-table"
    if not installed_table.is_file() or installed_table.is_symlink():
        assert csv_info.returncode == 127
        assert "Fehlendes Compilerziel" in csv_info.stderr
        assert "Keine installierte Mojo-Quelle verfügbar" in csv_info.stderr
    else:
        if (prefix / "lib" / "libKGENCompilerRTShared.so").exists():
            assert csv_info.returncode == 0, csv_info.stderr
            assert "Zeilen: 1025" in csv_info.stdout
            assert "Spalten: 746" in csv_info.stdout
        else:
            assert csv_info.returncode == 127
            assert "Keine vollständige Modular-Mojo-Laufzeit gefunden" in csv_info.stderr

    assert not private.exists()
    layout = (shared / "INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "csvdir=/home/alex/.local/share/reta/csv" in layout
    assert "assetdir=/home/alex/.local/share/reta/assets" in layout
    assert "referencedir=/home/alex/.local/share/reta/python_reference" in layout
    assert "binarydir=/home/alex/.local/bin" in layout
    assert "libdir=/home/alex/.local/lib" in layout
    assert "legacy_libexecdir=/home/alex/.local/lib/reta" in layout
    assert "sharedlibdir=/home/alex/.local/lib" in layout

def test_shared_libraries_install_flat_below_libdir_and_are_not_executable(tmp_path: Path) -> None:
    target_dir = _layout_target_dir(tmp_path)
    target_root = target_dir.parent
    target_lib = target_root / "lib" / "reta"
    target_lib.mkdir(parents=True, exist_ok=True)
    for starter in ("reta", "grundStrukHtml", "rpb", "rp", "rpl", "rpe"):
        _write_stub_target(target_dir / starter)
    for library in (
        "libreta_core_mojo.so",
        "libreta_prompt_mojo.so",
        "libreta_prompt_interactive_mojo.so",
    ):
        (target_lib / library).write_text("fake shared library\n", encoding="utf-8")
        (target_lib / f"{library}.reta-source-id").write_text(_current_source_id(), encoding="utf-8")

    stage = tmp_path / "stage"
    result = subprocess.run(
        [str(ROOT / "scripts" / "install.sh")],
        cwd=ROOT,
        env={
            **os.environ,
            "DESTDIR": str(stage),
            "PREFIX": "/usr/local",
            "RETA_INSTALL_MOJO_RUNTIME": "0",
            "RETA_TARGET_DIR": str(target_dir),
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    prefix = stage / "usr" / "local"
    for library in (
        "libreta_core_mojo.so",
        "libreta_prompt_mojo.so",
        "libreta_prompt_interactive_mojo.so",
    ):
        installed = prefix / "lib" / library
        assert installed.is_file()
        assert not os.access(installed, os.X_OK)
        assert not (prefix / "lib" / "reta" / library).exists()
        assert not (prefix / "lib" / f"{library}.reta-source-id").exists()

def test_uninstall_removes_only_reta_layout(tmp_path: Path) -> None:
    stage = _install(tmp_path)
    unrelated = stage / "usr" / "local" / "share" / "keep-me"
    unrelated.parent.mkdir(parents=True, exist_ok=True)
    unrelated.write_text("unrelated", encoding="utf-8")

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
    assert not (stage / "usr" / "local" / "lib" / "reta").exists()
    assert not (stage / "usr" / "local" / "share" / "reta").exists()
    for command in ("reta-native", "generate-html-native", "reta-mojo-compat-bin", "generate_html", "reta-mojo", "reta-mojo-compat", "mojo-runtime-exec"):
        assert not (stage / "usr" / "local" / "bin" / command).exists()
    for manpage in ("generate_html.1", "reta.1", "rp.1", "rpl.1", "rpe.1", "rpb.1"):
        assert not (stage / "usr" / "local" / "share" / "man" / "man1" / manpage).exists()
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
    libdir = stage / "usr" / "lib"
    shared = stage / "usr" / "share" / "reta"
    assert (stage / "usr" / "bin" / "reta-native").is_file()
    assert not (private / "reta-native").exists()
    assert not (private / "python_reference").exists()
    assert not (private / "bin").exists()
    assert not (private / "scripts").exists()
    assert (shared / "python_reference" / "csv").is_dir()
    assert not (shared / "python_reference" / "csv").is_symlink()
    assert (shared / "python_reference" / "csv" / "religion.csv").is_file()
    assert (shared / "csv" / "religion.csv").is_file()
    assert not (stage / "usr" / "bin" / "reta").exists()
    assert not list((stage / "usr").rglob("*.reta-source-id"))
