from __future__ import annotations

import ast
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "python_reference/reta_architecture/facade.py"
CATALOG = ROOT / "assets/architecture_facade.tsv"
MODULE = ROOT / "src/reta_mojo/architecture_facade.mojo"
EXPORTS_MODULE = ROOT / "src/reta_mojo/architecture_exports.mojo"


def _class() -> ast.ClassDef:
    tree = ast.parse(SOURCE.read_text(encoding="utf-8"))
    return next(
        node
        for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == "RetaArchitecture"
    )


def _rows(kind: str) -> list[list[str]]:
    return [
        line.split("\t")
        for line in CATALOG.read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#") and line.startswith(kind + "\t")
    ]


def _field_names() -> list[str]:
    return [
        node.target.id
        for node in _class().body
        if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name)
    ]


def _method_names() -> list[str]:
    return [
        node.name
        for node in _class().body
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]


def _bootstrap_assignments() -> list[str]:
    method = next(
        node
        for node in _class().body
        if isinstance(node, ast.FunctionDef) and node.name == "bootstrap"
    )
    result = []
    for node in method.body:
        if not isinstance(node, ast.Assign) or len(node.targets) != 1:
            continue
        target = node.targets[0]
        if isinstance(target, ast.Name) and target.id != "architecture":
            result.append(target.id)
    return result


def _snapshot_names() -> list[str]:
    method = next(
        node
        for node in _class().body
        if isinstance(node, ast.FunctionDef) and node.name == "snapshot"
    )
    returned = next(node for node in ast.walk(method) if isinstance(node, ast.Return))
    assert isinstance(returned.value, ast.Dict)
    return [key.value for key in returned.value.keys]


def test_generated_facade_catalog_is_reproducible(tmp_path: Path) -> None:
    output = tmp_path / "architecture_facade.tsv"
    subprocess.run(
        [
            sys.executable,
            str(ROOT / "tools/generate_architecture_facade_catalog.py"),
            "--source",
            str(SOURCE),
            "--output",
            str(output),
        ],
        check=True,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        text=True,
    )
    assert output.read_bytes() == CATALOG.read_bytes()


def test_catalog_preserves_all_four_ordered_surfaces() -> None:
    fields = _rows("field")
    methods = _rows("method")
    bootstraps = _rows("bootstrap")
    snapshots = _rows("snapshot")
    assert [row[2] for row in fields] == _field_names()
    assert [row[2] for row in methods] == _method_names()
    assert [row[2] for row in bootstraps] == _bootstrap_assignments()
    assert [row[2] for row in snapshots] == _snapshot_names()
    assert (len(fields), len(methods), len(bootstraps), len(snapshots)) == (
        45,
        49,
        45,
        48,
    )
    assert {row[2] for row in fields} == {row[2] for row in bootstraps}


def test_native_facade_graph_is_bridge_free_and_queryable() -> None:
    text = MODULE.read_text(encoding="utf-8")
    assert "struct ArchitectureFacadeEntry" in text
    assert "struct ArchitectureFacadeNativeCompletionPlan" in text
    assert "plan_architecture_facade_native_completion" in text
    assert "architecture_facade_native_completion_valid" in text
    assert "architecture_facade_catalog_valid" in text
    assert "architecture_facade_dependencies" in text
    assert "architecture_facade.tsv" in text
    assert "from std.python import" not in text
    assert "PythonObject" not in text
    assert "subprocess" not in text


def test_build_install_and_launcher_own_the_new_diagnostic() -> None:
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    targets = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8")
    launcher = ROOT / "bin/reta-mojo-facade"
    assert "architecture_facade_main.mojo reta-mojo-facade" in build
    assert "reta-mojo-facade" in targets.splitlines()
    assert launcher.stat().st_mode & 0o111


def test_architecture_export_filter_transfers_its_local_copy() -> None:
    """Regression for the Mojo 1.0 ownership error reported in Stage 12c5i."""
    text = EXPORTS_MODULE.read_text(encoding="utf-8")
    assert "var entry = catalog.entries[index].copy()" in text
    assert "result.append(entry^)" in text
    assert "result.append(entry)" not in text


def test_porting_matrix_marks_facade_as_native_owner() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(
        line
        for line in matrix.splitlines()
        if "`reta_architecture/facade.py`" in line
    )
    assert "| nativ |" in row
    assert "architecture_facade.mojo" in row
