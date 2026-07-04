#!/usr/bin/env python3
"""Generate the exact public surface catalog for historical ``retaPrompt.py``."""
from __future__ import annotations

import argparse
import ast
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "python_reference" / "retaPrompt.py"
DEFAULT_OUTPUT = ROOT / "src" / "reta_mojo" / "legacy_reta_prompt_catalog.mojo"


def _bound_names(target: ast.expr) -> list[str]:
    if isinstance(target, ast.Name):
        return [target.id]
    if isinstance(target, (ast.Tuple, ast.List)):
        result: list[str] = []
        for element in target.elts:
            result.extend(_bound_names(element))
        return result
    # Attribute/subscript assignments mutate an existing object and do not
    # bind a module-level name (for example ``sys.argv``).
    return []


def public_names() -> list[str]:
    tree = ast.parse(SOURCE.read_text(encoding="utf-8"), filename=str(SOURCE))
    result: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.Import):
            result.extend(alias.asname or alias.name.split(".", 1)[0] for alias in node.names)
        elif isinstance(node, ast.ImportFrom):
            if node.module == "__future__":
                continue
            result.extend(alias.asname or alias.name for alias in node.names)
        elif isinstance(node, ast.Assign):
            for target in node.targets:
                result.extend(_bound_names(target))
        elif isinstance(node, ast.AnnAssign):
            result.extend(_bound_names(node.target))
        elif isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            result.append(node.name)
    return [name for name in result if not name.startswith("_")]


def render() -> str:
    names = public_names()
    quoted = ",\n        ".join(json.dumps(name, ensure_ascii=False) for name in names)
    return f'''"""Generated public surface of historical ``retaPrompt.py``.

Regenerate with ``tools/generate_legacy_reta_prompt_catalog.py``.
"""

from std.collections import List


def legacy_reta_prompt_exported_names() -> List[String]:
    return [
        {quoted}
    ]


def legacy_reta_prompt_exported_count() -> Int:
    return {len(names)}
'''


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    text = render()
    if args.check:
        current = args.output.read_text(encoding="utf-8") if args.output.exists() else ""
        if current != text:
            raise SystemExit(f"legacy retaPrompt catalog differs: {args.output}")
        print(f"legacy retaPrompt catalog identical: {len(public_names())} names")
        return
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(text, encoding="utf-8")
    print(f"generated {args.output}: {len(public_names())} names")


if __name__ == "__main__":
    main()
