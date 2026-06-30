#!/usr/bin/env python3
"""Emit the Python reference row-preparation fixture for Stage 11j."""
from __future__ import annotations

from reta_architecture.table_preparation import prepare_row_cells
from reta_architecture.table_wrapping import width_for_row


class ReferencePrepare:
    def __init__(self) -> None:
        self.rowsAsNumbers = {0, 2}
        self.shellRowsAmount = 80
        self.breiten = [4, 3]
        self.textwidth = 21
        self.religionNumbers: list[int] = []

    def setWidth(self, row_to_display: int, combi_rows: int = 0) -> int:
        return width_for_row(self, row_to_display, combi_rows)

    @staticmethod
    def wrapping(text: str, width: int):
        if width == 0 or len(text) <= width:
            return None
        return tuple(text[index : index + width] for index in range(0, len(text), width))


def main() -> None:
    rows = [
        (4, ["abcdef", "ignored", "xyzq"]),
        (1, ["  hi  ", "ignored", "終終終終"]),
        (3, ["12345678", "ignored", "z"]),
        (2, ["xy", "ignored", "uvw"]),
    ]
    prepare = ReferencePrepare()
    prepared: list[tuple[int, list[list[str]]]] = []
    for index, cells in rows:
        result = prepare_row_cells(
            prepare,
            0,
            {},
            3,
            cells,
            ({}, {}),
            None,
            True,
            None,
            {0, 2},
            index,
            0,
        )
        prepared.append((index, result))
    for index, row in sorted(prepared):
        print(f"{index}:" + "|".join("~".join(cell) for cell in row))


if __name__ == "__main__":
    main()
