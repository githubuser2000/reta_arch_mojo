#!/usr/bin/env python3
"""Frozen Python reference for the native prompt-session owner."""
from __future__ import annotations

import sys
from pathlib import Path

if len(sys.argv) != 3:
    raise SystemExit("usage: prompt_session_reference_batch.py LANGUAGE CASES.tsv")
language, cases_path = sys.argv[1:]
root = Path(__file__).resolve().parent.parent
reference = root / "python_reference"
sys.argv = ["prompt-session-reference", "-language=" + language]
sys.path.insert(0, str(reference))

from reta_architecture.facade import RetaArchitecture  # noqa: E402
from reta_architecture.prompt_language import PromptModus, custom_split  # noqa: E402
from reta_architecture.prompt_session import bootstrap_prompt_session  # noqa: E402
from reta_architecture.runtime_compat import BereichToNumbers2, isZeilenAngabe  # noqa: E402
import i18n.words_runtime as i18n  # noqa: E402

architecture = RetaArchitecture.bootstrap(reference)
bundle = bootstrap_prompt_session(
    architecture=architecture, i18n=i18n, force_rebuild=True
)

mode_by_number = {
    0: PromptModus.normal,
    1: PromptModus.speichern,
    2: PromptModus.loeschenStart,
    3: PromptModus.speicherungAusgaben,
    4: PromptModus.loeschenSelect,
    5: PromptModus.speicherungAusgabenMitZusatz,
    6: PromptModus.AusgabeSelektiv,
}


def emit_words(label: str, values) -> None:
    print(f"{label}={len(values)}")
    for value in values:
        print("[" + str(value) + "]")


for raw in Path(cases_path).read_text(encoding="utf-8").splitlines():
    if not raw:
        continue
    fields = raw.split("\t")
    operation, name = fields[:2]
    print("@@@" + name)
    if operation == "state":
        state = bundle.new_text_state(fields[2])
        print("text=[" + state.text + "]")
        emit_words("tokens", state.liste)
        emit_words("command_words", state.listeS)
    elif operation == "delete":
        stored, selection = fields[2], fields[3]
        result = bundle.delete_before_storage_commands(
            stored,
            PromptModus.loeschenSelect,
            selection,
            isZeilenAngabe,
            BereichToNumbers2,
        )
        print("stored=[" + result[0] + "]")
        print("remaining=[" + result[2] + "]")
    elif operation == "apply":
        mode = mode_by_number[int(fields[2])]
        state = bundle.new_text_state(fields[4])
        state.platzhalter = fields[3]
        state = bundle.apply_storage_output(fields[5], mode, state)
        print("text=[" + state.text + "]")
    elif operation == "history":
        line = fields[2]
        pieces = custom_split(line)
        should = bool(
            line.strip()
            and i18n.befehle2["nichtloggen"] not in pieces
            and i18n.befehle2["loggen"] not in pieces
        )
        print("append=" + ("1" if should else "0"))
    elif operation == "combine":
        placeholder, text = fields[2], fields[3]

        def prepare_large_output(
            stored, prompt_mode, prompt_mode2, prompt_mode_last, current, extra
        ):
            return False, [], "", [], 1024, custom_split(stored), [], False

        result = bundle.store_prompt(
            [],
            placeholder,
            text,
            PromptModus.normal,
            set(bundle.completion_runtime.befehle),
            prepare_large_output,
        )
        print("stored=[" + result.text_state.platzhalter + "]")
        print("mode=" + str(result.prompt_mode2.value))
    else:
        raise AssertionError(operation)
