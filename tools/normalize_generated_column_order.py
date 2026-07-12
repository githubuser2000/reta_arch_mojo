#!/usr/bin/env python3
"""Normalize intentionally unordered fragments in generated-column snapshots.

Some legacy generated columns expose Python/PyPy set iteration order in text such
as ``pro dieser Zahl sind: 19, 3``.  The associated explanatory clauses may be
emitted in the same unstable order.  That order is not semantic.  Release checks
remain byte-exact for normal output, but may compare normalized snapshots for
these narrowly defined number lists and their directly attached explanations.
"""
from __future__ import annotations

import csv
import io
import json
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



_FRACTIONAL_PAIR_PRODUCT = re.compile(
    r'"\s+\((?P<left_factor>[^()]*)\)\*\((?P<right_factor>[^()]*)\)\s+"'
)
_FRACTIONAL_PAIR_SEPARATOR = re.compile(
    r"\|\s*(?:außerdem|moreover):\s*", re.IGNORECASE
)


def _strip_generated_side_quotes(text: str) -> str:
    """Remove only the synthetic quote wrapper around one generated side."""

    text = text.strip()
    while text.startswith('"'):
        text = text[1:]
    while text.endswith('"'):
        text = text[:-1]
    return text


def _normalized_factor(text: str) -> str:
    return "".join(text.split())


def _canonical_fractional_pair(segment: str):
    """Return one unordered factor/text pair in deterministic orientation."""

    matches = list(_FRACTIONAL_PAIR_PRODUCT.finditer(segment))
    if len(matches) != 1:
        return None

    match = matches[0]
    left = (
        _normalized_factor(match.group("left_factor")),
        _strip_generated_side_quotes(segment[: match.start()]),
    )
    right = (
        _normalized_factor(match.group("right_factor")),
        _strip_generated_side_quotes(segment[match.end() :]),
    )
    first, second = sorted((left, right), key=lambda item: (item[0], item[1].casefold(), item[1]))
    return [list(first), list(second)]


def _canonical_fractional_cell(cell: str):
    """Canonicalize one generated fractional-motif cell as an unordered set."""

    segments = _FRACTIONAL_PAIR_SEPARATOR.split(cell)
    canonical = [_canonical_fractional_pair(segment) for segment in segments]
    if not canonical or any(item is None for item in canonical):
        return cell
    return {
        "fractional_pairs": sorted(
            canonical,
            key=lambda item: json.dumps(item, ensure_ascii=False, separators=(",", ":")),
        )
    }


def normalize_fractional_motif_star_csv(text: str) -> str:
    """Canonicalize only unordered pair order in fractional motif-star CSV."""

    rows = list(csv.reader(io.StringIO(text), delimiter=";"))
    canonical_rows = [
        [_canonical_fractional_cell(cell) for cell in row]
        for row in rows
    ]
    return json.dumps(
        canonical_rows, ensure_ascii=False, separators=(",", ":"), sort_keys=True
    ) + "\n"

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
    args = sys.argv[1:]
    fractional_motif_star = False
    if args and args[0] == "--fractional-motif-star":
        fractional_motif_star = True
        args = args[1:]
    if len(args) > 1:
        print(
            "usage: normalize_generated_column_order.py "
            "[--fractional-motif-star] [FILE]",
            file=sys.stderr,
        )
        return 2
    if args and args[0] != "-":
        with open(args[0], "r", encoding="utf-8") as handle:
            text = handle.read()
    else:
        text = sys.stdin.read()
    if fractional_motif_star:
        sys.stdout.write(normalize_fractional_motif_star_csv(text))
    else:
        sys.stdout.write(normalize_text(text))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
