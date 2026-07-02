#!/usr/bin/env python3
"""Compare native generate4readme output with the canonical Python reference."""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/libs/generate4readme.py"


def _python_output(english: bool) -> bytes:
    command = [os.environ.get("RETA_REFERENCE_PYTHON", sys.executable), str(REFERENCE)]
    if english:
        command.append("-language=english")
    env = os.environ.copy()
    env.update(
        {
            "PYTHONDONTWRITEBYTECODE": "1",
            "PYTHONHASHSEED": "0",
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


def _native_output(binary: Path, english: bool) -> bytes:
    command = [str(binary)]
    if english:
        command.append("-language=english")
    env = os.environ.copy()
    env.update({"RETA_ROOT": str(ROOT), "RETA_ASSET_DIR": str(ROOT / "assets")})
    return subprocess.run(
        command,
        cwd=ROOT,
        env=env,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--binary", type=Path, default=ROOT / "target/bin/generate-readme-native"
    )
    args = parser.parse_args()
    for english in (False, True):
        expected = _python_output(english)
        actual = _native_output(args.binary, english)
        if actual != expected:
            language = "english" if english else "german"
            raise SystemExit(
                f"{language} mismatch: python={len(expected)} bytes mojo={len(actual)} bytes"
            )
    print("generate4readme parity: 2/2 byte-identical under PYTHONHASHSEED=0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
