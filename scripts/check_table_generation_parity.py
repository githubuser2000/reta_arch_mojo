#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"


def _python_snapshot(python: str) -> dict[str, object]:
    code = (
        "import json;"
        "from reta_architecture.table_generation import bootstrap_table_generation;"
        "from i18n.words_runtime import csvFileNames;"
        "s=bootstrap_table_generation(csvFileNames).snapshot();"
        "print(json.dumps({"
        "'csv_sources':len(s['csv_sources']),"
        "'generated_morphisms':len(s['generated_morphisms']),"
        "'table_preparation':s['table_preparation_dependency'],"
        "'kombi_csvs':s['kombi_csvs']},ensure_ascii=False,sort_keys=True))"
    )
    result = subprocess.run(
        [python, "-c", code],
        cwd=PYROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr)
    return json.loads(result.stdout)


def _native_snapshot(binary: str) -> dict[str, object]:
    result = subprocess.run(
        [binary, "--summary"],
        cwd=ROOT,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr)
    values: dict[str, str] = {}
    for line in result.stdout.splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            values[key] = value
    return {
        "csv_sources": int(values["csv_sources"]),
        "generated_morphisms": int(values["generated_morphisms"]),
        "table_preparation": values["table_preparation"],
        "kombi_csvs": ["kombi.csv", "kombi-meta.csv"]
        if int(values["kombi_csvs"]) == 2
        else [],
    }


def _check_last_line(binary: str) -> None:
    cases = [(-1, 0, 0), (-1, 3, 2), (1, 3, 1), (99, 3, 2)]
    for requested, rows, expected in cases:
        result = subprocess.run(
            [binary, "--last-line", str(requested), str(rows)],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if result.returncode != 0:
            raise RuntimeError(result.stderr)
        actual = int(result.stdout.strip())
        if actual != expected:
            raise AssertionError((requested, rows, expected, actual))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--python", default=sys.executable)
    parser.add_argument("--binary", required=True)
    args = parser.parse_args()
    expected = _python_snapshot(args.python)
    actual = _native_snapshot(args.binary)
    if expected != actual:
        raise AssertionError((expected, actual))
    _check_last_line(args.binary)
    print(json.dumps({"snapshot": "identical", "last_line_cases": 4}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
