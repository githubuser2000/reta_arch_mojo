#!/usr/bin/env python3
"""Reference front-half prompt preparation for native Mojo parity tests."""
from __future__ import annotations

import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: prompt_preparation_reference_batch.py LANGUAGE CASES.tsv")
language, cases_path = sys.argv[1:]
root = Path(__file__).resolve().parent.parent
reference = root / "python_reference"
sys.argv = ["prompt-preparation-reference", "-language=" + language]
sys.path.insert(0, str(reference))

from reta_architecture.facade import RetaArchitecture  # noqa: E402
from reta_architecture.prompt_language import (  # noqa: E402
    PromptModus,
    bootstrap_prompt_language,
    custom_split,
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
    tokens = custom_split(text)
    marker = "-" + i18n.retaPrompt.retaPromptParameter["e"]
    inserted = force_e_raw == "1" and marker not in sys.argv
    if inserted:
        sys.argv.append(marker)
    try:
        compact, tokens = bundle.stextFromKleinKleinKleinBefehl(
            PromptModus.AusgabeSelektiv
            if selective_raw == "1"
            else PromptModus.normal,
            tokens,
            [],
        )
    finally:
        if inserted:
            sys.argv.remove(marker)
    if tokens and tokens[0] not in (
        "reta",
        i18n.befehle2["shell"],
        i18n.befehle2["python"],
        i18n.befehle2["abstand"],
    ):
        tokens = [i18n.retaPrompt.replacements.get(token, token) for token in tokens]
    if tokens[:1] != ["reta"]:
        tokens = list(set(tokens))
    print("@@@" + name)
    print("1" if compact else "0")
    print(*tokens, sep="\n")
