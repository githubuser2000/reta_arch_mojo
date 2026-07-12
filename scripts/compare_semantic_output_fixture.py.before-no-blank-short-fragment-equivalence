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
