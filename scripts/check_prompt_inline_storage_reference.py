#!/usr/bin/env python3
"""Freeze Python's set-based compound S/s storage semantics."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python_reference"))

import i18n.words_runtime as i18n  # noqa: E402
from reta_architecture.prompt_interaction import PromptInteractionBundle  # noqa: E402
from reta_architecture.prompt_language import PromptModus  # noqa: E402


class TextState:
    def __init__(self, tokens: list[str]) -> None:
        self.liste = list(tokens)
        self.menge = set(tokens)
        self.platzhalter = ""
        self.text = " ".join(tokens)
        self.befehlDavor = "previous"

    def hasWithoutABC(self, candidates: set[str]) -> bool:
        abc = {i18n.befehle2["abc"], i18n.befehle2["abcd"]}
        return bool(self.menge & candidates) and not bool(self.menge & abc)

    def has(self, candidates: set[str]) -> bool:
        return bool(self.menge & candidates)


class Harness:
    _storage_command = PromptInteractionBundle._storage_command
    i18n = i18n

    def __init__(self) -> None:
        self.stored: list[str] = []

    def store_prompt(
        self, chains: list[str], placeholder: str, text: str
    ) -> tuple[list[str], TextState]:
        del placeholder
        self.stored.append(text)
        return chains, TextState([])


def run(tokens: list[str]) -> tuple[bool, list[str]]:
    harness = Harness()
    state = TextState(tokens)
    handled, *_ = harness._storage_command(
        state, PromptModus.normal, [], ""
    )
    return handled, harness.stored


def main() -> int:
    for tokens in (
        ["S", "emotion", "1"],
        ["emotion", "S", "1"],
        ["emotion", "1", "s"],
        ["BefehlSpeichernDanach", "emotion", "1"],
    ):
        handled, stored = run(tokens)
        if not handled or stored != ["emotion 1"]:
            raise SystemExit(f"compound storage mismatch for {tokens!r}: {handled}, {stored}")

    handled, stored = run(["S", "S", "emotion"])
    if not handled or stored != ["S emotion"]:
        raise SystemExit(f"remove-once storage mismatch: {handled}, {stored}")

    for tokens in (
        ["S", "s", "emotion"],
        ["S", "BefehlSpeichernDanach", "emotion"],
        ["S", "abc"],
        ["S", "S"],
    ):
        handled, stored = run(tokens)
        if handled or stored:
            raise SystemExit(f"ambiguous/excluded storage was claimed for {tokens!r}")

    print(
        "compound prompt storage reference: 4 position/alias variants, "
        "remove-once duplicate, ambiguity/abc/only-storage exclusions valid"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
