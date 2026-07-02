#!/usr/bin/env python3
"""Compare large reta HTML tables without depending on column order.

The ``bigtable`` is canonicalized as a multiset of complete column vectors.
Physical column positions (``r_<n>`` / ``z_<n>`` class tokens), HTML attribute
order and class-token order are ignored.  Cell contents, nested markup, row
order and all non-positional metadata remain significant.

Input may be HTML directly, tar/tar.xz, or a tar stream accidentally named
``*.alx``.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import tarfile
from collections import Counter, defaultdict
from dataclasses import dataclass
from html.parser import HTMLParser
from pathlib import Path
from typing import Iterable

POSITION_CLASS_RE = re.compile(r"^[rz]_\d+$")
WS_RE = re.compile(r"\s+")


@dataclass(frozen=True)
class LoadedHtml:
    source: str
    member: str | None
    container_kind: str
    container_size: int
    container_md5: str
    container_sha256: str
    payload_size: int
    payload_md5: str
    payload_sha256: str
    text: str


@dataclass(frozen=True)
class CanonicalTable:
    source: str
    member: str | None
    container_kind: str
    container_size: int
    container_md5: str
    container_sha256: str
    payload_size: int
    payload_md5: str
    payload_sha256: str
    rows: int
    columns: int
    column_hashes: tuple[str, ...]
    table_hash: str
    headers_by_hash: dict[str, tuple[str, ...]]


def _regular_members(archive: tarfile.TarFile) -> list[tarfile.TarInfo]:
    members = [member for member in archive.getmembers() if member.isfile()]
    preferred = [
        member
        for member in members
        if Path(member.name).suffix.lower() in {".alx", ".html", ".htm"}
    ]
    return preferred or members


def _digest_bytes(data: bytes) -> tuple[str, str]:
    return hashlib.md5(data).hexdigest(), hashlib.sha256(data).hexdigest()


def load_html(path: Path) -> LoadedHtml:
    path = path.resolve()
    container = path.read_bytes()
    container_md5, container_sha256 = _digest_bytes(container)
    try:
        is_tar = tarfile.is_tarfile(path)
    except OSError:
        is_tar = False
    if is_tar:
        with tarfile.open(path, mode="r:*") as archive:
            members = _regular_members(archive)
            if len(members) != 1:
                names = ", ".join(member.name for member in members[:10])
                raise ValueError(
                    f"{path} enthält {len(members)} mögliche HTML-Dateien; "
                    f"erwartet wird genau eine: {names}"
                )
            member = members[0]
            handle = archive.extractfile(member)
            if handle is None:
                raise ValueError(f"Tar-Mitglied ist nicht lesbar: {member.name}")
            payload = handle.read()
            payload_md5, payload_sha256 = _digest_bytes(payload)
            return LoadedHtml(
                str(path),
                member.name,
                "tar",
                len(container),
                container_md5,
                container_sha256,
                len(payload),
                payload_md5,
                payload_sha256,
                payload.decode("utf-8"),
            )
    payload_md5, payload_sha256 = _digest_bytes(container)
    return LoadedHtml(
        str(path),
        None,
        "html",
        len(container),
        container_md5,
        container_sha256,
        len(container),
        payload_md5,
        payload_sha256,
        container.decode("utf-8"),
    )


def _length_prefixed(data: bytes) -> bytes:
    return len(data).to_bytes(8, "big") + data


def _normalized_attrs(
    attrs: list[tuple[str, str | None]], *, remove_positions: bool = False
) -> str:
    normalized: list[tuple[str, str]] = []
    for raw_key, raw_value in attrs:
        key = raw_key.lower()
        value = (raw_value or "").replace("\r\n", "\n").replace("\r", "\n")
        if key == "class":
            tokens = value.split()
            if remove_positions:
                tokens = [
                    token for token in tokens if not POSITION_CLASS_RE.fullmatch(token)
                ]
            value = " ".join(sorted(tokens))
            if not value:
                continue
        normalized.append((key, value))
    normalized.sort()
    return "\x1f".join(f"{key}={value}" for key, value in normalized)


def _normalize_outer_cell_whitespace(value: str) -> str:
    value = value.replace("\r\n", "\n").replace("\r", "\n")
    if value.startswith("\n"):
        value = value[1:]
    if value.endswith("\n"):
        value = value[:-1]
    return value


class BigTableParser(HTMLParser):
    """Capture only direct rows/cells of ``table#bigtable``.

    Nested tables remain canonical markup inside the surrounding cell and do
    not become false outer rows.
    """

    def __init__(self) -> None:
        super().__init__(convert_charrefs=False)
        self.table_depth = 0
        self.target_depth: int | None = None
        self.in_target = False
        self.in_outer_row = False
        self.row_attrs = ""
        self.current_cells: list[bytes] = []
        self.rows: list[list[bytes]] = []
        self.headers: list[str] = []
        self.in_outer_cell = False
        self.cell_attrs = ""
        self.cell_parts: list[str] = []
        self.cell_text_parts: list[str] = []

    def _inside_cell_markup(self, tag: str, attrs: list[tuple[str, str | None]], closing: bool = False) -> None:
        if not self.in_outer_cell:
            return
        if closing:
            self.cell_parts.append(f"</{tag.lower()}>")
        else:
            attr_text = _normalized_attrs(attrs)
            self.cell_parts.append(
                f"<{tag.lower()}" + (f" {attr_text}" if attr_text else "") + ">"
            )

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        tag = tag.lower()
        if tag == "table":
            self.table_depth += 1
            attr_map = {key.lower(): value for key, value in attrs}
            if not self.in_target and attr_map.get("id") == "bigtable":
                self.in_target = True
                self.target_depth = self.table_depth
                return
            self._inside_cell_markup(tag, attrs)
            return
        if not self.in_target or self.target_depth is None:
            return
        if tag == "tr" and self.table_depth == self.target_depth and not self.in_outer_cell:
            self.in_outer_row = True
            self.row_attrs = _normalized_attrs(attrs)
            self.current_cells = []
            return
        if tag == "td" and self.in_outer_row and self.table_depth == self.target_depth and not self.in_outer_cell:
            self.in_outer_cell = True
            self.cell_attrs = _normalized_attrs(attrs, remove_positions=True)
            self.cell_parts = []
            self.cell_text_parts = []
            return
        self._inside_cell_markup(tag, attrs)

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if self.in_outer_cell:
            attr_text = _normalized_attrs(attrs)
            self.cell_parts.append(
                f"<{tag.lower()}" + (f" {attr_text}" if attr_text else "") + "/>"
            )

    def handle_endtag(self, tag: str) -> None:
        tag = tag.lower()
        if not self.in_target or self.target_depth is None:
            if tag == "table" and self.table_depth > 0:
                self.table_depth -= 1
            return
        if tag == "td" and self.in_outer_cell and self.table_depth == self.target_depth:
            inner = _normalize_outer_cell_whitespace("".join(self.cell_parts))
            canonical = (
                self.row_attrs + "\x1d" + self.cell_attrs + "\x1e" + inner
            ).encode("utf-8")
            self.current_cells.append(canonical)
            if not self.rows:
                self.headers.append(WS_RE.sub(" ", "".join(self.cell_text_parts)).strip())
            self.in_outer_cell = False
            self.cell_parts = []
            self.cell_text_parts = []
            return
        if tag == "tr" and self.in_outer_row and self.table_depth == self.target_depth and not self.in_outer_cell:
            self.rows.append(self.current_cells)
            self.current_cells = []
            self.in_outer_row = False
            return
        if tag == "table":
            if self.table_depth == self.target_depth:
                self.in_target = False
                self.target_depth = None
                self.table_depth -= 1
                return
            self._inside_cell_markup(tag, [], closing=True)
            self.table_depth -= 1
            return
        self._inside_cell_markup(tag, [], closing=True)

    def handle_data(self, data: str) -> None:
        if self.in_outer_cell:
            normalized = data.replace("\r\n", "\n").replace("\r", "\n")
            self.cell_parts.append(normalized)
            self.cell_text_parts.append(normalized)

    def handle_entityref(self, name: str) -> None:
        if self.in_outer_cell:
            token = f"&{name};"
            self.cell_parts.append(token)
            self.cell_text_parts.append(token)

    def handle_charref(self, name: str) -> None:
        if self.in_outer_cell:
            token = f"&#{name};"
            self.cell_parts.append(token)
            self.cell_text_parts.append(token)

    def handle_comment(self, data: str) -> None:
        if self.in_outer_cell:
            self.cell_parts.append(f"<!--{data}-->")


def canonicalize_table(loaded: LoadedHtml) -> CanonicalTable:
    parser = BigTableParser()
    parser.feed(loaded.text)
    parser.close()
    if not parser.rows:
        raise ValueError(f"Keine direkten Zeilen in table#bigtable: {loaded.source}")
    column_count = len(parser.rows[0])
    if column_count == 0:
        raise ValueError(f"Keine direkten Zellen in table#bigtable: {loaded.source}")
    for row_index, row in enumerate(parser.rows):
        if len(row) != column_count:
            raise ValueError(
                f"Nichtrechteckige äußere Tabelle in {loaded.source}: Zeile "
                f"{row_index} hat {len(row)} statt {column_count} Zellen"
            )

    hashers = [hashlib.sha256() for _ in range(column_count)]
    for row in parser.rows:
        for index, canonical in enumerate(row):
            hashers[index].update(_length_prefixed(canonical))
    unsorted_hashes = [hasher.hexdigest() for hasher in hashers]
    headers: dict[str, list[str]] = defaultdict(list)
    for digest, header in zip(unsorted_hashes, parser.headers):
        headers[digest].append(header)
    column_hashes = tuple(sorted(unsorted_hashes))
    table_hasher = hashlib.sha256()
    table_hasher.update(len(parser.rows).to_bytes(8, "big"))
    table_hasher.update(column_count.to_bytes(8, "big"))
    for digest in column_hashes:
        table_hasher.update(bytes.fromhex(digest))
    return CanonicalTable(
        source=loaded.source,
        member=loaded.member,
        container_kind=loaded.container_kind,
        container_size=loaded.container_size,
        container_md5=loaded.container_md5,
        container_sha256=loaded.container_sha256,
        payload_size=loaded.payload_size,
        payload_md5=loaded.payload_md5,
        payload_sha256=loaded.payload_sha256,
        rows=len(parser.rows),
        columns=column_count,
        column_hashes=column_hashes,
        table_hash=table_hasher.hexdigest(),
        headers_by_hash={key: tuple(value) for key, value in headers.items()},
    )


def compare_tables(first: CanonicalTable, second: CanonicalTable) -> dict[str, object]:
    first_counter = Counter(first.column_hashes)
    second_counter = Counter(second.column_hashes)
    missing = first_counter - second_counter
    extra = second_counter - first_counter

    def describe(values: Counter[str], headers: dict[str, tuple[str, ...]]) -> list[dict[str, object]]:
        return [
            {
                "sha256": digest,
                "count": count,
                "headers": list(headers.get(digest, ()))[:5],
            }
            for digest, count in sorted(values.items())
        ]

    equal = (
        first.rows == second.rows
        and first.columns == second.columns
        and not missing
        and not extra
    )
    return {
        "equal_ignoring_column_order": equal,
        "first": {
            "source": first.source,
            "member": first.member,
            "container_kind": first.container_kind,
            "container_size": first.container_size,
            "container_md5": first.container_md5,
            "container_sha256": first.container_sha256,
            "payload_size": first.payload_size,
            "payload_md5": first.payload_md5,
            "payload_sha256": first.payload_sha256,
            "rows": first.rows,
            "columns": first.columns,
            "canonical_sha256": first.table_hash,
        },
        "second": {
            "source": second.source,
            "member": second.member,
            "container_kind": second.container_kind,
            "container_size": second.container_size,
            "container_md5": second.container_md5,
            "container_sha256": second.container_sha256,
            "payload_size": second.payload_size,
            "payload_md5": second.payload_md5,
            "payload_sha256": second.payload_sha256,
            "rows": second.rows,
            "columns": second.columns,
            "canonical_sha256": second.table_hash,
        },
        "missing_columns": describe(missing, first.headers_by_hash),
        "extra_columns": describe(extra, second.headers_by_hash),
    }


def main(argv: Iterable[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Vergleicht reta-middle.alx strukturell ohne Spaltenreihenfolge."
    )
    parser.add_argument("first", type=Path)
    parser.add_argument("second", type=Path)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args(list(argv) if argv is not None else None)
    first = canonicalize_table(load_html(args.first))
    second = canonicalize_table(load_html(args.second))
    result = compare_tables(first, second)
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2, sort_keys=True))
    else:
        print(
            "gleich_ohne_spaltenreihenfolge="
            + ("ja" if result["equal_ignoring_column_order"] else "nein")
        )
        for label in ("first", "second"):
            item = result[label]
            member = f"::{item['member']}" if item["member"] else ""
            print(
                f"{label}={item['source']}{member} kind={item['container_kind']} "
                f"container_bytes={item['container_size']} "
                f"container_md5={item['container_md5']} "
                f"payload_bytes={item['payload_size']} "
                f"payload_md5={item['payload_md5']} rows={item['rows']} "
                f"columns={item['columns']} canonical_sha256={item['canonical_sha256']}"
            )
        print(f"fehlende_spalten={len(result['missing_columns'])}")
        print(f"zusaetzliche_spalten={len(result['extra_columns'])}")
    return 0 if result["equal_ignoring_column_order"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
