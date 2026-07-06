from __future__ import annotations

from pathlib import Path
import subprocess
import tarfile
import lzma
import os
import sys
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


def _declared_source_paths() -> list[str]:
    """Read the Git index in a checkout or the manifests in a source archive."""
    git_files = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=False,
        capture_output=True,
    )
    if git_files.returncode == 0:
        return git_files.stdout.decode("utf-8").split("\0")

    manifest = ROOT / "SOURCE_MANIFEST.sha256"
    symlinks = ROOT / "SOURCE_SYMLINKS.txt"
    assert manifest.is_file(), "source archive has neither Git index nor manifest"
    paths = [
        line.split("  ", 1)[1].removeprefix("./")
        for line in manifest.read_text(encoding="utf-8").splitlines()
        if "  " in line
    ]
    if symlinks.is_file():
        paths.extend(
            line.split(" -> ", 1)[0].removeprefix("./")
            for line in symlinks.read_text(encoding="utf-8").splitlines()
            if " -> " in line
        )
    return paths


def test_declared_source_contains_no_archive_excluded_temporary_files() -> None:
    tracked = _declared_source_paths()
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
    text = SCRIPT.read_text(encoding="utf-8")
    assert "RETA_BROTLI_PYTHON" in text
    assert '"$ROOT/.venv/bin/python3"' in text
    output = tmp_path / "reta_arch_mojo_test.tar.br"
    subprocess.run(
        [str(SCRIPT), str(output)],
        cwd=ROOT,
        check=True,
        capture_output=True,
        env={
            **os.environ,
            "RETA_BROTLI_QUALITY": "1",
            "RETA_BROTLI_PYTHON": sys.executable,
        },
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
