#!/usr/bin/env python3
"""Generate the complete immutable input-semantics catalog.

The Python owner builds PromptVocabulary from the dynamic Program/i18n object
graph.  Mojo loads the resulting ordered values from a UTF-8 TSV catalog and
therefore keeps the exact public contract without importing Python at runtime.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
OUT = ROOT / "assets" / "input_semantics_catalog.tsv"


def _ensure_canonical_hash_seed() -> None:
    if os.environ.get("PYTHONHASHSEED") == "0":
        return
    env = os.environ.copy()
    env["PYTHONHASHSEED"] = "0"
    os.execve(sys.executable, [sys.executable, str(Path(__file__).resolve()), *sys.argv[1:]], env)


def _clean(value: object) -> str:
    text = str(value)
    if any(ch in text for ch in "\t\r\n"):
        raise ValueError(f"unsupported catalog value: {text!r}")
    return text


def _load_reference():
    sys.path[:0] = [str(PYROOT), str(PYROOT / "libs")]
    old_cwd = Path.cwd()
    try:
        os.chdir(PYROOT)
        import LibRetaPrompt  # type: ignore
    finally:
        os.chdir(old_cwd)
    return LibRetaPrompt


def main() -> int:
    _ensure_canonical_hash_seed()
    reference = _load_reference()
    vocabulary = reference.promptVocabulary
    input_snapshot = reference._ARCHITECTURE.inputs.snapshot()

    rows: list[str] = ["# kind\tfield\tkey\tordinal\tvalue"]
    row_ranges = input_snapshot["row_ranges"]
    rows.append("\t".join(["meta", "multiple_prefix", "", "0", _clean(row_ranges["multiple_prefix"])]))
    rows.append("\t".join(["meta", "comma_split_pattern", "", "0", _clean(row_ranges["comma_split_pattern"])]))

    list_fields = [
        "main_parameters",
        "spalten",
        "eigs_n",
        "eigs_r",
        "ausgabe_paras",
        "kombi_main_paras",
        "zeilen_paras",
        "haupt_for_neben",
        "not_parameter_values",
        "ausgabe_art",
        "zeilen_typen",
        "zeilen_zeit",
        "zeilen_typen_b",
        "befehle",
    ]
    for field in list_fields:
        for ordinal, value in enumerate(getattr(vocabulary, field)):
            rows.append("\t".join(["list", field, "", str(ordinal), _clean(value)]))

    set_fields = ["haupt_for_neben_set", "befehle2"]
    for field in set_fields:
        for ordinal, value in enumerate(sorted(getattr(vocabulary, field))):
            rows.append("\t".join(["set", field, "", str(ordinal), _clean(value)]))
    for ordinal, value in enumerate(sorted(vocabulary.gebrochen_erlaubte_zahlen)):
        rows.append("\t".join(["intset", "gebrochen_erlaubte_zahlen", "", str(ordinal), str(value)]))

    for key, values in vocabulary.spalten_dict.items():
        clean_key = _clean(key)
        for ordinal, value in enumerate(values):
            rows.append("\t".join(["map", "spalten_dict", clean_key, str(ordinal), _clean(value)]))
        if not values:
            rows.append("\t".join(["map-empty", "spalten_dict", clean_key, "0", "-"]))

    OUT.write_text("\n".join(rows) + "\n", encoding="utf-8")
    snapshot = vocabulary.snapshot()
    print(
        "input_semantics_catalog="
        f"{len(rows) - 1} rows spalten={snapshot['spalten_len']} "
        f"spalten_dict={snapshot['spalten_dict_keys']} commands={snapshot['befehle_len']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
