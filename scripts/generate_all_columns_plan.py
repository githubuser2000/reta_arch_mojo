#!/usr/bin/env python3
"""Generate the native plan for the historical ``-spalten --alles`` flag.

The Python reference folds twelve independent column buckets into the synthetic
``alles`` parameter.  This script serializes that already-resolved tuple so the
Mojo CLI can own the all-column path without importing Python at runtime.
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
OUTPUT = ROOT / "assets" / "all_columns_plan.tsv"

BUCKET_NAMES = (
    "ordinary",
    "modal",
    "concat",
    "kombi",
    "prime_effect",
    "fraction_universe",
    "fraction_galaxy",
    "generated_command",
    "kombi2",
    "fraction_emotion",
    "fraction_size",
    "meta",
)


def payload(value: object) -> str:
    if isinstance(value, (tuple, list)):
        return ",".join("" if item is None else str(item) for item in value)
    return str(value)


def emit() -> None:
    sys.path.insert(0, str(REFERENCE))
    from reta import Program  # noqa: PLC0415

    program = Program(["reta"], runAlles=False)
    program.dataDict = [{} for _ in range(14)]
    program.storeParamtersForColumns()
    all_name = program.ParametersMain.alles[0]
    resolved = program.paraDict[(all_name, "")]
    if len(resolved) != len(BUCKET_NAMES):
        raise RuntimeError(f"expected {len(BUCKET_NAMES)} buckets, got {len(resolved)}")

    print("# bucket\tpayload")
    for bucket, values in zip(BUCKET_NAMES, resolved, strict=True):
        for value in values:
            text = payload(value)
            if "\t" in text or "\n" in text or "\r" in text:
                raise RuntimeError(f"invalid payload in {bucket}: {text!r}")
            print(f"{bucket}\t{text}")


def main() -> None:
    if "--emit" in sys.argv:
        emit()
        return
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "0"
    completed = subprocess.run(
        [sys.executable, str(Path(__file__).resolve()), "--emit"],
        cwd=ROOT,
        env=env,
        check=True,
        capture_output=True,
        text=True,
    )
    OUTPUT.write_text(completed.stdout, encoding="utf-8")
    count = sum(1 for line in completed.stdout.splitlines() if line and not line.startswith("#"))
    print(f"wrote {OUTPUT.relative_to(ROOT)}: {count} entries")


if __name__ == "__main__":
    main()
