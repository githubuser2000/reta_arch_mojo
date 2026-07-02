#!/usr/bin/env python3
"""Compare native presheaf/sheaf diagnostics with the Python reference."""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"


def run(*args: str) -> str:
    result = subprocess.run(
        args,
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode:
        raise SystemExit(result.stderr or result.stdout)
    return result.stdout


def python_snapshot(python: str, command: str) -> dict:
    result = subprocess.run(
        [python, "reta_architecture_probe_py.py", command],
        cwd=PYROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
        env={**os.environ, "PYTHONHASHSEED": "0"},
    )
    if result.returncode:
        raise SystemExit(result.stderr or result.stdout)
    return json.loads(result.stdout)


def parse_summary(text: str) -> dict[str, int]:
    values: dict[str, int] = {}
    for line in text.splitlines():
        key, separator, value = line.partition("=")
        if separator and value.lstrip("-").isdigit():
            values[key] = int(value)
    return values


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument(
        "--python",
        default=os.environ.get("RETA_REFERENCE_PYTHON", "python3"),
    )
    args = parser.parse_args()

    presheaves = python_snapshot(args.python, "presheaves-json")
    sheaves = python_snapshot(args.python, "sheaves-json")
    native = parse_summary(run(str(args.binary), "--summary"))
    expected = {
        "csv": len(presheaves["csv"]),
        "translations": len(presheaves["translations"]),
        "assets": len(presheaves["assets"]),
        "prompt": len(presheaves["prompt_state"]),
        "main_alias_groups": len(
            sheaves["parameter_semantics"]["main_alias_groups"]
        ),
        "pair_to_columns": len(
            sheaves["parameter_semantics"]["pair_to_columns"]
        ),
        "html_reference": sheaves["html_reference_size"],
    }
    if native != expected:
        raise AssertionError((expected, native))

    reference_by_column: dict[int, dict] = {}
    for line in (PYROOT / "htmlclassesPy.jsonl").read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        payload = json.loads(line)
        if payload.get("row_number") == 0:
            reference_by_column[int(payload["column_number"])] = payload
    for column in (0, 1, 4, 669):
        actual = json.loads(run(str(args.binary), "--html", str(column)))
        expected_payload = reference_by_column.get(column, {})
        if actual != expected_payload:
            raise AssertionError((column, expected_payload, actual))

    print("presheaf/sheaf parity: summary and 4 HTML references identical")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
