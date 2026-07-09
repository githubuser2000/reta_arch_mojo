from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYTHON_SOURCE = ROOT / "python_reference/reta_architecture/console_io.py"
MOJO_SOURCE = ROOT / "src/reta_mojo/console_io.mojo"


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


def test_python_console_io_surface_is_known() -> None:
    classes, functions = _surface()
    assert set(classes) == {"DefaultOrderedDict", "ConsoleIOMorphismBundle"}
    assert functions == (
        "chunks",
        "unique_everseen",
        "cli_output",
        "debug_pair",
        "debug_value",
        "_doc_path",
        "reta_prompt_help_text",
        "print_reta_prompt_help",
        "reta_help_text",
        "print_reta_help",
        "get_text_wrap_things",
        "bootstrap_console_io_morphisms",
    )


def test_complete_typed_owner_covers_observable_surface() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    required = (
        "struct DefaultOrderedDict",
        "struct ConsoleIOMorphismBundle",
        "def chunks_strings(",
        "def unique_everseen_strings(",
        "def unique_everseen_ascii_lower(",
        "def cli_output(",
        "def debug_pair(",
        "def debug_value(",
        "def _doc_path(",
        "def reta_prompt_help_text(",
        "def print_reta_prompt_help(",
        "def reta_help_text(",
        "def print_reta_help(",
        "def get_text_wrap_things(",
        "def bootstrap_console_io_morphisms(",
        "def snapshot(self) -> ConsoleIOMorphismSnapshot",
    )
    for token in required:
        assert token in source
    for method in (
        "chunks",
        "unique_everseen",
        "cliout",
        "debug_pair",
        "debug_value",
        "reta_prompt_help_text",
        "print_reta_prompt_help",
        "reta_help_text",
        "print_reta_help",
        "text_wrap_runtime",
        "default_ordered_dict_type",
        "snapshot",
    ):
        assert f"def {method}(" in source


def test_console_io_owner_has_no_python_or_child_process_bridge() -> None:
    source = MOJO_SOURCE.read_text(encoding="utf-8")
    for token in ("std.python", "PythonObject", "subprocess", "fork(", "execve("):
        assert token not in source


def test_console_io_build_and_install_surface_is_wired() -> None:
    abi = (ROOT / "src/reta_diagnostics_abi.mojo").read_text(encoding="utf-8")
    assert "reta_mojo_console_io_entry" in abi
    targets = (ROOT / "scripts/install_targets.txt").read_text(encoding="utf-8").splitlines()
    assert "reta-mojo-diagnostics" in targets
    assert "reta-mojo-console-io" not in targets
    launcher = ROOT / "tools/wrappers/reta-mojo-console-io"
    assert launcher.is_file()
    assert launcher.stat().st_mode & 0o111
    launcher_source = launcher.read_text(encoding="utf-8")
    assert "reta-mojo-diagnostics" in launcher_source
    assert '"console-io"' in launcher_source
    assert "mojo-runtime-exec" in launcher_source


def test_help_assets_match_reference_contract() -> None:
    # Prompt assets are exact function results.  The CLI help assets include
    # one additional newline intentionally emitted by the startup surface.
    for language in ("de", "en"):
        prompt = (ROOT / f"assets/reta_prompt_help_{language}.txt").read_bytes()
        reta = (ROOT / f"assets/reta_help_{language}.txt").read_bytes()
        assert prompt
        assert reta.endswith(b"\n\n")
        assert not prompt.endswith(b"\n\n\n")
