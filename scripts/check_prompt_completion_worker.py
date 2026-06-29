#!/usr/bin/env python3
"""Verify that the Readline OS seam delegates candidates to the Mojo worker."""
from __future__ import annotations

import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(root / "python_reference"))
import mojo_bridge  # noqa: E402

try:
    for language in ("english", "deutsch"):
        cases = root / "tests" / "fixtures" / "prompt_completion" / f"{language}.tsv"
        expected_path = cases.with_suffix(".expected")
        output: list[str] = []
        for raw in cases.read_text(encoding="utf-8").splitlines():
            name, text = raw.split("\t", 1)
            values = mojo_bridge._native_prompt_completion(text, language)
            if values is None:
                raise SystemExit(f"native completion worker unavailable for {language}")
            output.append("@@@" + name)
            output.extend(values)
        actual = "\n".join(output) + "\n"
        expected = expected_path.read_text(encoding="utf-8")
        if actual != expected:
            raise SystemExit(f"worker completion mismatch for {language}")
finally:
    mojo_bridge._close_prompt_completion_process()
print("Readline-Grenze delegiert 12 Kontexte bytegleich an den Mojo-Arbeiter.")
