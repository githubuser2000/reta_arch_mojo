#!/usr/bin/env python3
"""Generate the static ProgramWorkflow surface from the Python reference AST."""
from __future__ import annotations

import argparse
import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "python_reference/reta_architecture/program_workflow.py"
DEFAULT_OUTPUT = ROOT / "assets/program_workflow.tsv"


def _workflow_class(tree: ast.Module) -> ast.ClassDef:
    return next(
        node
        for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == "ProgramWorkflowBundle"
    )


def _literal_string_list(node: ast.AST) -> list[str]:
    value = ast.literal_eval(node)
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise TypeError("orchestration_steps must be a literal list[str]")
    return value


def generate(source: Path) -> str:
    tree = ast.parse(source.read_text(encoding="utf-8"))
    workflow = _workflow_class(tree)
    rows: list[tuple[str, int, str, str, str]] = []

    fields = [
        node.target.id
        for node in workflow.body
        if isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name)
    ]
    for ordinal, name in enumerate(fields):
        rows.append(("field", ordinal, name, "-", "-"))

    methods = [node for node in workflow.body if isinstance(node, ast.FunctionDef)]
    for ordinal, method in enumerate(methods):
        arity = max(0, len(method.args.args) - 1)
        visibility = "private" if method.name.startswith("_") else "public"
        rows.append(("method", ordinal, method.name, str(arity), visibility))

    self_edges: list[tuple[str, str]] = []
    for method in methods:
        seen: set[tuple[str, str]] = set()
        for node in ast.walk(method):
            if not isinstance(node, ast.Call) or not isinstance(node.func, ast.Attribute):
                continue
            owner = node.func.value
            if isinstance(owner, ast.Name) and owner.id == "self":
                edge = (method.name, node.func.attr)
                if edge not in seen:
                    seen.add(edge)
                    self_edges.append(edge)
    for ordinal, (source_name, target_name) in enumerate(self_edges):
        rows.append(("self_call", ordinal, source_name, target_name, "-"))

    snapshot = next(node for node in methods if node.name == "snapshot")
    returned = next(node for node in ast.walk(snapshot) if isinstance(node, ast.Return))
    if not isinstance(returned.value, ast.Dict):
        raise TypeError("snapshot must return a literal dict")
    steps_node: ast.AST | None = None
    for key, value in zip(returned.value.keys, returned.value.values):
        if isinstance(key, ast.Constant) and key.value == "orchestration_steps":
            steps_node = value
            break
    if steps_node is None:
        raise KeyError("snapshot orchestration_steps missing")
    for ordinal, name in enumerate(_literal_string_list(steps_node)):
        rows.append(("step", ordinal, name, "-", "-"))

    bootstrap = next(
        node
        for node in tree.body
        if isinstance(node, ast.FunctionDef) and node.name == "bootstrap_program_workflow"
    )
    rows.append(("bootstrap", 0, bootstrap.name, str(len(bootstrap.args.args)), "public"))

    lines = ["# kind\tordinal\tname\tvalue\textra\n"]
    lines.extend("\t".join(map(str, row)) + "\n" for row in rows)
    return "".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(generate(args.source), encoding="utf-8")
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
