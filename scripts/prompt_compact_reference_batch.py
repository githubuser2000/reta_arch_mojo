#!/usr/bin/env python3
"""Batch-print compact-prompt expansion from the Python reference."""
from __future__ import annotations

import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: prompt_compact_reference_batch.py LANGUAGE CASES.tsv")
language, cases_path = sys.argv[1:]
root = Path(__file__).resolve().parent.parent
reference = root / "python_reference"
sys.argv = ["prompt-compact-reference", "-language=" + language]
sys.path.insert(0, str(reference))

from reta_architecture.facade import RetaArchitecture  # noqa: E402
from reta_architecture.prompt_language import (  # noqa: E402
    PromptModus,
    bootstrap_prompt_language,
)
import i18n.words_runtime as i18n  # noqa: E402

architecture = RetaArchitecture.bootstrap(reference)
bundle = bootstrap_prompt_language(
    architecture=architecture, i18n=i18n, force_rebuild=True
)

for raw in Path(cases_path).read_text(encoding="utf-8").splitlines():
    if not raw:
        continue
    name, selective_raw, force_e_raw, text = raw.split("\t", 3)
    selective = selective_raw == "1"
    force_e = force_e_raw == "1"
    tokens = bundle.completion_runtime.custom_split(text) if hasattr(bundle.completion_runtime, "custom_split") else None
    if tokens is None:
        from reta_architecture.prompt_language import custom_split
        tokens = custom_split(text)
    marker = "-" + i18n.retaPrompt.retaPromptParameter["e"]
    inserted = False
    if force_e and marker not in sys.argv:
        sys.argv.append(marker)
        inserted = True
    try:
        compact, expanded = bundle.stextFromKleinKleinKleinBefehl(
            PromptModus.AusgabeSelektiv if selective else PromptModus.normal,
            tokens,
            [],
        )
    finally:
        if inserted:
            sys.argv.remove(marker)
    print("@@@" + name)
    print("1" if compact else "0")
    for token in expanded:
        print(token)
