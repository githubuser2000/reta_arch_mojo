#!/usr/bin/env python3
"""Generate the exact native packaging contract from frozen ``setup.py``.

The historical setuptools file combines immutable package metadata, five
command classes and one external gettext extraction command.  Runtime
installation is owned by ``scripts/install.sh``; this generator freezes the
remaining observable setup.py surface for the Mojo compatibility owner.
"""
from __future__ import annotations

import argparse
import ast
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "python_reference" / "setup.py"
OUTPUT = ROOT / "src" / "reta_mojo" / "setup_metadata_catalog.mojo"


def _base_name(node: ast.expr) -> str:
    if isinstance(node, ast.Name):
        return node.id
    if isinstance(node, ast.Attribute):
        parts: list[str] = []
        current: ast.expr = node
        while isinstance(current, ast.Attribute):
            parts.append(current.attr)
            current = current.value
        if isinstance(current, ast.Name):
            parts.append(current.id)
        return ".".join(reversed(parts))
    return ast.unparse(node)


def _dict_name_rows(node: ast.expr) -> list[tuple[str, str]]:
    if not isinstance(node, ast.Dict):
        raise ValueError("expected a dictionary expression")
    rows: list[tuple[str, str]] = []
    for key, value in zip(node.keys, node.values, strict=True):
        if key is None:
            raise ValueError("dictionary unpacking is not supported")
        name = ast.literal_eval(key)
        if not isinstance(name, str):
            raise ValueError("command key must be a string")
        rows.append((name, _base_name(value)))
    return rows


def _discover_packages() -> list[str]:
    packages: list[str] = []
    for init_file in sorted(SOURCE.parent.rglob("__init__.py")):
        relative = init_file.parent.relative_to(SOURCE.parent)
        if not relative.parts or any(part.startswith(".") for part in relative.parts):
            continue
        packages.append(".".join(relative.parts))
    return packages


def _extract_message_files() -> list[str]:
    i18n_root = SOURCE.parent / "i18n"
    return [
        path.relative_to(SOURCE.parent).as_posix()
        for path in sorted(i18n_root.rglob("*.py"))
    ]


def data() -> dict[str, object]:
    tree = ast.parse(SOURCE.read_text(encoding="utf-8"))
    setup_call = next(
        node
        for node in ast.walk(tree)
        if isinstance(node, ast.Call)
        and isinstance(node.func, ast.Name)
        and node.func.id == "setup"
    )
    keywords = {item.arg: item.value for item in setup_call.keywords if item.arg}

    def literal(name: str):
        return ast.literal_eval(keywords[name])

    classes: list[dict[str, object]] = []
    for node in tree.body:
        if not isinstance(node, ast.ClassDef):
            continue
        classes.append(
            {
                "name": node.name,
                "base": _base_name(node.bases[0]) if node.bases else "object",
                "methods": [
                    child.name
                    for child in node.body
                    if isinstance(child, (ast.FunctionDef, ast.AsyncFunctionDef))
                ],
            }
        )

    defined_cmdclass: list[tuple[str, str]] = []
    for node in tree.body:
        if not isinstance(node, ast.Assign):
            continue
        if any(isinstance(target, ast.Name) and target.id == "cmdclass" for target in node.targets):
            defined_cmdclass = _dict_name_rows(node.value)
            break

    active_cmdclass = _dict_name_rows(keywords["cmdclass"])
    package_data = literal("package_data")
    package_patterns: list[str] = []
    for owner, values in package_data.items():
        package_patterns.extend(f"{owner}\t{value}" for value in values)

    return {
        "name": literal("name"),
        "version": literal("version"),
        "description": literal("description"),
        "author": literal("author"),
        "requires": literal("install_requires"),
        "package_patterns": package_patterns,
        "packages": _discover_packages(),
        "classes": classes,
        "defined_cmdclass": [f"{key}\t{value}" for key, value in defined_cmdclass],
        "active_cmdclass": [f"{key}\t{value}" for key, value in active_cmdclass],
        "extract_files": _extract_message_files(),
        "extract_output": "i18n/messages.pot",
    }


def _mojo_list(values: list[str]) -> str:
    if not values:
        return ""
    return ",\n        ".join(json.dumps(value, ensure_ascii=False) for value in values)


def render() -> str:
    item = data()
    classes = item["classes"]
    assert isinstance(classes, list)
    class_names = [str(entry["name"]) for entry in classes]
    class_bases = [str(entry["base"]) for entry in classes]
    class_methods = [",".join(entry["methods"]) for entry in classes]
    method_count = sum(len(entry["methods"]) for entry in classes)

    def function(name: str, values: list[str]) -> str:
        return (
            f"def {name}() -> List[String]:\n"
            "    return [\n"
            f"        {_mojo_list(values)}\n"
            "    ]\n"
        )

    return f'''"""Generated native packaging contract from ``setup.py``.

Regenerate with ``tools/generate_setup_metadata.py``.
"""

from std.collections import List


def setup_package_name() -> String:
    return {json.dumps(item['name'], ensure_ascii=False)}


def setup_package_version() -> String:
    return {json.dumps(item['version'], ensure_ascii=False)}


def setup_description() -> String:
    return {json.dumps(item['description'], ensure_ascii=False)}


def setup_author() -> String:
    return {json.dumps(item['author'], ensure_ascii=False)}


{function('setup_install_requirements', list(item['requires']))}

{function('setup_package_data_patterns', list(item['package_patterns']))}

{function('setup_discovered_packages', list(item['packages']))}

{function('setup_command_class_names', class_names)}

{function('setup_command_class_bases', class_bases)}

{function('setup_command_class_methods', class_methods)}


def setup_command_method_count() -> Int:
    return {method_count}


{function('setup_defined_command_rows', list(item['defined_cmdclass']))}

{function('setup_active_command_rows', list(item['active_cmdclass']))}

{function('setup_extract_message_files', list(item['extract_files']))}


def setup_extract_message_output() -> String:
    return {json.dumps(item['extract_output'])}
'''


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--output", type=Path, default=OUTPUT)
    args = parser.parse_args()
    text = render()
    if args.check:
        if not args.output.exists() or args.output.read_text(encoding="utf-8") != text:
            raise SystemExit(f"setup metadata differs: {args.output}")
        item = data()
        print(
            "setup metadata identical: "
            f"{item['name']} {item['version']}, "
            f"{len(item['classes'])} command classes, "
            f"{len(item['extract_files'])} gettext sources"
        )
        return
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(text, encoding="utf-8")
    item = data()
    print(
        f"generated {args.output}: {item['name']} {item['version']}, "
        f"{len(item['classes'])} command classes"
    )


if __name__ == "__main__":
    main()
