#!/usr/bin/env python3
"""Compute reproducible Python→Mojo porting metrics from the matrix generator.

The status mapping in ``tools/generate_porting_matrix.py`` is the single source
of truth.  This avoids manually incremented percentages drifting away from the
actual 92-file reference inventory.
"""
from __future__ import annotations

import argparse
import ast
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
GENERATOR = ROOT / "tools/generate_porting_matrix.py"
FULL_STATUSES = {"nativ", "generiert nativ"}


def native_mapping() -> dict[str, tuple[str, str, str]]:
    tree = ast.parse(GENERATOR.read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "NATIVE"
            for target in node.targets
        ):
            value = ast.literal_eval(node.value)
            if not isinstance(value, dict):
                raise TypeError("NATIVE must be a dict")
            return value
    raise RuntimeError("NATIVE mapping missing")


def line_count(path: Path) -> int:
    return len(path.read_text(encoding="utf-8", errors="replace").splitlines())


def mojo_line_count(root: Path) -> int:
    return sum(line_count(path) for path in root.rglob("*.mojo") if path.is_file())


def compute() -> dict[str, Any]:
    mapping = native_mapping()
    files = [
        path
        for path in sorted(PYROOT.rglob("*.py"))
        if path.relative_to(PYROOT).as_posix() != "mojo_bridge.py"
    ]
    rows = []
    for path in files:
        rel = path.relative_to(PYROOT).as_posix()
        lines = line_count(path)
        status = mapping.get(rel, ("Python-Referenz/Bridge", "", ""))[0]
        rows.append((rel, lines, status))

    total_lines = sum(lines for _, lines, _ in rows)
    full_rows = [row for row in rows if row[2] in FULL_STATUSES]
    touched_rows = [row for row in rows if row[0] in mapping]
    full_lines = sum(lines for _, lines, _ in full_rows)
    touched_lines = sum(lines for _, lines, _ in touched_rows)

    return {
        "reference_files": len(rows),
        "reference_lines": total_lines,
        "fully_native_files": len(full_rows),
        "fully_native_percent": 100.0 * len(full_rows) / len(rows),
        "at_least_partly_ported_files": len(touched_rows),
        "at_least_partly_ported_percent": 100.0 * len(touched_rows) / len(rows),
        "fully_native_reference_lines": full_lines,
        "fully_native_reference_line_percent": 100.0 * full_lines / total_lines,
        "touched_reference_lines": touched_lines,
        "touched_reference_line_percent": 100.0 * touched_lines / total_lines,
        "mojo_lines_src": mojo_line_count(ROOT / "src"),
        "mojo_lines_reta_mojo": mojo_line_count(ROOT / "src/reta_mojo"),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()
    data = compute()
    if args.json:
        print(json.dumps(data, ensure_ascii=False, sort_keys=True, indent=2))
        return 0
    print(
        "vollständig nativ/generiert: "
        f"{data['fully_native_files']}/{data['reference_files']} "
        f"= {data['fully_native_percent']:.1f} %"
    )
    print(
        "mindestens teilweise portiert: "
        f"{data['at_least_partly_ported_files']}/{data['reference_files']} "
        f"= {data['at_least_partly_ported_percent']:.1f} %"
    )
    print(
        "angegriffene Referenzzeilen: "
        f"{data['touched_reference_lines']}/{data['reference_lines']} "
        f"= {data['touched_reference_line_percent']:.1f} %"
    )
    print(f"Mojo-Zeilen in src/: {data['mojo_lines_src']}")
    print(f"Mojo-Zeilen in src/reta_mojo/: {data['mojo_lines_reta_mojo']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
