from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_OWNER = ROOT / "python_reference/reta_architecture/runtime_compat.py"
MOJO_OWNER = ROOT / "src/reta_mojo/runtime_compat.mojo"
ARITHMETIC_OWNER = ROOT / "src/reta_mojo/arithmetic.mojo"

EXPECTED_FUNCTIONS = (
    "BereichToNumbers2",
    "retaPromptHilfe",
    "retaHilfe",
    "getTextWrapThings",
    "x",
    "alxp",
    "chunks",
    "cliout",
    "unique_everseen",
    "multiples",
    "teiler",
    "invert_dict_B",
    "textHatZiffer",
    "primfaktoren",
    "primRepeat",
    "primRepeat2",
    "moduloA",
)


def _python_surface() -> tuple[tuple[str, ...], tuple[str, ...]]:
    tree = ast.parse(PYTHON_OWNER.read_text(encoding="utf-8"))
    functions = tuple(
        node.name for node in tree.body if isinstance(node, ast.FunctionDef)
    )
    classes = tuple(
        node.name for node in tree.body if isinstance(node, ast.ClassDef)
    )
    return functions, classes


def test_runtime_compat_python_surface_is_fully_owned() -> None:
    functions, classes = _python_surface()
    assert functions == EXPECTED_FUNCTIONS
    assert classes == ("nPmEnum",)
    source = MOJO_OWNER.read_text(encoding="utf-8")
    for name in EXPECTED_FUNCTIONS:
        assert f"def {name}(" in source
    for helper in (
        "npm_galaxy",
        "npm_universe",
        "npm_emotion",
        "npm_size",
        "npm_n_values",
        "npm_one_plus_n_values",
        "runtime_compat_snapshot",
    ):
        assert f"def {helper}(" in source


def test_runtime_compat_constants_match_reference_contract() -> None:
    source = MOJO_OWNER.read_text(encoding="utf-8")
    assert 'RUNTIME_COMPAT_COMMA_PATTERN = ",(?!' in source
    assert 'RUNTIME_COMPAT_PRIME_CROSS_NAME = "Primzahlkreuz_pro_contra"' in source
    assert "Primzahl-Kreuz-Algorithmus_(15)" in source
    assert 'return [["Multiplikationen", ""]]' in source
    for value in range(2, 10):
        assert f"= {value}" in source


def test_runtime_compat_has_no_python_or_process_bridge() -> None:
    source = MOJO_OWNER.read_text(encoding="utf-8")
    for forbidden in ("std.python", "PythonObject", "subprocess", "external_call"):
        assert forbidden not in source
    assert "range_to_numbers" in source
    assert "factor_pairs" in source
    assert "native_cli_startup" in source
    assert "terminal_columns" in source


def test_arithmetic_digit_owner_is_unicode_safe() -> None:
    source = ARITHMETIC_OWNER.read_text(encoding="utf-8")
    assert "from .unicode_digits import has_unicode_digit" in source
    body = source.split("def has_digit", 1)[1].split("\ndef ", 1)[0]
    assert "return has_unicode_digit(text)" in body
    assert "text[byte=index]" not in body
