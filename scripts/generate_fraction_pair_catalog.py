#!/usr/bin/env python3
"""Generate the exact legacy fractional prime-universe relation catalog.

Do not reimplement the historical set algebra here.  Its visible pair order is
part of Reta's output contract and depends on the precise sequence of Python
set-union operations in ``meta_columns.py`` and ``concat_csv.py``.  This build
time extractor invokes those reference functions directly and serialises their
ordered result for the Python-free Mojo runtime.

Run with ``PYTHONHASHSEED=0``.  The script rejects any other hash seed because
CPython set iteration is otherwise deliberately process-randomised.
"""
from __future__ import annotations

import os
import sys
from fractions import Fraction
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
REFERENCE_ROOT = ROOT / "python_reference"
CSV_DIR = REFERENCE_ROOT / "csv"
OUTPUT = ROOT / "assets" / "fraction_pairs.tsv"
MAX_ROW = 1024

if os.environ.get("PYTHONHASHSEED") != "0":
    raise SystemExit(
        "generate_fraction_pair_catalog.py requires PYTHONHASHSEED=0 "
        "to preserve the legacy CPython set order"
    )

sys.path.insert(0, str(REFERENCE_ROOT))

from reta_architecture import concat_csv, meta_columns  # noqa: E402
from reta_architecture.runtime_compat import unique_everseen  # noqa: E402


class _TableLimits:
    hoechsteZeile = {MAX_ROW: MAX_ROW}


class _ReferenceFractionRuntime:
    """Minimal receiver required by the original relation helpers."""

    def __init__(self) -> None:
        self.tables = _TableLimits()
        self.CSVsAlreadRead: dict[str, list[list[str]]] = {}
        self.BruecheUni: tuple[Fraction, ...] = ()
        self.BruecheGal: tuple[Fraction, ...] = ()
        self.BruecheEmo: tuple[Fraction, ...] = ()
        self.BruecheStrukGroesse: tuple[Fraction, ...] = ()

    def readConcatCSV_choseCsvFile(self, selection: object) -> str:
        # The reference enum routes 2/3 to the galaxy table and 0/1 to the
        # universe table.  ``selection`` is intentionally kept generic because
        # the legacy enum values are plain integers in this code path.
        filename = (
            "gebrochen-rational-galaxie.csv"
            if selection in (2, 3)
            else "gebrochen-rational-universum.csv"
        )
        return str(CSV_DIR / filename)


# Bind the original free functions as methods, exactly like their production
# owner does.  This keeps every OrderedSet/set union and conversion step intact.
_ReferenceFractionRuntime.getAllBrueche = meta_columns.getAllBrueche
_ReferenceFractionRuntime.readOneCSVAndReturn = meta_columns.readOneCSVAndReturn
_ReferenceFractionRuntime.findAllBruecheAndTheirCombinations = (
    meta_columns.findAllBruecheAndTheirCombinations
)
_ReferenceFractionRuntime.convertSetOfPaarenToDictOfNumToPaareMul = (
    concat_csv.convertSetOfPaarenToDictOfNumToPaareMul
)
_ReferenceFractionRuntime.convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction = (
    concat_csv.convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction
)
_ReferenceFractionRuntime.combineDicts = concat_csv.combineDicts


def _fraction_source(
    runtime: _ReferenceFractionRuntime, name: str
) -> tuple[Fraction, ...]:
    return runtime.BruecheUni if name == "Uni" else runtime.BruecheGal


def _ordered_pairs(
    values: Iterable[tuple[Fraction, Fraction]],
) -> tuple[tuple[Fraction, Fraction], ...]:
    # This is the exact de-duplication used by generated_columns.py: reversed
    # pairs represent the same relation and only the first visible one survives.
    return tuple(unique_everseen(values, key=frozenset))


def build_catalog() -> tuple[int, int, list[tuple[str, ...]]]:
    runtime = _ReferenceFractionRuntime()
    combinations = runtime.findAllBruecheAndTheirCombinations()
    rows: list[tuple[str, ...]] = []

    for context in ("UniUni", "UniGal", "GalUni", "GalGal"):
        first_values = _fraction_source(runtime, context[:3])
        second_values = _fraction_source(runtime, context[3:])

        for polygon in ("stern", "gleichf"):
            inverse = polygon == "gleichf"
            relation_pairs = runtime.convertSetOfPaarenToDictOfNumToPaareMul(
                combinations[context][polygon]["mul"], inverse
            )
            mixed_pairs = (
                runtime.convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction(
                    first_values,
                    second_values,
                    inverse,
                )
            )
            pair_map = runtime.combineDicts(relation_pairs, mixed_pairs)

            for result_number, values in pair_map.items():
                for order, pair in enumerate(_ordered_pairs(values)):
                    first, second = pair
                    rows.append(
                        (
                            context,
                            polygon,
                            str(result_number),
                            str(order),
                            str(first.numerator),
                            str(first.denominator),
                            str(second.numerator),
                            str(second.denominator),
                        )
                    )

    return len(runtime.BruecheGal), len(runtime.BruecheUni), rows


def main() -> None:
    galaxy_count, universe_count, rows = build_catalog()
    OUTPUT.write_text(
        "".join("\t".join(row) + "\n" for row in rows),
        encoding="utf-8",
    )
    print(
        f"wrote {len(rows)} ordered fraction pairs to {OUTPUT.relative_to(ROOT)} "
        f"(galaxy={galaxy_count}, universe={universe_count}, "
        f"PYTHONHASHSEED={os.environ['PYTHONHASHSEED']})"
    )


if __name__ == "__main__":
    main()
