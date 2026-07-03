from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_architecture/table_output.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/table_output.mojo"


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


def test_python_table_output_surface_is_known() -> None:
    classes, functions = _surface()
    assert set(classes) == {"BreakoutException", "TableOutput", "TableOutputBundle"}
    assert functions == ("bootstrap_table_output",)
    methods = set(classes["TableOutput"])
    assert {
        "outType",
        "color",
        "oneTable",
        "breitenn",
        "nummeriere",
        "textHeight",
        "textWidth",
        "onlyThatColumns",
        "cliOut",
        "cliout2",
        "colorize",
    } <= methods
    assert set(classes["TableOutputBundle"]) == {"create", "snapshot"}


def test_complete_typed_owner_covers_observable_surface() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    required = (
        "struct TableOutputConfig",
        "struct TableOutputRenderResult",
        "struct TableOutput",
        "struct TableOutputBundle",
        "def out_type(",
        "def set_out_type(",
        "def color(",
        "def set_color(",
        "def one_table(",
        "def set_one_table(",
        "def breitenn(",
        "def set_breitenn(",
        "def nummeriere(",
        "def set_nummeriere(",
        "def text_height(",
        "def set_text_height(",
        "def text_width(",
        "def set_text_width(",
        "def only_that_columns(",
        "def cli_out(",
        "def cliout2(",
        "def colorize(",
        "def create(",
        "def snapshot(",
        "def bootstrap_table_output(",
        "render_table_with_native_context(",
        "select_columns(",
    )
    for token in required:
        assert token in source


def test_table_output_owner_has_no_python_or_child_process_bridge() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for token in ("std.python", "PythonObject", "subprocess", "fork(", "execve("):
        assert token not in source


def test_table_output_build_and_install_surface_is_wired() -> None:
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    assert "build src/table_output_main.mojo reta-mojo-table-output -I src" in build
    targets = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8").splitlines()
    assert "reta-mojo-table-output" in targets
    launcher = ROOT / "bin/reta-mojo-table-output"
    assert launcher.is_file()
    assert launcher.stat().st_mode & 0o111
    launcher_source = launcher.read_text(encoding="utf-8")
    assert "reta-mojo-table-output" in launcher_source
    assert "mojo-runtime-exec" in launcher_source


def test_table_rendering_exposes_colorize_adapter_without_duplication() -> None:
    rendering = (ROOT / "src/reta_mojo/table_rendering.mojo").read_text(encoding="utf-8")
    assert "def colorize_shell_text(" in rendering
    assert "return _shell_colorize(text, number, rest)" in rendering
