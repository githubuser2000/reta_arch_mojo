#!/usr/bin/env python3
"""Check native compound ``leeren`` terminal-row semantics."""

from __future__ import annotations

import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROMPT = Path(os.environ.get("RETA_PROMPT_NATIVE", ROOT / "target/bin/reta-prompt-native"))


def run_prompt(*words: str, profile: str = "rpb") -> bytes:
    if not PROMPT.is_file() or not os.access(PROMPT, os.X_OK):
        raise SystemExit(f"missing native prompt binary: {PROMPT}")
    with tempfile.TemporaryDirectory(prefix="reta-compound-clear-") as tmp_name:
        tmp = Path(tmp_name)
        (tmp / "assets").symlink_to(ROOT / "assets", target_is_directory=True)
        (tmp / "python_reference").mkdir()
        (tmp / "python_reference/csv").symlink_to(
            ROOT / "python_reference/csv", target_is_directory=True
        )
        completed = subprocess.run(
            [str(PROMPT), profile, *words],
            cwd=tmp,
            env={**os.environ, "LINES": "3", "COLUMNS": "80"},
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
            timeout=120,
        )
    if completed.returncode != 0:
        raise SystemExit(
            f"native prompt failed for {words!r}: exit={completed.returncode}; "
            f"stderr={completed.stderr.decode(errors='replace')}"
        )
    if completed.stderr:
        raise SystemExit(
            f"native prompt wrote stderr for {words!r}: "
            f"{completed.stderr.decode(errors='replace')}"
        )
    return completed.stdout


def assert_compound_clear(words: tuple[str, ...], profile: str = "rpb") -> None:
    output = run_prompt(*words, profile=profile)
    expected_prefix = b"\n" * 4
    if not output.startswith(expected_prefix):
        raise SystemExit(
            f"compound clear did not emit LINES + 1 blank lines for {words!r}: "
            f"prefix={output[:32]!r}"
        )
    if output.startswith(expected_prefix + b"\n"):
        raise SystemExit(f"compound clear emitted too many leading lines for {words!r}")
    if b"reta -zeilen" not in output:
        raise SystemExit(f"compound clear did not continue into table execution: {words!r}")


def main() -> int:
    assert_compound_clear(("leeren", "emotion", "1"))
    assert_compound_clear(("emotion", "1", "leeren"))
    assert_compound_clear(("clear", "emotions", "1"), profile="retaPrompt.english")

    plain = run_prompt("emotion", "1")
    if plain.startswith(b"\n" * 4):
        raise SystemExit("plain table command unexpectedly emitted compound clear lines")

    standalone = run_prompt("leeren")
    if standalone != b"\x1b[2J\x1b[H":
        raise SystemExit(
            "standalone clear stopped using its distinct ANSI contract: "
            f"{standalone!r}"
        )

    print(
        "native compound clear: 3 localized/position variants emit LINES + 1 "
        "blank lines before table; standalone ANSI clear preserved"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
