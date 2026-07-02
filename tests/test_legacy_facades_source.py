from __future__ import annotations

import ast
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def function_names(path: Path) -> set[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    return {
        node.name
        for node in tree.body
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    }


def test_center_facade_covers_all_active_python_functions() -> None:
    python_functions = function_names(ROOT / "python_reference/libs/center.py")
    mojo = (ROOT / "src/reta_mojo/legacy_center.mojo").read_text(encoding="utf-8")
    compatibility_names = {
        "isZeilenBruchAngabe_betweenKommas",
        "isZeilenBruchOrGanzZahlAngabe",
        "isZeilenBruchAngabe",
        "isZeilenAngabe",
        "isZeilenAngabe_betweenKommas",
        "retaPromptHilfe",
        "retaHilfe",
        "getTextWrapThings",
        "x",
        "alxp",
        "chunks",
        "cliout",
        "strAsGeneratorToListOfNumStrs",
        "unique_everseen",
        "BereichToNumbers2",
        "BereichToNumbers2_EinBereich",
        "BereichToNumbers2_EinBereich_Menge",
        "BereichToNumbers2_EinBereich_Menge_nichtVielfache",
        "BereichToNumbers2_EinBereich_Menge_vielfache",
        "multiples",
        "teiler",
        "invert_dict_B",
        "textHatZiffer",
        "primfaktoren",
        "primRepeat",
        "primRepeat2",
        "moduloA",
    }
    assert python_functions == compatibility_names
    for name in compatibility_names:
        assert f'def {name}(' in mojo
    assert "from std.python import" not in mojo
    assert "PythonObject" not in mojo


def test_lib4tables_facade_covers_exact_public_reexports() -> None:
    tree = ast.parse((ROOT / "python_reference/libs/lib4tables.py").read_text(encoding="utf-8"))
    python_all = next(
        ast.literal_eval(node.value)
        for node in tree.body
        if isinstance(node, ast.Assign)
        and any(isinstance(target, ast.Name) and target.id == "__all__" for target in node.targets)
    )
    mojo = (ROOT / "src/reta_mojo/legacy_lib4tables.mojo").read_text(encoding="utf-8")
    for name in python_all:
        assert f'"{name}"' in mojo
    assert "def isPrimMultipleMatches(" in mojo
    assert "from std.python import" not in mojo


def test_unicode_digit_and_help_assets_are_reproducible() -> None:
    subprocess.run([sys.executable, "tools/generate_unicode_digits.py", "--check"], cwd=ROOT, check=True)
    subprocess.run([sys.executable, "tools/generate_legacy_help_assets.py", "--check"], cwd=ROOT, check=True)
    ranges = (ROOT / "assets/unicode_digit_ranges.tsv").read_text(encoding="utf-8").splitlines()
    assert len([line for line in ranges if line and not line.startswith("#") and line != "start\tend"]) == 83
    unicode_owner = (ROOT / "src/reta_mojo/unicode_digits.mojo").read_text(encoding="utf-8")
    assert "UNICODE_DIGIT_RANGE_COUNT = 83" in unicode_owner
    assert "UNICODE_DIGIT_CODEPOINT_COUNT = 808" in unicode_owner


def test_facades_are_claimed_native_and_forbidden_bridge_stays_absent() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    for path in ("libs/center.py", "libs/lib4tables.py"):
        row = next(line for line in matrix.splitlines() if f"`{path}`" in line)
        assert "| nativ |" in row
    assert not (ROOT / "src/reta_mojo/prompt_python_bridge.mojo").exists()
