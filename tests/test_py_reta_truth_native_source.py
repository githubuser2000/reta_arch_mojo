from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _native_mapping() -> dict[str, tuple[str, str, str]]:
    tree = ast.parse((ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "NATIVE"
            for target in node.targets
        ):
            value = ast.literal_eval(node.value)
            assert isinstance(value, dict)
            return value
    raise AssertionError("NATIVE mapping missing")


def test_native_truth_owner_delegates_to_existing_typed_owners() -> None:
    source = (ROOT / "src/reta_mojo/py_reta_truth.mojo").read_text(encoding="utf-8")
    assert "build_parameter_semantics(bootstrap_reta_schema())" in source
    assert "read_semicolon_csv(csv_resource(filename))" in source
    assert "tags_for_column(schema, 744)" in source
    assert "tags_for_column(schema, 745)" in source
    assert "subprocess" not in source
    assert "PythonKit" not in source
    assert "run_process" not in source


def test_native_truth_test_covers_every_reference_invariant() -> None:
    source = (ROOT / "tests/test_py_reta_truth_native.mojo").read_text(encoding="utf-8")
    for literal in (
        "[4, 21, 54, 197, 425, 745]",
        "[30, 82, 425, 745]",
        '"Neues M (13) Kontinuum"',
        '"alternative Größenordnungen"',
        "[0, 5]",
        "[0, 4]",
    ):
        assert literal in source
    for filename in (
        "religion.csv",
        "cn-religion.csv",
        "en-religion.csv",
        "kr-religion.csv",
        "vn-religion.csv",
    ):
        assert filename in source


def test_truth_reference_tests_are_claimed_native_and_current_stage_builds_them() -> None:
    mapping = _native_mapping()
    assert mapping["tests/test_py_reta_truth_matrix.py"][0] == "nativ"
    assert mapping["tests/test_py_reta_truth_output_invariants.py"][0] == "nativ"
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .py_reta_truth import *" in package
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ar.sh" in current
    current_stage = (ROOT / "scripts/test_stage12c5ar.sh").read_text(encoding="utf-8")
    assert "test_stage12c5aq.sh" in current_stage
    command_stage = (ROOT / "scripts/test_stage12c5aq.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ap.sh" in command_stage
    stage = (ROOT / "scripts/test_stage12c5ap.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ao.sh" in stage
    assert "tests/test_py_reta_truth_native.mojo" in stage
