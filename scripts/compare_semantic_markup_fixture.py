#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import runpy
import sys


def main() -> int:
    if len(sys.argv) != 4:
        print(
            "usage: compare_semantic_markup_fixture.py MODE EXPECTED ACTUAL",
            file=sys.stderr,
        )
        return 2

    mode, expected_name, actual_name = sys.argv[1:]
    if mode not in {"html", "bbcode"}:
        print(f"unsupported markup mode: {mode}", file=sys.stderr)
        return 2

    root = Path(__file__).resolve().parent.parent
    namespace = runpy.run_path(
        str(root / "tests" / "test_compat_launcher.py")
    )
    semantic_markup_table = namespace["_semantic_markup_table"]

    expected_path = Path(expected_name)
    actual_path = Path(actual_name)

    expected = semantic_markup_table(mode, expected_path.read_bytes())
    actual = semantic_markup_table(mode, actual_path.read_bytes())

    if actual == expected:
        return 0

    print(
        f"Semantische {mode}-Tabellen unterscheiden sich:\n"
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
