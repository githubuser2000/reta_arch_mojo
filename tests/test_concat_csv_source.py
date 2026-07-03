from __future__ import annotations

import ast
from pathlib import Path
import re
import subprocess
import sys

import pytest

ROOT = Path(__file__).resolve().parents[1]
PY_CONCAT = ROOT / "python_reference/reta_architecture/concat_csv.py"
PY_FACADE = ROOT / "python_reference/libs/lib4tables_concat.py"
MOJO_CONCAT = ROOT / "src/reta_mojo/concat_csv.mojo"
MOJO_FACADE = ROOT / "src/reta_mojo/legacy_lib4tables_concat.mojo"


def _module_function_names(path: Path) -> set[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    return {
        node.name
        for node in tree.body
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    }


def _class_method_names(path: Path, class_name: str) -> list[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    cls = next(
        node
        for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == class_name
    )
    return [node.name for node in cls.body if isinstance(node, ast.FunctionDef)]


def test_concat_csv_python_surface_has_explicit_native_owner_mapping() -> None:
    python_functions = _module_function_names(PY_CONCAT)
    expected = {
        "_ensure_runtime_dependencies",
        "bootstrap_concat_csv",
        "convertSetOfPaarenToDictOfNumToPaareDiv",
        "convertSetOfPaarenToDictOfNumToPaareMul",
        "convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction",
        "combineDicts",
        "readConcatCsv_tabelleDazuColchange",
        "readConcatCsv",
        "readConcatCSV_choseCsvFile",
        "readConcatCsv_ChangeTableToAddToTable",
        "readConcatCsv_LoopBody",
        "readConcatCsv_SetHtmlParamaters",
    }
    assert python_functions == expected

    concat = MOJO_CONCAT.read_text(encoding="utf-8")
    facade = MOJO_FACADE.read_text(encoding="utf-8")
    mappings = {
        "bootstrap_concat_csv": "def bootstrap_concat_csv(",
        "convertSetOfPaarenToDictOfNumToPaareDiv": '"convertSetOfPaarenToDictOfNumToPaareDiv"',
        "convertSetOfPaarenToDictOfNumToPaareMul": '"convertSetOfPaarenToDictOfNumToPaareMul"',
        "convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction": '"convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction"',
        "combineDicts": '"combineDicts"',
        "readConcatCsv_tabelleDazuColchange": "def transform_fraction_concat_row(",
        "readConcatCsv": "def append_concat_csv(",
        "readConcatCSV_choseCsvFile": "def concat_csv_path(",
        "readConcatCsv_ChangeTableToAddToTable": "def prepare_concat_source(",
        "readConcatCsv_LoopBody": "append_concat_csv selection plan",
        "readConcatCsv_SetHtmlParamaters": "struct ConcatColumnMetadata",
    }
    for python_name, native_marker in mappings.items():
        assert native_marker in concat or native_marker in facade, python_name

    # Runtime dependency injection disappears at the typed native boundary.
    assert "_ensure_runtime_dependencies" not in concat
    assert "PythonObject" not in concat + facade
    assert "from std.python import" not in concat + facade


def test_legacy_concat_facade_maps_exact_python_method_surface() -> None:
    python_methods = _class_method_names(PY_FACADE, "Concat")
    assert python_methods[0] == "__init__"
    active_methods = python_methods[1:]
    facade = MOJO_FACADE.read_text(encoding="utf-8")
    mapped_methods = re.findall(r'_method\("([^"]+)"', facade)
    assert mapped_methods == active_methods
    assert len(mapped_methods) == 34

    expected_state = {
        "ones",
        "CSVsAlreadRead",
        "CSVsSame",
        "BruecheUni",
        "BruecheGal",
        "gebrRatMulSternUni",
        "gebrRatDivSternUni",
        "gebrRatMulGleichfUni",
        "gebrRatDivGleichfUni",
        "gebrRatMulSternGal",
        "gebrRatDivSternGal",
        "gebrRatMulGleichfGal",
        "gebrRatDivGleichfGal",
    }
    for name in expected_state:
        assert f'"{name}"' in facade


def test_concat_csv_probe_stays_byte_identical_to_python_reference() -> None:
    probe = ROOT / "target/tests/concat_csv_probe"
    if not probe.is_file():
        pytest.skip("requires the compiled Mojo concat_csv_probe")
    subprocess.run(
        [sys.executable, "scripts/check_concat_csv_parity.py"],
        cwd=ROOT,
        check=True,
    )


def test_concat_csv_owners_are_claimed_native() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    for path in ("reta_architecture/concat_csv.py", "libs/lib4tables_concat.py"):
        row = next(line for line in matrix.splitlines() if f"`{path}`" in line)
        assert "| nativ |" in row
