from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def _install(tmp_path: Path, prefix: str = "/usr") -> Path:
    stage = tmp_path / "stage"
    result = subprocess.run(
        [str(ROOT / "scripts" / "install.sh")],
        cwd=ROOT,
        env={
            **os.environ,
            "DESTDIR": str(stage),
            "PREFIX": prefix,
            "RETA_INSTALL_MOJO_RUNTIME": "0",
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    return stage


def test_fhs_usr_layout_uses_share_for_csv_and_assets(tmp_path: Path) -> None:
    stage = _install(tmp_path)
    prefix = stage / "usr"
    private = prefix / "lib" / "reta"
    shared = prefix / "share" / "reta"

    assert (shared / "csv" / "religion.csv").is_file()
    assert (shared / "assets" / "parameter_aliases.tsv").is_file()
    assert (prefix / "share" / "man" / "man1" / "generate_html.1").is_file()
    assert (private / "python_reference" / "csv").is_symlink()
    assert (private / "python_reference" / "csv" / "religion.csv").is_file()
    assert (private / "assets").is_symlink()
    assert (private / "assets" / "parameter_aliases.tsv").is_file()

    public_reta = prefix / "bin" / "reta"
    assert public_reta.is_symlink()
    assert public_reta.resolve() == (private / "bin" / "reta").resolve()

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
    assert result.returncode == 0, result.stderr
    assert "file_count=457" in result.stdout
    assert "missing_required=0" in result.stdout

    layout = (private / "INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "csvdir=/usr/share/reta/csv" in layout
    assert "assetdir=/usr/share/reta/assets" in layout
    assert "mandir=/usr/share/man" in layout

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
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert (stage / "usr" / "local" / "share" / "reta" / "csv" / "religion.csv").is_file()
    assert (stage / "usr" / "local" / "bin" / "reta").is_symlink()



def test_user_local_prefix_keeps_data_below_home_share(tmp_path: Path) -> None:
    stage = _install(tmp_path, prefix="/home/alex/.local")
    prefix = stage / "home" / "alex" / ".local"
    private = prefix / "lib" / "reta"
    shared = prefix / "share" / "reta"

    assert (shared / "csv" / "religion.csv").is_file()
    assert (shared / "assets" / "parameter_aliases.tsv").is_file()
    assert (private / "python_reference" / "csv").is_symlink()
    assert (private / "python_reference" / "csv" / "religion.csv").is_file()
    assert (prefix / "bin" / "reta").resolve() == (private / "bin" / "reta").resolve()

    csv_info = subprocess.run(
        [str(prefix / "bin" / "reta-mojo"), "--mojo-csv-info"],
        cwd=tmp_path,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert csv_info.returncode == 0, csv_info.stderr
    assert "Zeilen: 1025" in csv_info.stdout
    assert "Spalten: 746" in csv_info.stdout

    layout = (private / "INSTALL_LAYOUT").read_text(encoding="utf-8")
    assert "csvdir=/home/alex/.local/share/reta/csv" in layout
    assert "assetdir=/home/alex/.local/share/reta/assets" in layout

def test_uninstall_removes_only_reta_layout(tmp_path: Path) -> None:
    stage = _install(tmp_path)
    unrelated = stage / "usr" / "share" / "keep-me"
    unrelated.parent.mkdir(parents=True, exist_ok=True)
    unrelated.write_text("unrelated", encoding="utf-8")

    result = subprocess.run(
        [str(ROOT / "scripts" / "uninstall.sh")],
        cwd=ROOT,
        env={**os.environ, "DESTDIR": str(stage), "PREFIX": "/usr"},
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert not (stage / "usr" / "lib" / "reta").exists()
    assert not (stage / "usr" / "share" / "reta").exists()
    assert not (stage / "usr" / "share" / "man" / "man1" / "generate_html.1").exists()
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
        },
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    private = stage / "usr" / "libexec" / "reta"
    shared = stage / "usr" / "share" / "reta"
    assert (private / "target" / "bin" / "reta-native").is_file()
    assert (private / "python_reference" / "csv").is_symlink()
    assert (private / "python_reference" / "csv" / "religion.csv").is_file()
    assert (shared / "csv" / "religion.csv").is_file()
    assert (stage / "usr" / "bin" / "reta").resolve() == (private / "bin" / "reta").resolve()
