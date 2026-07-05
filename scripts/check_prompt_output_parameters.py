#!/usr/bin/env python3
"""Compare native prompt output-option plans with the Python executor argv.

The historical controller forwards every prompt output parameter to ``reta`` in
the order produced by ``list(set(theWholePromptList))``.  This checker replaces
only ``reta.Program`` and compares those exact arguments with the typed Mojo
plan; rendered table bytes and terminal state are outside this contract.
"""
from __future__ import annotations

import contextlib
import io
import os
import shlex
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
RS = "\x1e"
FS = "\x1f"


def fail(message: str) -> None:
    raise SystemExit(message)


def native_cases(binary: Path) -> dict[str, tuple[str, str]]:
    completed = subprocess.run(
        [str(binary)],
        cwd=ROOT,
        env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
        text=True,
        timeout=120,
    )
    cases: dict[str, tuple[str, str]] = {}
    for line in completed.stdout.splitlines():
        if not line.startswith("CASE\t"):
            continue
        fields = line.split("\t", 3)
        if len(fields) != 4:
            fail(f"malformed native probe line: {line!r}")
        _, command, ownership, payload = fields
        cases[command] = (ownership, payload)
    return cases


def reference_plan(command: str) -> str:
    previous_cwd = Path.cwd()
    previous_path = list(sys.path)
    os.chdir(REFERENCE)
    sys.path.insert(0, str(REFERENCE))
    try:
        import reta  # type: ignore[import-not-found]
        import retaPrompt  # type: ignore[import-not-found]

        calls: list[list[str]] = []

        class CollectProgram:
            def __init__(self, args: object, *unused: object, **kwargs: object) -> None:
                del unused, kwargs
                calls.append([str(value) for value in args])

        original = reta.Program
        reta.Program = CollectProgram
        sink = io.StringIO()
        argv = ["retaPrompt.py", "-vi", "-befehl", *shlex.split(command)]
        try:
            with contextlib.redirect_stdout(sink), contextlib.redirect_stderr(sink):
                retaPrompt.promptInteraction.run_scope(argv)
        except SystemExit:
            pass
        finally:
            reta.Program = original
    finally:
        os.chdir(previous_cwd)
        sys.path[:] = previous_path

    if not calls:
        fail(f"Python reference emitted no reta invocation: {command}")
    records: list[str] = []
    for call in calls:
        normalized = [
            token
            for index, token in enumerate(call)
            if token and not (index == 0 and token == "reta")
        ]
        records.append(FS.join(normalized))
    return RS.join(records)


def main() -> int:
    if len(sys.argv) != 2:
        fail("usage: check_prompt_output_parameters.py PROBE_BINARY")
    cases = native_cases(Path(sys.argv[1]).resolve())
    if len(cases) != 7:
        fail(f"expected 7 native output-option cases, got {len(cases)}")

    for command, (ownership, native) in cases.items():
        if ownership != "OWNED":
            fail(f"native ownership still rejects output parameters: {command}")
        reference = reference_plan(command)
        if native != reference:
            fail(
                "output-parameter plan mismatch for "
                + command
                + "\nreference="
                + reference.replace(FS, "|").replace(RS, " || ")
                + "\nnative="
                + native.replace(FS, "|").replace(RS, " || ")
            )

    print("prompt output-parameter ownership and argv order: 7/7")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
