#!/usr/bin/env python3
"""Generate the non-ordinary Reta parameter alias catalog.

The historical Python schema stores twelve independent column-selection buckets
inside every ``paraNdataMatrix`` entry.  ``assets/parameter_aliases.tsv`` only
contains bucket 0 (physical columns).  This generator serializes buckets 1..11
for the native Mojo runtime, in both German and English.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
OUTPUT = ROOT / "assets" / "generated_aliases.tsv"

BUCKET_NAMES = (
    "ordinary",
    "modal",
    "concat",
    "kombi",
    "prime_effect",
    "fraction_universe",
    "fraction_galaxy",
    "generated_command",
    "kombi2",
    "fraction_emotion",
    "fraction_size",
    "meta",
)


def _payload(value: Any) -> str:
    if isinstance(value, (tuple, list)):
        return ",".join("" if item is None else str(item) for item in value)
    return str(value)


def _extract(language: str) -> list[dict[str, str]]:
    # The translation bootstrap inspects sys.argv at import time.
    sys.argv = [sys.argv[0], f"-language={language}"]
    sys.path.insert(0, str(REFERENCE))
    from i18n.words_matrix import paraNdataMatrix  # noqa: PLC0415

    # ``ParameterSemanticsBuilder`` folds the matrix into ``paraDict`` with
    # dictionary update semantics.  Therefore a later matrix entry replaces an
    # earlier entry for the same ``(main alias, parameter alias)`` pair.  This is
    # observable for real aliases such as English ``multiplications=motifStar``.
    # Serialising every raw matrix occurrence would incorrectly combine both
    # commands, so first construct the effective last-write-wins mapping.
    effective_entries: dict[tuple[str, str], tuple[Any, ...]] = {}
    for entry in paraNdataMatrix:
        main_aliases = tuple(str(value) for value in entry[0])
        parameter_aliases = tuple(str(value) for value in entry[1]) or ("",)
        for main_alias in main_aliases:
            for parameter_alias in parameter_aliases:
                effective_entries[(main_alias, parameter_alias)] = entry

    rows: list[dict[str, str]] = []
    for (main_alias, parameter_alias), entry in effective_entries.items():
        for bucket_index in range(1, len(BUCKET_NAMES)):
            tuple_index = 2 + bucket_index
            if tuple_index >= len(entry):
                continue
            values = entry[tuple_index]
            for value in values:
                rows.append(
                    {
                        "language": language,
                        "main": main_alias,
                        "parameter": parameter_alias,
                        "bucket": BUCKET_NAMES[bucket_index],
                        "payload": _payload(value),
                    }
                )
    return rows


def _child(language: str) -> None:
    print(json.dumps(_extract(language), ensure_ascii=False, sort_keys=True))


def _parent() -> None:
    rows: list[dict[str, str]] = []
    for language in ("german", "english"):
        completed = subprocess.run(
            [sys.executable, str(Path(__file__).resolve()), "--emit-language", language],
            cwd=ROOT,
            check=True,
            capture_output=True,
            text=True,
        )
        rows.extend(json.loads(completed.stdout))

    unique = {
        (
            row["language"],
            row["main"],
            row["parameter"],
            row["bucket"],
            row["payload"],
        )
        for row in rows
    }
    ordered = sorted(unique)
    OUTPUT.write_text(
        "".join("\t".join(row) + "\n" for row in ordered),
        encoding="utf-8",
    )
    print(f"wrote {len(ordered)} aliases to {OUTPUT.relative_to(ROOT)}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--emit-language", choices=("german", "english"))
    args = parser.parse_args()
    if args.emit_language:
        _child(args.emit_language)
    else:
        _parent()


if __name__ == "__main__":
    main()
