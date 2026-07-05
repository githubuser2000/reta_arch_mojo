#!/usr/bin/env python3
"""Inspect the frozen prompt's ordinary-number guard around classic tables.

The legacy true-n/m path raises before producing a plan.  This probe keeps the
reference untouched and records calls made before that exception.  It proves
that classic integer-only families are not activated by whole rows projected
from a pure fraction, while a real comma-local integer component does activate
them later in the controller.
"""
from __future__ import annotations

import contextlib
import io
import os
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
os.chdir(REFERENCE)
sys.path.insert(0, str(REFERENCE))

import retaPrompt  # noqa: E402
import reta_architecture.prompt_execution as prompt_execution  # noqa: E402


CASES = [
    "universum motive v2/3",
    "mond universum motive v2/3",
    "richtung universum motive v2/3",
    "primzahlkreuz universum motive v2/3",
    "alles universum motive v2/3",
    "thomas universum motive v2/3",
    "mond universum motive v2/3,5",
]


def inspect(command: str) -> tuple[str, int, int]:
    calls: list[tuple[object, ...]] = []

    def collect(*args: object) -> None:
        calls.append(args)

    prompt_execution.retaExecuteNprint = collect
    argv = ["retaPrompt.py", "-vi", "-befehl", *shlex.split(command)]
    error = "NONE"
    sink = io.StringIO()
    try:
        with contextlib.redirect_stdout(sink), contextlib.redirect_stderr(sink):
            retaPrompt.promptInteraction.run_scope(argv)
    except SystemExit:
        error = "SystemExit"
    except IndexError:
        error = "IndexError"

    classic_calls = 0
    for call in calls:
        columns = call[4]
        if any(
            marker in column
            for column in columns
            for marker in (
                "gestirn",
                "Galaxieabsicht",
                "primzahlkreuz",
                "--alles",
                "--galaxie=thomas",
            )
        ):
            classic_calls += 1
    return error, len(calls), classic_calls


def main() -> None:
    for command in CASES:
        error, call_count, classic_count = inspect(command)
        print(f"{command}\t{error}\t{call_count}\t{classic_count}")


if __name__ == "__main__":
    main()
