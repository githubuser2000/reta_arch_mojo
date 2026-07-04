from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/parameter_runtime.mojo"
CLI = ROOT / "src/reta_mojo/native_reta_cli.mojo"
MATRIX_GENERATOR = ROOT / "tools/generate_porting_matrix.py"


def test_parameter_runtime_has_explicit_native_owner() -> None:
    text = OWNER.read_text(encoding="utf-8")
    for symbol in (
        "struct ParameterRuntimeBundle",
        "struct ParameterRuntimePlan",
        "def build_parameter_runtime_plan",
        "def upper_limit_values_for_argument",
        "def upper_limit_from_arguments",
        "def apply_upper_limit_argument",
        "def parameter_runtime_effective_highest",
    ):
        assert symbol in text
    assert "std.python" not in text
    assert "subprocess" not in text


def test_productive_cli_delegates_to_the_owner() -> None:
    text = CLI.read_text(encoding="utf-8")
    assert "from .parameter_runtime import" in text
    assert "return build_parameter_runtime_plan(tokens, maximum_columns, maximum_rows)" in text
    assert "def _collect_generated_alias" not in text
    assert "load_runtime_alias_catalog" not in text
    assert "load_generated_alias_catalog" not in text
    assert "load_all_column_selection" not in text


def test_porting_matrix_generator_tracks_the_new_owner() -> None:
    tree = ast.parse(MATRIX_GENERATOR.read_text(encoding="utf-8"))
    mapping = None
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "NATIVE"
            for target in node.targets
        ):
            mapping = ast.literal_eval(node.value)
            break
    assert mapping is not None
    status, target, note = mapping["reta_architecture/parameter_runtime.py"]
    assert status == "nativ"
    assert "parameter_runtime.mojo" in target
    assert "ParameterRuntimePlan" in note
