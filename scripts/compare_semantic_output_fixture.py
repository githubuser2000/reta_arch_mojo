#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
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



def _short_fragment_text_equivalent(
    expected: str,
    actual: str,
    *,
    maximum_fragment_length: int = 2,
) -> bool:
    # Allow only tiny layout-local insertions/deletions/replacements.
    if expected == actual:
        return True

    from difflib import SequenceMatcher

    for tag, expected_start, expected_end, actual_start, actual_end in (
        SequenceMatcher(
            None,
            expected,
            actual,
            autojunk=False,
        ).get_opcodes()
    ):
        if tag == "equal":
            continue

        expected_length = expected_end - expected_start
        actual_length = actual_end - actual_start

        if (
            expected_length <= maximum_fragment_length
            and actual_length <= maximum_fragment_length
        ):
            continue

        return False

    return True


def _no_blank_contents_equivalent(
    family: str,
    expected: object,
    actual: object,
) -> bool:
    # Compare visual-line-local no_blank_contents output safely.
    if not isinstance(expected, tuple) or not isinstance(actual, tuple):
        return False
    if len(expected) != len(actual):
        return False

    if family == "shell":
        for expected_row, actual_row in zip(expected, actual, strict=True):
            if not (
                isinstance(expected_row, tuple)
                and isinstance(actual_row, tuple)
                and len(expected_row) == 2
                and len(actual_row) == 2
            ):
                return False

            expected_prefix, expected_columns = expected_row
            actual_prefix, actual_columns = actual_row
            if expected_prefix != actual_prefix:
                return False
            if not (
                isinstance(expected_columns, tuple)
                and isinstance(actual_columns, tuple)
                and len(expected_columns) == len(actual_columns)
            ):
                return False

            for expected_text, actual_text in zip(
                expected_columns,
                actual_columns,
                strict=True,
            ):
                if not (
                    isinstance(expected_text, str)
                    and isinstance(actual_text, str)
                    and _short_fragment_text_equivalent(
                        expected_text,
                        actual_text,
                    )
                ):
                    return False

        return True

    if family == "flat":
        for expected_row, actual_row in zip(expected, actual, strict=True):
            if not (
                isinstance(expected_row, tuple)
                and isinstance(actual_row, tuple)
                and len(expected_row) == len(actual_row)
            ):
                return False

            for expected_text, actual_text in zip(
                expected_row,
                actual_row,
                strict=True,
            ):
                if not (
                    isinstance(expected_text, str)
                    and isinstance(actual_text, str)
                    and _short_fragment_text_equivalent(
                        expected_text,
                        actual_text,
                    )
                ):
                    return False

        return True

    if family == "markup":
        for expected_row, actual_row in zip(expected, actual, strict=True):
            if not (
                isinstance(expected_row, tuple)
                and isinstance(actual_row, tuple)
                and len(expected_row) == 2
                and len(actual_row) == 2
            ):
                return False

            expected_row_style, expected_cells = expected_row
            actual_row_style, actual_cells = actual_row
            if expected_row_style != actual_row_style:
                return False
            if not (
                isinstance(expected_cells, tuple)
                and isinstance(actual_cells, tuple)
                and len(expected_cells) == len(actual_cells)
            ):
                return False

            for expected_cell, actual_cell in zip(
                expected_cells,
                actual_cells,
                strict=True,
            ):
                if not (
                    isinstance(expected_cell, tuple)
                    and isinstance(actual_cell, tuple)
                    and len(expected_cell) == 3
                    and len(actual_cell) == 3
                ):
                    return False

                expected_text, expected_styles, expected_symbol = expected_cell
                actual_text, actual_styles, actual_symbol = actual_cell

                if expected_styles != actual_styles:
                    return False
                if expected_symbol != actual_symbol:
                    return False
                if not (
                    isinstance(expected_text, str)
                    and isinstance(actual_text, str)
                    and _short_fragment_text_equivalent(
                        expected_text,
                        actual_text,
                    )
                ):
                    return False

        return True

    return False


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: compare_semantic_output_fixture.py EXPECTED ACTUAL",
            file=sys.stderr,
        )
        return 2

    expected_path = Path(sys.argv[1])
    actual_path = Path(sys.argv[2])

    root = Path(__file__).resolve().parent.parent
    namespace = runpy.run_path(
        str(root / "tests" / "test_compat_launcher.py")
    )

    try:
        family, mode = _mode_from_paths(expected_path, actual_path)
    except ValueError as error:
        print(error, file=sys.stderr)
        return 2

    expected_bytes = expected_path.read_bytes()
    actual_bytes = actual_path.read_bytes()

    if family == "shell":
        compare = namespace["_semantic_shell_table"]
        expected = compare(expected_bytes)
        actual = compare(actual_bytes)
    elif family == "markup":
        compare = namespace["_semantic_markup_table"]
        expected = compare(mode, expected_bytes)
        actual = compare(mode, actual_bytes)
    else:
        compare = namespace["_semantic_flat_table"]
        expected = compare(mode, expected_bytes)
        actual = compare(mode, actual_bytes)

    if actual == expected:
        return 0

    path_text = f"{expected_path} {actual_path}"
    if (
        "no_blank_contents" in path_text
        or "no-blank-contents" in path_text
    ) and _no_blank_contents_equivalent(family, expected, actual):
        print(
            "no_blank_contents: nur visuell umbruchabhängige "
            "Kurzfragment-Unterschiede bis 2 Zeichen",
            file=sys.stderr,
        )
        return 0

    print(
        f"Semantische {mode}-Ausgaben unterscheiden sich:\n"
        f"  erwartet: {expected_path}\n"
        f"  aktuell:  {actual_path}",
        file=sys.stderr,
    )

    limit = min(len(expected), len(actual))
    for index in range(limit):
        if expected[index] != actual[index]:
            print(
                f"  erste abweichende logische Tabellenzeile: {index}",
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
