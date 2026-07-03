from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_architecture/table_generation.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/table_generation.mojo"


def _surface() -> tuple[dict[str, tuple[str, ...]], tuple[str, ...]]:
    module = ast.parse(PYTHON_SOURCE.read_text(encoding="utf-8"))
    classes: dict[str, tuple[str, ...]] = {}
    functions: list[str] = []
    for node in module.body:
        if isinstance(node, ast.ClassDef):
            classes[node.name] = tuple(
                item.name
                for item in node.body
                if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef))
            )
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            functions.append(node.name)
    return classes, tuple(functions)


def test_complete_table_generation_surface_is_owned() -> None:
    classes, functions = _surface()
    assert classes == {
        "TableGenerationResult": ("snapshot",),
        "TableGenerationBundle": (
            "_concat_csv_inputs",
            "_set_last_line_number",
            "_apply_generated_column_morphisms",
            "_read_kombi_tables",
            "build_for_program",
            "snapshot",
        ),
    }
    assert functions == ("bootstrap_table_generation",)
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for class_name, methods in classes.items():
        assert f"struct {class_name}" in source
        for method in methods:
            assert f"def {method}(" in source
    for function in functions:
        assert f"def {function}(" in source


def test_native_orchestration_order_is_explicit() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    build = source[source.index("def build_for_program(") :]
    assert build.index("_concat_csv_inputs") < build.index("_set_last_line_number")
    assert build.index("_set_last_line_number") < build.index("_apply_generated_column_morphisms")
    assert build.index("_apply_generated_column_morphisms") < build.index("_read_kombi_tables")
    assert "apply_native_generated_columns" in source
    assert "apply_kombi_join_columns" in source
    assert "capture_last_line_number" in source


def test_native_owner_has_no_python_or_process_bridge() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for token in ("std.python", "PythonObject", "subprocess", "fork(", "execve("):
        assert token not in source


def test_build_install_and_launcher_surfaces_are_wired() -> None:
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    assert "build src/table_generation_main.mojo reta-mojo-table-generation -I src" in build
    assert "reta-mojo-table-generation" in (
        ROOT / "scripts/install_targets.txt"
    ).read_text(encoding="utf-8").splitlines()
    assert (ROOT / "bin/reta-mojo-table-generation").stat().st_mode & 0o111


def test_static_snapshot_contract_matches_python_counts() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    assert '["prim", "gebrGal", "gebroUni", "gebrEmo", "gebrGroe"]' in source
    assert '"capture_last_line_number"' in source
    assert '["kombi.csv", "kombi-meta.csv"]' in source
    assert source.count('            "concat') >= 8
