#!/usr/bin/env python3
from __future__ import annotations

from collections import Counter
from pathlib import Path
import sys


def parse(path: Path) -> dict[str, tuple[list[int], bool]]:
    result: dict[str, tuple[list[int], bool]] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        token, encoded = line.split("\t", 1)
        values_text, applies_text = encoded.rsplit("|", 1)
        values = [] if not values_text else [int(v) for v in values_text.split(",")]
        result[token] = (values, applies_text == "1")
    return result


def main() -> int:
    expected = parse(Path(sys.argv[1]))
    actual = parse(Path(sys.argv[2]))
    if expected.keys() != actual.keys():
        raise SystemExit("token sets differ")
    exact = 0
    semantic = 0
    for token in expected:
        ev, ea = expected[token]
        av, aa = actual[token]
        if (ev, ea) == (av, aa):
            exact += 1
            semantic += 1
            continue
        if ea == aa and Counter(ev) == Counter(av):
            semantic += 1
            continue
        raise SystemExit(
            f"parameter-runtime mismatch for {token}: expected={(ev, ea)!r} actual={(av, aa)!r}"
        )
    print(f"parameter runtime parity: {semantic}/{len(expected)} semantic, {exact}/{len(expected)} byte-order exact")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
