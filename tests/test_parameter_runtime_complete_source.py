from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_OWNER = ROOT / "python_reference/reta_architecture/parameter_runtime.py"
MOJO_OWNER = ROOT / "src/reta_mojo/parameter_runtime.mojo"


def test_every_module_function_has_a_native_owner_or_typed_replacement() -> None:
    tree = ast.parse(PYTHON_OWNER.read_text(encoding="utf-8"))
    functions = [node.name for node in tree.body if isinstance(node, ast.FunctionDef)]
    assert functions == [
        "_ensure_runtime_imports",
        "bootstrap_parameter_runtime",
        "produce_all_spalten_numbers",
        "apply_width_parameter",
        "parameters_to_commands_and_numbers",
        "upper_limit_values_for_argument",
        "upper_limit_from_arguments",
        "apply_upper_limit_argument",
    ]
    source = MOJO_OWNER.read_text(encoding="utf-8")
    for name in functions[1:]:
        assert f"def {name}(" in source
    assert "def parameter_runtime_legacy_snapshot(" in source
    assert "runtime_imports=static" in source


def test_mutable_program_object_is_replaced_by_one_plan() -> None:
    source = MOJO_OWNER.read_text(encoding="utf-8")
    for token in (
        "struct ParameterRuntimePlan(Copyable):",
        "struct ParameterRuntimeWidthResult(Copyable, Equatable):",
        "def build_parameter_runtime_plan(",
        "def parameters_to_commands_and_numbers(",
        "diagnostics: List[String]",
    ):
        assert token in source
    assert "PythonObject" not in source
    assert "from std.python import" not in source
    assert "getattr(" not in source
    assert "setattr(" not in source


def test_porting_matrix_promotes_parameter_runtime_to_native() -> None:
    generator = (ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8")
    assert '"reta_architecture/parameter_runtime.py": ("nativ"' in generator
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(
        line
        for line in matrix.splitlines()
        if "`reta_architecture/parameter_runtime.py`" in line
    )
    assert "| nativ |" in row
    assert "ParameterRuntimePlan" in row
