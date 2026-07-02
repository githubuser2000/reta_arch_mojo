#!/usr/bin/env python3
"""Compare native Mojo and frozen Python RepoManifest snapshots."""
from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
sys.path.insert(0, str(PYROOT))
sys.path.insert(0, str(PYROOT / "libs"))
sys.dont_write_bytecode = True

from reta_architecture.package_integrity import RepoManifest  # noqa: E402


def native_snapshot(binary: Path, root: Path) -> dict:
    result = subprocess.run(
        [str(binary), "--json-files", str(root)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
    )
    return json.loads(result.stdout)


def compare(binary: Path, tree: Path, label: str) -> None:
    expected = RepoManifest.from_tree(tree).snapshot(include_files=True)
    actual = native_snapshot(binary, tree)
    if actual != expected:
        differing = [key for key in expected if expected[key] != actual.get(key)]
        raise SystemExit(f"{label}: package-integrity mismatch in {differing}")
    print(
        f"{label}: files={actual['file_count']} bytes={actual['total_bytes']} "
        f"runtime={actual['runtime_artifact_count']} digest={actual['digest']}"
    )


def make_runtime_fixture(root: Path) -> None:
    (root / "csv").mkdir(parents=True)
    (root / "sub").mkdir()
    (root / "__pycache__").mkdir()
    (root / ".git/objects").mkdir(parents=True)
    (root / "alpha.txt").write_text("alpha\n", encoding="utf-8")
    (root / ".hidden").write_text("dot\n", encoding="utf-8")
    (root / "hidden").write_text("plain\n", encoding="utf-8")
    (root / "sub/beta.bin").write_bytes(bytes((0, 255, 10)))
    (root / "csv/religion.csv").write_bytes(
        "one\r\ntwo\u2028three\u0085".encode("utf-8")
    )
    (root / "__pycache__/ignored.pyc").write_bytes(b"cache")
    (root / ".git/objects/x").write_bytes(b"object")
    (root / "link-alpha").symlink_to("alpha.txt")
    (root / "sub-link").symlink_to("sub", target_is_directory=True)
    (root / "dangling").symlink_to("missing")
    os.mkfifo(root / "pipe")


def main() -> int:
    binary = Path(
        os.environ.get(
            "RETA_PACKAGE_INTEGRITY_BIN",
            ROOT / "target/bin/reta-mojo-package-integrity",
        )
    ).resolve()
    if not binary.is_file():
        raise SystemExit(f"missing native package-integrity binary: {binary}")
    compare(binary, PYROOT, "python-reference")
    with TemporaryDirectory(prefix="reta-package-integrity-") as temp_dir:
        fixture = Path(temp_dir) / "tree"
        fixture.mkdir()
        make_runtime_fixture(fixture)
        compare(binary, fixture, "runtime-fixture")
    print("package-integrity parity=2/2")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
