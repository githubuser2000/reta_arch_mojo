#!/usr/bin/env python3
"""Generate compact parity constants for the native multis3 port."""
from __future__ import annotations

import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python_reference"))
from multis3 import mult3  # noqa: E402

MOD = 1_000_000_007
MULTIPLIER = 1_000_003
START = 2
STOP = 256

count = 0
fingerprint = 0
per_value_counts: list[int] = []
for value in range(START, STOP + 1):
    _, triples = mult3([value])
    ordered = sorted(triples)
    per_value_counts.append(len(ordered))
    for a, b, c in ordered:
        count += 1
        token = (((value * 1009 + a) * 1009 + b) * 1009 + c) % MOD
        fingerprint = (fingerprint * MULTIPLIER + token) % MOD

# A second checksum over the count distribution catches values with zero triples.
count_fingerprint = 0
for value, amount in zip(range(START, STOP + 1), per_value_counts):
    count_fingerprint = (count_fingerprint * MULTIPLIER + value * 257 + amount) % MOD

out = ROOT / "tests" / "multis3_parity_constants.mojo"
out.write_text(
    "\n".join(
        [
            '"""Generated from python_reference/multis3.py; do not edit."""',
            "",
            f"comptime MULTIS3_PARITY_START = {START}",
            f"comptime MULTIS3_PARITY_STOP = {STOP}",
            f"comptime MULTIS3_PARITY_MOD = {MOD}",
            f"comptime MULTIS3_PARITY_MULTIPLIER = {MULTIPLIER}",
            f"comptime MULTIS3_PARITY_TRIPLE_COUNT = {count}",
            f"comptime MULTIS3_PARITY_FINGERPRINT = {fingerprint}",
            f"comptime MULTIS3_PARITY_COUNT_FINGERPRINT = {count_fingerprint}",
            "",
        ]
    ),
    encoding="utf-8",
)
print(out)
