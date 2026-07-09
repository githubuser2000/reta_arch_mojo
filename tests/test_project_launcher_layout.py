from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def test_source_tree_has_single_binary_depot_and_no_root_run_launchers() -> None:
    result = subprocess.run(
        [str(ROOT / "scripts/check_project_launcher_layout.sh")],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr


def test_bin_contains_only_mojo_resolver() -> None:
    entries = sorted(path.name for path in (ROOT / "bin").iterdir())
    assert entries == ["mojo-real"]
    assert not (ROOT / "run").exists()
    for name in ("reta", "rp", "rpl", "rpe", "rpb", "generate_html", "grundStrukHtml"):
        assert not (ROOT / name).exists()


def test_source_wrappers_are_real_files_not_symlinks() -> None:
    wrappers = ROOT / "tools" / "wrappers"
    expected = ["reta", "rp", "rpl", "rpe", "rpb", "generate_html", "mojo-runtime-exec"]
    for name in expected:
        path = wrappers / name
        assert path.is_file()
        assert not path.is_symlink()
        assert path.stat().st_mode & 0o111
