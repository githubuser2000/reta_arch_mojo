from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_architecture/morphisms.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/morphisms.mojo"


def _python_surface() -> dict[str, tuple[str, ...]]:
    module = ast.parse(PYTHON_SOURCE.read_text(encoding="utf-8"))
    result: dict[str, tuple[str, ...]] = {}
    for node in module.body:
        if isinstance(node, ast.ClassDef):
            result[node.name] = tuple(
                item.name
                for item in node.body
                if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef))
            )
    return result


def test_python_morphism_surface_is_fully_owned() -> None:
    surface = _python_surface()
    assert surface == {
        "AliasMorphisms": (
            "resolve_main_alias",
            "resolve_parameter_alias",
            "canonicalize_pair",
            "column_numbers_for_pair",
        ),
        "RangeMorphisms": ("parse_row_range",),
        "PromptMorphisms": (
            "split",
            "split_prompt_text",
            "split_command_words",
            "expand_shorthand",
        ),
        "RendererMorphisms": (
            "output_mode_for_tables",
            "apply_output_mode",
        ),
        "MorphismBundle": ("from_topology_and_sheaves", "snapshot"),
    }
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for methods in surface.values():
        for method in methods:
            assert f"def {method}(" in source


def test_native_morphisms_use_typed_owners_without_python_bridge() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    assert "ParameterSemanticsSheaf" in source
    assert "ContextSelection" in source
    assert "OutputRuntimeState" in source
    assert "PromptExpansionRequest" in source
    assert "_deduplicate_sorted" in source
    assert "std.python" not in source
    assert "PythonObject" not in source
    assert "subprocess" not in source
    assert "RendererMorphisms(topology_context.copy(), default_output_mode)" in source
    assert "RendererMorphisms(topology_context^, default_output_mode)" not in source


def test_morphism_bundle_snapshot_preserves_python_order() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    assert '"alias", "ranges", "prompt", "renderers"' in source
