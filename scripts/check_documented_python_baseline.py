#!/usr/bin/env python3
"""Confirm that the frozen Python reference has exactly the catalogued red tests."""
from __future__ import annotations

import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
TARGET = "tests/test_architecture_refactor.py"
EXPECTED = {
    "test_prompt_runtime_layer_is_explicit",
    "test_parameter_semantics_regression_counts",
    "test_program_workflow_layer_is_explicit",
}


def main() -> int:
    result = subprocess.run(
        [
            "python3",
            "-m",
            "pytest",
            "-q",
            "--tb=short",
            "-rf",
            TARGET,
        ],
        cwd=REFERENCE,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )
    output = result.stdout
    if result.returncode != 1:
        raise SystemExit(
            f"expected the frozen baseline to fail with status 1, got {result.returncode}\n{output}"
        )
    missing = sorted(name for name in EXPECTED if name not in output)
    if missing:
        raise SystemExit(f"missing documented failures {missing}\n{output}")
    failure_names = set(re.findall(r"FAILED .*::(test_[A-Za-z0-9_]+)", output))
    if failure_names != EXPECTED:
        raise SystemExit(
            f"unexpected failure set: {sorted(failure_names)} != {sorted(EXPECTED)}\n{output}"
        )
    if not re.search(r"3 failed, 67 passed", output):
        raise SystemExit(f"unexpected baseline summary\n{output}")
    print("frozen Python baseline: 67 passed, 3 catalogued failures")
    for name in sorted(EXPECTED):
        print(f"  {name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
