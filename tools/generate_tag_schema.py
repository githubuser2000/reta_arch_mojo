#!/usr/bin/env python3
"""Generate the native Mojo table-tag catalog and parity constants."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
PYREF = ROOT / "python_reference"
sys.path.insert(0, str(PYREF))

from reta_architecture.tag_schema import (  # noqa: E402
    ST,
    tableTags,
    tableTags2,
    tableTags_kombiTable,
    tableTags2_kombiTable,
    tableTags_kombiTable2,
    tableTags2_kombiTable2,
)

MODULUS = 1_000_000_007


def ints(values: Iterable[object]) -> str:
    return "[" + ", ".join(str(int(getattr(v, "value", v))) for v in values) + "]"


def quote(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def reverse_sort_key(group_mapping: dict, column: object, tags: object) -> tuple[int, int]:
    tag_values = tuple(sorted(int(tag.value) for tag in tags))
    for index, (group_tags, _columns) in enumerate(group_mapping.items()):
        if tuple(sorted(int(tag.value) for tag in group_tags)) == tag_values:
            return index, int(column)
    return len(group_mapping), int(column)


def emit_reverse(lines: list[str], name: str, mapping: dict, group_mapping: dict) -> None:
    lines.append(f"    var {name} = List[TagColumnEntry]()")
    for column, tags in sorted(
        mapping.items(), key=lambda item: reverse_sort_key(group_mapping, item[0], item[1])
    ):
        tag_values = sorted(int(tag.value) for tag in tags)
        lines.append(
            f"    {name}.append(TagColumnEntry({int(column)}, {ints(tag_values)}))"
        )


def emit_groups(lines: list[str], name: str, mapping: dict) -> None:
    lines.append(f"    var {name} = List[TagGroup]()")
    for tags, columns in mapping.items():
        tag_values = sorted(int(tag.value) for tag in tags)
        column_values = sorted(int(column) for column in columns)
        lines.append(
            f"    {name}.append(TagGroup({ints(tag_values)}, {ints(column_values)}))"
        )


def generate_catalog() -> str:
    lines = [
        '"""Generated native snapshot of reta_architecture.tag_schema.\n\nRegenerate with tools/generate_tag_schema.py.\n"""',
        "",
        "from std.collections import List",
        "from .tag_schema import TagGroup, TagColumnEntry, TagSchemaBundle",
        "",
        "",
        "def bootstrap_tag_schema() -> TagSchemaBundle:",
    ]
    emit_groups(lines, "primary", tableTags)
    emit_reverse(lines, "primary_reverse", tableTags2, tableTags)
    emit_groups(lines, "combination", tableTags_kombiTable)
    emit_reverse(lines, "combination_reverse", tableTags2_kombiTable, tableTags_kombiTable)
    emit_groups(lines, "combination_two", tableTags_kombiTable2)
    emit_reverse(lines, "combination_two_reverse", tableTags2_kombiTable2, tableTags_kombiTable2)
    lines.append("    var tag_names = List[String]()")
    for tag in ST:
        lines.append(f"    tag_names.append({quote(tag.name)})")
    lines.append(
        "    return TagSchemaBundle(primary^, primary_reverse^, combination^, combination_reverse^, combination_two^, combination_two_reverse^, tag_names^)"
    )
    lines.append("")
    return "\n".join(lines)


def hash_field(value: int, field: object) -> int:
    for byte in str(field).encode("utf-8"):
        value = (value * 257 + byte + 1) % MODULUS
    return (value * 257 + 257) % MODULUS


def record_hash(*fields: object) -> int:
    value = 17
    for field in fields:
        value = hash_field(value, field)
    return value


def fingerprint(records: Iterable[tuple[object, ...]]) -> tuple[int, int, int]:
    count = total = squares = 0
    for record in records:
        value = record_hash(*record)
        count += 1
        total = (total + value) % MODULUS
        squares = (squares + value * value) % MODULUS
    return count, total, squares


def group_records(mapping: dict) -> list[tuple[object, ...]]:
    return [
        (*sorted(int(tag.value) for tag in tags), "|", *sorted(int(c) for c in columns))
        for tags, columns in mapping.items()
    ]


def reverse_records(mapping: dict) -> list[tuple[object, ...]]:
    return [
        (int(column), *(sorted(int(tag.value) for tag in tags)))
        for column, tags in mapping.items()
    ]


def generate_constants() -> str:
    datasets = {
        "PRIMARY_GROUP": group_records(tableTags),
        "PRIMARY_REVERSE": reverse_records(tableTags2),
        "KOMBI_GROUP": group_records(tableTags_kombiTable),
        "KOMBI_REVERSE": reverse_records(tableTags2_kombiTable),
        "KOMBI2_GROUP": group_records(tableTags_kombiTable2),
        "KOMBI2_REVERSE": reverse_records(tableTags2_kombiTable2),
    }
    lines = [
        '"""Generated fingerprints for the complete Python table-tag schema."""',
        "",
        f"comptime TAG_FINGERPRINT_MODULUS = {MODULUS}",
    ]
    for name, records in datasets.items():
        count, total, squares = fingerprint(records)
        lines.extend(
            [
                f"comptime EXPECTED_{name}_COUNT = {count}",
                f"comptime EXPECTED_{name}_SUM = {total}",
                f"comptime EXPECTED_{name}_SQUARE_SUM = {squares}",
            ]
        )
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    (ROOT / "src/reta_mojo/tag_schema_catalog.mojo").write_text(
        generate_catalog(), encoding="utf-8"
    )
    (ROOT / "tests/tag_schema_parity_constants.mojo").write_text(
        generate_constants(), encoding="utf-8"
    )
    print(
        json.dumps(
            {
                "tag_names": len(ST),
                "primary_groups": len(tableTags),
                "primary_reverse": len(tableTags2),
                "primary_links": sum(len(v) for v in tableTags.values()),
                "kombi_groups": len(tableTags_kombiTable),
                "kombi_reverse": len(tableTags2_kombiTable),
                "kombi2_groups": len(tableTags_kombiTable2),
                "kombi2_reverse": len(tableTags2_kombiTable2),
            },
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()
