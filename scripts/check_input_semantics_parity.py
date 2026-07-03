#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"


def _run(command: list[str], cwd: Path, env: dict[str, str] | None = None) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr)
    return result.stdout


def _python_snapshot(python: str) -> dict[str, str]:
    code = r'''
import json
import LibRetaPrompt
snapshot = LibRetaPrompt.promptVocabulary.snapshot()
row = LibRetaPrompt._ARCHITECTURE.inputs.snapshot()["row_ranges"]
snapshot.update({
    "multiple_prefix": row["multiple_prefix"],
    "comma_split_pattern": row["comma_split_pattern"],
    "prompt_vocabulary_builder_available": True,
})
print(json.dumps(snapshot, ensure_ascii=False, sort_keys=True))
'''
    env = os.environ.copy()
    env["PYTHONPATH"] = os.pathsep.join([str(PYROOT), str(PYROOT / "libs")])
    payload = json.loads(_run([python, "-c", code], PYROOT, env))
    return {
        key: ("true" if value is True else "false" if value is False else str(value))
        for key, value in payload.items()
    }


def _native_snapshot(binary: str) -> dict[str, str]:
    output = _run([binary, "--mojo-input-snapshot"], ROOT)
    return dict(line.split("=", 1) for line in output.splitlines() if "=" in line)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--python", required=True)
    parser.add_argument("--binary", required=True)
    args = parser.parse_args()
    expected = _python_snapshot(args.python)
    actual = _native_snapshot(args.binary)
    if expected != actual:
        raise AssertionError({"expected": expected, "actual": actual})
    print(json.dumps({"input_semantics_snapshot": "identical", "fields": len(actual)}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
