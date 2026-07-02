from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_mojo_setup_installs_python_test_dependencies() -> None:
    setup = (ROOT / "scripts/setup_mojo.sh").read_text(encoding="utf-8")
    helper = (ROOT / "scripts/setup_test_dependencies.sh").read_text(encoding="utf-8")
    requirements = (ROOT / "requirements-test.txt").read_text(encoding="utf-8")
    assert "setup_test_dependencies.sh" in setup
    assert "uv pip install --python" in helper
    assert "-m ensurepip --upgrade" in helper
    assert "pytest" in requirements


def test_stage_scripts_select_a_python_that_can_import_pytest() -> None:
    resolver = (ROOT / "scripts/find_test_python.sh").read_text(encoding="utf-8")
    assert "import pytest" in resolver
    assert "setup_test_dependencies.sh" in resolver
    assert "command -v python3" in resolver
    assert "command -v pypy3" in resolver
    for name in ("test_stage12c5e.sh", "test_stage12c5k.sh", "test_stage12c5l.sh", "test_stage12c5m.sh"):
        source = (ROOT / "scripts" / name).read_text(encoding="utf-8")
        assert "find_test_python.sh" in source
        assert '"$TEST_PYTHON" -m pytest' in source
