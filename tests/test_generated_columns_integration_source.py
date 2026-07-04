from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src/reta_mojo/generated_columns_integration.mojo"


def test_dynamic_concat_object_is_replaced_by_typed_request() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    for token in (
        "struct GeneratedColumnsApplicationRequest(Copyable):",
        "struct GeneratedColumnsRuntime(Copyable):",
        "def bootstrap_generated_columns_runtime(",
        "def apply_generated_columns_request(",
        "apply_native_generated_columns(",
    ):
        assert token in source
    for field in (
        "table: CsvTable",
        "selected_columns: List[Int]",
        "modal_concepts: List[ModalConcept]",
        "meta_requests: List[MetaColumnRequest]",
        "fraction_requests: List[FractionColumnRequest]",
        "generated_commands: List[String]",
        "language: String",
        "output_mode: String",
        "last_row: Int",
    ):
        assert field in source
    assert "PythonObject" not in source
    assert "from std.python import" not in source
    assert "getattr(" not in source
    assert "setattr(" not in source


def test_integration_reuses_every_existing_algorithm_owner() -> None:
    source = SOURCE.read_text(encoding="utf-8")
    for owner in (
        ".generated_columns",
        ".generated_table_columns",
        ".generated_aliases",
        ".csv_table",
    ):
        assert owner in source
    contract = source[source.index("def generated_columns_integration_contract") :]
    for owner in (
        "generated_columns.mojo",
        "generated_table_columns.mojo",
        "prime_cross_columns.mojo",
        "prime_universe_columns.mojo",
        "meta_columns.mojo",
        "fraction_concat_columns.mojo",
    ):
        assert owner in contract


def test_porting_matrix_promotes_generated_columns_to_native() -> None:
    generator = (ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8")
    assert '"reta_architecture/generated_columns.py": ("nativ"' in generator
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(
        line
        for line in matrix.splitlines()
        if "`reta_architecture/generated_columns.py`" in line
    )
    assert "| nativ |" in row
    assert "generated_columns_integration.mojo" in row


def test_package_exports_runtime_and_request() -> None:
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .generated_columns_integration import (" in package
    assert "GeneratedColumnsApplicationRequest," in package
    assert "bootstrap_generated_columns_runtime," in package
