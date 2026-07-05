#!/usr/bin/env python3
"""Freeze the combined classic/property/catalog order around n/m domains.

The historical Python controller still has the known shared n/m rectangle bug.
This probe imports only the stable outer branch order by observing executor argv;
it does not treat the inner Python fraction grid as a correctness oracle.
"""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RS = "\x1e"
FS = "\x1f"
COMBINED = (
    "mond richtung primzahlkreuz alles thomas motive EIGNgut "
    "universum 15_13 16_2 v2/3,5"
)


def fail(message: str) -> None:
    raise SystemExit(message)


def reference_records(command: str) -> list[list[str]]:
    completed = subprocess.run(
        [
            sys.executable,
            "scripts/prompt_mixed_reciprocal_reference.py",
            command,
        ],
        cwd=ROOT,
        env={
            **os.environ,
            "PYTHONHASHSEED": "0",
            "PYTHONDONTWRITEBYTECODE": "1",
        },
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=300,
        check=True,
        text=True,
    )
    payload = completed.stdout.rstrip("\n")
    if payload == "FALLBACK":
        fail(f"Python outer-order reference unexpectedly fell back: {command}")
    return [record.split(FS) for record in payload.split(RS)]


def record_indices(records: list[list[str]], prefix: str) -> list[int]:
    return [
        index
        for index, record in enumerate(records)
        if any(value.startswith(prefix) for value in record)
    ]


def record_index(records: list[list[str]], prefix: str) -> int:
    matches = record_indices(records, prefix)
    if len(matches) != 1:
        fail(f"expected one {prefix!r} record, got {matches!r}")
    return matches[0]


def first_record_index(records: list[list[str]], prefix: str) -> int:
    matches = record_indices(records, prefix)
    if not matches:
        fail(f"expected at least one {prefix!r} record")
    return matches[0]


def row_shell(record: list[str]) -> tuple[str, ...]:
    return tuple(
        value
        for value in record
        if value.startswith("--vielfachevonzahlen=")
        or value.startswith("--vorhervonausschnitt=")
        or value.startswith("--oberesmaximum=")
    )


def main() -> int:
    records = reference_records(COMBINED)
    markers = (
        "--Galaxie=thomas",
        "--Menschliches=motivation",
        "--konzept=gut",
        "--Universum=transzendentalien",
        "--Bedeutung=gestirn",
        "--alles",
        "--Bedeutung=primzahlkreuz",
        "--Primzahlwirkung=Galaxieabsicht",
        "--Multiversum=",
        "--Grundstrukturen=",
    )
    indices = tuple(
        first_record_index(records, marker)
        if marker == "--Menschliches=motivation"
        else record_index(records, marker)
        for marker in markers
    )
    if indices != tuple(sorted(indices)):
        fail(f"combined Python outer order changed: {indices!r}")

    shared_markers = (
        "--Galaxie=thomas",
        "--konzept=gut",
        "--Bedeutung=gestirn",
        "--alles",
        "--Primzahlwirkung=Galaxieabsicht",
        "--Multiversum=",
        "--Grundstrukturen=",
    )
    shells = [row_shell(records[record_index(records, marker)]) for marker in shared_markers]
    if any(shell != shells[0] for shell in shells[1:]):
        fail(f"combined outer axes no longer share the ordinary row shell: {shells!r}")

    prime = records[record_index(records, "--Bedeutung=primzahlkreuz")]
    if "--vielfachevonzahlen=5" not in prime:
        fail("prime-cross lost the explicit ordinary multiple axis")
    if "--oberesmaximum=1029" not in prime:
        fail("prime-cross lost its historical maximum")
    if any(value.startswith("--vorhervonausschnitt=") for value in prime):
        fail("prime-cross unexpectedly inherited projected whole rows")

    print("combined outer-order reference: 14/14")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
