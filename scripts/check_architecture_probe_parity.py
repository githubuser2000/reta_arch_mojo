#!/usr/bin/env python3
"""Validate the native architecture probe against generated reference assets."""
from __future__ import annotations

import argparse
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "assets" / "architecture_probe"
REFERENCE = ROOT / "python_reference" / "reta_architecture_probe_py.py"
TOKEN = "@@RETA_REFERENCE_ROOT@@"
HOME_TOKEN = "@@RETA_HOME@@"


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


def command_from_filename(filename: str) -> str:
    if filename.endswith(".json"):
        return filename[:-5]
    if filename.endswith(".md"):
        return filename[:-3]
    raise ValueError(filename)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path, required=True)
    parser.add_argument("--python", default=os.environ.get("RETA_REFERENCE_PYTHON", "python3"))
    parser.add_argument("--skip-package-integrity", action="store_true")
    args = parser.parse_args()

    run([args.python, "tools/generate_architecture_probe_assets.py", "--check"])
    binary = args.binary.resolve()
    env = {
        **os.environ,
        "PYTHONHASHSEED": "0",
        "PYTHONDONTWRITEBYTECODE": "1",
        "RETA_ROOT": str(ROOT),
        "RETA_REFERENCE_DIR": str(ROOT / "python_reference"),
        "RETA_ASSET_DIR": str(ROOT / "assets"),
    }

    lines = (ASSET_DIR / "manifest.tsv").read_text(encoding="utf-8").splitlines()
    checked = 0
    for line in lines:
        filename = line.split("\t", 1)[0]
        command = command_from_filename(filename)
        expected = (ASSET_DIR / filename).read_text(encoding="utf-8").replace(
            TOKEN, str(ROOT / "python_reference")
        ).replace(HOME_TOKEN, env.get("HOME", ""))
        actual = run([str(binary), command], env=env)
        if actual != expected:
            raise AssertionError(
                f"architecture probe mismatch for {command!r}\n"
                f"expected length={len(expected)} actual length={len(actual)}"
            )
        checked += 1

    if not args.skip_package_integrity:
        expected = run([args.python, str(REFERENCE), "package-integrity-json"], env=env)
        actual = run([str(binary), "package-integrity-json"], env=env)
        if actual != expected:
            raise AssertionError(
                "architecture probe mismatch for 'package-integrity-json'\n"
                f"expected={expected[:500]!r}\nactual={actual[:500]!r}"
            )
        checked += 1

    print(f"architecture probe parity: {checked} cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
