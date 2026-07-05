from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GENERATOR = ROOT / "tools/generate_command_parity_assets.py"
STUB_ROOT = ROOT / "tools/reference_runtime_stubs/rich"


def test_generator_isolated_from_ambient_rich_installations() -> None:
    source = GENERATOR.read_text(encoding="utf-8")
    assert 'REFERENCE_RUNTIME_STUBS = ROOT / "tools/reference_runtime_stubs"' in source
    assert 'env["PYTHONNOUSERSITE"] = "1"' in source
    assert 'env["PYTHONPATH"] = str(REFERENCE_RUNTIME_STUBS)' in source
    assert "os.pathsep + previous_pythonpath" in source
    assert "actual={actual_hash} expected={expected_hash}" in source


def test_canonical_rich_stub_is_deliberately_tiny_and_text_only() -> None:
    expected = {"__init__.py", "console.py", "markdown.py", "syntax.py"}
    assert {path.name for path in STUB_ROOT.iterdir() if path.is_file()} == expected

    console_source = (STUB_ROOT / "console.py").read_text(encoding="utf-8")
    syntax_source = (STUB_ROOT / "syntax.py").read_text(encoding="utf-8")
    markdown_source = (STUB_ROOT / "markdown.py").read_text(encoding="utf-8")
    ast.parse(console_source)
    ast.parse(syntax_source)
    ast.parse(markdown_source)
    assert 'if end == "" and not text.endswith("\\n")' in console_source
    assert "sys.stdout.write" in console_source
    assert "class Syntax" in syntax_source
    assert "class Markdown" in markdown_source
    assert "Console(width" not in console_source


def test_legacy_migration_accepts_only_exact_whitelisted_hashes(tmp_path, monkeypatch) -> None:
    import importlib.util
    import hashlib

    spec = importlib.util.spec_from_file_location("command_assets", GENERATOR)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    old = b"old generated asset"
    new = b"canonical generated asset"
    path = tmp_path / "asset.out"
    path.write_bytes(old)
    monkeypatch.setattr(module, "ROOT", tmp_path)
    monkeypatch.setattr(
        module,
        "LEGACY_ASSET_HASHES",
        {"asset.out": {hashlib.sha256(old).hexdigest()}},
    )
    ok, unknown = module.migrate_legacy_assets({path: new}, ["asset.out"])
    assert ok and unknown == []
    assert path.read_bytes() == new

    path.write_bytes(b"unexpected")
    ok, unknown = module.migrate_legacy_assets({path: new}, ["asset.out"])
    assert not ok
    assert unknown and "asset.out:" in unknown[0]
    assert path.read_bytes() == b"unexpected"


def test_pinned_check_does_not_execute_the_reference_renderer(tmp_path, monkeypatch, capsys) -> None:
    import importlib.util
    import hashlib
    import sys

    spec = importlib.util.spec_from_file_location("command_assets_pinned", GENERATOR)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    payload = b"pinned"
    path = tmp_path / "asset.out"
    path.write_bytes(payload)
    monkeypatch.setattr(module, "ROOT", tmp_path)
    monkeypatch.setattr(
        module,
        "CANONICAL_ASSET_HASHES",
        {"asset.out": hashlib.sha256(payload).hexdigest()},
    )
    monkeypatch.setattr(
        module,
        "expected_files",
        lambda: (_ for _ in ()).throw(AssertionError("reference executed")),
    )
    monkeypatch.setattr(sys, "argv", ["generator", "--check"])
    assert module.main() == 0
    assert "pinned cases" in capsys.readouterr().out


def test_already_canonical_migration_is_idempotent_across_python_versions(
    tmp_path, monkeypatch, capsys
) -> None:
    import importlib.util
    import hashlib
    import sys

    spec = importlib.util.spec_from_file_location("command_assets_idempotent", GENERATOR)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    payload = b"canonical"
    path = tmp_path / "asset.out"
    path.write_bytes(payload)
    monkeypatch.setattr(module, "ROOT", tmp_path)
    monkeypatch.setattr(
        module,
        "CANONICAL_ASSET_HASHES",
        {"asset.out": hashlib.sha256(payload).hexdigest()},
    )
    monkeypatch.setattr(
        module,
        "expected_files",
        lambda: (_ for _ in ()).throw(AssertionError("reference executed")),
    )
    monkeypatch.setattr(sys, "argv", ["generator", "--migrate-legacy"])
    assert module.main() == 0
    assert "already canonical" in capsys.readouterr().out
