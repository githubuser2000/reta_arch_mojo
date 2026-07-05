#!/usr/bin/env python3
"""Freeze position-independent historical abc and logging effects."""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
RPB = PYROOT / "rpb"


def run_prompt(command: str) -> bytes:
    completed = subprocess.run(
        [sys.executable, str(RPB), command],
        cwd=ROOT,
        env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
        check=False,
        capture_output=True,
        timeout=90,
    )
    if completed.returncode != 0:
        raise SystemExit(
            f"reference prompt failed for {command!r}: "
            f"exit={completed.returncode}; stderr={completed.stderr.decode(errors='replace')}"
        )
    if completed.stderr:
        raise SystemExit(
            f"reference prompt wrote stderr for {command!r}: "
            f"{completed.stderr.decode(errors='replace')}"
        )
    return completed.stdout


def check_logging_membership_contract() -> None:
    sys.path.insert(0, str(PYROOT))
    from reta_architecture import prompt_execution as reference  # noqa: PLC0415

    class FakeText:
        listeS: list[str] = []

        def __init__(self, tokens: tuple[str, ...]) -> None:
            self.tokens = set(tokens)

        def has(self, expected: set[str]) -> bool:
            return bool(self.tokens & expected)

        def hasWithoutABC(self, expected: set[str]) -> bool:
            return bool(self.tokens & expected)

    cases = (
        (("loggen",), True),
        (("nichtloggen",), False),
        (("nichtloggen", "loggen"), True),
        ((), False),
    )
    for tokens, expected in cases:
        state, gave_output = reference.PromptVonGrosserAusgabeSonderBefehlAusgaben(
            False, FakeText(tokens), False
        )
        if state is not expected:
            raise SystemExit(f"logging membership contract changed for {tokens}")
        if tokens and not gave_output:
            raise SystemExit(f"logging effect stopped claiming output for {tokens}")


def main() -> int:
    abc_prefix = run_prompt("abc Haus")
    abc_suffix = run_prompt("Haus abc")
    if abc_prefix != b"8 1 21 19\n" or abc_suffix != abc_prefix:
        raise SystemExit("position-independent abc reference contract changed")

    check_logging_membership_contract()
    print(
        "position-independent prompt effects: "
        "2 abc placements and logging membership/precedence valid"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
