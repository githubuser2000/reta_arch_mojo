from __future__ import annotations

from pathlib import Path
import subprocess
import tarfile
import brotli

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "create_source_archive.sh"


def test_source_archive_excludes_nested_caches_and_build_products(tmp_path: Path) -> None:
    text = SCRIPT.read_text(encoding="utf-8")
    assert "*/.pytest_cache" in text
    assert "*/__pycache__" in text
    assert "prompt_python_bridge" in text
    output = tmp_path / "reta_arch_mojo_test.tar.bz2"
    subprocess.run([str(SCRIPT), str(output)], cwd=ROOT, check=True, capture_output=True)
    with tarfile.open(output, "r:bz2") as archive:
        names = archive.getnames()
    assert names
    assert not any("/.pytest_cache/" in f"/{name}/" for name in names)
    assert not any("/__pycache__/" in f"/{name}/" for name in names)
    assert not any(name.endswith((".pyc", ".pyo", "/middle.alx")) for name in names)
    assert not any(name.endswith("prompt_python_bridge.mojo") for name in names)


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
