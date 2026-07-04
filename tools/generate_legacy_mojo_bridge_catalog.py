#!/usr/bin/env python3
"""Generate exact public/function catalogs for historical ``mojo_bridge.py``."""
from __future__ import annotations

import argparse
import ast
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "python_reference" / "mojo_bridge.py"
DEFAULT_OUTPUT = ROOT / "src" / "reta_mojo" / "legacy_mojo_bridge_catalog.mojo"


def _bound_names(target: ast.expr) -> list[str]:
    if isinstance(target, ast.Name):
        return [target.id]
    if isinstance(target, (ast.Tuple, ast.List)):
        result: list[str] = []
        for element in target.elts:
            result.extend(_bound_names(element))
        return result
    return []


def public_names() -> list[str]:
    tree = ast.parse(SOURCE.read_text(encoding="utf-8"), filename=str(SOURCE))
    result: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.Assign):
            for target in node.targets:
                result.extend(_bound_names(target))
        elif isinstance(node, ast.AnnAssign):
            result.extend(_bound_names(node.target))
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            result.append(node.name)
    return [name for name in result if not name.startswith("_")]


def function_names() -> list[str]:
    tree = ast.parse(SOURCE.read_text(encoding="utf-8"), filename=str(SOURCE))
    functions = [
        node
        for node in ast.walk(tree)
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    ]
    functions.sort(key=lambda node: (node.lineno, node.col_offset))
    return [node.name for node in functions]


def _render_list(name: str, values: list[str]) -> str:
    quoted = ",\n        ".join(json.dumps(value, ensure_ascii=False) for value in values)
    return f"""def {name}() -> List[String]:
    return [
        {quoted}
    ]


"""


def render() -> str:
    public = public_names()
    functions = function_names()
    return (
        '"""Generated exact surface catalogs for historical ``mojo_bridge.py``.\n\n'
        'Regenerate with ``tools/generate_legacy_mojo_bridge_catalog.py``.\n'
        '"""\n\n'
        'from std.collections import List\n\n\n'
        + _render_list("legacy_mojo_bridge_public_names", public)
        + _render_list("legacy_mojo_bridge_function_names", functions)
        + f"def legacy_mojo_bridge_public_count() -> Int:\n    return {len(public)}\n\n\n"
        + f"def legacy_mojo_bridge_function_count() -> Int:\n    return {len(functions)}\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    text = render()
    if args.check:
        current = args.output.read_text(encoding="utf-8") if args.output.exists() else ""
        if current != text:
            raise SystemExit(f"legacy mojo bridge catalog differs: {args.output}")
        print(
            "legacy mojo bridge catalog identical: "
            f"{len(public_names())} public names, {len(function_names())} functions"
        )
        return 0
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(text, encoding="utf-8")
    print(
        f"generated {args.output}: {len(public_names())} public names, "
        f"{len(function_names())} functions"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
