from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PY_OWNER = ROOT / "python_reference/reta_architecture/combi_join.py"
MOJO_OWNER = ROOT / "src/reta_mojo/combi_join.mojo"


def _methods() -> list[str]:
    tree = ast.parse(PY_OWNER.read_text(encoding="utf-8"))
    owner = next(
        node
        for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == "KombiJoin"
    )
    return [
        node.name
        for node in owner.body
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]


def test_historical_surface_has_one_typed_native_owner() -> None:
    assert _methods() == [
        "__init__",
        "prepareTableJoin",
        "removeOneNumber",
        "tableJoin",
        "prepare_kombi",
        "readKombiCsv",
        "kombiNumbersCorrectTestAndSet",
    ]
    source = MOJO_OWNER.read_text(encoding="utf-8")
    for marker in (
        "struct KombiLineSelection",
        "struct KombiPreparedGroup",
        "struct KombiSourceBundle",
        "def prepareTableJoin(",
        "def removeOneNumber(",
        "def tableJoin(",
        "def prepare_kombi(",
        "def readKombiCsv(",
        "def kombiNumbersCorrectTestAndSet(",
        "def bootstrap_combi_join(",
    ):
        assert marker in source
    assert "OrderedDict" not in source
    assert "OrderedSet" not in source
    assert "std.python" not in source
    assert "PythonObject" not in source
    assert 'external_call["system"' not in source


def test_order_independent_parity_tool_is_content_sensitive() -> None:
    tool = (ROOT / "tools/compare_middle_alx.py").read_text(encoding="utf-8")
    assert "class BigTableParser" in tool
    assert "column_hashes = tuple(sorted(unsorted_hashes))" in tool
    assert "POSITION_CLASS_RE" in tool
    assert "table#bigtable" in tool
    assert (ROOT / "tests/test_middle_alx_compare.py").is_file()


def test_cli_build_and_install_surfaces_are_wired() -> None:
    assert (ROOT / "src/combi_join_main.mojo").is_file()
    assert (ROOT / "tools/wrappers/reta-mojo-combi-join").is_file()
    assert "src/combi_join_main.mojo" in (ROOT / "scripts/build.sh").read_text(
        encoding="utf-8"
    )
    assert "reta-mojo-combi-join" in (
        ROOT / "scripts/install_bins.sh"
    ).read_text(encoding="utf-8")
    assert "reta-mojo-combi-join" in (
        ROOT / "scripts/check_build_layout.sh"
    ).read_text(encoding="utf-8")


def test_matrix_claims_complete_native_ownership() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(
        line
        for line in matrix.splitlines()
        if "`reta_architecture/combi_join.py`" in line
    )
    assert "| nativ |" in row
    assert "src/reta_mojo/combi_join.mojo" in row
