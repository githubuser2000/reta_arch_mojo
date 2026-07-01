#!/usr/bin/env python3
"""Generate dynamic HTML heading metadata for native generator columns.

Unlike physical columns, generator columns do not have a stable CSV source
index.  Their rendered heading is the stable semantic key.  A frozen curated catalog covers focused generator families, while complete
German and English all-columns fixtures provide the authoritative semantic
map. Later entries deliberately overwrite duplicate headings, matching the
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
CURATED = ROOT / "assets" / "html_heading_catalog_curated.tsv"
CELL_RE = re.compile(r"""(<td(?:[^>"']|"[^"]*"|'[^']*')*>)(.*?)</td>""", re.S)
ROW_RE = re.compile(r"<tr[^>]*>.*?</tr>", re.S)

CASES: list[tuple[str, list[str]]] = [
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--bedeutung=primzahlkreuz"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--meaning=primecross"]),
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--primzahlwirkung=absicht"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--prime_effect=intentions"]),
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--universummetakonkret=meta"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--universeMetaConcrete=meta"]),
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--gebrochenuniversum=2"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--fractional_universe_n/m=2"]),
    # Physical aliases can carry legacy HTML metadata from a different
    # all-columns position.  Their semantic heading is the stable bridge key.
    ("german", ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--Menschliches=manipulation"]),
    ("english", ["-language=english", "-lines", "--thisrangebefore=1-3", "-columns", "--human=manipulation"]),
]


ALL_COLUMNS_FIXTURES: list[tuple[str, Path]] = [
    ("german", ROOT / "tests" / "fixtures" / "generate_html" / "middle-all-row1-de.html"),
    ("english", ROOT / "tests" / "fixtures" / "generate_html" / "middle-all-row1-en.html"),
]


def normalize(payload: str) -> str:
    return html.unescape(payload.strip()).replace("\t", " ").replace("\r", " ").replace("\n", " ")


def render(
    language: str,
    args: list[str],
    *,
    raw_nocolor: bool = False,
) -> tuple[list[tuple[str, str]], list[tuple[str, str]]]:
    output_args = (["-output", "--type=html", "--width=0", "--onetable"] if language == "english" else ["-ausgabe", "--art=html", "--breite=0", "--onetable"])
    if raw_nocolor:
        output_args.append("--nocolor")
    command = [sys.executable, str(REFERENCE), *args, *output_args]
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "0"
    output = subprocess.check_output(command, cwd=ROOT, env=env, text=True)
    rows = ROW_RE.findall(output)
    if len(rows) < 2:
        raise RuntimeError(f"expected heading and body row for: {' '.join(args)}")
    return CELL_RE.findall(rows[0]), CELL_RE.findall(rows[1])


def append_rendered_rows(
    lines: list[str],
    language: str,
    headings: list[tuple[str, str]],
    bodies: list[tuple[str, str]],
) -> None:
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


def append_case(
    lines: list[str],
    language: str,
    args: list[str],
    *,
    raw_nocolor: bool = False,
) -> None:
    headings, bodies = render(language, args, raw_nocolor=raw_nocolor)
    append_rendered_rows(lines, language, headings, bodies)


def append_fixture(lines: list[str], language: str, path: Path) -> None:
    output = path.read_text(encoding="utf-8")
    rows = ROW_RE.findall(output)
    if len(rows) != 2:
        raise RuntimeError(f"expected exactly two rows in {path.relative_to(ROOT)}")
    append_rendered_rows(
        lines,
        language,
        CELL_RE.findall(rows[0]),
        CELL_RE.findall(rows[1]),
    )


def main() -> None:
    curated_lines = CURATED.read_text(encoding="utf-8").splitlines()
    if not curated_lines or not curated_lines[0].startswith("# language"):
        raise RuntimeError(f"invalid curated catalog: {CURATED.relative_to(ROOT)}")
    lines = curated_lines.copy()
    # The complete all-columns rendering is the authoritative semantic bridge
    # for both physical and generated columns.  Frozen Python-reference rows
    # make the catalog fast and reproducible without rerunning the expensive
    # 807-column command on every source check.
    for language, fixture in ALL_COLUMNS_FIXTURES:
        append_fixture(lines, language, fixture)
    OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {OUTPUT.relative_to(ROOT)}: {len(lines) - 1} entries")


if __name__ == "__main__":
    main()
