#!/usr/bin/env python3
"""Generate native help-text assets used by the legacy center facade."""
from __future__ import annotations

import argparse
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "python_reference" / "doc"
ASSETS = ROOT / "assets"


def prompt_body(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    start = text.find("+++", 2)
    if start < 0:
        raise SystemExit(f"missing prompt-help delimiter in {path}")
    return re.sub(r"{#.*}", "", text)[start + 3 :]


def generated_assets() -> dict[Path, bytes]:
    return {
        ASSETS / "reta_help_de.txt": (DOC / "readme-reta.md").read_bytes() + b"\n",
        ASSETS / "reta_help_en.txt": (DOC / "readme-reta-en.md").read_bytes() + b"\n",
        ASSETS / "reta_prompt_help_de.txt": prompt_body(DOC / "readme-retaPrompt.md").encode("utf-8"),
        ASSETS / "reta_prompt_help_en.txt": prompt_body(DOC / "readme-retaPrompt-en.md").encode("utf-8"),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    generated = generated_assets()
    stale = [path for path, payload in generated.items() if not path.exists() or path.read_bytes() != payload]
    if args.check:
        if stale:
            for path in stale:
                print(f"out of date: {path.relative_to(ROOT)}")
            return 1
        print(f"legacy help assets: {len(generated)}/4 current")
        return 0
    for path, payload in generated.items():
        path.write_bytes(payload)
        print(f"generated {path.relative_to(ROOT)} ({len(payload)} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
