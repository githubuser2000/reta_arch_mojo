from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FINGERPRINT = ROOT / "tools/mojo_test_build_fingerprint.py"
BUILD = ROOT / "scripts/build-tests.sh"
WRAPPER = ROOT / "scripts/test_all.sh"


def _fingerprint(root: Path, test: str, context: str = "ctx") -> str:
    completed = subprocess.run(
        [
            sys.executable,
            str(FINGERPRINT),
            "--root",
            str(root),
            "--context-id",
            context,
            test,
        ],
        check=True,
        text=True,
        capture_output=True,
    )
    return completed.stdout.strip().split("\t", 1)[1]


def test_transitive_fingerprint_changes_only_for_relevant_inputs(tmp_path: Path) -> None:
    (tmp_path / "src/reta_mojo").mkdir(parents=True)
    (tmp_path / "tests").mkdir()
    (tmp_path / "src/reta_mojo/b.mojo").write_text("comptime VALUE = 1\n", encoding="utf-8")
    (tmp_path / "src/reta_mojo/a.mojo").write_text(
        "from .b import VALUE\n", encoding="utf-8"
    )
    (tmp_path / "src/reta_mojo/unrelated.mojo").write_text(
        "comptime OTHER = 1\n", encoding="utf-8"
    )
    (tmp_path / "tests/test_sample.mojo").write_text(
        "from reta_mojo.a import VALUE\n", encoding="utf-8"
    )

    first = _fingerprint(tmp_path, "tests/test_sample.mojo")
    (tmp_path / "src/reta_mojo/unrelated.mojo").write_text(
        "comptime OTHER = 2\n", encoding="utf-8"
    )
    assert _fingerprint(tmp_path, "tests/test_sample.mojo") == first

    (tmp_path / "src/reta_mojo/b.mojo").write_text("comptime VALUE = 2\n", encoding="utf-8")
    assert _fingerprint(tmp_path, "tests/test_sample.mojo") != first


def test_fingerprint_includes_build_context_and_missing_local_imports(tmp_path: Path) -> None:
    (tmp_path / "src/reta_mojo").mkdir(parents=True)
    (tmp_path / "tests").mkdir()
    test = tmp_path / "tests/test_sample.mojo"
    test.write_text("from reta_mojo.missing import VALUE\n", encoding="utf-8")
    first = _fingerprint(tmp_path, "tests/test_sample.mojo", "ctx-a")
    assert _fingerprint(tmp_path, "tests/test_sample.mojo", "ctx-b") != first
    (tmp_path / "src/reta_mojo/missing.mojo").write_text(
        "comptime VALUE = 1\n", encoding="utf-8"
    )
    assert _fingerprint(tmp_path, "tests/test_sample.mojo", "ctx-a") != first


def test_build_entrypoint_is_fail_closed_and_supports_forced_rebuild() -> None:
    build = BUILD.read_text(encoding="utf-8")
    wrapper = WRAPPER.read_text(encoding="utf-8")
    assert "mojo_test_build_fingerprint.py" in build
    assert ".reta-test-build-id" in build
    assert "== reuse %s ==" in build
    assert "RETA_TEST_REBUILD_ALL" in build
    assert "--rebuild-all" in build
    assert 'rm -f "$MANIFEST"' in build
    assert "--rebuild-all" in wrapper
    assert "RETA_TEST_REBUILD_ALL" in wrapper
