#!/usr/bin/env python3
"""Generate portable native catalogs for presheaves and sheaves.

The Python reference discovers files dynamically and keeps HTML metadata as
JSON dictionaries.  Native Mojo consumes stable UTF-8 TSV catalogs instead;
paths stay relative so source trees and FHS installs remain portable.
"""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
ASSETS = ROOT / "assets"
PRESHEAF_OUT = ASSETS / "presheaf_catalog.tsv"
HTML_OUT = ASSETS / "html_reference_sheaf.tsv"


def _language_for_csv(path: Path) -> str:
    stem = path.stem
    if "-" not in stem:
        return ""
    candidate = stem.split("-", 1)[0]
    return candidate if len(candidate) in (2, 3) else ""


def _language_for_translation(path: Path) -> str:
    parts = path.relative_to(REFERENCE).parts
    if "i18n" not in parts:
        return ""
    index = parts.index("i18n")
    if index + 1 >= len(parts):
        return ""
    candidate = parts[index + 1]
    return candidate if candidate in {"de", "en", "vn", "cn", "kr"} else ""


def _rows_for_pattern(kind: str, pattern: str, start: int) -> tuple[list[str], int]:
    rows: list[str] = []
    ordinal = start
    for path in sorted(REFERENCE.glob(pattern)):
        relative = path.relative_to(REFERENCE).as_posix()
        suffix = path.suffix
        if kind == "csv":
            language = _language_for_csv(path)
            scope = "csv"
        elif kind == "translations":
            language = _language_for_translation(path)
            scope = "i18n"
        else:
            language = ""
            scope = suffix.lstrip(".") or "file"
        fields = [kind, str(ordinal), relative, suffix, path.name, language, scope]
        if any("\t" in field or "\n" in field or "\r" in field for field in fields):
            raise ValueError(f"unsupported catalog path: {path}")
        rows.append("\t".join(fields))
        ordinal += 1
    return rows, ordinal


def generate_presheaf_catalog() -> tuple[int, dict[str, int]]:
    rows = ["# kind\tordinal\trelative_path\tsuffix\tname\tlanguage\tscope"]
    ordinal = 0
    counts: dict[str, int] = {"csv": 0, "translations": 0, "assets": 0}
    patterns = [
        ("csv", "csv/*.csv"),
        ("translations", "i18n/**/*.po"),
        ("translations", "i18n/**/*.mo"),
        ("translations", "i18n/**/*.pot"),
        ("assets", "*.md"),
        ("assets", "*.org"),
        ("assets", "*.alx"),
        ("assets", "*.jsonl"),
        ("assets", "*.js"),
        ("assets", "*.ts"),
        ("assets", "doc/*.md"),
        ("assets", "doc/*.org"),
    ]
    for kind, pattern in patterns:
        part, ordinal = _rows_for_pattern(kind, pattern, ordinal)
        rows.extend(part)
        counts[kind] += len(part)
    PRESHEAF_OUT.write_text("\n".join(rows) + "\n", encoding="utf-8")
    return ordinal, counts


def generate_html_reference_catalog() -> int:
    source = REFERENCE / "htmlclassesPy.jsonl"
    by_column: dict[int, str] = {}
    if source.exists():
        for raw_line in source.read_text(encoding="utf-8").splitlines():
            line = raw_line.strip()
            if not line:
                continue
            try:
                payload = json.loads(line)
                column = int(payload["column_number"])
            except (json.JSONDecodeError, KeyError, TypeError, ValueError):
                continue
            if payload.get("row_number") != 0:
                continue
            compact = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
            if "\t" in compact or "\n" in compact or "\r" in compact:
                raise ValueError(f"unsupported HTML payload for column {column}")
            # Python dict assignment uses the last row for duplicate columns.
            by_column[column] = compact
    rows = ["# column_number\tpayload_json"]
    rows.extend(f"{column}\t{by_column[column]}" for column in sorted(by_column))
    HTML_OUT.write_text("\n".join(rows) + "\n", encoding="utf-8")
    return len(by_column)


def main() -> int:
    total, counts = generate_presheaf_catalog()
    html_count = generate_html_reference_catalog()
    print(
        "presheaf_catalog="
        f"{total} csv={counts['csv']} translations={counts['translations']} "
        f"assets={counts['assets']} html_reference={html_count}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
