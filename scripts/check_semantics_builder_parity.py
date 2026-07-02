#!/usr/bin/env python3
"""Compare the full native parameter semantics against the Python snapshot."""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "assets/parameter_semantics_reference.json"
PROBE = ROOT / "target/tests/semantics_builder_probe"


def expected_lines() -> list[str]:
    payload = json.loads(REFERENCE.read_text(encoding="utf-8"))
    lines: list[str] = []
    for mode in ("normal", "inverted"):
        section = payload[mode]
        lines.extend(
            [
                f"mode={mode}",
                f"matrix_entries={section['matrix_entries']}",
                f"para_main={section['para_main']}",
                f"para_dict={section['para_dict']}",
                f"reverse1={section['reverse1']}",
                f"reverse2={section['reverse2']}",
                f"simple_columns={section['simple_columns']}",
                "data_dict_sizes=" + ",".join(map(str, section["data_dict_sizes"])),
                "all_values_sizes=" + ",".join(map(str, section["all_values_sizes"])),
                f"fingerprint={section['fingerprint']}",
            ]
        )
    return lines


def main() -> int:
    if not PROBE.is_file():
        print(f"missing native semantics probe: {PROBE}", file=sys.stderr)
        return 2
    actual: list[str] = []
    for arguments in ((), ("--invert",)):
        actual.extend(
            subprocess.check_output([str(PROBE), *arguments], cwd=ROOT, text=True).splitlines()
        )
    expected = expected_lines()
    if actual != expected:
        from difflib import unified_diff

        print(
            "\n".join(
                unified_diff(
                    expected,
                    actual,
                    fromfile="python-reference",
                    tofile="mojo-native",
                    lineterm="",
                )
            ),
            file=sys.stderr,
        )
        return 1
    print(
        "parameter semantics parity: "
        f"{len(expected)}/{len(expected)} lines and both full fingerprints exact"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
