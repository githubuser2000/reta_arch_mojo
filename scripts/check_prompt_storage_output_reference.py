#!/usr/bin/env python3
"""Freeze the historical stored-output/addition boundary and its Python bug."""
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
RPB = PYROOT / "rpb"
INTERACTION = PYROOT / "reta_architecture" / "prompt_interaction.py"
SESSION = PYROOT / "reta_architecture" / "prompt_session.py"


def run_reference(command: str) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        [sys.executable, str(RPB), command],
        cwd=ROOT,
        env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
        check=False,
        capture_output=True,
        timeout=90,
    )


def check_source_boundary() -> None:
    interaction = INTERACTION.read_text(encoding="utf-8")
    session = SESSION.read_text(encoding="utf-8")
    if 'output_saved = {self.i18n.befehle2["o"], self.i18n.befehle2["BefehlSpeicherungAusgeben"]}' not in interaction:
        raise SystemExit("stored-output alias set changed")
    if "len(text_state.menge - output_saved) > 1" not in interaction:
        raise SystemExit("stored-output addition trigger changed")
    if "chains, text_state.liste, text_state" not in interaction:
        raise SystemExit("stored-output addition no longer passes list payload")
    if 'txt_state.platzhalter + " " + pending_output' not in session:
        raise SystemExit("stored-output list/string concatenation defect changed")


def check_runtime_defect() -> None:
    completed = run_reference("o prim 60")
    if completed.returncode == 0:
        raise SystemExit("Python stored-output addition unexpectedly succeeded")
    stderr = completed.stderr.decode("utf-8", errors="replace")
    if "TypeError" not in stderr or "not \"list\"" not in stderr:
        raise SystemExit(
            "Python stored-output addition failed differently: " + stderr[:400]
        )

    alone = run_reference("o")
    if alone.returncode != 0:
        raise SystemExit(
            "single stored-output command should remain non-crashing; stderr="
            + alone.stderr.decode("utf-8", errors="replace")[:400]
        )


def main() -> int:
    check_source_boundary()
    check_runtime_defect()
    print(
        "stored-output reference boundary: single o is stable; "
        "addition path is documented Python TypeError"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
