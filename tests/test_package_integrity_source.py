from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_native_package_integrity_owner_is_explicit() -> None:
    source = (ROOT / "src/reta_mojo/package_integrity.mojo").read_text(encoding="utf-8")
    assert "struct RepoManifest" in source
    assert "SHA256_Update" in source
    assert "python_splitlines_count" in source
    assert "from std.python import" not in source
    assert 'external_call["system"' not in source
    assert '"opendir"' in source and 'external_call[' in source
    assert '"readdir"' in source
    assert (ROOT / "src/package_integrity_main.mojo").is_file()
    assert (ROOT / "bin/reta-mojo-package-integrity").is_file()
    assert "reta-mojo-package-integrity" in (ROOT / "scripts/install_bins.sh").read_text(encoding="utf-8")
    assert "reta-mojo-package-integrity" in (ROOT / "scripts/check_build_layout.sh").read_text(encoding="utf-8")


def test_package_integrity_is_in_build_and_porting_matrix() -> None:
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    assert "src/package_integrity_main.mojo" in build
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(line for line in matrix.splitlines() if "`reta_architecture/package_integrity.py`" in line)
    assert "| nativ |" in row
    assert "package_integrity.mojo" in row


def test_fixture_preserves_normal_file_and_symlink_contract() -> None:
    fixture = ROOT / "tests/fixtures/package_integrity/tree"
    assert (fixture / "link-alpha").is_symlink()
    assert (fixture / "link-alpha").read_text(encoding="utf-8") == "alpha\n"
    assert not (fixture / "__pycache__").exists()
    assert not (fixture / ".git").exists()


def test_runtime_artifact_cases_are_created_dynamically() -> None:
    parity = (ROOT / "scripts/check_package_integrity_parity.py").read_text(encoding="utf-8")
    assert "TemporaryDirectory" in parity
    assert '"__pycache__"' in parity
    assert '".git/objects"' in parity
    assert "target_is_directory=True" in parity
    assert "os.mkfifo" in parity
