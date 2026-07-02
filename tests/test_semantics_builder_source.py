from __future__ import annotations

import ast
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PY_SEMANTICS = ROOT / "python_reference/reta_architecture/semantics_builder.py"
PY_COLUMNS = ROOT / "python_reference/reta_architecture/column_selection.py"
PY_UNIVERSAL = ROOT / "python_reference/reta_architecture/universal.py"
MOJO_SEMANTICS = ROOT / "src/reta_mojo/semantics_builder.mojo"
MOJO_COLUMNS = ROOT / "src/reta_mojo/column_selection.mojo"
MOJO_UNIVERSAL = ROOT / "src/reta_mojo/universal.mojo"


def _class_methods(path: Path, class_name: str) -> list[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    cls = next(
        node
        for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == class_name
    )
    return [
        node.name
        for node in cls.body
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]


def _module_functions(path: Path) -> list[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    return [
        node.name
        for node in tree.body
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]


def test_parameter_semantics_builder_surface_has_native_owner() -> None:
    assert _class_methods(PY_SEMANTICS, "ParameterSemanticsBuilder") == [
        "__init__",
        "allowed_prim_numbers_for_command",
        "build_reverse_lookup",
        "collect_all_values",
        "into_parameter_datatype",
        "build",
    ]
    source = MOJO_SEMANTICS.read_text(encoding="utf-8")
    for marker in (
        "struct ParameterSemanticsBuildResult",
        "def allowed_prim_numbers_for_command(",
        "def build_reverse_lookup(",
        "def collect_all_values(",
        "def into_parameter_datatype(",
        "def build_parameter_semantics(",
        "def parameter_semantics_fingerprint(",
    ):
        assert marker in source
    assert "Dict[String, Int]" in source
    assert "from std.python import" not in source
    assert "PythonObject" not in source
    assert 'external_call["system"' not in source


def test_full_catalog_and_python_fingerprints_are_reproducible_assets() -> None:
    catalog = ROOT / "src/reta_mojo/semantics_builder_catalog.mojo"
    reference = ROOT / "assets/parameter_semantics_reference.json"
    generator = ROOT / "tools/generate_semantics_builder_catalog.py"
    probe = ROOT / "tests/semantics_builder_probe.mojo"
    combined_suite = ROOT / "tests/test_semantics_stage12c5f.mojo"
    parity = ROOT / "scripts/check_semantics_builder_parity.py"
    for path in (catalog, reference, generator, probe, combined_suite, parity):
        assert path.is_file(), path
    payload = json.loads(reference.read_text(encoding="utf-8"))
    assert payload["catalog_entries"] == 431
    assert payload["normal"]["para_dict"] == 4155
    assert payload["normal"]["simple_columns"] == 556
    assert payload["normal"]["fingerprint"] == (
        "14361:946406030:222404321:921621192:75488621"
    )
    assert payload["inverted"]["fingerprint"] == (
        "12624:500592877:712071932:377318734:638165603"
    )
    generator_source = generator.read_text(encoding="utf-8")
    assert "class StableSet(set):" in generator_source
    assert "def normalized_schema(" in generator_source
    catalog_source = catalog.read_text(encoding="utf-8")
    assert catalog_source.count("def _append_parameter_entries_") >= 18
    assert "def bootstrap_parameter_semantics_schema()" in catalog_source


def test_reference_regression_counts_use_current_556_columns() -> None:
    source = (ROOT / "python_reference/tests/test_architecture_refactor.py").read_text(
        encoding="utf-8"
    )
    assert "len(program.AllSimpleCommandSpalten), 556" in source
    assert "len(program.AllSimpleCommandSpalten), 554" not in source
    assert "[556, 46, 11, 12, 7, 23, 23, 10, 14, 23, 23, 12, 0, 0]" in source


def test_column_selection_surface_is_fully_typed() -> None:
    assert _module_functions(PY_COLUMNS) == ["bootstrap_column_selection"]
    assert _class_methods(PY_COLUMNS, "ColumnSelectionBundle") == [
        "type_naming",
        "bucket_values",
        "bucket_names",
        "new_bucket_map",
        "bind_program_sections",
        "snapshot",
    ]
    source = MOJO_COLUMNS.read_text(encoding="utf-8")
    for marker in (
        "struct ColumnSelectionBundle",
        "def bootstrap_column_selection(",
        "def bind_column_sections(",
        "struct BoundColumnSections",
    ):
        assert marker in source
    assert "PythonObject" not in source


def test_universal_surface_is_fully_typed() -> None:
    assert _module_functions(PY_UNIVERSAL) == [
        "merge_parameter_dicts",
        "normalize_column_buckets",
        "sync_generated_columns_from_tables",
        "sync_output_section_from_tables",
    ]
    assert _class_methods(PY_UNIVERSAL, "UniversalBundle") == [
        "merge_parameter_dicts",
        "normalize_column_buckets",
        "sync_tables",
        "snapshot",
    ]
    source = MOJO_UNIVERSAL.read_text(encoding="utf-8")
    for marker in (
        "def merge_parameter_dicts(",
        "def normalize_column_buckets(",
        "def sync_generated_columns_from_tables(",
        "def sync_output_section_from_tables(",
        "def sync_tables(",
        "def universal_operation_names(",
    ):
        assert marker in source
    assert "PythonObject" not in source


def test_semantics_cli_is_wired_into_heavy_build_and_install() -> None:
    assert (ROOT / "src/semantics_builder_main.mojo").is_file()
    assert (ROOT / "bin/reta-mojo-semantics").is_file()
    assert "src/semantics_builder_main.mojo" in (
        ROOT / "scripts/build-heavy.sh"
    ).read_text(encoding="utf-8")
    assert "reta-mojo-semantics" in (
        ROOT / "scripts/install_bins.sh"
    ).read_text(encoding="utf-8")
    assert "reta-mojo-semantics" in (
        ROOT / "scripts/check_build_layout.sh"
    ).read_text(encoding="utf-8")


def test_all_three_reference_owners_are_claimed_native() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    for path in (
        "reta_architecture/semantics_builder.py",
        "reta_architecture/column_selection.py",
        "reta_architecture/universal.py",
    ):
        row = next(line for line in matrix.splitlines() if f"`{path}`" in line)
        assert "| nativ |" in row or "| generiert nativ |" in row
