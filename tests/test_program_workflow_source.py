from __future__ import annotations

import ast
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "python_reference/reta_architecture/program_workflow.py"
CATALOG = ROOT / "assets/program_workflow.tsv"
MODULE = ROOT / "src/reta_mojo/program_workflow.mojo"
MAIN = ROOT / "src/program_workflow_main.mojo"


def _workflow_class() -> ast.ClassDef:
    tree = ast.parse(SOURCE.read_text(encoding="utf-8"))
    return next(
        node
        for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == "ProgramWorkflowBundle"
    )


def _rows(kind: str) -> list[list[str]]:
    return [
        line.split("\t")
        for line in CATALOG.read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#") and line.startswith(kind + "\t")
    ]


def test_program_workflow_catalog_is_reproducible(tmp_path: Path) -> None:
    output = tmp_path / "program_workflow.tsv"
    subprocess.run(
        [
            sys.executable,
            str(ROOT / "tools/generate_program_workflow_catalog.py"),
            "--source",
            str(SOURCE),
            "--output",
            str(output),
        ],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    assert output.read_bytes() == CATALOG.read_bytes()


def test_catalog_preserves_fields_methods_calls_and_steps() -> None:
    workflow = _workflow_class()
    fields = [
        node.target.id
        for node in workflow.body
        if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name)
    ]
    methods = [node.name for node in workflow.body if isinstance(node, ast.FunctionDef)]
    assert [row[2] for row in _rows("field")] == fields
    assert [row[2] for row in _rows("method")] == methods
    assert (len(fields), len(methods)) == (4, 11)
    assert len(_rows("self_call")) == 10
    assert len(_rows("step")) == 12
    assert _rows("step")[0][2] == "load_religion_table"
    assert _rows("step")[10][2] == "join_kombi_tables"


def test_native_workflow_owns_real_deterministic_operations() -> None:
    text = MODULE.read_text(encoding="utf-8")
    for symbol in (
        "requested_religion_output_kind",
        "load_program_workflow_religion_table",
        "apply_language_specific_motive_column",
        "plan_kombi_workflow",
        "program_workflow_snapshot",
    ):
        assert f"def {symbol}" in text
    assert "decode_religion_rows_threaded" in text
    assert "read_semicolon_csv" in text
    assert "from std.python import" not in text
    assert "PythonObject" not in text
    assert "subprocess" not in text


def test_build_install_launcher_and_main_are_wired() -> None:
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    targets = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8")
    launcher = ROOT / "bin/reta-mojo-workflow"
    assert "program_workflow_main.mojo reta-mojo-workflow" in build
    assert "reta-mojo-workflow" in targets.splitlines()
    assert "--load-religion" in MAIN.read_text(encoding="utf-8")
    assert launcher.stat().st_mode & 0o111


def test_porting_matrix_marks_program_workflow_fully_native() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(
        line
        for line in matrix.splitlines()
        if "`reta_architecture/program_workflow.py`" in line
    )
    assert "| nativ |" in row
    assert "program_workflow.mojo" in row


def test_religion_json_scanner_is_utf8_boundary_safe() -> None:
    parser = (ROOT / "src/reta_mojo/parallel_execution.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_program_workflow.mojo").read_text(encoding="utf-8")
    assert "var bytes = json.as_bytes()" in parser
    assert "Int(bytes[cursor])" in parser
    assert "ord(json[byte=cursor])" not in parser
    assert "한글 中文 Việt" in mojo_test
    defects = (ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8")
    assert "MOJO-FIXED-031" in defects


def test_output_kind_priority_and_fast_fixture_are_regression_covered() -> None:
    module = MODULE.read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_program_workflow.mojo").read_text(encoding="utf-8")
    parity = (ROOT / "scripts/check_program_workflow_parity.py").read_text(encoding="utf-8")
    fixture = (
        ROOT / "tests/fixtures/program_workflow_root/csv/religion.csv"
    ).read_text(encoding="utf-8")
    assert module.index("if argv[index] == bbcode_argument") < module.index(
        "if argv[index] == html_argument"
    )
    assert 'args.append("--art=html")' in mojo_test
    assert 'args.append("--art=bbcode")' in mojo_test
    assert '["reta", "--art=html", "--art=bbcode"]' in parity
    assert '["reta", "--art=bbcode", "--art=html"]' in parity
    assert "한글 中文 Việt" in fixture
    assert "MOJO-FIXED-032" in (ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8")


def test_complete_typed_workflow_replaces_heterogeneous_program_object() -> None:
    text = MODULE.read_text(encoding="utf-8")
    for token in (
        "struct ProgramWorkflowI18n",
        "struct ProgramWorkflowParameterReadResult",
        "struct ProgramWorkflowBeginResult",
        "struct ProgramWorkflowExecutionResult",
        "def _csv_path(",
        "def _decode_religion_cell(",
        "def _requested_religion_output_kind(",
        "def _load_religion_table(",
        "def _apply_language_specific_motive_column(",
        "def _reset_runtime_flags(",
        "def _read_positive_and_negative_parameters(",
        "def bring_all_important_begin_things(",
        "def workflow_everything(",
        "def combi_table_workflow(",
        "def snapshot(",
        "def table_generation_plan_from_runtime(",
        "def configure_program_workflow(",
    ):
        assert token in text
    assert "build_parameter_runtime_plan" in text
    assert "bootstrap_table_generation" in text
    assert "bootstrap_column_selection" in text
    assert "select_display_lines" in text


def test_table_generation_has_only_one_galaxy_output_declaration() -> None:
    source = (ROOT / "src/reta_mojo/table_generation.mojo").read_text(encoding="utf-8")
    assert source.count("var galaxy_output_columns = List[Int]()") == 1


def test_complete_workflow_is_explicitly_exported_by_package() -> None:
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .program_workflow import (" in package
    assert "ProgramWorkflowExecutionResult," in package
    assert "configure_program_workflow," in package


def test_workflow_basename_has_one_local_declaration() -> None:
    text = MODULE.read_text(encoding="utf-8")
    body = text.split("def program_workflow_basename", 1)[1].split("def program_workflow_csv_path", 1)[0]
    assert body.count("var pieces = path.split") == 1
