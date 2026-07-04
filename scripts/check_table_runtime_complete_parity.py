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
from reta_architecture.table_runtime import bootstrap_table_runtime
s = bootstrap_table_runtime().snapshot()
print("class=" + s["class"])
print("table_class=" + s["table_class"])
print("owns_legacy_tables=" + str(s["owns_legacy_tables"]).lower())
print("legacy_facade=" + s["legacy_facade"])
state = s["state_sections"]
print("state_class=" + state["class"])
print("state_sections=" + "\x1f".join(state["sections"]))
print("state_architecture_owner=" + state["architecture_owner"])
print("state_legacy_owner=" + state["legacy_owner"])
print("component_morphisms=" + "\x1f".join(s["component_morphisms"]))
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
    print("table-runtime snapshot parity: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
