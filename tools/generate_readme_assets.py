#!/usr/bin/env python3
"""Generate deterministic assets for the historical generate4readme script.

The Python reference inherits set iteration order for four fractional parameter
value lists.  Runtime behavior therefore changes with PYTHONHASHSEED.  The
native owner uses PYTHONHASHSEED=0 as its explicit canonical reference and
stores the resulting complete German and English documents as immutable assets.
"""
from __future__ import annotations

import argparse
import hashlib
import os
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/libs/generate4readme.py"
DEFAULT_OUTPUT_DIR = ROOT / "assets"
MANIFEST_NAME = "generated_readme_manifest.tsv"


@dataclass(frozen=True)
class Document:
    language: str
    filename: str
    payload: bytes

    @property
    def lines(self) -> int:
        return self.payload.count(b"\n")

    @property
    def sha256(self) -> str:
        return hashlib.sha256(self.payload).hexdigest()


def _reference_python() -> str:
    return os.environ.get("RETA_REFERENCE_PYTHON", sys.executable)


def _render(language: str, *, hash_seed: str = "0") -> bytes:
    command = [_reference_python(), str(REFERENCE)]
    if language == "english":
        command.append("-language=english")
    env = os.environ.copy()
    env.update(
        {
            "PYTHONDONTWRITEBYTECODE": "1",
            "PYTHONHASHSEED": hash_seed,
            "PYTHONPATH": str(ROOT / "python_reference"),
        }
    )
    return subprocess.run(
        command,
        cwd=ROOT,
        env=env,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout


def generate() -> list[Document]:
    return [
        Document("german", "generated_readme_german.md", _render("german")),
        Document("english", "generated_readme_english.md", _render("english")),
    ]


def _manifest(documents: list[Document]) -> bytes:
    lines = ["# language\tfilename\tbytes\tlines\tsha256\tpython_hash_seed\n"]
    for document in documents:
        lines.append(
            "\t".join(
                (
                    document.language,
                    document.filename,
                    str(len(document.payload)),
                    str(document.lines),
                    document.sha256,
                    "0",
                )
            )
            + "\n"
        )
    return "".join(lines).encode("utf-8")


def write(output_dir: Path, *, check: bool) -> None:
    documents = generate()
    outputs = {document.filename: document.payload for document in documents}
    outputs[MANIFEST_NAME] = _manifest(documents)
    output_dir.mkdir(parents=True, exist_ok=True)
    mismatches: list[str] = []
    for filename, payload in outputs.items():
        path = output_dir / filename
        if check:
            if not path.exists() or path.read_bytes() != payload:
                mismatches.append(str(path))
        else:
            path.write_bytes(payload)
    if mismatches:
        raise SystemExit("readme assets differ: " + ", ".join(mismatches))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    write(args.output_dir, check=args.check)
    print(args.output_dir / MANIFEST_NAME)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
