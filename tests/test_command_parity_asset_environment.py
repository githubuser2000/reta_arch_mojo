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
