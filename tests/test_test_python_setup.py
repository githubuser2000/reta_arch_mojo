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


def test_all_shell_pytest_calls_use_the_common_resolver() -> None:
    resolver = (ROOT / "scripts/find_test_python.sh").read_text(encoding="utf-8")
    runner = ROOT / "scripts/run_pytest.sh"
    runner_source = runner.read_text(encoding="utf-8")
    assert "import pytest" in resolver
    assert "setup_test_dependencies.sh" in resolver
    assert "command -v python3" in resolver
    assert "command -v pypy3" in resolver
    assert "find_test_python.sh" in runner_source
    assert 'exec "$TEST_PYTHON" -m pytest "$@"' in runner_source
    assert runner.stat().st_mode & 0o111

    offenders = []
    for path in sorted((ROOT / "scripts").glob("*.sh")):
        source = path.read_text(encoding="utf-8")
        if "python3 -m pytest" in source:
            offenders.append(path.name)
    assert offenders == []

    for name in (
        "test_stage12c5e.sh",
        "test_stage12c5j.sh",
        "test_stage12c5k.sh",
        "test_stage12c5l.sh",
        "test_stage12c5m.sh",
    ):
        source = (ROOT / "scripts" / name).read_text(encoding="utf-8")
        assert (
            "find_test_python.sh" in source
            or "run_pytest.sh" in source
        )
