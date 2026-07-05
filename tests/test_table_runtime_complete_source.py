from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_architecture/table_runtime.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/table_runtime.mojo"
STATE_SOURCE = ROOT / "src/reta_mojo/table_state.mojo"


def _surface() -> tuple[dict[str, tuple[str, ...]], tuple[str, ...]]:
    tree = ast.parse(PYTHON_SOURCE.read_text(encoding="utf-8"))
    classes: dict[str, tuple[str, ...]] = {}
    functions: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.ClassDef):
            classes[node.name] = tuple(
                item.name
                for item in node.body
                if isinstance(item, (ast.FunctionDef, ast.AsyncFunctionDef))
            )
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            functions.append(node.name)
    return classes, tuple(functions)


def test_python_table_runtime_surface_is_known() -> None:
    classes, functions = _surface()
    assert set(classes) == {"BreakoutException", "Tables", "TableRuntimeBundle"}
    assert functions == (
        "_get_text_wrap_things",
        "_prepare_class",
        "_concat_class",
        "bootstrap_table_runtime",
    )
    methods = set(classes["Tables"])
    assert {
        "keineUeberschriften",
        "keineleereninhalte",
        "spaltegGestirn",
        "tableStateSnapshot",
        "outputModeName",
        "NichtsOutputYes",
        "markdownOutputYes",
        "bbcodeOutputYes",
        "htmlOutputYes",
        "outType",
        "hoechsteZeile",
        "generRows",
        "ifPrimMultis",
        "ifZeilenSetted",
        "gebrUnivSet",
        "breitenn",
        "nummeriere",
        "textHeight",
        "textWidth",
        "fillBoth",
        "tableReducedInLinesByTypeSet",
    } <= methods
    assert set(classes["TableRuntimeBundle"]) == {"create_tables", "snapshot"}


def test_complete_typed_owner_covers_runtime_surface() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    required = (
        "struct BreakoutException",
        "struct RuntimeComponentClass",
        "struct Maintable",
        "struct TablesRuntimeSnapshot",
        "struct Tables",
        "struct TableRuntimeBundleSnapshot",
        "struct TableRuntimeBundle",
        "def _get_text_wrap_things(",
        "def _prepare_class(",
        "def _concat_class(",
        "def keineUeberschriften(",
        "def set_keineUeberschriften(",
        "def tableStateSnapshot(",
        "def outputModeName(",
        "def set_outType(",
        "def set_hoechsteZeile(",
        "def set_breitenn(",
        "def set_nummeriere(",
        "def set_textWidth(",
        "def fillBoth(",
        "def tableReducedInLinesByTypeSet(",
        "var appended_table_column: Int",
        "def createSpalteGestirn(",
        "def create_tables(",
        "def bootstrap_table_runtime(",
    )
    for token in required:
        assert token in source


def test_table_state_factory_and_snapshots_are_fully_typed() -> None:
    source = STATE_SOURCE.read_text(encoding="utf-8")
    for token in (
        "struct GeneratedColumnSectionSnapshot",
        "struct TableDisplayStateSnapshot",
        "struct TableStateSectionsSnapshot",
        "struct TableStateBundleSnapshot",
        "struct TableStateBundle",
        "def generated_column_section_snapshot(",
        "def table_display_state_snapshot(",
        "def table_state_sections_snapshot(",
        "def new_generated_rows(",
        "def bootstrap_table_state(",
    ):
        assert token in source


def test_table_runtime_has_no_python_or_child_process_bridge() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for token in ("std.python", "PythonObject", "subprocess", "fork(", "execve("):
        assert token not in source


def test_table_runtime_owner_is_authoritative_in_metrics() -> None:
    metrics = (ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8")
    assert '"reta_architecture/table_runtime.py": ("nativ"' in metrics


def test_table_runtime_is_explicitly_exported_by_package() -> None:
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .table_runtime import (" in package
    assert "TableRuntimeBundle," in package
    assert "bootstrap_table_runtime," in package


def test_gestirn_metadata_assignment_is_single_and_well_formed() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    assignment = "self.state.generated_columns.parameters[metadata_index] = ("
    assert source.count(assignment) == 1
    assert f"{assignment}\n                result.generated_parameter\n            )" in source


def test_runtime_test_imports_private_legacy_helpers_explicitly() -> None:
    source = (ROOT / "tests/test_table_runtime_complete.mojo").read_text(encoding="utf-8")
    assert "from reta_mojo.table_runtime import (" in source
    assert "_prepare_class," in source
    assert "_concat_class," in source
    assert "_get_text_wrap_things," in source
    assert "from reta_mojo.table_runtime import *" not in source


def test_highest_row_accessor_is_non_raising_and_has_historical_defaults() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    assert "self.state.highest_rows.get(114, 163)" in source
    assert "self.state.highest_rows.get(1024, 1024)" in source
    accessor = source[source.index("def hoechsteZeile(") : source.index("def set_hoechsteZeile(")]
    assert "highest_rows[114]" not in accessor
    assert "highest_rows[1024]" not in accessor
