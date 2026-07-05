from __future__ import annotations

from pathlib import Path
import subprocess
import tarfile
import lzma
import os
import brotli

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "create_source_archive.sh"


def test_source_archive_excludes_nested_caches_and_build_products(tmp_path: Path) -> None:
    text = SCRIPT.read_text(encoding="utf-8")
    assert "*/.pytest_cache" in text
    assert "*/__pycache__" in text
    assert "prompt_python_bridge" in text
    for temporary in ("*.tmp", "*~", "*.swp", "*.swo", ".#*"):
        assert temporary in text
    output = tmp_path / "reta_arch_mojo_test.tar.bz2"
    subprocess.run([str(SCRIPT), str(output)], cwd=ROOT, check=True, capture_output=True)
    with tarfile.open(output, "r:bz2") as archive:
        names = archive.getnames()
    assert names
    assert not any("/.pytest_cache/" in f"/{name}/" for name in names)
    assert not any("/__pycache__/" in f"/{name}/" for name in names)
    assert not any(name.endswith((".pyc", ".pyo", ".tmp", ".swp", ".swo", "~", "/middle.alx")) for name in names)
    assert not any(name.endswith("prompt_python_bridge.mojo") for name in names)


def test_git_index_contains_no_archive_excluded_temporary_files() -> None:
    tracked = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=True,
        capture_output=True,
    ).stdout.decode("utf-8").split("\0")
    forbidden_suffixes = (".pyc", ".pyo", ".tmp", ".swp", ".swo", "~")
    offenders = sorted(
        name
        for name in tracked
        if name
        and (
            name.endswith(forbidden_suffixes)
            or "/__pycache__/" in f"/{name}/"
            or "/.pytest_cache/" in f"/{name}/"
            or name == "middle.alx"
        )
    )
    assert offenders == []
    assert "*.tmp" in (ROOT / ".gitignore").read_text(encoding="utf-8")


def test_source_archive_supports_brotli_and_roundtrips(tmp_path: Path) -> None:
    output = tmp_path / "reta_arch_mojo_test.tar.br"
    subprocess.run(
        [str(SCRIPT), str(output)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        env={**__import__("os").environ, "RETA_BROTLI_QUALITY": "1"},
    )
    raw_tar = tmp_path / "reta_arch_mojo_test.tar"
    raw_tar.write_bytes(brotli.decompress(output.read_bytes()))
    with tarfile.open(raw_tar, "r:") as archive:
        names = archive.getnames()
    assert names
    assert not any("/.venv/" in f"/{name}/" for name in names)
    assert not any("/.git/" in f"/{name}/" for name in names)
    assert not any(name.endswith("prompt_python_bridge.mojo") for name in names)


def test_source_archive_supports_parallel_xz_and_roundtrips(tmp_path: Path) -> None:
    text = SCRIPT.read_text(encoding="utf-8")
    assert "*.tar.xz|*.txz" in text
    assert 'xz -T"$XZ_THREADS"' in text
    output = tmp_path / "reta_arch_mojo_test.tar.xz"
    subprocess.run(
        [str(SCRIPT), str(output)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        env={**os.environ, "RETA_XZ_LEVEL": "1", "RETA_XZ_THREADS": "2"},
    )
    raw_tar = tmp_path / "reta_arch_mojo_test_xz.tar"
    raw_tar.write_bytes(lzma.decompress(output.read_bytes()))
    with tarfile.open(raw_tar, "r:") as archive:
        names = archive.getnames()
    assert names
    assert not any("/.venv/" in f"/{name}/" for name in names)
    assert not any("/.git/" in f"/{name}/" for name in names)
    assert not any(name.endswith("prompt_python_bridge.mojo") for name in names)
