#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
sys.path.insert(0, str(REFERENCE))


def join(values: list[object]) -> str:
    return "\x1f".join(str(value) for value in values)


def bundle(language: str):
    # This script is invoked once per language by the parity shell script so
    # the historical import-time i18n language selection remains exact.
    sys.argv = ["prompt-language-legacy-reference", "-language=" + language]
    from reta_architecture.prompt_language import bootstrap_prompt_language

    return bootstrap_prompt_language(force_rebuild=True)


def main() -> None:
    language = sys.argv[1]
    current = bundle(language)
    snapshot = current.snapshot()
    print(
        "snapshot",
        language,
        snapshot["class"],
        snapshot["not_parameter_values_len"],
        len({str(value).split("=")[0] for value in current.not_parameter_values}),
        len(current.befehle),
        snapshot["gebrochen_erlaubte_zahlen_len"],
        snapshot["wahl15_len"],
        snapshot["wahl16_len"],
        join(snapshot["short_command_letters"]),
        sep="\t",
    )
    parameter_cases = (
        "-zeilen" if language == "deutsch" else "-lines",
        "--zeit=heute" if language == "deutsch" else "--time=today",
        "--breite=0" if language == "deutsch" else "--width=0",
        "--Religionen=sternpolygon",
        "-1",
        "-1-3",
        "-1/2",
        "--unbekannt=2",
    )
    for text in parameter_cases:
        print("parameter", language, text, int(current.isReTaParameter(text)), sep="\t")
    for text in ("15_", "15_13_10", "16_15_13_10", "16_5", "16_999"):
        print("numeric", language, text, int(current.is15or16command(text)), sep="\t")
    for text in ("reta (1 2)  ende", "a b", "(1 2 3)"):
        from reta_architecture.prompt_language import custom_split

        print("split", language, text, join(custom_split(text)), sep="\t")
    from reta_architecture.prompt_language import custom_split2

    text = "1,(2,3),[4,5],6"
    print("split2", language, text, join(custom_split2(text, ",")), sep="\t")


if __name__ == "__main__":
    main()
