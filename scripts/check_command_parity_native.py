#!/usr/bin/env python3
"""Run the representative command matrix against the native Reta binary."""
from __future__ import annotations

import argparse
import csv
import hashlib
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets/command_parity.tsv"


def normalize_html(text: str) -> str:
    def sort_p4(match: re.Match[str]) -> str:
        values = [item for item in match.group(1).split(",") if item]
        try:
            values = [str(value) for value in sorted(int(item) for item in values)]
        except ValueError:
            return match.group(0)
        return "p4_" + ",".join(values)

    text = re.sub(r"p4_([0-9,]+)", sort_p4, text)
    return re.sub(r"\s+", " ", text).strip()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path, default=ROOT / "target/bin/reta-native")
    args = parser.parse_args()
    binary = args.binary.resolve()
    if not binary.is_file():
        raise SystemExit(f"native Reta binary missing: {binary}")

    env = dict(os.environ)
    runtime_proc = subprocess.run(
        [str(ROOT / "scripts/find_mojo_runtime.sh")],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=True,
    )
    runtime = Path(runtime_proc.stdout.strip())
    env["LD_LIBRARY_PATH"] = str(runtime) + (
        os.pathsep + env["LD_LIBRARY_PATH"] if env.get("LD_LIBRARY_PATH") else ""
    )
    env.setdefault("RETA_ROOT", str(ROOT))
    env.setdefault("RETA_REFERENCE_DIR", str(ROOT / "python_reference"))
    env.setdefault("RETA_DATA_DIR", str(ROOT / "python_reference/csv"))
    env.setdefault("RETA_ASSET_DIR", str(ROOT / "assets"))

    failures: list[str] = []
    with MANIFEST.open(newline="", encoding="utf-8") as handle:
        rows = csv.reader(handle, delimiter="\t")
        header = next(rows)
        if header[:4] != ["label", "mode", "asset", "sha256"]:
            raise SystemExit("invalid command parity manifest header")
        count = 0
        for row in rows:
            if not row:
                continue
            label, mode, asset_name, digest, *tokens = row
            expected_bytes = (ROOT / "assets/command_parity" / asset_name).read_bytes()
            if hashlib.sha256(expected_bytes).hexdigest() != digest:
                failures.append(f"{label}: fixture sha256 mismatch")
                continue
            proc = subprocess.run(
                [str(binary), *tokens],
                cwd=ROOT,
                env=env,
                capture_output=True,
                timeout=300,
            )
            if proc.returncode != 0:
                failures.append(
                    f"{label}: native rc {proc.returncode}: "
                    + proc.stderr.decode("utf-8", errors="replace").strip()
                )
                continue
            if proc.stderr:
                failures.append(
                    f"{label}: unexpected stderr: "
                    + proc.stderr.decode("utf-8", errors="replace").strip()
                )
                continue
            actual = proc.stdout.decode("utf-8")
            expected = expected_bytes.decode("utf-8")
            if mode == "html":
                actual = normalize_html(actual)
            if actual != expected:
                failures.append(
                    f"{label}: output mismatch ({len(actual)} != {len(expected)} chars)"
                )
            count += 1

    if failures:
        print("native command parity failed:")
        for failure in failures:
            print(f"  {failure}")
        return 1
    print(f"native command parity: {count} cases")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
