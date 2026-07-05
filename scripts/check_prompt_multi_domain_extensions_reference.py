#!/usr/bin/env python3
"""Freeze stable outer ordering for multi-domain property/numeric axes."""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "python_reference/reta_architecture/prompt_execution.py"
RS = "\x1e"
FS = "\x1f"


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> int:
    source = SOURCE.read_text(encoding="utf-8")
    motives = source.index('i18n.gebrochenUniGal["gebrochengalaxie"]')
    properties = source.index("eigN, eigR = [], []", motives)
    universe = source.index('i18n.befehle2["universum"]', properties)
    if not motives < properties < universe:
        fail("Python Motives/property/Universe branch order changed")

    completed = subprocess.run(
        [
            sys.executable,
            "scripts/prompt_mixed_reciprocal_reference.py",
            "motive universum 15_13 16_2 v2/3,5",
        ],
        cwd=ROOT,
        env={**os.environ, "PYTHONHASHSEED": "0"},
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=300,
        check=True,
        text=True,
    )
    payload = completed.stdout.rstrip("\n")
    if payload == "FALLBACK":
        fail("Python numeric outer-order reference unexpectedly fell back")
    records = [record.split(FS) for record in payload.split(RS)]
    if len(records) < 2:
        fail("Python numeric outer-order reference emitted too few calls")
    if not any(value.startswith("--Multiversum=") for value in records[-2]):
        fail("Python numeric family 16 no longer precedes family 15")
    if not any(value.startswith("--Grundstrukturen=") for value in records[-1]):
        fail("Python numeric family 15 is no longer the final tail")

    print("multi-domain extension reference: 5/5")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
