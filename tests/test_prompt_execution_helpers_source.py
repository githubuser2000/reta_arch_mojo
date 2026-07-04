from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_execution_helpers.mojo"
PACKAGE = ROOT / "src/reta_mojo/__init__.mojo"
REFERENCE = ROOT / "python_reference/reta_architecture/prompt_execution.py"


def test_pure_prompt_execution_helpers_have_native_owner():
    source = OWNER.read_text(encoding="utf-8")
    for name in (
        "anotherOberesMaximum",
        "returnOnlyParasAsList",
        "grKl",
        "getDictLimtedByKeyList",
        "dictToList",
        "vorherVonAusschnittOderZaehlung",
    ):
        assert f"def {name}(" in source
    assert "PromptExecutionHelpersBundle" in source
    assert "prompt_is_reta_parameter" in source
    assert "range_to_numbers" in source
    assert "import subprocess" not in source
    assert "Python.h" not in source


def test_helper_surface_matches_python_reference_names():
    reference = REFERENCE.read_text(encoding="utf-8")
    source = OWNER.read_text(encoding="utf-8")
    for name in (
        "anotherOberesMaximum",
        "returnOnlyParasAsList",
        "grKl",
        "getDictLimtedByKeyList",
        "dictToList",
        "vorherVonAusschnittOderZaehlung",
    ):
        assert f"def {name}(" in reference
        assert f"def {name}(" in source


def test_package_exports_prompt_execution_helpers():
    package = PACKAGE.read_text(encoding="utf-8")
    assert "from .prompt_execution_helpers import *" in package
