#!/usr/bin/env python3
from __future__ import annotations
import os, sys
from pathlib import Path
root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root / "python_reference"))
from reta_architecture.prompt_execution import bruchSpalt, createRangesForBruchLists

def serial_groups(groups):
    if not groups:
        return "INVALID"
    return "\x1e".join("\x1f".join(group) for group in groups)

def serial_range(value):
    if not value:
        return "INVALID"
    numbers, suffix = value
    return ",".join(str(v) for v in numbers) + "\t" + suffix

for text in sys.argv[1:]:
    groups = bruchSpalt(text)
    result = createRangesForBruchLists(groups) if groups else []
    print(serial_groups(groups) + "\t" + serial_range(result))
