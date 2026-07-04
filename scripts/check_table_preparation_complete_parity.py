#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def parse(payload: bytes) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in payload.decode("utf-8").splitlines():
        key, value = line.split("=", 1)
        result[key] = value
    return result


def python_snapshot(python: str) -> dict[str, str]:
    code = r'''
from reta_architecture.table_preparation import bootstrap_table_preparation
s = bootstrap_table_preparation().snapshot()
for key in (
    "class",
    "display_line_morphism",
    "row_morphism",
    "tag_gluing_morphism",
    "cell_morphism",
    "parallel_row_morphism",
    "deduplication_morphism",
    "last_line_morphism",
):
    print(f"{key}={s[key]}")
print("universal_operations=" + "\x1f".join(s["universal_operations"]))
for key in ("main_table_result", "kombi_table_result", "legacy_delegate"):
    print(f"{key}={s[key]}")
'''
    env = os.environ.copy()
    env["PYTHONPATH"] = str(ROOT / "python_reference")
    env["PYTHONHASHSEED"] = "0"
    return parse(subprocess.check_output([python, "-c", code], cwd=ROOT, env=env))


def native_snapshot(binary: Path) -> dict[str, str]:
    env = os.environ.copy()
    env["RETA_ROOT"] = str(ROOT)
    env["RETA_ASSET_DIR"] = str(ROOT / "assets")
    return parse(subprocess.check_output([str(binary)], cwd=ROOT, env=env))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--python", required=True)
    parser.add_argument("--binary", type=Path, required=True)
    args = parser.parse_args()
    expected = python_snapshot(args.python)
    actual = native_snapshot(args.binary)
    assert actual == expected, (actual, expected)
    print("table-preparation snapshot parity: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
