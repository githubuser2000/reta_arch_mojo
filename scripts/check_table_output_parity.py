#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run(command: list[str], *, env: dict[str, str] | None = None) -> bytes:
    return subprocess.check_output(command, cwd=ROOT, env=env)


def reference(python: str, code: str, *args: str) -> bytes:
    env = os.environ.copy()
    env["PYTHONPATH"] = str(ROOT / "python_reference")
    env["PYTHONHASHSEED"] = "0"
    return run([python, "-c", code, *args], env=env)


def native(binary: Path, *args: str) -> bytes:
    env = os.environ.copy()
    env["RETA_ROOT"] = str(ROOT)
    env["RETA_ASSET_DIR"] = str(ROOT / "assets")
    return run([str(binary), *args], env=env)


def parse_summary(payload: bytes) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in payload.decode("utf-8").splitlines():
        key, value = line.split("=", 1)
        result[key] = value
    return result


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--python", required=True)
    parser.add_argument("--binary", required=True, type=Path)
    args = parser.parse_args()

    snapshot_code = r'''
import json
from reta_architecture.table_output import bootstrap_table_output
print(json.dumps(bootstrap_table_output().snapshot(), ensure_ascii=False, sort_keys=True))
'''
    expected_snapshot = json.loads(reference(args.python, snapshot_code))
    actual_snapshot = parse_summary(native(args.binary, "--summary"))
    assert actual_snapshot == expected_snapshot, (actual_snapshot, expected_snapshot)

    selection_code = r'''
from reta_architecture.table_output import TableOutput
class Tables: pass
output = TableOutput(Tables(), [])
for row in output.onlyThatColumns([["a", "b", "c"], ["d", "e", "f"]], [3, 1, 9]):
    print("row=" + "\x1f".join(row))
'''
    assert native(args.binary, "--select") == reference(args.python, selection_code)

    color_code = r'''
import sys
from reta_architecture.table_output import TableOutput
class Tables: pass
number, rest, text = sys.argv[1:]
output = TableOutput(Tables(), [])
sys.stdout.write(output.colorize(text, int(number), rest in {"1", "true"}))
'''
    for number, rest, text in (("0", "false", "H"), ("2", "true", "x"), ("5", "false", "prim"), ("9", "false", "moon")):
        assert native(args.binary, "--colorize", number, rest, text) == reference(
            args.python, color_code, number, rest, text
        )

    print("table-output parity: ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
