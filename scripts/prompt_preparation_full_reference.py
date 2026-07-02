#!/usr/bin/env python3
"""Emit the full historical prompt-preparation tuple for parity tests."""
from __future__ import annotations

import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: prompt_preparation_full_reference.py LANGUAGE CASES.tsv")
language, cases_path = sys.argv[1:]
root = Path(__file__).resolve().parent.parent
reference = root / "python_reference"
sys.argv = ["prompt-preparation-full-reference", "-language=" + language]
sys.path.insert(0, str(reference))

from reta_architecture.facade import RetaArchitecture  # noqa: E402
from reta_architecture.prompt_language import PromptModus  # noqa: E402
from reta_architecture.prompt_preparation import bootstrap_prompt_preparation  # noqa: E402
import i18n.words_runtime as i18n  # noqa: E402

architecture = RetaArchitecture.bootstrap(reference)
bundle = bootstrap_prompt_preparation(
    architecture=architecture, i18n=i18n, force_rebuild=True
)

for raw in Path(cases_path).read_text(encoding="utf-8").splitlines():
    if not raw:
        continue
    name, placeholder, mode, mode2, last_mode, text, extra, force_e = raw.split("\t")
    result = bundle.prepare_grosse_ausgabe(
        placeholder,
        PromptModus(int(mode)),
        PromptModus(int(mode2)),
        PromptModus(int(last_mode)),
        text,
        extra.split("\x1f") if extra else [],
    )
    print("@@@" + name)
    print("pure=" + str(int(result[0])))
    print("max=" + str(result[4]))
    print("compact=" + str(int(result[7])))
    print(*result[5], sep="\n")
