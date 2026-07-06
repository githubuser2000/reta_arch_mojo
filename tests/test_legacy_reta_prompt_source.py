from __future__ import annotations

import ast
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PYTHON_FACADE = ROOT / "python_reference" / "retaPrompt.py"
MOJO_FACADE = ROOT / "src" / "reta_mojo" / "legacy_reta_prompt.mojo"
CATALOG = ROOT / "src" / "reta_mojo" / "legacy_reta_prompt_catalog.mojo"
GENERATOR = ROOT / "tools" / "generate_legacy_reta_prompt_catalog.py"


def _bound_names(target: ast.expr) -> list[str]:
    if isinstance(target, ast.Name):
        return [target.id]
    if isinstance(target, (ast.Tuple, ast.List)):
        result: list[str] = []
        for element in target.elts:
            result.extend(_bound_names(element))
        return result
    return []


def _public_python_names() -> list[str]:
    tree = ast.parse(PYTHON_FACADE.read_text(encoding="utf-8"))
    result: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.Import):
            result.extend(alias.asname or alias.name.split(".", 1)[0] for alias in node.names)
        elif isinstance(node, ast.ImportFrom):
            if node.module != "__future__":
                result.extend(alias.asname or alias.name for alias in node.names)
        elif isinstance(node, ast.Assign):
            for target in node.targets:
                result.extend(_bound_names(target))
        elif isinstance(node, ast.AnnAssign):
            result.extend(_bound_names(node.target))
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            result.append(node.name)
    return [name for name in result if not name.startswith("_")]


def test_generated_catalog_matches_exact_python_surface() -> None:
    subprocess.run([sys.executable, str(GENERATOR), "--check"], cwd=ROOT, check=True)
    source = CATALOG.read_text(encoding="utf-8")
    block = re.search(
        r"def legacy_reta_prompt_exported_names\(\).*?return \[(.*?)\n    \]",
        source,
        re.S,
    )
    assert block is not None
    mapped = re.findall(r'"([^"\\]+)"', block.group(1))
    expected = _public_python_names()
    assert len(expected) == 55
    assert mapped == expected
    assert "prompt_parallel_config" in mapped


def test_native_facade_reuses_existing_prompt_owners() -> None:
    source = MOJO_FACADE.read_text(encoding="utf-8")
    for owner in (
        ".legacy_libreta_prompt",
        ".prompt_runtime",
        ".prompt_interaction",
        ".prompt_process_dispatch",
        ".prompt_session",
    ):
        assert owner in source
    for name in (
        "LegacyRetaPromptBundle",
        "bootstrap_legacy_reta_prompt",
        "newSession",
        "speichern",
        "PromptAllesVorGroesserSchleife",
        "PromptLoescheVorSpeicherungBefehle",
        "promptSpeicherungB",
        "promptSpeicherungA",
        "promptInput",
        "PromptScope",
        "start",
    ):
        assert name in source
    assert "from std.python import" not in source
    assert "PythonObject" not in source
    assert "subprocess" not in source
    assert "python_reference" not in source


def test_process_entry_point_remains_the_only_observable_io_owner() -> None:
    source = MOJO_FACADE.read_text(encoding="utf-8")
    assert "print(" not in source
    assert "prompt_main.mojo" in source
    controller = (ROOT / "src" / "prompt_main.mojo").read_text(encoding="utf-8")
    assert "new_prompt_interaction(startup)" in controller
    assert "run_reta_prompt_arguments_native" in controller
    assert "plan_prompt_fallback_process_dispatch(" in controller


def test_package_matrix_and_stage_claim_complete_native_facade() -> None:
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .legacy_reta_prompt import (" in package
    assert "bootstrap_legacy_reta_prompt," in package
    generator = (ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8")
    assert '"retaPrompt.py": ("nativ"' in generator
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(line for line in matrix.splitlines() if "`retaPrompt.py`" in line)
    assert "| nativ |" in row
    assert "legacy_reta_prompt.mojo" in row
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current
    presheaf_stage = (ROOT / "scripts/test_stage12c5bd.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bc.sh" in presheaf_stage
    installed_launcher_stage = (ROOT / "scripts/test_stage12c5bc.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bb.sh" in installed_launcher_stage
    positive_first_stage = (ROOT / "scripts/test_stage12c5bb.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ba.sh" in positive_first_stage
    build_fix_stage = (ROOT / "scripts/test_stage12c5ba.sh").read_text(encoding="utf-8")
    assert "test_stage12c5az.sh" in build_fix_stage
    mixed_fraction_stage = (ROOT / "scripts/test_stage12c5az.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ay.sh" in mixed_fraction_stage
    process_alias_stage = (ROOT / "scripts/test_stage12c5ay.sh").read_text(encoding="utf-8")
    historical_prompt_stage = (ROOT / "scripts/test_stage12c5ax.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ax.sh" in process_alias_stage
    assert "test_stage12c5aw.sh" in historical_prompt_stage
    monotonic_stage = (ROOT / "scripts/test_stage12c5aw.sh").read_text(encoding="utf-8")
    assert "test_stage12c5av.sh" in monotonic_stage
    build_stage = (ROOT / "scripts/test_stage12c5av.sh").read_text(encoding="utf-8")
    assert "test_stage12c5au.sh" in build_stage
    startup_stage = (ROOT / "scripts/test_stage12c5au.sh").read_text(encoding="utf-8")
    assert "test_stage12c5at.sh" in startup_stage
    current_stage = (ROOT / "scripts/test_stage12c5at.sh").read_text(encoding="utf-8")
    assert "test_stage12c5as.sh" in current_stage
    refactor_stage = (ROOT / "scripts/test_stage12c5ar.sh").read_text(encoding="utf-8")
    assert "test_stage12c5aq.sh" in refactor_stage
    command_stage = (ROOT / "scripts/test_stage12c5aq.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ap.sh" in command_stage
    stage = (ROOT / "scripts/test_stage12c5ap.sh").read_text(encoding="utf-8")
    assert "test_stage12c5ao.sh" in stage
