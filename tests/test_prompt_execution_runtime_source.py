from __future__ import annotations

import ast
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/reta_architecture/prompt_execution.py"
OWNER = ROOT / "src/reta_mojo/prompt_execution.mojo"
RUNTIME = ROOT / "src/reta_mojo/prompt_execution_runtime.mojo"
PROMPT_MAIN = ROOT / "src/prompt_main.mojo"


def _reference_surface() -> list[str]:
    tree = ast.parse(REFERENCE.read_text(encoding="utf-8"))
    return [
        node.name
        for node in tree.body
        if isinstance(node, (ast.FunctionDef, ast.ClassDef))
    ]


def _ownership_entries() -> list[tuple[str, str, str]]:
    source = OWNER.read_text(encoding="utf-8")
    body = source.split("def prompt_execution_owners()", 1)[1].split(
        "@fieldwise_init\nstruct PromptExecutionSnapshot", 1
    )[0]
    return re.findall(
        r'PromptExecutionOwner\("([^"]+)", "([^"]+)", "([^"]+)"\)',
        body,
    )


def _owner_path(owner: str) -> Path:
    if owner == "prompt_main.mojo":
        return ROOT / "src" / owner
    return ROOT / "src/reta_mojo" / owner


def test_every_python_execution_entry_has_mapped_native_evidence() -> None:
    reference = _reference_surface()
    entries = _ownership_entries()
    assert len(reference) == 22
    assert [entry[0] for entry in entries] == reference
    assert len({entry[0] for entry in entries}) == 22
    for python_name, owner, evidence in entries:
        path = _owner_path(owner)
        assert path.exists(), (python_name, owner)
        assert evidence in path.read_text(encoding="utf-8"), (
            python_name,
            owner,
            evidence,
        )


def test_large_prompt_execution_effect_is_owned_by_typed_runtime_result() -> None:
    runtime = RUNTIME.read_text(encoding="utf-8")
    main = PROMPT_MAIN.read_text(encoding="utf-8")
    assert "struct PromptRenderedInvocation(Copyable)" in runtime
    assert "struct PromptTableExecutionResult(Copyable)" in runtime
    assert "def prompt_table_command_echo(" in runtime
    assert "def render_prompt_table_plan(" in runtime
    assert "run_native_reta(" in runtime
    assert "print(" not in runtime
    assert "from reta_mojo.prompt_execution_runtime import render_prompt_table_plan" in main
    assert "var execution = render_prompt_table_plan(" in main
    assert "def _run_native_table_tokens(" not in main


def test_prompt_execution_has_no_embedded_python_runtime() -> None:
    for path in (
        OWNER,
        RUNTIME,
        ROOT / "src/reta_mojo/prompt_execution_helpers.mojo",
        ROOT / "src/reta_mojo/prompt_fraction_execution.mojo",
        ROOT / "src/reta_mojo/prompt_table_execution.mojo",
    ):
        source = path.read_text(encoding="utf-8")
        assert "std.python" not in source
        assert "PythonObject" not in source
