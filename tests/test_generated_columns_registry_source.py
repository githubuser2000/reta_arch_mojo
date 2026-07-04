from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PY_SOURCE = ROOT / "python_reference/reta_architecture/generated_columns.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/generated_columns.mojo"


def _python_public_surface() -> tuple[list[str], list[str]]:
    tree = ast.parse(PY_SOURCE.read_text(encoding="utf-8"))
    classes = [node.name for node in tree.body if isinstance(node, ast.ClassDef)]
    functions = [
        node.name
        for node in tree.body
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
        and not node.name.startswith("_")
    ]
    return classes, functions


def test_generated_column_registry_and_bundle_are_native_typed_owners() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for token in (
        "struct GeneratedColumnSpec(",
        "struct GeneratedColumnRegistry(",
        "struct GeneratedColumnsBundle(",
        "def default_generated_column_registry(",
        "def bootstrap_generated_columns(",
        "def generated_columns_surface(",
    ):
        assert token in source
    assert source.count("GeneratedColumnSpec(") >= 11


def test_registry_preserves_all_python_morphisms_in_exact_order() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    expected = [
        ("concatVervielfacheZeile", "[19, 90]", '["legacy-column-propagation"]'),
        ("concatModallogik", "List[Int]()", '["modal-logic", "generated-concepts"]'),
        ("concat1RowPrimUniverse2", "List[Int]()", '["prim-universe", "fractional-generated-column"]'),
        ("concat1PrimzahlkreuzProContra", "List[Int]()", '["prime-cross", "pro-contra", "generated-column"]'),
        ("concatPrimCreativityType", "[64]", '["sternPolygon", "galaxie"]'),
        ("concatGleichheitFreiheitDominieren", "[132]", '["sternPolygon", "universum"]'),
        ("concatGeistEmotionEnergieMaterieTopologie", "[242]", '["sternPolygon", "universum"]'),
        ("concatMondExponzierenLogarithmusTyp", "[64]", '["sternPolygon", "universum", "galaxie"]'),
        ("concatLovePolygon", "[9]", '["sternPolygon", "galaxie", "gleichfoermigesPolygon"]'),
        ("createSpalteGestirn", "[64]", '["sternPolygon", "universum", "galaxie"]'),
    ]
    positions: list[int] = []
    for method_name, trigger_columns, tags in expected:
        start = source.index(f'                "{method_name}",')
        positions.append(start)
        fragment = source[start : start + 420]
        assert trigger_columns in fragment
        assert tags in fragment
    assert positions == sorted(positions)


def test_surface_catalog_names_every_public_python_owner_in_source_order() -> None:
    classes, functions = _python_public_surface()
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    positions = [
        source.index(f'GeneratedColumnsSurfaceEntry("{name}"')
        for name in classes + functions
    ]
    assert positions == sorted(positions)
    assert len(positions) == 16
