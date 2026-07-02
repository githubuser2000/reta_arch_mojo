#!/usr/bin/env python3
"""Compare complete Python and Mojo ``--alles`` HTML tables efficiently.

The parser keeps only three SHA-256 digests per cell (raw serialization,
decoded text and semantic normal form).  It therefore validates the complete
149k-cell table without retaining both 25 MiB HTML object trees in memory.
Semantic values are reparsed only for the few mismatching cells requested by
``--show``.
"""
from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
from dataclasses import dataclass, field
from html.parser import HTMLParser
from pathlib import Path
from typing import Iterable


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


class CompactTableParser(HTMLParser):
    """Compact equivalent of the historical ``TableParser``.

    Its deliberately simple row state mirrors the old parser exactly,
    including the handling of nested table markup inside cells.  This keeps
    the established 198-row/149356-cell contract while reducing retained
    per-cell data to three digests.
    """

    def __init__(self, capture_indices: Iterable[int] = ()) -> None:
        super().__init__(convert_charrefs=False)
        self.records = bytearray()
        self.shape: list[int] = []
        self.headers: list[str] = []
        self.captured: dict[int, str] = {}
        self.capture_indices = set(capture_indices)
        self.row: list[tuple[bytes, str, str]] | None = None
        self.cell: Cell | None = None

    def handle_starttag(self, tag: str, attrs) -> None:  # type: ignore[no-untyped-def]
        lower = tag.lower()
        if lower == "tr":
            self.row = []
        elif lower in {"td", "th"} and self.row is not None:
            self.cell = Cell()
        elif lower == "li" and self.cell is not None:
            self.cell.current_item = []
        if self.cell is not None:
            self.cell.raw.append(self.get_starttag_text() or f"<{tag}>")

    def handle_endtag(self, tag: str) -> None:
        lower = tag.lower()
        if self.cell is not None:
            self.cell.raw.append(f"</{tag}>")
        if lower == "li" and self.cell is not None and self.cell.current_item is not None:
            self.cell.items.append("".join(self.cell.current_item))
            self.cell.current_item = None
        elif lower in {"td", "th"} and self.cell is not None and self.row is not None:
            self.row.append(
                (
                    compact_record(self.cell),
                    normalize_text(decoded_text(self.cell)),
                    repr(semantic_value(self.cell))[:1000],
                )
            )
            self.cell = None
        elif lower == "tr" and self.row is not None:
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

    def _append_text(self, value: str) -> None:
        if self.cell is None:
            return
        self.cell.raw.append(value)
        self.cell.text.append(value)
        if self.cell.current_item is not None:
            self.cell.current_item.append(value)

    def handle_data(self, data: str) -> None:
        self._append_text(data)

    def handle_entityref(self, name: str) -> None:
        self._append_text(f"&{name};")

    def handle_charref(self, name: str) -> None:
        self._append_text(f"&#{name};")


def parse(path: Path, capture_indices: Iterable[int] = ()) -> ParsedTable:
    parser = CompactTableParser(capture_indices)
    with path.open(encoding="utf-8", errors="replace") as stream:
        while chunk := stream.read(1024 * 1024):
            parser.feed(chunk)
    parser.close()
    return ParsedTable(parser.records, parser.shape, parser.headers, parser.captured)


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


def main() -> int:
    cli = argparse.ArgumentParser()
    cli.add_argument("python_html", type=Path)
    cli.add_argument("mojo_html", type=Path)
    cli.add_argument("--show", type=int, default=5)
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
    raw_equal = text_equal = semantic_equal = 0
    mismatch_indices: list[int] = []
    expected_records = memoryview(python_table.records)
    actual_records = memoryview(mojo_table.records)
    for index in range(total):
        start = index * 96
        if expected_records[start : start + 32] == actual_records[start : start + 32]:
            raw_equal += 1
        if expected_records[start + 32 : start + 64] == actual_records[start + 32 : start + 64]:
            text_equal += 1
        if expected_records[start + 64 : start + 96] == actual_records[start + 64 : start + 96]:
            semantic_equal += 1
        elif len(mismatch_indices) < args.show:
            mismatch_indices.append(index)

    def metric(name: str, value: int) -> None:
        percent = 100.0 if total == 0 else 100.0 * value / total
        print(f"{name}={value}/{total} ({percent:.6f}%)")

    print(f"cells={total}")
    metric("raw_cells_equal", raw_equal)
    metric("decoded_text_cells_equal", text_equal)
    metric("semantic_cells_equal", semantic_equal)

    if mismatch_indices:
        expected_values = parse(args.python_html, mismatch_indices).captured
        actual_values = parse(args.mojo_html, mismatch_indices).captured
        for index in mismatch_indices:
            row_index, column_index = coordinate(python_table.shape, index)
            header = (
                python_table.headers[column_index]
                if column_index < len(python_table.headers)
                else ""
            )
            print(f"DIFF row={row_index} column={column_index} header={header!r}")
            print(f"  python={expected_values.get(index, '<missing>')}")
            print(f"  mojo={actual_values.get(index, '<missing>')}")

    if semantic_equal != total:
        print("SEMANTIC_MISMATCH")
        return 1
    print("SEMANTIC_PARITY")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
