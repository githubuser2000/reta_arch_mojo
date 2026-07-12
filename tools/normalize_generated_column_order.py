#!/usr/bin/env python3
"""Normalize intentionally unordered number lists in generated-column snapshots.

Some legacy generated columns expose Python/PyPy set iteration order in text such
as "pro dieser Zahl sind: 19, 3".  That order is not semantic.  Release checks
should still be byte-exact for normal output, but they may compare normalized
snapshots for these known unordered number lists.
"""
from __future__ import annotations

import re
import sys

_NUMBER_LIST_AFTER_PREFIX = re.compile(
    r"(?P<prefix>"
    r"(?:pro dieser Zahl sind:|contra dieser Zahl sind:|"
    r"per this number are:|contra this number are:)"
    r"\s*)"
    r"(?P<numbers>\d+(?:,\s*\d+)+)"
)

_REPEATED_RELATION_LIST = re.compile(
    r"\b(?P<word>gegen|against|pro|per)\s+"
    r"(?P<numbers>\d+(?:,\s*(?P=word)\s+\d+)+)"
)


def _sorted_numbers(numbers_text: str) -> list[int]:
    return sorted(int(part) for part in re.findall(r"\d+", numbers_text))


def normalize_text(text: str) -> str:
    """Return text with only known unordered generated-column lists sorted."""

    def replace_prefixed(match: re.Match[str]) -> str:
        numbers = _sorted_numbers(match.group("numbers"))
        return match.group("prefix") + ", ".join(str(number) for number in numbers)

    def replace_repeated_relation(match: re.Match[str]) -> str:
        word = match.group("word")
        numbers = _sorted_numbers(match.group("numbers"))
        return ", ".join(f"{word} {number}" for number in numbers)

    text = _NUMBER_LIST_AFTER_PREFIX.sub(replace_prefixed, text)
    text = _REPEATED_RELATION_LIST.sub(replace_repeated_relation, text)
    return text


def main() -> int:
    if len(sys.argv) > 2:
        print("usage: normalize_generated_column_order.py [FILE]", file=sys.stderr)
        return 2
    if len(sys.argv) == 2 and sys.argv[1] != "-":
        with open(sys.argv[1], "r", encoding="utf-8") as handle:
            text = handle.read()
    else:
        text = sys.stdin.read()
    sys.stdout.write(normalize_text(text))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
