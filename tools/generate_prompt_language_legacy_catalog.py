#!/usr/bin/env python3
"""Generate the exact historical PromptLanguageBundle data surface.

The resulting TSV is immutable runtime data.  Mojo owns all parsing and
classification logic; Python/PyPy3 is used only to regenerate/check the frozen
reference catalog.
"""
from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
LANGUAGES = ("deutsch", "english", "vietnamese", "chinese", "korean")


def snapshot(language: str) -> dict[str, object]:
    code = r'''
import json
import sys
from pathlib import Path
reference = Path(sys.argv[1])
language = sys.argv[2]
sys.argv = ["prompt-language-legacy", "-language=" + language]
sys.path.insert(0, str(reference))
from reta_architecture.prompt_language import bootstrap_prompt_language
bundle = bootstrap_prompt_language(force_rebuild=True)
print(json.dumps({
    "not_parameter_values": [str(value) for value in bundle.not_parameter_values],
    "commands": [str(value) for value in bundle.befehle],
    "allowed_fraction_numbers": sorted(int(value) for value in bundle.gebrochen_erlaubte_zahlen),
    "short_command_letters": sorted(str(value) for value in bundle.short_command_letters),
}, ensure_ascii=False))
'''
    completed = subprocess.run(
        [sys.executable, "-c", code, str(REFERENCE), language],
        cwd=REFERENCE,
        env={**os.environ, "PYTHONHASHSEED": "0"},
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    return json.loads(completed.stdout)


def safe(value: object) -> str:
    text = str(value)
    if any(character in text for character in "\t\r\n"):
        raise ValueError(f"control separator in catalog value: {text!r}")
    return text


def render() -> str:
    rows: list[str] = []
    for language in LANGUAGES:
        data = snapshot(language)
        domains = (
            ("parameter", data["not_parameter_values"]),
            ("command", data["commands"]),
            ("allowed_fraction", data["allowed_fraction_numbers"]),
            ("short", data["short_command_letters"]),
        )
        for domain, values in domains:
            for value in values:
                rows.append("\t".join((safe(language), domain, safe(value))))
    return "\n".join(rows) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output",
        type=Path,
        default=ROOT / "assets" / "prompt_language_legacy.tsv",
    )
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    content = render()
    if args.check:
        current = args.output.read_text(encoding="utf-8")
        if current != content:
            raise SystemExit(f"catalog differs: {args.output}")
        print(f"prompt language legacy catalog is reproducible: {args.output}")
        return
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(content, encoding="utf-8")
    print(f"generated {args.output}")


if __name__ == "__main__":
    main()
