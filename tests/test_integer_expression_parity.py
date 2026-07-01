from __future__ import annotations

import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BINARY = Path(
    os.environ.get(
        "RETA_INTEGER_EXPRESSION_PROBE",
        ROOT / "target" / "test-bin" / "integer-expression-probe",
    )
)
if not BINARY.is_absolute():
    BINARY = ROOT / BINARY

# Fixed, non-user-controlled expressions.  The reference intentionally uses
# eval for historical compatibility; the native parser must reproduce these
# observable integer results without executing Python.
CASES = [
    "{1,2,-3}",
    "{1,1+1}",
    "[2*3]",
    "(1)",
    "(1,)",
    "[]",
    "{}",
    "{n*2+1 for n in range(3)}",
    "{2*n for n in range(2,5)}",
    "[3*n for n in range(2)]",
    "[n for n in range(5,0,-2)]",
    "[n//2 for n in range(-3,4)]",
    "[n%3 for n in range(-3,4)]",
    "[2**n for n in range(5)]",
    "[2*(n+1)-1 for n in range(4)]",
]

REJECTED_CASES = [
    "[1/2]",  # float, not set[int]
    "[9223372036854775808]",  # outside native Int, therefore fallback
    "[9223372036854775807+1]",
    "[3037000500*3037000500]",
    "[2**63]",
    "[n for n in range(3) if n]",  # not yet in the finite native grammar
    "[n+m for n in range(2) for m in range(2)]",
    "[__import__('os').system('true')]",
]


def _reference(expression: str) -> str:
    # Mirror str_as_generator_to_set without importing the full architecture
    # package, whose bootstrap has unrelated runtime dependencies.
    text = expression
    if text.startswith("(") and text.endswith(")"):
        text = "[" + text[1:-1] + "]"
    try:
        result = set(eval(text, {"__builtins__": {"range": range}}, {}))  # noqa: S307
    except Exception:
        return "invalid"
    if not all(type(value) is int for value in result):
        return "invalid"
    values = "".join(f"\t{value}" for value in sorted(result))
    return "valid" + values


def test_safe_integer_expression_subset_matches_reference() -> None:
    assert BINARY.is_file(), f"missing probe: {BINARY}"
    completed = subprocess.run(
        [str(BINARY), *CASES],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    assert completed.stderr == b""
    assert completed.stdout.decode().splitlines() == [
        _reference(expression) for expression in CASES
    ]


def test_non_owned_or_unsafe_expressions_are_rejected() -> None:
    completed = subprocess.run(
        [str(BINARY), *REJECTED_CASES],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
    )
    assert completed.stderr == b""
    assert completed.stdout.decode().splitlines() == ["invalid"] * len(
        REJECTED_CASES
    )
