from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "compare_middle_alx", ROOT / "tools" / "compare_middle_alx.py"
)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = MODULE
SPEC.loader.exec_module(MODULE)


def _write(path: Path, headers: list[tuple[str, str]], rows: list[list[str]]) -> None:
    pieces = ['<table id="bigtable">', '<tr>']
    for index, (classes, text) in enumerate(headers):
        pieces.append(f'<td class="z_0 r_{index} {classes}">{text}</td>')
    pieces.append('</tr>')
    for row in rows:
        pieces.append('<tr>')
        pieces.extend(f'<td>{cell}</td>' for cell in row)
        pieces.append('</tr>')
    pieces.append('</table>')
    path.write_text("\n".join(pieces), encoding="utf-8")


def test_column_order_and_class_token_order_are_ignored(tmp_path: Path) -> None:
    first = tmp_path / "first.alx"
    second = tmp_path / "second.alx"
    _write(first, [("p1_a p2_b", "A"), ("p1_c p2_d", "B")], [["1", "2"], ["3", "4"]])
    _write(second, [("p2_d p1_c", "B"), ("p2_b p1_a", "A")], [["2", "1"], ["4", "3"]])
    left = MODULE.canonicalize_table(MODULE.load_html(first))
    right = MODULE.canonicalize_table(MODULE.load_html(second))
    assert MODULE.compare_tables(left, right)["equal_ignoring_column_order"]


def test_cell_change_is_not_ignored(tmp_path: Path) -> None:
    first = tmp_path / "first.alx"
    second = tmp_path / "second.alx"
    _write(first, [("p1_a", "A")], [["1"]])
    _write(second, [("p1_a", "A")], [["2"]])
    left = MODULE.canonicalize_table(MODULE.load_html(first))
    right = MODULE.canonicalize_table(MODULE.load_html(second))
    assert not MODULE.compare_tables(left, right)["equal_ignoring_column_order"]
