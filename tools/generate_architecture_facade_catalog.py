#!/usr/bin/env python3
"""Generate the static contract of ``reta_architecture.facade`` from its AST.

The Python facade is mostly a composition root: ordered fields, bootstrap
steps, cache/rebuild entry points and a stable snapshot surface.  This tool
freezes that observable graph without importing the Python package or running
any of its heavyweight bootstrap code.
"""
from __future__ import annotations

import argparse
import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "python_reference/reta_architecture/facade.py"
DEFAULT_OUTPUT = ROOT / "assets/architecture_facade.tsv"


def dotted_name(node: ast.AST) -> str:
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        prefix = dotted_name(node.value)
        return f"{prefix}.{node.attr}" if prefix else node.attr
    if isinstance(node, ast.Call):
        name = dotted_name(node.func)
        return f"{name}()" if name else ""
    return ""


def first_call_name(node: ast.AST) -> str:
    if isinstance(node, ast.Call):
        return dotted_name(node.func)
    for child in ast.iter_child_nodes(node):
        name = first_call_name(child)
        if name:
            return name
    return ast.unparse(node)


def imported_owners(tree: ast.Module) -> dict[str, str]:
    owners: dict[str, str] = {}
    for node in ast.walk(tree):
        if not isinstance(node, ast.ImportFrom) or not node.module:
            continue
        for alias in node.names:
            owners[alias.asname or alias.name] = node.module
    return owners


def owner_for_type(type_name: str, owners: dict[str, str]) -> str:
    root = type_name.split("[", 1)[0].split(".", 1)[0]
    return owners.get(root, "builtins" if root == "object" else "unknown")


def parse_contract(source: Path) -> tuple[list[tuple], list[tuple], list[tuple], list[tuple]]:
    tree = ast.parse(source.read_text(encoding="utf-8"))
    owners = imported_owners(tree)
    cls = next(
        node
        for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == "RetaArchitecture"
    )

    fields: list[tuple] = []
    for node in cls.body:
        if not isinstance(node, ast.AnnAssign) or not isinstance(node.target, ast.Name):
            continue
        type_name = ast.unparse(node.annotation)
        fields.append(
            (
                len(fields),
                node.target.id,
                type_name,
                owner_for_type(type_name, owners),
            )
        )

    methods: list[tuple] = []
    for node in cls.body:
        if not isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            continue
        dependencies: list[str] = []
        for call in ast.walk(node):
            if not isinstance(call, ast.Call) or not isinstance(call.func, ast.Attribute):
                continue
            if not isinstance(call.func.value, ast.Name) or call.func.value.id != "self":
                continue
            if not call.func.attr.startswith("bootstrap_"):
                continue
            if call.func.attr not in dependencies:
                dependencies.append(call.func.attr)
        arg_names = [arg.arg for arg in (*node.args.posonlyargs, *node.args.args, *node.args.kwonlyargs)]
        methods.append(
            (
                len(methods),
                node.name,
                "1" if "force_rebuild" in arg_names else "0",
                ",".join(dependencies) if dependencies else "-",
            )
        )

    bootstrap_method = next(
        node
        for node in cls.body
        if isinstance(node, ast.FunctionDef) and node.name == "bootstrap"
    )
    bootstraps: list[tuple] = []
    for node in bootstrap_method.body:
        if not isinstance(node, ast.Assign) or len(node.targets) != 1:
            continue
        target = node.targets[0]
        if not isinstance(target, ast.Name) or target.id == "architecture":
            continue
        bootstraps.append(
            (
                len(bootstraps),
                target.id,
                first_call_name(node.value),
            )
        )

    snapshot_method = next(
        node
        for node in cls.body
        if isinstance(node, ast.FunctionDef) and node.name == "snapshot"
    )
    return_node = next(
        node for node in ast.walk(snapshot_method) if isinstance(node, ast.Return)
    )
    if not isinstance(return_node.value, ast.Dict):
        raise TypeError("RetaArchitecture.snapshot must return a dict literal")
    snapshots: list[tuple] = []
    for key, value in zip(return_node.value.keys, return_node.value.values, strict=True):
        if not isinstance(key, ast.Constant) or not isinstance(key.value, str):
            raise TypeError("snapshot keys must be string literals")
        snapshots.append((len(snapshots), key.value, first_call_name(value)))

    field_names = [row[1] for row in fields]
    bootstrap_names = [row[1] for row in bootstraps]
    if len(field_names) != len(bootstrap_names) or set(field_names) != set(bootstrap_names):
        raise ValueError(
            "facade fields and bootstrap assignments no longer match:\n"
            f"fields={field_names!r}\nbootstraps={bootstrap_names!r}"
        )
    return fields, methods, bootstraps, snapshots


def write_catalog(source: Path, output: Path) -> None:
    fields, methods, bootstraps, snapshots = parse_contract(source)
    lines = [
        "# kind\tordinal\tname\tvalue\textra\n",
        f"# source={source.name}\n",
    ]
    lines.extend(
        f"field\t{ordinal}\t{name}\t{type_name}\t{owner}\n"
        for ordinal, name, type_name, owner in fields
    )
    lines.extend(
        f"method\t{ordinal}\t{name}\t{force_rebuild}\t{dependencies}\n"
        for ordinal, name, force_rebuild, dependencies in methods
    )
    lines.extend(
        f"bootstrap\t{ordinal}\t{name}\t{factory}\t-\n"
        for ordinal, name, factory in bootstraps
    )
    lines.extend(
        f"snapshot\t{ordinal}\t{name}\t{producer}\t-\n"
        for ordinal, name, producer in snapshots
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text("".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()
    write_catalog(args.source.resolve(), args.output.resolve())
    print(args.output.resolve())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
