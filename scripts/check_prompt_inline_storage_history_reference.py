#!/usr/bin/env python3
"""Freeze the reference boundary between inline storage and command history."""

from __future__ import annotations

import inspect
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python_reference"))

import i18n.words_runtime as i18n  # noqa: E402
from reta_architecture.prompt_interaction import PromptInteractionBundle  # noqa: E402
from reta_architecture.prompt_language import PromptModus  # noqa: E402


class TextState:
    def __init__(self, tokens: list[str], previous: str = "prim 60") -> None:
        self.liste = list(tokens)
        self.menge = set(tokens)
        self.platzhalter = ""
        self.text = " ".join(tokens)
        self.befehlDavor = previous

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
        # The reference creates a fresh text state and returns from the storage
        # branch.  The physical storage line is therefore never made the next
        # executable "previous command".
        return chains, TextState([], previous="prim 60")


def main() -> int:
    for tokens in (
        ["S", "emotion", "1"],
        ["emotion", "S", "1"],
        ["emotion", "1", "s"],
        ["BefehlSpeichernDanach", "emotion", "1"],
    ):
        harness = Harness()
        handled, mode, _, _, state = harness._storage_command(
            TextState(tokens), PromptModus.normal, [], ""
        )
        if not handled or mode is not PromptModus.normal:
            raise SystemExit(f"inline storage was not consumed for {tokens!r}")
        if harness.stored != ["emotion 1"]:
            raise SystemExit(f"wrong stored payload for {tokens!r}: {harness.stored!r}")
        if state.befehlDavor != "":
            raise SystemExit(
                "storage branch did not clear previous-command state for "
                f"{tokens!r}: {state.befehlDavor!r}"
            )

    loop_source = inspect.getsource(PromptInteractionBundle.run_scope)
    storage_dispatch = loop_source.index("handled, prompt_mode")
    continue_after_storage = loop_source.index("if handled:", storage_dispatch)
    execute_after_storage = loop_source.index("self._execute(", continue_after_storage)
    if "continue" not in loop_source[continue_after_storage:execute_after_storage]:
        raise SystemExit("reference loop no longer skips execution after storage")

    print(
        "inline storage history reference: 4 position/alias variants are "
        "consumed before execution and never become the previous command"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
