#!/usr/bin/env python3
"""Generate CPython-compatible iteration order for all meta request subsets.

The legacy runtime stores the twelve (metavariable, side) pairs in a built-in
``set`` and then converts it to ``list``.  Its order is deterministic for these
integer tuples but depends on the set table size, so one global rank is not
sufficient.  This asset records the exact Python 3 iteration order for every
non-empty subset without requiring Python in the native runtime.
"""
from __future__ import annotations

import argparse
from pathlib import Path

PAIRS = tuple((metavariable, side) for metavariable in range(2, 8) for side in range(2))


def generate() -> str:
    lines: list[str] = []
    for mask in range(1, 1 << len(PAIRS)):
        selected = {pair for bit, pair in enumerate(PAIRS) if mask & (1 << bit)}
        payload = ";".join(f"{metavariable},{side}" for metavariable, side in selected)
        lines.append(f"{mask}\t{payload}")
    return "\n".join(lines) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="assets/meta_request_order.tsv")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    path = Path(args.output)
    content = generate()
    if args.check:
        if not path.exists() or path.read_text(encoding="utf-8") != content:
            raise SystemExit(f"stale generated asset: {path}")
        print(f"meta request order asset is current: {path}")
        return 0
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print(f"wrote {len(PAIRS)} pairs / {(1 << len(PAIRS)) - 1} subset orders to {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
