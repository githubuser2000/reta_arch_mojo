#!/usr/bin/env python3
"""Generate native HTML cell-open metadata from the Python reference.

The physical-column catalog preserves the dynamic CSS classes emitted by the
reference for all 746 CSV columns and both numbering columns.
"""
from __future__ import annotations

import csv
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "python_reference" / "reta.py"
CSV_PATH = ROOT / "python_reference" / "csv" / "religion.csv"
OUTPUT = ROOT / "assets" / "html_cell_catalog.tsv"
TD_RE = re.compile(r"<td[^>]*>")


def physical_columns() -> int:
    with CSV_PATH.open(encoding="utf-8", newline="") as handle:
        return len(next(csv.reader(handle, delimiter=";")))


def render(language: str) -> tuple[list[str], list[str]]:
    if language == "german":
        args = [
            sys.executable,
            str(REFERENCE),
            "-zeilen",
            "--vorhervonausschnitt=1",
            "-spalten",
            "--alles",
            "-ausgabe",
            "--art=html",
            "--breite=0",
            "--onetable",
        ]
    else:
        args = [
            sys.executable,
            str(REFERENCE),
            "-language=english",
            "-lines",
            "--thisrangebefore=1",
            "-columns",
            "--all",
            "-output",
            "--type=html",
            "--width=0",
            "--onetable",
        ]
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "0"
    rendered = subprocess.check_output(args, cwd=ROOT, env=env, text=True)
    rows = [line for line in rendered.splitlines() if line.startswith("<tr")]
    if len(rows) != 2:
        raise RuntimeError(f"expected heading and one body row, got {len(rows)}")
    return TD_RE.findall(rows[0]), TD_RE.findall(rows[1])


def main() -> None:
    count = physical_columns()
    lines = ["# language\tsource_column\theading_open\tbody_open"]
    for language in ("german", "english"):
        headings, bodies = render(language)
        if len(headings) < count + 2 or len(bodies) < count + 2:
            raise RuntimeError(
                f"{language}: expected at least {count + 2} cells, "
                f"got {len(headings)}/{len(bodies)}"
            )
        for source_column in (-2, -1):
            position = source_column + 2
            lines.append(
                "\t".join(
                    (language, str(source_column), headings[position], bodies[position])
                )
            )
        for source_column in range(count):
            position = source_column + 2
            lines.append(
                "\t".join(
                    (language, str(source_column), headings[position], bodies[position])
                )
            )
    OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {OUTPUT.relative_to(ROOT)}: {2 * (count + 2)} entries")


if __name__ == "__main__":
    main()
