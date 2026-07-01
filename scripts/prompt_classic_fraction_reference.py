#!/usr/bin/env python3
"""Serialize stable classic-family fraction plans from the Python reference."""
from __future__ import annotations

import sys

from prompt_mixed_reciprocal_reference import reference_plan


def main() -> None:
    for command in sys.argv[1:]:
        plan = reference_plan(command)
        print("NOOP" if plan == "" else plan)


if __name__ == "__main__":
    main()
