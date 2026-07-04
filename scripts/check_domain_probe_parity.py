#!/usr/bin/env python3
"""Compare the native domain-probe core with the Python reference CLI."""
from __future__ import annotations

import argparse
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference/reta_domain_probe_py.py"
ASSET_DIR = ROOT / "assets" / "architecture_probe"
REFERENCE_TOKEN = "@@RETA_REFERENCE_ROOT@@"
HOME_TOKEN = "@@RETA_HOME@@"

CASES = [
    ("mains",),
    ("params", "religionen"),
    ("pairs", "religionen"),
    ("pairs-json", "religionen"),
    ("main-json", "religionen"),
    ("pair", "religionen", "sternpolygon"),
    ("pair-json", "religionen", "sternpolygon"),
    ("main-columns", "religionen"),
    ("column", "4"),
    ("column-json", "4"),
    ("reverse", "4"),
    ("html-json", "4"),
    ("html-all-json",),
    ("pair-html-json", "religionen", "sternpolygon"),
    ("schema-json",),
    ("architecture-json",),
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
    parity_env = {
        **os.environ,
        "PYTHONHASHSEED": "0",
        "PYTHONDONTWRITEBYTECODE": "1",
        "RETA_ROOT": str(ROOT),
    }
    run(
        [args.python, "tools/generate_architecture_probe_assets.py", "--check"],
        env=parity_env,
    )
    for case in CASES:
        if case == ("architecture-json",):
            expected = (ASSET_DIR / "snapshot-json.json").read_text(encoding="utf-8")
            expected = expected.replace(
                REFERENCE_TOKEN, str(ROOT / "python_reference")
            ).replace(HOME_TOKEN, parity_env.get("HOME", ""))
        else:
            expected = run([args.python, str(REFERENCE), *case], env=parity_env)
        actual = run([str(binary), *case], env=parity_env)
        if actual != expected:
            raise AssertionError(
                f"domain probe mismatch for {case!r}\n"
                f"expected={expected!r}\nactual={actual!r}"
            )
    print(f"domain probe parity: {len(CASES)} cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
