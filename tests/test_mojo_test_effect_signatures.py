from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TESTS = ROOT / "tests"
TEST_FUNCTION = re.compile(r"^\s*def\s+(test_[A-Za-z0-9_]+)\s*\([^)]*\)(.*):\s*$")


def test_all_mojo_test_functions_are_allowed_to_propagate_assertion_errors() -> None:
    """std.testing assertions and checked indexing may raise in Mojo 1.0.0b2.

    Requiring ``raises`` on every test function is deliberately conservative:
    it prevents a newly added assertion or checked container access from
    turning a late full-suite target into a parser failure.
    """

    missing: list[str] = []
    for path in sorted(TESTS.glob("test_*.mojo")):
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            match = TEST_FUNCTION.match(line)
            if match and "raises" not in match.group(2).split():
                missing.append(f"{path.relative_to(ROOT)}:{line_number}:{match.group(1)}")
    assert missing == [], "Mojo test functions without raises:\n" + "\n".join(missing)
