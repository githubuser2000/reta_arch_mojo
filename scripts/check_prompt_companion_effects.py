#!/usr/bin/env python3
"""Freeze Python ordering and terminal-line semantics of prompt companion effects."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/reta_architecture/prompt_execution.py"


def branch(source: str, marker: str) -> int:
    try:
        return source.index(marker)
    except ValueError as exc:
        raise SystemExit(f"missing reference marker: {marker}") from exc


def main() -> int:
    source = REFERENCE.read_text(encoding="utf-8")
    short = branch(source, 'Txt.hasWithoutABC({i18n.befehle2["kurzbefehle"]})')
    commands = branch(source, 'Txt.hasWithoutABC({i18n.befehle2["befehle"]})')
    help_ = branch(
        source,
        'Txt.hasWithoutABC(\n        {i18n.befehle2["h"], i18n.befehle2["help"], i18n.befehle2["hilfe"]}',
    )
    numeric_state = branch(source, "bedingungZahl, bedingungBrueche = (")
    numeric_guard = branch(
        source,
        "if fullBlockIsZahlenbereichAndBruch and (bedingungZahl or bedingungBrueche):",
    )
    clear = branch(source, 'Txt.hasWithoutABC({i18n.befehle2["leeren"]})')
    clear_lines = branch(source, "range(os.get_terminal_size().lines + 1)")
    first_table = branch(
        source, 'Txt.hasWithoutABC({i18n.befehle2["emotion"], i18n.befehle2["E"]})'
    )

    if not (
        short
        < commands
        < help_
        < numeric_state
        < numeric_guard
        < clear
        < clear_lines
        < first_table
    ):
        raise SystemExit("historical informational/clear/table effect order changed")

    section = source[short:numeric_state]
    for canonical in ("kurzbefehle", "befehle", "hilfe"):
        if canonical not in section:
            raise SystemExit(f"missing informational membership branch: {canonical}")
    if "Txt.hasWithoutABC" not in section:
        raise SystemExit("informational effects stopped using unordered membership")

    print(
        "prompt companion effects reference: short commands -> commands -> help -> "
        "terminal rows + 1 blank lines -> table"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
