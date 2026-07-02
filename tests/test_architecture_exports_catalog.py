from __future__ import annotations

import ast
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "python_reference/reta_architecture/__init__.py"
CATALOG = ROOT / "assets/architecture_exports.tsv"


def _source_contract() -> tuple[list[tuple[str, str, str]], list[str]]:
    tree = ast.parse(SOURCE.read_text(encoding="utf-8"))
    imports: list[tuple[str, str, str]] = []
    public: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.ImportFrom):
            imports.extend(
                (node.module or "", alias.name, alias.asname or alias.name)
                for alias in node.names
            )
        elif isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "__all__"
            for target in node.targets
        ):
            public = [element.value for element in node.value.elts]
    return imports, public


def _catalog_rows() -> list[tuple[int, int, str, str, str, bool]]:
    rows = []
    for line in CATALOG.read_text(encoding="utf-8").splitlines():
        if not line or line.startswith("#"):
            continue
        all_ordinal, import_ordinal, module, imported, public, flag = line.split("\t")
        rows.append(
            (int(all_ordinal), int(import_ordinal), module, imported, public, flag == "1")
        )
    return rows


def test_generated_catalog_is_reproducible(tmp_path: Path) -> None:
    output = tmp_path / "architecture_exports.tsv"
    subprocess.run(
        [
            sys.executable,
            str(ROOT / "tools/generate_architecture_exports.py"),
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


def test_catalog_preserves_import_and_all_contract() -> None:
    imports, public = _source_contract()
    rows = _catalog_rows()
    assert len(imports) == len(rows) == 314
    assert len(public) == 232
    assert len({module for module, _, _ in imports}) == 46

    by_import_ordinal = sorted(rows, key=lambda row: row[1])
    assert [row[2:5] for row in by_import_ordinal] == [
        (module, imported, public_name)
        for module, imported, public_name in imports
    ]
    public_rows = [row for row in rows if row[5]]
    assert [row[4] for row in public_rows] == public
    assert [row[0] for row in public_rows] == list(range(len(public)))


def test_native_sources_are_wired_into_build_and_install_surface() -> None:
    module = (ROOT / "src/reta_mojo/architecture_exports.mojo").read_text()
    main = (ROOT / "src/architecture_exports_main.mojo").read_text()
    build = (ROOT / "scripts/build.sh").read_text()
    launcher = ROOT / "bin/reta-mojo-exports"
    assert "struct ArchitectureExportSpec" in module
    assert "load_architecture_export_catalog" in module
    assert "--symbol" in main and "--module" in main
    assert "architecture_exports_main.mojo reta-mojo-exports" in build
    assert launcher.stat().st_mode & 0o111
