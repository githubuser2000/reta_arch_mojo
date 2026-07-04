from __future__ import annotations

import ast
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/mojo_bridge.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo"
CATALOG = ROOT / "src/reta_mojo/legacy_mojo_bridge_catalog.mojo"
GENERATOR = ROOT / "tools/generate_legacy_mojo_bridge_catalog.py"


def _public_names() -> list[str]:
    tree = ast.parse(PYTHON_SOURCE.read_text(encoding="utf-8"))
    result: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.Assign):
            for target in node.targets:
                if isinstance(target, ast.Name) and not target.id.startswith("_"):
                    result.append(target.id)
        elif isinstance(node, ast.AnnAssign):
            if isinstance(node.target, ast.Name) and not node.target.id.startswith("_"):
                result.append(node.target.id)
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            if not node.name.startswith("_"):
                result.append(node.name)
    return result


def _function_names() -> list[str]:
    tree = ast.parse(PYTHON_SOURCE.read_text(encoding="utf-8"))
    functions = [
        node
        for node in ast.walk(tree)
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]
    functions.sort(key=lambda node: (node.lineno, node.col_offset))
    return [node.name for node in functions]


def test_generated_catalog_matches_historical_surface() -> None:
    subprocess.run([sys.executable, str(GENERATOR), "--check"], cwd=ROOT, check=True)
    source = CATALOG.read_text(encoding="utf-8")
    public_block = re.search(
        r"def legacy_mojo_bridge_public_names\(\).*?return \[(.*?)\n    \]",
        source,
        re.S,
    )
    function_block = re.search(
        r"def legacy_mojo_bridge_function_names\(\).*?return \[(.*?)\n    \]",
        source,
        re.S,
    )
    assert public_block and function_block
    public = re.findall(r'"([^"\\]+)"', public_block.group(1))
    functions = re.findall(r'"([^"\\]+)"', function_block.group(1))
    assert public == _public_names()
    assert functions == _function_names()
    assert len(public) == 15
    assert len(functions) == 19
    native_source = MOJO_SOURCE.read_text(encoding="utf-8")
    for name in public[1:]:
        assert f"def {name}(" in native_source


def test_native_facade_uses_existing_native_boundaries() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for owner in (
        ".native_prompt_input",
        ".prompt_external_commands",
        ".completion_nested",
        ".html_document",
    ):
        assert owner in source
    for symbol in (
        "struct LegacyMojoBridgeBundle",
        "def run_reta_encoded(",
        "def read_prompt_line_encoded(",
        "def run_reta_prompt_line_encoded(",
        "def generate_html_document(",
    ):
        assert symbol in source
    assert "from std.python import" not in source
    assert "PythonObject" not in source
    assert "import_module" not in source


def test_html_orchestration_has_one_reusable_owner() -> None:
    owner = (ROOT / "src/reta_mojo/html_document.mojo").read_text(encoding="utf-8")
    main = (ROOT / "src/generate_html_main.mojo").read_text(encoding="utf-8")
    assert "def assemble_html_document(" in owner
    assert "def generate_html_middle(" in owner
    assert "assemble_html_document(hierarchy_html, language)" in main
    assert "run_native_reta" not in main
    assert "RETA_GENERATE_HTML_MIDDLE_FILE" not in main


def test_prompt_external_adapter_exposes_tokenized_prompt_child() -> None:
    source = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(
        encoding="utf-8"
    )
    assert "def run_reta_prompt_arguments_native(" in source
    assert '"retaPrompt.py", arguments, reference_root' in source


def test_matrix_and_package_export_the_native_bridge_owner() -> None:
    generator = (ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8")
    assert '"mojo_bridge.py": ("nativ"' in generator
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(line for line in matrix.splitlines() if "`mojo_bridge.py`" in line)
    assert "| nativ |" in row
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .legacy_mojo_bridge import (" in package
    for name in _public_names()[1:]:
        assert re.search(rf"^\s*{re.escape(name)},$", package, re.MULTILINE)
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5an.sh" in current
