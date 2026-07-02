from __future__ import annotations

import ast
import hashlib
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def _methods(path: Path) -> dict[str, set[str]]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    result: dict[str, set[str]] = {}
    for node in tree.body:
        if isinstance(node, ast.ClassDef):
            result[node.name] = {
                child.name
                for child in node.body
                if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef))
            }
    return result


def test_presheaf_and_sheaf_public_surfaces_are_owned() -> None:
    presheaf_methods = _methods(ROOT / "python_reference/reta_architecture/presheaves.py")
    sheaf_methods = _methods(ROOT / "python_reference/reta_architecture/sheaves.py")
    presheaf_source = (ROOT / "src/reta_mojo/presheaves.mojo").read_text(encoding="utf-8")
    sheaf_source = (ROOT / "src/reta_mojo/sheaves.mojo").read_text(encoding="utf-8")
    parameter_source = (ROOT / "src/reta_mojo/parameter_semantics.mojo").read_text(encoding="utf-8")
    for class_name, methods in presheaf_methods.items():
        assert f"struct {class_name}" in presheaf_source
        for method in methods:
            assert f"def {method}(" in presheaf_source
    for class_name, methods in sheaf_methods.items():
        owner = parameter_source if class_name == "ParameterSemanticsSheaf" else sheaf_source
        assert f"struct {class_name}" in owner
        for method in methods:
            assert f"def {method}(" in owner or f"def {method}(\n" in owner


def test_generated_catalogs_match_reference_discovery_and_html_last_write() -> None:
    paths = [
        ROOT / "assets/presheaf_catalog.tsv",
        ROOT / "assets/html_reference_sheaf.tsv",
    ]
    before = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
    result = subprocess.run(
        ["python3", "tools/generate_presheaf_sheaf_catalogs.py"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    assert result.returncode == 0, result.stderr
    after = {path: hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
    assert before == after
    assert "presheaf_catalog=269" in result.stdout
    presheaf_rows = [
        line for line in paths[0].read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#")
    ]
    html_rows = [
        line for line in paths[1].read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#")
    ]
    assert len(presheaf_rows) == 269
    assert sum(line.startswith("csv\t") for line in presheaf_rows) == 79
    assert sum(line.startswith("translations\t") for line in presheaf_rows) == 27
    assert sum(line.startswith("assets\t") for line in presheaf_rows) == 163
    assert len(html_rows) == 669


def test_native_owners_have_no_python_or_process_bridge() -> None:
    sources = "\n".join(
        (ROOT / relative).read_text(encoding="utf-8")
        for relative in (
            "src/reta_mojo/presheaves.mojo",
            "src/reta_mojo/sheaves.mojo",
            "src/reta_mojo/parameter_semantics.mojo",
        )
    )
    forbidden = ("std.python", "PythonObject", "subprocess", "fork(", "execve(")
    for token in forbidden:
        assert token not in sources


def test_build_and_install_surfaces_include_native_sheaf_diagnostics() -> None:
    assert "build src/sheaves_main.mojo reta-mojo-sheaves -I src" in (
        ROOT / "scripts/build.sh"
    ).read_text(encoding="utf-8")
    assert "reta-mojo-sheaves" in (
        ROOT / "scripts/install_targets.txt"
    ).read_text(encoding="utf-8").splitlines()
    assert (ROOT / "bin/reta-mojo-sheaves").stat().st_mode & 0o111


def test_presheaf_catalog_is_portable_and_ordered() -> None:
    rows = [
        line.split("\t")
        for line in (ROOT / "assets/presheaf_catalog.tsv").read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#")
    ]
    assert [int(row[1]) for row in rows] == list(range(len(rows)))
    assert all(not Path(row[2]).is_absolute() for row in rows)
    assert all(len(row) == 7 for row in rows)
