from __future__ import annotations

from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MANPAGES = tuple(
    line.strip()
    for line in (ROOT / "scripts" / "reta_manpages.sh").read_text(encoding="utf-8").splitlines()
    if line.strip().endswith(".1")
)


def test_public_manpages_exist_and_cover_prompt_profiles() -> None:
    man_dir = ROOT / "man"
    for name in MANPAGES:
        text = (man_dir / name).read_text(encoding="utf-8")
        assert ".SH NAME" in text
        assert ".SH SYNOPSIS" in text

    assert "main parameters start with one dash" in (man_dir / "reta.1").read_text(encoding="utf-8")
    assert "interactive Reta prompt" in (man_dir / "rp.1").read_text(encoding="utf-8")
    assert "compact logged Reta prompt profile" in (man_dir / "rpl.1").read_text(encoding="utf-8")
    assert "Emacs-style output" in (man_dir / "rpe.1").read_text(encoding="utf-8")
    assert "one-shot Reta prompt frontend" in (man_dir / "rpb.1").read_text(encoding="utf-8")


def test_central_manpage_manifest_is_used_by_installer_and_uninstaller() -> None:
    manifest = (ROOT / "scripts" / "reta_manpages.sh").read_text(encoding="utf-8")
    for name in MANPAGES:
        assert name in manifest

    install = (ROOT / "scripts" / "install.sh").read_text(encoding="utf-8")
    uninstall = (ROOT / "scripts" / "uninstall.sh").read_text(encoding="utf-8")
    check = (ROOT / "scripts" / "check_install_layout.sh").read_text(encoding="utf-8")

    assert "reta_public_manpages" in install
    assert "reta_public_manpages" in uninstall
    assert "reta_public_manpages" in check
    assert "install -m 0644 \"$ROOT/man/$manpage\"" in install
    assert "rm -f \"$STAGE_MANDIR/man1/$manpage\"" in uninstall


def test_pixi_and_cmake_expose_manpage_checks() -> None:
    pixi = (ROOT / "pixi.toml").read_text(encoding="utf-8")
    cmake = (ROOT / "CMakeLists.txt").read_text(encoding="utf-8")
    runner = (ROOT / "scripts" / "run_install_task.sh").read_text(encoding="utf-8")

    assert 'check-manpages = "scripts/run_install_task.sh check-manpages"' in pixi
    assert 'cmake-check-manpages = "cmake --build build --target reta-check-manpages"' in pixi
    assert "reta-check-manpages" in cmake
    assert "check-manpages" in runner


def test_check_manpages_script() -> None:
    result = subprocess.run(
        [str(ROOT / "scripts" / "check_manpages.sh")],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    assert f"Manpages konsistent: {len(MANPAGES)} Dateien" in result.stdout
