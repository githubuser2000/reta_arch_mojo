from __future__ import annotations

import ast
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PYTHON_FACADE = ROOT / "python_reference/libs/LibRetaPrompt.py"
MOJO_FACADE = ROOT / "src/reta_mojo/legacy_libreta_prompt.mojo"


def _public_python_names() -> list[str]:
    tree = ast.parse(PYTHON_FACADE.read_text(encoding="utf-8"))
    names: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.ImportFrom):
            names.extend(alias.asname or alias.name for alias in node.names)
        elif isinstance(node, ast.Assign):
            for target in node.targets:
                if isinstance(target, ast.Name):
                    names.append(target.id)
        elif isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
            names.append(node.target.id)
    # pathlib.Path is imported through ``from pathlib import Path``.
    return names


def test_all_imported_and_materialized_names_are_described() -> None:
    source = MOJO_FACADE.read_text(encoding="utf-8")
    block = re.search(
        r"def legacy_libreta_prompt_exported_names\(\).*?return \[(.*?)\n    \]",
        source,
        re.S,
    )
    assert block is not None
    mapped = re.findall(r'"([A-Za-z_][A-Za-z0-9_]*)"', block.group(1))
    expected = _public_python_names()
    assert len(expected) == 48
    assert mapped == expected


def test_import_time_globals_are_explicit_typed_fields() -> None:
    source = MOJO_FACADE.read_text(encoding="utf-8")
    assert "struct LegacyLibRetaPromptBundle(Copyable):" in source
    for name in (
        "promptRuntime",
        "completionRuntime",
        "promptLanguage",
        "promptSession",
        "retaProgram",
        "promptVocabulary",
        "mainParas",
        "spaltenDict",
        "gebrochenErlaubteZahlen",
        "wahl15",
        "wahl16",
    ):
        assert re.search(rf"var {name}: ", source)
    assert "bootstrap_legacy_libreta_prompt" in source
    assert "def bootstrap_legacy_libreta_prompt() raises" in source
    assert 'prompt_runtime_contract("deutsch")' in source
    assert "from std.python import" not in source
    assert "PythonObject" not in source
    assert "subprocess" not in source


def test_existing_native_owners_are_reused_without_new_executable() -> None:
    source = MOJO_FACADE.read_text(encoding="utf-8")
    for owner in (
        ".input_semantics",
        ".prompt_runtime",
        ".completion_runtime",
        ".prompt_language",
        ".prompt_session",
        ".legacy_center",
        ".runtime_compat",
    ):
        assert owner in source
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    assert "legacy-libretaprompt" not in build.lower()
    assert not (ROOT / "src/legacy_libreta_prompt_main.mojo").exists()


def test_package_and_porting_matrix_claim_native_owner() -> None:
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .legacy_libreta_prompt import (" in package
    assert "bootstrap_legacy_libreta_prompt," in package
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(line for line in matrix.splitlines() if "`libs/LibRetaPrompt.py`" in line)
    assert "| nativ |" in row
    assert "legacy_libreta_prompt.mojo" in row
