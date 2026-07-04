from __future__ import annotations

import ast
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PYTHON_FACADE = ROOT / "python_reference/libs/lib4tables_prepare.py"
MOJO_FACADE = ROOT / "src/reta_mojo/legacy_lib4tables_prepare.mojo"


def _module_functions() -> list[str]:
    tree = ast.parse(PYTHON_FACADE.read_text(encoding="utf-8"))
    return [node.name for node in tree.body if isinstance(node, ast.FunctionDef)]


def _prepare_methods() -> list[str]:
    tree = ast.parse(PYTHON_FACADE.read_text(encoding="utf-8"))
    prepare = next(
        node for node in tree.body if isinstance(node, ast.ClassDef) and node.name == "Prepare"
    )
    return [
        node.name
        for node in prepare.body
        if isinstance(node, ast.FunctionDef) and node.name != "__init__"
    ]


def test_complete_legacy_surface_is_mapped_in_source_order() -> None:
    source = MOJO_FACADE.read_text(encoding="utf-8")
    mapped = re.findall(r'_method\("([^"]+)"', source)
    expected = _module_functions() + _prepare_methods()
    assert _module_functions() == [
        "_sync_wrapping_runtime",
        "setShellRowsAmount",
        "chunks",
        "splitMoreIfNotSmall",
        "alxwrap",
    ]
    assert len(_prepare_methods()) == 20
    assert mapped == expected


def test_typed_prepare_facade_delegates_to_existing_native_owners() -> None:
    source = MOJO_FACADE.read_text(encoding="utf-8")
    assert "struct Prepare(Copyable):" in source
    assert "var state: PrepareAdapterState" in source
    for marker in (
        "adapter_setZaehlungen",
        "adapter_FilterOriginalLines",
        "adapter_prepare4out",
        "adapter_prepare4out_LoopBody",
        "adapter_prepare4out_Tagging",
        "adapter_cellWork",
    ):
        assert marker in source
    assert "from std.python import" not in source
    assert "PythonObject" not in source
    assert "subprocess" not in source


def test_mutable_python_module_globals_are_explicit_runtime_state() -> None:
    source = MOJO_FACADE.read_text(encoding="utf-8")
    assert "struct LegacyPrepareModuleRuntime(Copyable):" in source
    assert "var wrapping_runtime: TextWrapRuntime" in source
    for legacy_global in (
        "shellRowsAmount",
        "h_de",
        "dic",
        "fill",
        "wrappingType",
    ):
        assert legacy_global in source


def test_package_export_and_porting_claim_are_complete() -> None:
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .legacy_lib4tables_prepare import Prepare" in package
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(
        line for line in matrix.splitlines() if "`libs/lib4tables_prepare.py`" in line
    )
    assert "| nativ |" in row
    assert "legacy_lib4tables_prepare.mojo" in row


def test_zero_terminal_width_sentinel_and_warning_cleanup_are_locked_in() -> None:
    mojo_test = (ROOT / "tests/test_legacy_lib4tables_prepare.mojo").read_text(
        encoding="utf-8"
    )
    adapters = (ROOT / "src/reta_mojo/table_adapters.mojo").read_text(
        encoding="utf-8"
    )
    assert "var unlimited_context = make_parallel_row_preparation_context(" in mojo_test
    assert 'assert_equal(unlimited.cells[0], ["abcdef"])' in mojo_test
    assert "shell_rows_amount=80, text_width=3" in mojo_test
    function = adapters.split("def parametersCmdWithSomeBereich", 1)[1].split(
        "def deleteDoublesInSets", 1
    )[0]
    assert "len(piece)" not in function
    assert "len(negative_prefix)" not in function
    assert "piece.byte_length()" in function
    assert "negative_prefix.byte_length()" in function
    assert "var accepted = (" in function
