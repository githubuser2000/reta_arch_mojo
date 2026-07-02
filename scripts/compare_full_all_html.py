#!/usr/bin/env python3
"""Compare complete Python and Mojo ``--alles`` HTML tables efficiently.

The historical table contains nested ``<tr>``/``<td>`` fragments inside cells.
The original verifier used :class:`html.parser.HTMLParser`; it was semantically
correct but could spend minutes in its generic tokenizer.  This verifier uses a
small scanner for exactly the tags and entities relevant to the table while
preserving the old row-reset behaviour byte for byte.

Only three SHA-256 digests per cell are retained: raw serialization, decoded
text and semantic normal form.  The complete 149k-cell table therefore remains
bounded in memory and normally compares in a few seconds.
"""
from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
from collections import Counter, defaultdict, deque
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable


_TOKEN = re.compile(
    r"<[^>]*>|&(?:#[xX][0-9A-Fa-f]+|#\d+|[A-Za-z][A-Za-z0-9]+);",
    re.DOTALL,
)
_TAG_NAME = re.compile(r"^<\s*(/?)\s*([A-Za-z0-9]+)")


@dataclass
class Cell:
    raw: list[str] = field(default_factory=list)
    text: list[str] = field(default_factory=list)
    items: list[str] = field(default_factory=list)
    current_item: list[str] | None = None


@dataclass
class ParsedTable:
    records: bytearray
    shape: list[int]
    headers: list[str]
    captured: dict[int, str]


def normalize_text(value: str) -> str:
    value = html.unescape(value).replace(r'\"', '"')
    value = re.sub(r"\s+", " ", value).strip()
    value = re.sub(r"\s+([,;:.!?\)])", r"\1", value)
    value = re.sub(r"([\(])\s+", r"\1", value)
    return value


def decoded_text(cell: Cell) -> str:
    return html.unescape("".join(cell.text))


def semantic_value(cell: Cell) -> tuple[str, tuple[str, ...] | str]:
    if cell.items:
        return "list", tuple(sorted(normalize_text(item) for item in cell.items))
    return "text", normalize_text("".join(cell.text))


def _digest(value: str) -> bytes:
    return hashlib.sha256(value.encode("utf-8", errors="replace")).digest()


def compact_record(cell: Cell) -> bytes:
    raw = "".join(cell.raw)
    decoded = decoded_text(cell)
    semantic = json.dumps(
        semantic_value(cell), ensure_ascii=False, separators=(",", ":")
    )
    return _digest(raw) + _digest(decoded) + _digest(semantic)


class FastTableScanner:
    """Specialized equivalent of the previous ``CompactTableParser``.

    Starting a nested ``tr`` replaces the active row, exactly as the former
    ``HTMLParser`` callbacks did.  That detail yields the established
    198-row/149356-cell shape rather than treating embedded formatting tables
    as ordinary outer-cell markup.
    """

    def __init__(self, capture_indices: Iterable[int] = ()) -> None:
        self.records = bytearray()
        self.shape: list[int] = []
        self.headers: list[str] = []
        self.captured: dict[int, str] = {}
        self.capture_indices = set(capture_indices)
        self.row: list[tuple[bytes, str, str]] | None = None
        self.cell: Cell | None = None

    def append_text(self, value: str) -> None:
        if self.cell is None:
            return
        self.cell.raw.append(value)
        self.cell.text.append(value)
        if self.cell.current_item is not None:
            self.cell.current_item.append(value)

    def start_tag(self, tag: str, token: str) -> None:
        if tag == "tr":
            self.row = []
        elif tag in {"td", "th"} and self.row is not None:
            self.cell = Cell()
        elif tag == "li" and self.cell is not None:
            self.cell.current_item = []
        if self.cell is not None:
            self.cell.raw.append(token)

    def end_tag(self, tag: str) -> None:
        if self.cell is not None:
            self.cell.raw.append(f"</{tag}>")
        if tag == "li" and self.cell is not None and self.cell.current_item is not None:
            self.cell.items.append("".join(self.cell.current_item))
            self.cell.current_item = None
        elif tag in {"td", "th"} and self.cell is not None and self.row is not None:
            self.row.append(
                (
                    compact_record(self.cell),
                    normalize_text(decoded_text(self.cell)),
                    repr(semantic_value(self.cell))[:1000],
                )
            )
            self.cell = None
        elif tag == "tr" and self.row is not None:
            base = len(self.records) // 96
            if not self.shape:
                self.headers = [header for _, header, _ in self.row]
            for local_index, (record, _, display) in enumerate(self.row):
                flat_index = base + local_index
                self.records.extend(record)
                if flat_index in self.capture_indices:
                    self.captured[flat_index] = display
            self.shape.append(len(self.row))
            self.row = None

    def feed(self, source: str) -> None:
        position = 0
        for match in _TOKEN.finditer(source):
            if match.start() > position:
                self.append_text(source[position : match.start()])
            token = match.group(0)
            position = match.end()
            if token.startswith("&"):
                self.append_text(token)
                continue
            parsed = _TAG_NAME.match(token)
            if parsed is None:
                # HTMLParser ignored comments and declarations because the old
                # verifier did not override their callbacks.
                continue
            closing = bool(parsed.group(1))
            tag = parsed.group(2).lower()
            if closing:
                self.end_tag(tag)
            else:
                self.start_tag(tag, token)
                if token.rstrip().endswith("/>"):
                    self.end_tag(tag)
        if position < len(source):
            self.append_text(source[position:])


def parse(path: Path, capture_indices: Iterable[int] = ()) -> ParsedTable:
    scanner = FastTableScanner(capture_indices)
    scanner.feed(path.read_text(encoding="utf-8", errors="replace"))
    return ParsedTable(
        scanner.records, scanner.shape, scanner.headers, scanner.captured
    )


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def coordinate(shape: list[int], flat_index: int) -> tuple[int, int]:
    offset = 0
    for row_index, width in enumerate(shape):
        if flat_index < offset + width:
            return row_index, flat_index - offset
        offset += width
    raise IndexError(flat_index)


def occurrence_mapping(expected: list[str], actual: list[str]) -> list[int] | None:
    """Map each expected header occurrence to the matching actual occurrence."""
    if Counter(expected) != Counter(actual):
        return None
    locations: dict[str, deque[int]] = defaultdict(deque)
    for index, header in enumerate(actual):
        locations[header].append(index)
    return [locations[header].popleft() for header in expected]


def is_hash_unstable_header(header: str) -> bool:
    """Columns whose Python contents/order depend on an uncontrolled hash seed.

    The original Python implementation builds these ten columns through sets
    whose iteration order influences either the physical column order or a
    truncated generated item stream.  A reference produced without an explicit
    ``PYTHONHASHSEED`` is therefore not reproducible byte-for-byte between
    processes.  All other columns remain strict after occurrence-based header
    alignment.
    """
    if (
        header.startswith("generierte Multiplikationen ")
        and header.endswith(", mit Faktoren aus gebrochen-rationalen Zahlen")
    ):
        return True
    return header == (
        "Gegen / pro: Nach Rechenregeln auf Primzahlkreuz und Vielfachern "
        "von Primzahlen"
    )


def _metric(name: str, value: int, total: int) -> None:
    percent = 100.0 if total == 0 else 100.0 * value / total
    print(f"{name}={value}/{total} ({percent:.6f}%)")


def main() -> int:
    cli = argparse.ArgumentParser()
    cli.add_argument("python_html", type=Path)
    cli.add_argument("mojo_html", type=Path)
    cli.add_argument("--show", type=int, default=5)
    cli.add_argument(
        "--allow-unseeded-python",
        action="store_true",
        help=(
            "align duplicate-aware columns by header and exclude the ten "
            "known CPython hash-order-dependent generated columns"
        ),
    )
    args = cli.parse_args()

    python_table = parse(args.python_html)
    mojo_table = parse(args.mojo_html)
    print(f"python_sha256={sha256(args.python_html)}")
    print(f"mojo_sha256={sha256(args.mojo_html)}")
    print(f"python_bytes={args.python_html.stat().st_size}")
    print(f"mojo_bytes={args.mojo_html.stat().st_size}")
    print(f"rows={len(python_table.shape)}/{len(mojo_table.shape)}")

    if python_table.shape != mojo_table.shape:
        if len(python_table.shape) != len(mojo_table.shape):
            print("STRUCTURE_MISMATCH: row counts differ")
        else:
            print("STRUCTURE_MISMATCH: per-row cell counts differ")
        return 1
    if len(python_table.records) != len(mojo_table.records):
        print("STRUCTURE_MISMATCH: flat cell counts differ")
        return 1

    total = len(python_table.records) // 96
    raw_equal = text_equal = positional_semantic_equal = 0
    expected_records = memoryview(python_table.records)
    actual_records = memoryview(mojo_table.records)
    positional_mismatches: list[tuple[int, int]] = []
    for index in range(total):
        start = index * 96
        if expected_records[start : start + 32] == actual_records[start : start + 32]:
            raw_equal += 1
        if expected_records[start + 32 : start + 64] == actual_records[start + 32 : start + 64]:
            text_equal += 1
        if expected_records[start + 64 : start + 96] == actual_records[start + 64 : start + 96]:
            positional_semantic_equal += 1
        elif len(positional_mismatches) < args.show:
            positional_mismatches.append((index, index))

    print(f"cells={total}")
    _metric("raw_cells_equal", raw_equal, total)
    _metric("decoded_text_cells_equal", text_equal, total)
    _metric("semantic_cells_equal", positional_semantic_equal, total)

    mapping = occurrence_mapping(python_table.headers, mojo_table.headers)
    if mapping is None:
        print("header_multiset_equal=false")
        if args.allow_unseeded_python:
            print("UNSEEDED_REFERENCE_HEADER_MISMATCH")
            return 1
    else:
        print("header_multiset_equal=true")
        print(
            "header_reordered_columns="
            + str(sum(index != mapped for index, mapped in enumerate(mapping)))
        )

    aligned_equal = 0
    aligned_total = 0
    stable_equal = 0
    stable_total = 0
    excluded_cells = 0
    unstable_mismatches = 0
    stable_mismatches: list[tuple[int, int, int, int]] = []
    expected_offset = actual_offset = 0
    header_width = len(python_table.headers)
    actual_header_width = len(mojo_table.headers)

    if mapping is not None:
        for row_index, (expected_width, actual_width) in enumerate(
            zip(python_table.shape, mojo_table.shape)
        ):
            full_table_row = (
                expected_width == header_width
                and actual_width == actual_header_width
            )
            pairs = (
                enumerate(mapping)
                if full_table_row
                else ((column, column) for column in range(expected_width))
            )
            for expected_column, actual_column in pairs:
                expected_flat = expected_offset + expected_column
                actual_flat = actual_offset + actual_column
                expected_start = expected_flat * 96 + 64
                actual_start = actual_flat * 96 + 64
                equal = (
                    expected_records[expected_start : expected_start + 32]
                    == actual_records[actual_start : actual_start + 32]
                )
                aligned_total += 1
                aligned_equal += int(equal)
                unstable = (
                    full_table_row
                    and is_hash_unstable_header(
                        python_table.headers[expected_column]
                    )
                )
                if unstable:
                    excluded_cells += 1
                    unstable_mismatches += int(not equal)
                    continue
                stable_total += 1
                stable_equal += int(equal)
                if not equal and len(stable_mismatches) < args.show:
                    stable_mismatches.append(
                        (
                            expected_flat,
                            actual_flat,
                            row_index,
                            expected_column,
                        )
                    )
            expected_offset += expected_width
            actual_offset += actual_width

        _metric("header_aligned_semantic_cells_equal", aligned_equal, aligned_total)
        print(f"hash_unstable_cells_excluded={excluded_cells}")
        print(f"hash_unstable_cell_mismatches={unstable_mismatches}")
        _metric("stable_semantic_cells_equal", stable_equal, stable_total)

    mismatches = stable_mismatches if args.allow_unseeded_python else [
        (expected, actual, *coordinate(python_table.shape, expected))
        for expected, actual in positional_mismatches
    ]
    if mismatches:
        expected_indices = [item[0] for item in mismatches]
        actual_indices = [item[1] for item in mismatches]
        expected_values = parse(args.python_html, expected_indices).captured
        actual_values = parse(args.mojo_html, actual_indices).captured
        for expected_flat, actual_flat, row_index, column_index in mismatches:
            header = (
                python_table.headers[column_index]
                if column_index < len(python_table.headers)
                else ""
            )
            print(
                f"DIFF row={row_index} column={column_index} "
                f"header={header!r}"
            )
            print(f"  python={expected_values.get(expected_flat, '<missing>')}")
            print(f"  mojo={actual_values.get(actual_flat, '<missing>')}")

    if args.allow_unseeded_python:
        if mapping is None or stable_equal != stable_total:
            print("UNSEEDED_REFERENCE_MISMATCH")
            return 1
        print("UNSEEDED_REFERENCE_PARITY")
        return 0

    if positional_semantic_equal != total:
        print("SEMANTIC_MISMATCH")
        return 1
    print("SEMANTIC_PARITY")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
