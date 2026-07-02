from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_architecture/table_wrapping.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/table_wrapping.mojo"


def _python_surface() -> tuple[dict[str, tuple[str, ...]], tuple[str, ...]]:
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


def test_complete_python_table_wrapping_surface_is_owned() -> None:
    classes, functions = _python_surface()
    assert classes == {
        "Wraptype": (),
        "TextWrapRuntime": ("snapshot",),
        "TableWrappingBundle": ("wrap_text", "width_for_row", "snapshot"),
    }
    assert functions == (
        "refresh_textwrap_runtime",
        "textwrap_runtime",
        "set_shell_rows_amount",
        "get_shell_rows_amount",
        "set_wrapping_type",
        "get_wrapping_type",
        "chunks",
        "split_more_if_not_small",
        "alxwrap",
        "wrap_cell_text",
        "width_for_row",
        "bootstrap_table_wrapping",
    )
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for function in functions:
        assert f"def {function}(" in source
    for method in classes["TextWrapRuntime"] + classes["TableWrappingBundle"]:
        assert f"def {method}(" in source


def test_native_runtime_state_replaces_python_singleton_explicitly() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    assert "struct TextWrapRuntimeState" in source
    assert "struct TextWrapRuntimeSnapshot" in source
    assert "struct TableWrappingSnapshot" in source
    assert "getTextWrapThings" in source
    assert "codepoint_slices()" in source
    assert "hard_chunks" in source
    assert "std.python" not in source
    assert "PythonObject" not in source
    assert "subprocess" not in source


def test_morphism_bundle_does_not_transfer_from_immutable_context() -> None:
    source = (ROOT / "src/reta_mojo/morphisms.mojo").read_text(encoding="utf-8")
    assert "RendererMorphisms(topology_context.copy(), default_output_mode)" in source
    assert "RendererMorphisms(topology_context^, default_output_mode)" not in source
