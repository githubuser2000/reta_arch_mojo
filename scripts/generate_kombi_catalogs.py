#!/usr/bin/env python3
"""Generate native Kombi alias and integer-relation catalogs.

The alias catalog mirrors the translated ``kombiParaNdataMatrix`` dictionaries.
The relation catalog preserves the observable CPython ``set`` iteration order
used by ``KombiJoin.prepare_kombi`` for every main-table row number.
"""
from __future__ import annotations

import argparse
import csv
import json
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
ALIAS_OUTPUT = ROOT / "assets" / "kombi_aliases.tsv"
RELATION_OUTPUT = ROOT / "assets" / "kombi_relation_order.tsv"


def _extract_aliases(language: str) -> list[tuple[str, str, str, str, int]]:
    sys.argv = [sys.argv[0], f"-language={language}"]
    sys.path.insert(0, str(REFERENCE))
    from i18n.words_context import kombiMainParas  # noqa: PLC0415
    from i18n.words_matrix import (  # noqa: PLC0415
        kombiParaNdataMatrix,
        kombiParaNdataMatrix2,
    )

    rows: list[tuple[str, str, str, str, int]] = []
    for kind, domain, matrix in (
        ("galaxy", str(kombiMainParas["galaxie"]), kombiParaNdataMatrix),
        ("universe", str(kombiMainParas["universum"]), kombiParaNdataMatrix2),
    ):
        for column, aliases in matrix.items():
            for alias in aliases:
                rows.append((language, kind, domain, str(alias), int(column)))
    return rows


def _alias_child(language: str) -> None:
    print(json.dumps(_extract_aliases(language), ensure_ascii=False))


def _decode_number_token(token: str) -> list[int]:
    token = token.strip()
    if len(token) > 2 and token[0] == "(" and token[-1] == ")":
        return _decode_number_token(token[1:-1])
    unsigned = token[1:] if token[:1] in "+-" else token
    if unsigned.isdecimal() and unsigned:
        return [abs(int(token))]
    if len(token) > 2 and "/" in token:
        left, right = token.split("/", 1)
        return _decode_number_token(left) + _decode_number_token(right)
    raise ValueError(f"invalid Kombi relation token: {token!r}")


def _relation_rows(kind: str, filename: str) -> list[tuple[str, int, str]]:
    path = REFERENCE / "csv" / filename
    relations: dict[int, set[int]] = defaultdict(set)
    with path.open(newline="", encoding="utf-8") as handle:
        for row_index, row in enumerate(csv.reader(handle, delimiter=";")):
            if row_index == 0 or not row:
                continue
            values: list[int] = []
            for token in row[0].split("|"):
                values.extend(_decode_number_token(token))
            for value in values:
                if value in relations:
                    relations[value] |= {row_index}
                else:
                    relations[value] = set({row_index})
    return [
        (kind, value, ",".join(str(row) for row in relations[value]))
        for value in sorted(relations)
    ]


def _parent() -> None:
    alias_rows: list[tuple[str, str, str, str, int]] = []
    for language in ("german", "english"):
        completed = subprocess.run(
            [sys.executable, str(Path(__file__).resolve()), "--emit-language", language],
            cwd=ROOT,
            check=True,
            capture_output=True,
            text=True,
        )
        alias_rows.extend(tuple(row) for row in json.loads(completed.stdout))
    aliases = sorted(set(alias_rows), key=lambda row: (row[0], row[1], row[2], row[3], row[4]))
    ALIAS_OUTPUT.write_text(
        "".join(
            f"{language}\t{kind}\t{domain}\t{alias}\t{column}\n"
            for language, kind, domain, alias, column in aliases
        ),
        encoding="utf-8",
    )

    relation_rows = _relation_rows("galaxy", "kombi.csv") + _relation_rows(
        "universe", "kombi-meta.csv"
    )
    RELATION_OUTPUT.write_text(
        "".join(f"{kind}\t{number}\t{rows}\n" for kind, number, rows in relation_rows),
        encoding="utf-8",
    )
    print(f"wrote {len(aliases)} aliases to {ALIAS_OUTPUT.relative_to(ROOT)}")
    print(
        f"wrote {len(relation_rows)} relation rows to {RELATION_OUTPUT.relative_to(ROOT)}"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--emit-language", choices=("german", "english"))
    args = parser.parse_args()
    if args.emit_language:
        _alias_child(args.emit_language)
    else:
        _parent()


if __name__ == "__main__":
    main()
