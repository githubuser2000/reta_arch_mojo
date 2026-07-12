#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import runpy
import sys


def _mode_from_paths(expected: Path, actual: Path) -> tuple[str, str]:
    text = f"{expected} {actual}".lower()

    if "bbcode" in text:
        return "markup", "bbcode"
    if "html" in text:
        return "markup", "html"
    if "markdown" in text:
        return "flat", "markdown"
    if "emacs" in text:
        return "flat", "emacs"
    if "csv" in text:
        return "flat", "csv"
    if "shell" in text:
        return "shell", "shell"

    raise ValueError(
        "Ausgabeart konnte aus den Dateinamen nicht bestimmt werden: "
        f"{expected} / {actual}"
    )


def _normalize_text(data: bytes) -> str:
    return (
        data.decode("utf-8")
        .replace("\r\n", "\n")
        .replace("\r", "\n")
    )


def _split_before_marker(text: str, marker: re.Pattern[str]) -> list[str]:
    starts = [match.start() for match in marker.finditer(text)]
    if not starts:
        return []

    prefix = text[: starts[0]]
    if prefix.strip():
        raise ValueError(
            f"unerwarteter Text vor erster Seitentabelle: {prefix!r}"
        )

    pages: list[str] = []
    for index, start in enumerate(starts):
        end = starts[index + 1] if index + 1 < len(starts) else len(text)
        page = text[start:end]
        if page.strip():
            pages.append(page)
    return pages


def _split_pages(mode: str, text: str) -> tuple[str, list[str]]:
    if "\f" in text:
        return (
            "form-feed",
            [page for page in text.split("\f") if page.strip()],
        )

    if mode == "html":
        pages = _split_before_marker(
            text,
            re.compile(r"<table\b", re.IGNORECASE),
        )
        if pages:
            return "html-table", pages

    if mode == "bbcode":
        pages = _split_before_marker(
            text,
            re.compile(r"\[table(?:[=\]])", re.IGNORECASE),
        )
        if pages:
            return "bbcode-table", pages

    blocks = [
        block
        for block in re.split(r"\n[ \t]*\n+", text)
        if block.strip()
    ]
    if len(blocks) > 1:
        return "blank-line", blocks

    return "single-block", [text]


def _semantic_page(
    namespace: dict[str, object],
    family: str,
    mode: str,
    page: str,
) -> object:
    data = page.encode("utf-8")

    if family == "shell":
        return namespace["_semantic_shell_table"](data)
    if family == "markup":
        return namespace["_semantic_markup_table"](mode, data)
    return namespace["_semantic_flat_table"](mode, data)


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: compare_semantic_paginated_fixture.py EXPECTED ACTUAL",
            file=sys.stderr,
        )
        return 2

    expected_path = Path(sys.argv[1])
    actual_path = Path(sys.argv[2])

    try:
        family, mode = _mode_from_paths(expected_path, actual_path)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2

    expected_text = _normalize_text(expected_path.read_bytes())
    actual_text = _normalize_text(actual_path.read_bytes())

    try:
        expected_separator, expected_pages = _split_pages(mode, expected_text)
        actual_separator, actual_pages = _split_pages(mode, actual_text)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 1

    if expected_separator != actual_separator:
        print(
            "Unterschiedliche Art der Seitentrennung:\n"
            f"  erwartet: {expected_separator}\n"
            f"  aktuell:  {actual_separator}",
            file=sys.stderr,
        )
        return 1

    if len(expected_pages) != len(actual_pages):
        print(
            "Unterschiedliche Seitenzahl:\n"
            f"  erwartet: {len(expected_pages)}\n"
            f"  aktuell:  {len(actual_pages)}",
            file=sys.stderr,
        )
        return 1

    root = Path(__file__).resolve().parent.parent
    namespace = runpy.run_path(
        str(root / "tests" / "test_compat_launcher.py")
    )

    for page_number, (expected_page, actual_page) in enumerate(
        zip(expected_pages, actual_pages, strict=True),
        start=1,
    ):
        expected = _semantic_page(
            namespace,
            family,
            mode,
            expected_page,
        )
        actual = _semantic_page(
            namespace,
            family,
            mode,
            actual_page,
        )

        if actual == expected:
            continue

        print(
            f"Semantische Abweichung auf Seite {page_number} "
            f"({mode}):\n"
            f"  erwartet: {expected_path}\n"
            f"  aktuell:  {actual_path}",
            file=sys.stderr,
        )

        limit = min(len(expected), len(actual))
        for row_index in range(limit):
            if expected[row_index] != actual[row_index]:
                print(
                    f"  erste abweichende logische Tabellenzeile: "
                    f"{row_index}",
                    file=sys.stderr,
                )
                print(
                    f"  erwartet: {expected[row_index]!r}",
                    file=sys.stderr,
                )
                print(
                    f"  aktuell:  {actual[row_index]!r}",
                    file=sys.stderr,
                )
                break
        else:
            print(
                f"  unterschiedliche Zeilenzahl: "
                f"{len(expected)} != {len(actual)}",
                file=sys.stderr,
            )

        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
