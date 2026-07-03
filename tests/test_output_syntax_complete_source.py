from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PY_SEMANTICS = ROOT / "python_reference/reta_architecture/output_semantics.py"
PY_SYNTAX = ROOT / "python_reference/reta_architecture/output_syntax.py"
MOJO_MODES = ROOT / "src/reta_mojo/output_modes.mojo"
MOJO_SYNTAX = ROOT / "src/reta_mojo/output_syntax.mojo"


def _surface(path: Path) -> tuple[dict[str, tuple[str, ...]], tuple[str, ...]]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
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


def test_output_semantics_public_surface_is_owned() -> None:
    classes, functions = _surface(PY_SEMANTICS)
    assert classes == {
        "OutputModeSpec": ("snapshot",),
        "OutputModeApplication": ("snapshot",),
        "RetaOutputSemantics": (
            "__init__",
            "canonicalize",
            "spec_for",
            "create_syntax",
            "mode_for_output_syntax",
            "mode_for_tables",
            "is_mode",
            "apply_mode_to_tables",
            "snapshot",
        ),
    }
    assert functions == ("_bootstrap_output_semantics", "bootstrap_output_semantics")
    source = MOJO_MODES.read_text(encoding="utf-8")
    for name in ("OutputModeSpec", "OutputModeApplication", "RetaOutputSemantics"):
        assert f"struct {name}" in source
    assert "struct OutputModeSpec(Copyable, Equatable):" in source
    assert "struct OutputModeSpec(Copyable, Equatable, Writable):" not in source
    for method in (
        "snapshot",
        "canonicalize",
        "spec_for",
        "create_syntax",
        "mode_for_output_syntax",
        "mode_for_tables",
        "is_mode",
        "apply_mode_to_tables",
    ):
        assert f"def {method}(" in source
    assert "def bootstrap_output_semantics(" in source


def test_output_syntax_public_surface_is_owned() -> None:
    classes, functions = _surface(PY_SYNTAX)
    assert set(classes) == {
        "NichtsSyntax",
        "OutputSyntax",
        "csvSyntax",
        "emacsSyntax",
        "markdownSyntax",
        "bbCodeSyntax",
        "htmlSyntax",
        "OutputSyntaxBundle",
    }
    assert functions == ("bootstrap_output_syntax", "output_syntax_snapshot")
    source = MOJO_SYNTAX.read_text(encoding="utf-8")
    for constructor in (
        "NichtsSyntax",
        "OutputSyntax",
        "csvSyntax",
        "emacsSyntax",
        "markdownSyntax",
        "bbCodeSyntax",
        "htmlSyntax",
    ):
        assert f"def {constructor}(" in source
    for method in ("class_for", "colored_begin_col", "generate_cell", "snapshot"):
        assert f"def {method}(" in source
    for function in functions:
        assert f"def {function}(" in source
    assert "def OUTPUT_SYNTAX_CLASSES(" in source


def test_typed_owner_uses_html_catalog_without_python_bridge() -> None:
    combined = MOJO_MODES.read_text(encoding="utf-8") + MOJO_SYNTAX.read_text(
        encoding="utf-8"
    )
    assert "OutputCellRequest" in combined
    assert "html_cell_open" in combined
    assert "zero_width_callback_available" in combined
    for token in ("std.python", "PythonObject", "subprocess", "getattr(", "AnyType"):
        assert token not in combined


def test_build_install_launcher_and_stage_wiring() -> None:
    build = (ROOT / "scripts/build.sh").read_text(encoding="utf-8")
    abi = (ROOT / "src/reta_diagnostics_abi.mojo").read_text(encoding="utf-8")
    assert '"$ROOT/scripts/build_diagnostics_shared.sh"' in build
    assert "reta_mojo_output_syntax_entry" in abi
    targets = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8").splitlines()
    assert "reta-mojo-diagnostics" in targets
    assert "reta-mojo-output-syntax" not in targets
    launcher = ROOT / "bin/reta-mojo-output-syntax"
    assert launcher.stat().st_mode & 0o111
    launcher_source = launcher.read_text(encoding="utf-8")
    assert "reta-mojo-diagnostics" in launcher_source
    assert '"output-syntax"' in launcher_source
    stage = (ROOT / "scripts/test_stage12c5v.sh").read_text(encoding="utf-8")
    assert "test_output_semantics_complete.mojo" in stage
    assert "check_output_semantics_parity.py" in stage


def test_python_snapshot_constants_are_preserved() -> None:
    modes = MOJO_MODES.read_text(encoding="utf-8")
    syntax = MOJO_SYNTAX.read_text(encoding="utf-8")
    assert '["bbcode", "csv", "emacs", "html", "markdown", "nichts", "shell"]' not in modes
    for name in ("bbcode", "csv", "emacs", "html", "markdown", "nichts", "shell"):
        assert f'"{name}"' in modes
    assert '"libs.lib4tables"' in syntax
    assert '"reta_architecture.output_syntax"' in syntax
