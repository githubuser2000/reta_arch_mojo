from __future__ import annotations

import ast
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PYTHON = ROOT / "python_reference/reta_architecture/table_adapters.py"
MOJO = ROOT / "src/reta_mojo/table_adapters.mojo"
LEGACY_CONCAT = ROOT / "src/reta_mojo/legacy_lib4tables_concat.mojo"


def _tree() -> ast.Module:
    return ast.parse(PYTHON.read_text(encoding="utf-8"))


def _module_functions() -> list[str]:
    return [
        node.name
        for node in _tree().body
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]


def _logical_methods(class_name: str) -> list[str]:
    cls = next(
        node
        for node in _tree().body
        if isinstance(node, ast.ClassDef) and node.name == class_name
    )
    result: list[str] = []
    for node in cls.body:
        if not isinstance(node, ast.FunctionDef) or node.name == "__init__":
            continue
        # Python properties occur once as getter and once as setter.  The
        # native typed facade represents each logical property once.
        if node.name not in result:
            result.append(node.name)
    return result


def _mapped(facade: str) -> list[str]:
    text = MOJO.read_text(encoding="utf-8")
    pattern = rf'_method\("{re.escape(facade)}", "([^"]+)"'
    return re.findall(pattern, text)


def test_exact_python_surface_is_owned_in_source_order() -> None:
    assert _module_functions() == [
        "setShellRowsAmount",
        "chunks",
        "splitMoreIfNotSmall",
        "alxwrap",
    ]
    assert _mapped("module") == _module_functions()
    assert _mapped("Prepare") == _logical_methods("Prepare")
    assert _mapped("Concat") == _logical_methods("Concat")
    assert len(_mapped("Prepare")) == 17
    assert len(_mapped("Concat")) == 34


def test_prepare_constructor_state_is_explicitly_typed() -> None:
    text = MOJO.read_text(encoding="utf-8")
    constructor_assignments = {
        target.attr
        for node in ast.walk(_tree())
        if isinstance(node, ast.Assign)
        for target in node.targets
        if isinstance(target, ast.Attribute)
        and isinstance(target.value, ast.Name)
        and target.value.id == "self"
    }
    expected = {
        "tables",
        "hoechsteZeile",
        "originalLinesRange",
        "shellRowsAmount",
        "zaehlungen",
        "religionNumbers",
        "gezaehlt",
        "ifZeilenSetted",
    }
    assert expected <= constructor_assignments
    for name in expected:
        assert f'"{name}"' in text
    for typed_field in (
        "row_filter: RowFilterConfig",
        "original_lines: List[Int]",
        "shell_rows_amount: Int",
        "counting_group_by_row: List[Int]",
        "religion_numbers: List[Int]",
        "rows_as_numbers: Set[Int]",
        "wrapping_runtime: TextWrapRuntime",
    ):
        assert typed_field in text


def test_all_forwarding_owners_are_native_and_no_python_bridge_returns() -> None:
    text = MOJO.read_text(encoding="utf-8")
    concat = LEGACY_CONCAT.read_text(encoding="utf-8")
    assert "from .legacy_lib4tables_concat import *" in text
    for marker in (
        "filter_original_lines(",
        "select_display_lines(",
        "prepare_indexed_row(",
        "prepare_cell_fragments(",
        "wrap_cell_text(",
        "width_for_row(",
        "moon_number(",
        "legacy_concat_snapshot()",
    ):
        assert marker in text
    assert len(re.findall(r'_method\("Concat",', text)) == 34
    assert len(re.findall(r'_method\("', concat)) == 34
    combined = text + concat
    assert "from std.python import" not in combined
    assert "PythonObject" not in combined
    assert "subprocess" not in combined


def test_porting_matrix_claims_the_new_owner() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(
        line
        for line in matrix.splitlines()
        if "`reta_architecture/table_adapters.py`" in line
    )
    assert "| nativ |" in row
    assert "table_adapters.mojo" in row
