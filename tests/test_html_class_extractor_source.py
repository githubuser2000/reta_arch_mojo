from __future__ import annotations

import ast
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_OWNER = ROOT / "python_reference/reta_extract_html_classes.py"
MOJO_OWNER = ROOT / "src/reta_mojo/html_class_extractor.mojo"
MAIN = ROOT / "src/extract_html_classes_main.mojo"
FIXTURE = ROOT / "tests/fixtures/html_class_extractor.html"
EXPECTED = ROOT / "tests/fixtures/html_class_extractor_expected.jsonl"


def _python_cells() -> list[dict[str, object]]:
    spec = importlib.util.spec_from_file_location("reta_html_extract", PYTHON_OWNER)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module._extract_header_cells(FIXTURE.read_text(encoding="utf-8"))


def test_python_surface_is_fully_owned_by_native_extractor() -> None:
    tree = ast.parse(PYTHON_OWNER.read_text(encoding="utf-8"))
    functions = {node.name for node in tree.body if isinstance(node, ast.FunctionDef)}
    assert functions == {
        "_repo_root",
        "_stub_dir",
        "_run_reta_html",
        "_parse_attrs",
        "_first_attr_map",
        "_extract_header_cells",
        "main",
    }
    source = MOJO_OWNER.read_text(encoding="utf-8")
    assert "extract_header_cells" in source
    assert "render_html_class_jsonl" in source
    assert "HtmlClassCell" in source
    assert "PythonObject" not in source
    assert "std.python" not in source
    assert "subprocess" not in source


def test_fixture_is_exact_python_compact_jsonl() -> None:
    expected = "".join(
        json.dumps(cell, ensure_ascii=False, separators=(",", ":")) + "\n"
        for cell in _python_cells()
    )
    assert EXPECTED.read_text(encoding="utf-8") == expected
    assert len(expected.splitlines()) == 2


def test_native_main_uses_native_reta_without_child_process() -> None:
    source = MAIN.read_text(encoding="utf-8")
    assert "run_native_reta" in source
    assert 'csv_resource("religion.csv")' in source
    assert "RETA_HTML_CLASSES_INPUT" in source
    assert "PythonObject" not in source
    assert "subprocess" not in source


def test_csv_parser_preserves_unquoted_embedded_json_quotes() -> None:
    source = (ROOT / "src/reta_mojo/csv_table.mojo").read_text(encoding="utf-8")
    assert "if not in_quotes and index != chunk_start" in source
    test_source = (ROOT / "tests/test_csv_table.mojo").read_text(encoding="utf-8")
    assert "test_quotes_inside_unquoted_json_cell_are_literal" in test_source
