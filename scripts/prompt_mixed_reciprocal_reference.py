#!/usr/bin/env python3
"""Serialize legacy prompt plans for mixed reciprocal modifiers.

The full Python prompt normally renders a table and exits after a one-shot
command.  This probe replaces only the final reta executor, retaining the
historical preparation and fraction algebra while recording the exact argv
shape that native Mojo must reproduce.
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

RECORD_SEPARATOR = "\x1e"
FIELD_SEPARATOR = "\x1f"


def _serialize_call(call: tuple[object, ...]) -> str:
    ketten, stext_e, zeiln1, zeiln2, columns, selected_columns, text_state = call
    tokens = [
        "-zeilen",
        str(zeiln1),
        str(zeiln2),
        "--invertieren"
        if retaPrompt.i18n.befehle2["invertieren"] in stext_e
        else "",
        "-spalten",
        "".join(columns),
        "--breite=0",
        "-ausgabe",
        (
            "--"
            + retaPrompt.i18n.ausgabeParas["spaltenreihenfolgeundnurdiese"]
            + "="
            + selected_columns
            if selected_columns is not None
            else ""
        ),
        *ketten,
    ]
    return FIELD_SEPARATOR.join(token for token in tokens if token)


def reference_plan(command: str) -> str:
    calls: list[tuple[object, ...]] = []

    def collect(*args: object) -> None:
        calls.append(args)

    prompt_execution.retaExecuteNprint = collect
    argv = ["retaPrompt.py", "-vi", "-befehl", *shlex.split(command)]
    sink = io.StringIO()
    try:
        with contextlib.redirect_stdout(sink), contextlib.redirect_stderr(sink):
            retaPrompt.promptInteraction.run_scope(argv)
    except SystemExit:
        pass
    except IndexError:
        # The historical true n/m multiple bug is the explicit compatibility
        # boundary.  Native Mojo must return FALLBACK rather than inventing a
        # behavior that the reference does not define.
        return "FALLBACK"
    return RECORD_SEPARATOR.join(_serialize_call(call) for call in calls)


def main() -> None:
    for command in sys.argv[1:]:
        print(reference_plan(command))


if __name__ == "__main__":
    main()
