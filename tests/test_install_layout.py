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
    private = prefix / "lib" / "reta"
    shared = prefix / "share" / "reta"

    assert (shared / "csv" / "religion.csv").is_file()
    assert (shared / "assets" / "parameter_aliases.tsv").is_file()
    assert (shared / "assets" / "input_semantics_catalog.tsv").is_file()
    assert (prefix / "share" / "man" / "man1" / "generate_html.1").is_file()
    assert (private / "python_reference" / "csv").is_symlink()
    assert (private / "python_reference" / "csv" / "religion.csv").is_file()
    assert (private / "assets").is_symlink()
    assert (private / "assets" / "parameter_aliases.tsv").is_file()
    assert (private / "assets" / "input_semantics_catalog.tsv").is_file()
    assert (private / "scripts" / "check_mojo_binary_freshness.sh").is_file()
    assert (private / "scripts" / "current_source_id.sh").is_file()

    # Without a compiled thin reta starter in this minimal staged test, reta stays
    # a shell-wrapper symlink. Compiled targets that do exist are installed as
    # real binaries directly in bin, never below lib/reta.
    public_reta = prefix / "bin" / "reta"
    assert public_reta.is_symlink()
    assert public_reta.resolve() == (private / "bin" / "reta").resolve()
    assert (prefix / "bin" / "reta-native").is_file()
    assert not (private / "reta-native").exists()
    assert not list(prefix.rglob("*.reta-source-id"))

    public_integrity = prefix / "bin" / "reta-mojo-package-integrity"
    assert public_integrity.is_symlink()
    result = subprocess.run(
        [str(public_integrity), "--summary", str(ROOT / "python_reference")],
        cwd=tmp_path,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    installed_integrity = prefix / "bin" / "reta-mojo-package-integrity"
    if not installed_integrity.is_file() or installed_integrity.is_symlink():
        assert result.returncode == 127
        assert "Fehlendes Compilerziel" in result.stderr
    else:
        runtime_probe = subprocess.run(
            [str(private / "scripts" / "find_mojo_runtime.sh")],
            cwd=tmp_path,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if runtime_probe.returncode == 0:
            assert result.returncode == 0, result.stderr
            assert "file_count=457" in result.stdout
            assert "missing_required=0" in result.stdout
        else:
            assert result.returncode == 127
            assert "Keine vollständige Modular-Mojo-Laufzeit gefunden" in result.stderr

    layout = (private / "INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "csvdir=/usr/local/share/reta/csv" in layout
    assert "assetdir=/usr/local/share/reta/assets" in layout
    assert "mandir=/usr/local/share/man" in layout
    assert "binarydir=/usr/local/bin" in layout
    assert "sharedlibdir=/usr/local/lib/reta" in layout
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
    private = prefix / "lib" / "reta"
    shared = prefix / "share" / "reta"

    assert (shared / "csv" / "religion.csv").is_file()
    assert (shared / "assets" / "parameter_aliases.tsv").is_file()
    assert (shared / "assets" / "input_semantics_catalog.tsv").is_file()
    assert (private / "python_reference" / "csv").is_symlink()
    assert (private / "python_reference" / "csv" / "religion.csv").is_file()
    assert (prefix / "bin" / "reta").resolve() == (private / "bin" / "reta").resolve()
    assert (prefix / "bin" / "reta-native").is_file()
    assert not (private / "reta-native").exists()
    assert not list(prefix.rglob("*.reta-source-id"))

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
        runtime_probe = subprocess.run(
            [str(private / "scripts" / "find_mojo_runtime.sh")],
            cwd=tmp_path,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if runtime_probe.returncode == 0:
            assert csv_info.returncode == 0, csv_info.stderr
            assert "Zeilen: 1025" in csv_info.stdout
            assert "Spalten: 746" in csv_info.stdout
        else:
            assert csv_info.returncode == 127
            assert "Keine vollständige Modular-Mojo-Laufzeit gefunden" in csv_info.stderr

    layout = (private / "INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "csvdir=/home/alex/.local/share/reta/csv" in layout
    assert "assetdir=/home/alex/.local/share/reta/assets" in layout
    assert "binarydir=/home/alex/.local/bin" in layout
    assert "sharedlibdir=/home/alex/.local/lib/reta" in layout

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
    assert not (stage / "usr" / "local" / "share" / "man" / "man1" / "generate_html.1").exists()
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
    assert (stage / "usr" / "bin" / "reta-native").is_file()
    assert not (private / "reta-native").exists()
    assert (private / "python_reference" / "csv").is_symlink()
    assert (private / "python_reference" / "csv" / "religion.csv").is_file()
    assert (shared / "csv" / "religion.csv").is_file()
    assert (stage / "usr" / "bin" / "reta").resolve() == (private / "bin" / "reta").resolve()
    assert not list((stage / "usr").rglob("*.reta-source-id"))
