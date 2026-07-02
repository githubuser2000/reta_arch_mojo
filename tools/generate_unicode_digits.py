#!/usr/bin/env python3
"""Generate the frozen Mojo Unicode-digit lookup table.

The default path is deterministic and reads the committed TSV snapshot.  Use
``--refresh-from-python`` only when deliberately adopting the running Python
interpreter's Unicode database, then review the resulting compatibility change.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
RANGES_PATH = ROOT / "assets" / "unicode_digit_ranges.tsv"
OUTPUT_PATH = ROOT / "src" / "reta_mojo" / "unicode_digits.mojo"


def ranges_from_python() -> list[tuple[int, int]]:
    points = [codepoint for codepoint in range(sys.maxunicode + 1) if chr(codepoint).isdigit()]
    result: list[tuple[int, int]] = []
    if not points:
        return result
    start = previous = points[0]
    for codepoint in points[1:]:
        if codepoint == previous + 1:
            previous = codepoint
            continue
        result.append((start, previous))
        start = previous = codepoint
    result.append((start, previous))
    return result


def load_ranges() -> list[tuple[int, int]]:
    result: list[tuple[int, int]] = []
    for line in RANGES_PATH.read_text(encoding="utf-8").splitlines():
        if not line or line.startswith("#") or line == "start\tend":
            continue
        start, end = line.split("\t")
        result.append((int(start), int(end)))
    return result


def save_ranges(ranges: list[tuple[int, int]]) -> None:
    count = sum(end - start + 1 for start, end in ranges)
    text = (
        "# Frozen Python str.isdigit() ranges\n"
        f"# Captured with {sys.implementation.name} {sys.version_info.major}.{sys.version_info.minor}; "
        f"{len(ranges)} ranges; {count} codepoints.\n"
        "start\tend\n"
        + "".join(f"{start}\t{end}\n" for start, end in ranges)
    )
    RANGES_PATH.write_text(text, encoding="utf-8")


def render(ranges: list[tuple[int, int]]) -> str:
    count = sum(end - start + 1 for start, end in ranges)
    pairs = "\n".join(f"        IntPair({start}, {end})," for start, end in ranges)
    return f'''"""Generated Unicode ``str.isdigit`` ranges for Python-reference parity.

Generated from ``assets/unicode_digit_ranges.tsv``.  The frozen snapshot has
{len(ranges)} ranges and {count} codepoints; regenerate it deliberately with
``tools/generate_unicode_digits.py --refresh-from-python``.
"""

from std.collections import List
from .types import IntPair


comptime UNICODE_DIGIT_RANGE_COUNT = {len(ranges)}
comptime UNICODE_DIGIT_CODEPOINT_COUNT = {count}


def unicode_digit_ranges() -> List[IntPair]:
    return [
{pairs}
    ]


def is_unicode_digit_codepoint(value: Int) -> Bool:
    var ranges = unicode_digit_ranges()
    for index in range(len(ranges)):
        if value >= ranges[index].first and value <= ranges[index].second:
            return True
    return False


def has_unicode_digit(text: String) -> Bool:
    for codepoint in text.codepoints():
        if is_unicode_digit_codepoint(Int(codepoint)):
            return True
    return False
'''


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--refresh-from-python", action="store_true")
    args = parser.parse_args()

    if args.refresh_from_python:
        save_ranges(ranges_from_python())
    ranges = load_ranges()
    generated = render(ranges)
    if args.check:
        if not OUTPUT_PATH.exists() or OUTPUT_PATH.read_text(encoding="utf-8") != generated:
            print(f"out of date: {OUTPUT_PATH}", file=sys.stderr)
            return 1
        print(
            f"unicode digit table: {len(ranges)} ranges, "
            f"{sum(end - start + 1 for start, end in ranges)} codepoints"
        )
        return 0
    OUTPUT_PATH.write_text(generated, encoding="utf-8")
    print(f"generated {OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
