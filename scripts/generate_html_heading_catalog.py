#!/usr/bin/env python3
"""Generate dynamic HTML heading metadata for native generator columns.

Unlike physical columns, generator columns do not have a stable CSV source
index.  Their rendered heading is the stable semantic key.  The curated case
matrix covers every generator family currently implemented by the native CLI.
Later cases deliberately overwrite earlier duplicate headings, matching the
reference's parameter-map semantics.
"""
from __future__ import annotations

import html
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REFERENCE = ROOT / "python_reference" / "reta.py"
OUTPUT = ROOT / "assets" / "html_heading_catalog.tsv"
CELL_RE = re.compile(r"(<td[^>]*>)(.*?)</td>")

CASES: list[tuple[str, list[str]]] = [
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--bedeutung=primzahlkreuz"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--meaning=primecross"]),
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--primzahlwirkung=absicht"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--prime_effect=intentions"]),
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--universummetakonkret=meta"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--universeMetaConcrete=meta"]),
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--gebrochenuniversum=2"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--fractional_universe_n/m=2"]),
]


def normalize(payload: str) -> str:
    return html.unescape(payload.strip()).replace("\t", " ").replace("\r", " ").replace("\n", " ")


def render(language: str, args: list[str]) -> tuple[list[tuple[str, str]], list[tuple[str, str]]]:
    output_args = (["-output", "--type=html", "--width=0", "--onetable"] if language == "english" else ["-ausgabe", "--art=html", "--breite=0", "--onetable"])
    command = [sys.executable, str(REFERENCE), *args, *output_args]
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "0"
    output = subprocess.check_output(command, cwd=ROOT, env=env, text=True)
    rows = [line for line in output.splitlines() if line.startswith("<tr")]
    if len(rows) < 2:
        raise RuntimeError(f"expected heading and body row for: {' '.join(args)}")
    return CELL_RE.findall(rows[0]), CELL_RE.findall(rows[1])


def main() -> None:
    lines = ["# language\treference_rendered_column\theading_text\theading_open\tbody_open"]
    for language, args in CASES:
        headings, bodies = render(language, args)
        if len(headings) != len(bodies):
            raise RuntimeError(f"cell mismatch for {language}: {len(headings)}/{len(bodies)}")
        for rendered_column, ((heading_open, payload), (body_open, _)) in enumerate(zip(headings, bodies, strict=True)):
            if rendered_column < 2:
                continue
            heading = normalize(payload)
            fields = (language, str(rendered_column), heading, heading_open, body_open)
            if any("\t" in value or "\n" in value or "\r" in value for value in fields):
                raise RuntimeError(f"invalid TSV field for {language}:{rendered_column}")
            lines.append("\t".join(fields))
    OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {OUTPUT.relative_to(ROOT)}: {len(lines) - 1} entries")


if __name__ == "__main__":
    main()
