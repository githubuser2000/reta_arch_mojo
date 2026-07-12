#!/usr/bin/env python3
"""Normalize intentionally unordered fragments in generated-column snapshots.

Some legacy generated columns expose Python/PyPy set iteration order in text such
as ``pro dieser Zahl sind: 19, 3``.  The associated explanatory clauses may be
emitted in the same unstable order.  That order is not semantic.  Release checks
remain byte-exact for normal output, but may compare normalized snapshots for
these narrowly defined number lists and their directly attached explanations.
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


def _matching_parenthesis(text: str, opening: int) -> int | None:
    """Return the matching closing parenthesis for ``opening``."""

    depth = 0
    for index in range(opening, len(text)):
        char = text[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return index
    return None


def _split_top_level_explanation_clauses(body: str) -> list[str]:
    """Split legacy explanation clauses at top-level ``" , "`` separators."""

    clauses: list[str] = []
    start = 0
    depth = 0
    index = 0
    while index < len(body):
        char = body[index]
        if char == "(":
            depth += 1
        elif char == ")" and depth > 0:
            depth -= 1
        elif depth == 0 and body.startswith(" , ", index):
            clauses.append(body[start:index].strip())
            index += 3
            start = index
            continue
        index += 1
    clauses.append(body[start:].strip())
    return clauses


def _explanation_sort_key(clause: str) -> tuple[int, str]:
    """Sort clauses by their first referenced number, then deterministically."""

    numbers = re.findall(r"\d+", clause)
    first_number = int(numbers[0]) if numbers else sys.maxsize
    return first_number, clause.casefold()


def _normalize_attached_explanations(text: str) -> str:
    """Canonicalize explanations directly attached to known unordered lists."""

    chunks: list[str] = []
    cursor = 0

    for match in _NUMBER_LIST_AFTER_PREFIX.finditer(text):
        opening = match.end()
        while opening < len(text) and text[opening].isspace():
            opening += 1
        if opening >= len(text) or text[opening] != "(":
            continue

        closing = _matching_parenthesis(text, opening)
        if closing is None:
            continue

        body = text[opening + 1 : closing]
        clauses = _split_top_level_explanation_clauses(body)
        if len(clauses) < 2 or any(not clause for clause in clauses):
            continue

        canonical = "(" + " , ".join(sorted(clauses, key=_explanation_sort_key)) + ")"
        chunks.append(text[cursor:opening])
        chunks.append(canonical)
        cursor = closing + 1

    if not chunks:
        return text
    chunks.append(text[cursor:])
    return "".join(chunks)


def normalize_text(text: str) -> str:
    """Return text with only known unordered generated-column fragments sorted."""

    def replace_prefixed(match: re.Match[str]) -> str:
        numbers = _sorted_numbers(match.group("numbers"))
        return match.group("prefix") + ", ".join(str(number) for number in numbers)

    def replace_repeated_relation(match: re.Match[str]) -> str:
        word = match.group("word")
        numbers = _sorted_numbers(match.group("numbers"))
        return ", ".join(f"{word} {number}" for number in numbers)

    text = _NUMBER_LIST_AFTER_PREFIX.sub(replace_prefixed, text)
    text = _normalize_attached_explanations(text)
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
