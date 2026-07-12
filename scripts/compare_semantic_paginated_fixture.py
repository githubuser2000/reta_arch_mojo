#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import re
import runpy
import sys
from typing import Any


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


def _normalize(data: bytes) -> str:
    return (
        data.decode("utf-8")
        .replace("\r\n", "\n")
        .replace("\r", "\n")
    )


def _split_before_marker(text: str, pattern: str) -> list[str]:
    marker = re.compile(pattern, re.IGNORECASE)
    starts = [match.start() for match in marker.finditer(text)]
    if not starts:
        return []

    blocks: list[str] = []
    for index, start in enumerate(starts):
        end = starts[index + 1] if index + 1 < len(starts) else len(text)
        block = text[start:end]
        if block.strip():
            blocks.append(block)
    return blocks


def _split_shell_blocks(
    namespace: dict[str, Any],
    text: str,
) -> tuple[list[str], tuple[str, ...]]:
    ansi_cell_re = namespace["_ANSI_CELL_RE"]
    ansi_sgr_re = namespace["_ANSI_SGR_RE"]

    blocks: list[str] = []
    visible_text: list[str] = []
    current_lines: list[str] = []
    current_cell_count: int | None = None
    seen_numbered_row = False

    def flush() -> None:
        nonlocal current_lines, current_cell_count, seen_numbered_row
        if current_lines:
            blocks.append("\n".join(current_lines) + "\n")
        current_lines = []
        current_cell_count = None
        seen_numbered_row = False

    for line in text.splitlines():
        if not line.strip():
            continue

        matches = list(ansi_cell_re.finditer(line))
        if not matches:
            flush()
            visible = ansi_sgr_re.sub("", line)
            visible = "".join(visible.split())
            if visible:
                visible_text.append(visible)
            continue

        prefix = ansi_sgr_re.sub("", line[: matches[0].start()]).strip()
        cell_count = len(matches)
        is_numbered_row = bool(re.search(r"\d", prefix))
        is_underlined_header = (
            not is_numbered_row
            and "\x1b[4m" in line
        )

        starts_new_block = bool(
            current_lines
            and (
                cell_count != current_cell_count
                or (seen_numbered_row and is_underlined_header)
            )
        )
        if starts_new_block:
            flush()

        if current_cell_count is None:
            current_cell_count = cell_count

        current_lines.append(line)
        seen_numbered_row = seen_numbered_row or is_numbered_row

    flush()
    return blocks, tuple(visible_text)


def _split_blocks(
    namespace: dict[str, Any],
    family: str,
    mode: str,
    text: str,
) -> tuple[list[str], tuple[str, ...]]:
    if family == "shell":
        return _split_shell_blocks(namespace, text)

    if mode == "html":
        return _split_before_marker(text, r"<table\b"), ()

    if mode == "bbcode":
        return _split_before_marker(text, r"\[table(?:[=\]])"), ()

    if "\f" in text:
        return [block for block in text.split("\f") if block.strip()], ()

    blocks = [
        block
        for block in re.split(r"\n[ \t]*\n+", text)
        if block.strip()
    ]
    return blocks or [text], ()


def _semantic_block(
    namespace: dict[str, Any],
    family: str,
    mode: str,
    block: str,
) -> Any:
    data = block.encode("utf-8")

    if family == "shell":
        return namespace["_semantic_shell_table"](data)
    if family == "markup":
        return namespace["_semantic_markup_table"](mode, data)
    return namespace["_semantic_flat_table"](mode, data)


def _shell_row_key(prefix: str) -> str:
    digits = "".join(re.findall(r"\d+", prefix))
    return digits


def _merge_shell_blocks(blocks: list[Any]) -> tuple[Any, ...]:
    merged_keys: list[str] = []
    merged_columns: list[list[str]] = []

    for block_number, rows in enumerate(blocks, start=1):
        if not isinstance(rows, tuple):
            raise AssertionError(
                f"Shell-Block {block_number} ist keine Zeilentupel-Struktur."
            )

        keys = [_shell_row_key(str(prefix)) for prefix, _ in rows]

        if block_number == 1:
            merged_keys = keys
            merged_columns = [
                list(columns)
                for _, columns in rows
            ]
            continue

        if keys != merged_keys:
            raise AssertionError(
                f"Shell-Block {block_number} hat andere logische Zeilen: "
                f"{keys!r} != {merged_keys!r}"
            )

        for row_index, (_, columns) in enumerate(rows):
            merged_columns[row_index].extend(columns)

    return tuple(
        (key, tuple(columns))
        for key, columns in zip(
            merged_keys,
            merged_columns,
            strict=True,
        )
    )


def _merge_flat_blocks(blocks: list[Any]) -> tuple[Any, ...]:
    if not blocks:
        return ()

    row_count = len(blocks[0])
    merged = [list(row) for row in blocks[0]]

    for block_number, rows in enumerate(blocks[1:], start=2):
        if len(rows) != row_count:
            raise AssertionError(
                f"Flat-Block {block_number} hat {len(rows)} statt "
                f"{row_count} logische Zeilen."
            )
        for row_index, row in enumerate(rows):
            merged[row_index].extend(row)

    return tuple(tuple(row) for row in merged)


def _merge_markup_blocks(blocks: list[Any]) -> tuple[Any, ...]:
    if not blocks:
        return ()

    row_count = len(blocks[0])
    row_styles = [row_style for row_style, _ in blocks[0]]
    merged_cells = [list(cells) for _, cells in blocks[0]]

    for block_number, rows in enumerate(blocks[1:], start=2):
        if len(rows) != row_count:
            raise AssertionError(
                f"Markup-Block {block_number} hat {len(rows)} statt "
                f"{row_count} logische Zeilen."
            )

        styles = [row_style for row_style, _ in rows]
        if styles != row_styles:
            raise AssertionError(
                f"Markup-Block {block_number} hat andere Zeilenstile."
            )

        for row_index, (_, cells) in enumerate(rows):
            merged_cells[row_index].extend(cells)

    return tuple(
        (row_style, tuple(cells))
        for row_style, cells in zip(
            row_styles,
            merged_cells,
            strict=True,
        )
    )


def _canonical(
    namespace: dict[str, Any],
    family: str,
    mode: str,
    text: str,
) -> tuple[int, tuple[str, ...], Any]:
    raw_blocks, visible_text = _split_blocks(
        namespace,
        family,
        mode,
        text,
    )

    semantic_blocks = [
        _semantic_block(namespace, family, mode, block)
        for block in raw_blocks
    ]

    if len(semantic_blocks) < 2:
        raise AssertionError(
            f"{mode}-Ausgabe ist nicht paginiert: "
            f"nur {len(semantic_blocks)} Tabellenblock"
        )

    if family == "shell":
        merged = _merge_shell_blocks(semantic_blocks)
    elif family == "markup":
        merged = _merge_markup_blocks(semantic_blocks)
    else:
        merged = _merge_flat_blocks(semantic_blocks)

    return len(semantic_blocks), visible_text, merged


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

    root = Path(__file__).resolve().parent.parent
    namespace = runpy.run_path(
        str(root / "tests" / "test_compat_launcher.py")
    )

    try:
        expected_blocks, expected_text, expected = _canonical(
            namespace,
            family,
            mode,
            _normalize(expected_path.read_bytes()),
        )
        actual_blocks, actual_text, actual = _canonical(
            namespace,
            family,
            mode,
            _normalize(actual_path.read_bytes()),
        )
    except (AssertionError, ValueError) as error:
        print(f"Pagination konnte nicht rekonstruiert werden: {error}", file=sys.stderr)
        return 1

    if actual_text != expected_text:
        print(
            "Nichttabellarischer Seitentext unterscheidet sich:\n"
            f"  erwartet: {expected_text!r}\n"
            f"  aktuell:  {actual_text!r}",
            file=sys.stderr,
        )
        return 1

    if actual == expected:
        print(
            f"Pagination semantisch gleich: "
            f"{expected_blocks} Referenzblöcke, "
            f"{actual_blocks} native Blöcke",
            file=sys.stderr,
        )
        return 0

    print(
        f"Semantische paginierte {mode}-Ausgaben unterscheiden sich:\n"
        f"  erwartet: {expected_path}\n"
        f"  aktuell:  {actual_path}\n"
        f"  Referenzblöcke: {expected_blocks}\n"
        f"  native Blöcke:  {actual_blocks}",
        file=sys.stderr,
    )

    limit = min(len(expected), len(actual))
    for index in range(limit):
        if expected[index] != actual[index]:
            print(
                f"  erste abweichende vollständige Tabellenzeile: {index}",
                file=sys.stderr,
            )
            print(f"  erwartet: {expected[index]!r}", file=sys.stderr)
            print(f"  aktuell:  {actual[index]!r}", file=sys.stderr)
            break
    else:
        print(
            f"  unterschiedliche Zeilenzahl: "
            f"{len(expected)} != {len(actual)}",
            file=sys.stderr,
        )

    return 1


if __name__ == "__main__":
    raise SystemExit(main())
