from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_architecture/table_preparation.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/table_preparation.mojo"


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


def test_python_table_preparation_surface_is_known() -> None:
    classes, functions = _surface()
    assert set(classes) == {
        "MainTablePreparationResult",
        "KombiTablePreparationResult",
        "TablePreparationBundle",
    }
    assert set(functions) == {
        "_tag_modules",
        "prepare_output_table",
        "select_display_lines",
        "prepare_row_cells",
        "tag_output_column",
        "cell_work",
        "bootstrap_table_preparation",
    }
    assert classes["MainTablePreparationResult"] == ("snapshot",)
    assert classes["KombiTablePreparationResult"] == ("snapshot",)
    assert set(classes["TablePreparationBundle"]) == {
        "prepare_output_table",
        "select_display_lines",
        "prepare_row_cells",
        "tag_output_column",
        "cell_work",
        "deduplicate_parameter_sections",
        "capture_last_line_number",
        "prepare_main_output",
        "prepare_kombi_output",
        "snapshot",
    }


def test_complete_typed_owner_covers_observable_surface() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    required = (
        "struct MainTablePreparationResult",
        "struct KombiTablePreparationResult",
        "struct TablePreparationBundle",
        "struct PreparedOutputTableResult",
        "struct ColumnIndexMapping",
        "struct GeneratedTagOverrides",
        "struct PreparedColumnTag",
        "def prepare_output_table(",
        "def select_display_lines(",
        "def prepare_row_cells(",
        "def tag_output_column(",
        "def cell_work(",
        "def deduplicate_parameter_sections(",
        "def capture_last_line_number(",
        "def prepare_main_output(",
        "def prepare_kombi_output(",
        "parameter_already_present: Bool = False",
        "headings_amount = len(table.rows[0])",
        "def bootstrap_table_preparation(",
        "tags_for_column(",
        "prepare_indexed_row(",
    )
    for token in required:
        assert token in source


def test_table_preparation_owner_has_no_python_or_child_process_bridge() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for token in ("std.python", "PythonObject", "subprocess", "fork(", "execve("):
        assert token not in source


def test_table_preparation_keeps_parallelism_as_separate_outer_strategy() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    parallel = (ROOT / "src/reta_mojo/parallel_row_preparation.mojo").read_text(
        encoding="utf-8"
    )
    assert "prepare_indexed_row(" in source
    assert "prepare_rows_serial(" in source
    assert "from .table_preparation import (" in parallel
    assert "prepare_rows_serial," in parallel
    assert "parallelize[worker]" in parallel


def test_complete_owner_is_authoritative_in_metrics() -> None:
    metrics = (ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8")
    assert '"reta_architecture/table_preparation.py": ("nativ"' in metrics


def test_header_width_and_generated_override_branch_match_python_order() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    assert "headings_amount = len(table.rows[0])" in source
    assert "if parameter_already_present:" in source
    assert source.index("if parameter_already_present:") < source.index(
        "var generated = _generated_override_tags(source_column, overrides)"
    )
