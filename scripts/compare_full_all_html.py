#!/usr/bin/env python3
"""Compare complete Python and Mojo ``--alles`` HTML tables.

The report separates byte serialization, decoded cell text and a semantic HTML
normal form.  The semantic form preserves table shape and cell values, treats
``<ul>`` items as an unordered multiset, decodes entities, normalizes escaped
quotes and removes whitespace that is invisible before punctuation.
"""
from __future__ import annotations

import argparse
import hashlib
import html
import re
from dataclasses import dataclass, field
from html.parser import HTMLParser
from pathlib import Path


@dataclass
class Cell:
    raw: list[str] = field(default_factory=list)
    text: list[str] = field(default_factory=list)
    items: list[str] = field(default_factory=list)
    current_item: list[str] | None = None


class TableParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=False)
        self.rows: list[list[Cell]] = []
        self.row: list[Cell] | None = None
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
            self.row.append(self.cell)
            self.cell = None
        elif lower == "tr" and self.row is not None:
            self.rows.append(self.row)
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


def parse(path: Path) -> list[list[Cell]]:
    parser = TableParser()
    with path.open(encoding="utf-8", errors="replace") as stream:
        while chunk := stream.read(1024 * 1024):
            parser.feed(chunk)
    parser.close()
    return parser.rows


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def decoded_text(cell: Cell) -> str:
    return html.unescape("".join(cell.text))


def normalize_text(value: str) -> str:
    value = html.unescape(value).replace(r'\"', '"')
    value = re.sub(r"\s+", " ", value).strip()
    value = re.sub(r"\s+([,;:.!?\)])", r"\1", value)
    value = re.sub(r"([\(])\s+", r"\1", value)
    return value


def semantic_cell(cell: Cell) -> tuple[str, tuple[str, ...] | str]:
    if cell.items:
        return "list", tuple(sorted(normalize_text(item) for item in cell.items))
    return "text", normalize_text("".join(cell.text))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("python_html", type=Path)
    parser.add_argument("mojo_html", type=Path)
    parser.add_argument("--show", type=int, default=5, help="maximum semantic mismatches to print")
    args = parser.parse_args()

    python_rows = parse(args.python_html)
    mojo_rows = parse(args.mojo_html)
    print(f"python_sha256={sha256(args.python_html)}")
    print(f"mojo_sha256={sha256(args.mojo_html)}")
    print(f"python_bytes={args.python_html.stat().st_size}")
    print(f"mojo_bytes={args.mojo_html.stat().st_size}")
    print(f"rows={len(python_rows)}/{len(mojo_rows)}")

    if len(python_rows) != len(mojo_rows):
        print("STRUCTURE_MISMATCH: row counts differ")
        return 1
    python_shape = [len(row) for row in python_rows]
    mojo_shape = [len(row) for row in mojo_rows]
    if python_shape != mojo_shape:
        print("STRUCTURE_MISMATCH: per-row cell counts differ")
        return 1

    total = sum(python_shape)
    raw_equal = 0
    text_equal = 0
    semantic_equal = 0
    semantic_differences: list[tuple[int, int, str, str, str]] = []
    for row_index, (python_row, mojo_row) in enumerate(zip(python_rows, mojo_rows)):
        for column_index, (python_cell, mojo_cell) in enumerate(zip(python_row, mojo_row)):
            if "".join(python_cell.raw) == "".join(mojo_cell.raw):
                raw_equal += 1
            if decoded_text(python_cell) == decoded_text(mojo_cell):
                text_equal += 1
            python_semantic = semantic_cell(python_cell)
            mojo_semantic = semantic_cell(mojo_cell)
            if python_semantic == mojo_semantic:
                semantic_equal += 1
            elif len(semantic_differences) < args.show:
                header = normalize_text(decoded_text(python_rows[0][column_index]))
                semantic_differences.append(
                    (
                        row_index,
                        column_index,
                        header,
                        repr(python_semantic)[:1000],
                        repr(mojo_semantic)[:1000],
                    )
                )

    def metric(name: str, value: int) -> None:
        print(f"{name}={value}/{total} ({100.0 * value / total:.6f}%)")

    print(f"cells={total}")
    metric("raw_cells_equal", raw_equal)
    metric("decoded_text_cells_equal", text_equal)
    metric("semantic_cells_equal", semantic_equal)
    for row_index, column_index, header, python_value, mojo_value in semantic_differences:
        print(f"DIFF row={row_index} column={column_index} header={header!r}")
        print(f"  python={python_value}")
        print(f"  mojo={mojo_value}")

    if semantic_equal != total:
        print("SEMANTIC_MISMATCH")
        return 1
    print("SEMANTIC_PARITY")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
