from __future__ import annotations

import importlib.util
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts/check_command_parity_native.py"


def _load_module():
    spec = importlib.util.spec_from_file_location("check_command_parity_native", SCRIPT)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_native_parity_environment_overrides_installed_resource_paths(monkeypatch) -> None:
    monkeypatch.setenv("RETA_ROOT", "/installed/reta")
    monkeypatch.setenv("RETA_SHARE_DIR", "/usr/share/reta")
    monkeypatch.setenv("RETA_DATA_DIR", "/usr/share/reta/csv")
    monkeypatch.setenv("RETA_ASSET_DIR", "/usr/share/reta/assets")
    monkeypatch.setenv("RETA_REFERENCE_DIR", "/installed/reta/python")

    module = _load_module()
    env = module.native_parity_environment()

    assert "RETA_SHARE_DIR" not in env
    assert env["RETA_ROOT"] == str(ROOT)
    assert env["RETA_REFERENCE_DIR"] == str(ROOT / "python_reference")
    assert env["RETA_DATA_DIR"] == str(ROOT / "python_reference/csv")
    assert env["RETA_ASSET_DIR"] == str(ROOT / "assets")
    assert os.environ["RETA_DATA_DIR"] == "/usr/share/reta/csv"


def test_first_difference_reports_content_and_length_boundaries() -> None:
    module = _load_module()
    assert "char 2" in module.first_difference("abc", "abx")
    assert "one output ended" in module.first_difference("ab", "abc")
