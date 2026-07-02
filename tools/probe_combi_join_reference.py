#!/usr/bin/env python3
"""Emit stable line records from the historical Python KombiJoin owner."""
from __future__ import annotations

import csv
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYREF = ROOT / "python_reference"
sys.path.insert(0, str(PYREF))
os.chdir(ROOT)

import reta_architecture.combi_join as cj  # noqa: E402
from i18n.words_runtime import csvFileNames  # noqa: E402

cj._ensure_runtime_dependencies()
MOD = 1_000_000_007


def table_fingerprint(rows) -> int:
    value = 17
    for row in rows:
        for cell in row:
            for byte in str(cell).encode("utf-8"):
                value = (value * 257 + byte + 1) % MOD
            value = (value * 257 + 257) % MOD
        value = (value * 257 + 258) % MOD
    return value


def combinations_fingerprint(rows: list[list[int]]) -> int:
    value = 19
    for row in rows:
        for item in row:
            value = (value * 263 + abs(int(item)) + 1) % MOD
        value = (value * 263 + 263) % MOD
    return value


class FakeTables:
    def __init__(self, bucket: int):
        self.generatedSpaltenParameter: dict[int, object] = {}
        self.SpaltenVanillaAmount = 2
        self.dataDict = [{} for _ in range(9)]
        self.dataDict[bucket] = {1: []}
        self.textwidth = 0
        self.textWidth = 0
        self.htmlOutputYes = False
        self.bbcodeOutputYes = False
        self.breitenn = []
        self.getOut = type("Out", (), {"oneTable": True})()

    @staticmethod
    def fillBoth(first, second):
        while len(first) < len(second):
            first += [[]]
        while len(second) < len(first):
            second += [[]]
        return first, second

    @staticmethod
    def tableReducedInLinesByTypeSet(table, wanted):
        return [table[index] for index in sorted(wanted) if 0 <= index < len(table)]


def csv_row_count(path: str) -> int:
    with open(path, encoding="utf-8", newline="") as handle:
        return sum(1 for _ in csv.reader(handle, delimiter=";"))


def canonical_selection_rows(mapping):
    return [
        [str(int(key)), *map(str, sorted(map(int, value)))]
        for key, value in sorted(mapping.items(), key=lambda item: int(item[0]))
    ]


def source_records(kind: str) -> list[str]:
    filename = csvFileNames.kombi13 if kind == "galaxy" else csvFileNames.kombi15
    bucket = 3 if kind == "galaxy" else 8
    tables = FakeTables(bucket)
    owner = cj.KombiJoin.__new__(cj.KombiJoin)
    owner.tables = tables
    owner.sumOfAllCombiRowsAmount = 0
    row_count = csv_row_count(str(PYREF / "csv" / Path(filename).name))
    main = [["h0", "h1"]] + [[str(index), ""] for index in range(1, row_count)]
    selected_columns: set[int] = set()
    kombi_table, relitable, combinations, relation = owner.readKombiCsv(
        main, selected_columns, {1}, filename
    )
    selections = owner.prepare_kombi(
        set(), kombi_table, {"ka"}, {1, 2, 3, 5, 7, 9, 13}, combinations
    )
    selection_rows = canonical_selection_rows(selections)
    prepared = owner.prepareTableJoin(selections, kombi_table)
    prepared_rows = []
    for mapping in prepared:
        for key, rows in mapping.items():
            row_fingerprints = sorted(table_fingerprint([row]) for row in rows)
            prepared_rows.append(
                [str(int(key)), str(len(rows)), *map(str, row_fingerprints)]
            )
    prepared_rows.sort(key=lambda row: int(row[0]))
    relation_rows = [
        [str(int(key)), str(int(value))]
        for key, value in sorted(relation[0].items(), key=lambda item: int(item[0]))
    ]
    records = [
        "|".join(
            [
                "SOURCE",
                kind,
                str(len(kombi_table)),
                str(max(map(len, kombi_table), default=0)),
                str(len(combinations)),
                str(table_fingerprint(kombi_table)),
                str(combinations_fingerprint(combinations)),
            ]
        ),
        "|".join(
            [
                "APPEND",
                kind,
                str(len(relitable)),
                str(max(map(len, relitable), default=0)),
                str(table_fingerprint(relitable)),
                str(len(relation_rows)),
                str(table_fingerprint(relation_rows)),
                ",".join(map(str, sorted(selected_columns))),
            ]
        ),
        "|".join(
            [
                "SELECT",
                kind,
                str(len(selection_rows)),
                str(table_fingerprint(selection_rows)),
            ]
        ),
        "|".join(
            [
                "PREPARED",
                kind,
                str(len(prepared_rows)),
                str(table_fingerprint(prepared_rows)),
            ]
        ),
    ]
    return records


def main() -> int:
    parser_owner = cj.KombiJoin.__new__(cj.KombiJoin)
    for token in ["-13", "(+7)", "12/5", "(1/2)"]:
        parser_owner.kombiTable_Kombis_Col = []
        parser_owner.kombiNumbersCorrectTestAndSet(token)
        print("TOKEN|" + token + "|" + ",".join(map(str, parser_owner.kombiTable_Kombis_Col)))

    for kind in ("galaxy", "universe"):
        for record in source_records(kind):
            print(record)

    remove_owner = cj.KombiJoin.__new__(cj.KombiJoin)
    remove_owner.tables = FakeTables(3)
    for value in [
        remove_owner.removeOneNumber(["(1|2|3/4) Inhalt (1|2|3/4)"], 2)[0],
        remove_owner.removeOneNumber(["(2) Inhalt (2)"], 2)[0],
    ]:
        print("REMOVE|" + value)

    snapshot = cj.bootstrap_combi_join().snapshot()
    print(
        "BUNDLE|"
        + snapshot["implementation"]
        + "|"
        + ",".join(snapshot["morphisms"])
        + "|"
        + ",".join(Path(value).name for value in snapshot["csv_sources"])
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
