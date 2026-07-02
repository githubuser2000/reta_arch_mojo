#!/usr/bin/env python3
"""Compare the native domain-probe core with the Python reference CLI."""
from __future__ import annotations

import argparse
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/reta_domain_probe_py.py"

CASES = [
    ("pair", "religionen", "sternpolygon"),
    ("pair-json", "religionen", "sternpolygon"),
    ("main-columns", "religionen"),
    ("pairs-json", "religionen"),
    ("reverse", "4"),
]


def run(command: list[str], env: dict[str, str] | None = None) -> str:
    result = subprocess.run(
        command,
        cwd=ROOT,
        env=env,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return result.stdout


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--python", default=os.environ.get("RETA_REFERENCE_PYTHON", "python3"))
    args = parser.parse_args()
    binary = args.binary.resolve()
    for case in CASES:
        expected = run([args.python, str(REFERENCE), *case])
        actual = run([str(binary), *case], env={**os.environ, "RETA_ROOT": str(ROOT)})
        if actual != expected:
            raise AssertionError(
                f"domain probe mismatch for {case!r}\n"
                f"expected={expected!r}\nactual={actual!r}"
            )
    print(f"domain probe parity: {len(CASES)} cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
