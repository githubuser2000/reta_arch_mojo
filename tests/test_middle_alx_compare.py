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


def test_tar_container_digest_is_distinct_but_payload_is_equal(tmp_path: Path) -> None:
    import hashlib
    import tarfile

    raw = tmp_path / "raw.alx"
    wrapped = tmp_path / "wrapped.alx"
    _write(raw, [("p1_a", "A"), ("p1_b", "B")], [["1", "2"]])
    with tarfile.open(wrapped, "w") as archive:
        archive.add(raw, arcname="middle_pypy3_arch.alx")

    raw_loaded = MODULE.load_html(raw)
    wrapped_loaded = MODULE.load_html(wrapped)
    assert raw_loaded.container_kind == "html"
    assert wrapped_loaded.container_kind == "tar"
    assert wrapped_loaded.member == "middle_pypy3_arch.alx"
    assert raw_loaded.container_md5 != wrapped_loaded.container_md5
    assert raw_loaded.payload_md5 == wrapped_loaded.payload_md5
    assert raw_loaded.payload_sha256 == wrapped_loaded.payload_sha256
    assert raw_loaded.payload_md5 == hashlib.md5(raw.read_bytes()).hexdigest()

    left = MODULE.canonicalize_table(raw_loaded)
    right = MODULE.canonicalize_table(wrapped_loaded)
    result = MODULE.compare_tables(left, right)
    assert result["equal_ignoring_column_order"]
    assert result["first"]["container_md5"] != result["second"]["container_md5"]
    assert result["first"]["payload_md5"] == result["second"]["payload_md5"]
