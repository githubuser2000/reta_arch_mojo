#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python_reference"))
sys.path.insert(0, str(ROOT / "python_reference" / "libs"))

from reta_architecture import parameter_runtime as runtime  # noqa: E402


class Stub:
    pass


def encode(values: list[int], applies: bool) -> str:
    return f"{','.join(map(str, values))}|{1 if applies else 0}"


def main() -> None:
    stub = Stub()
    for token in sys.argv[1:]:
        values, applies = runtime.upper_limit_values_for_argument(stub, token)
        print(token + "\t" + encode(list(values), bool(applies)))


if __name__ == "__main__":
    main()
