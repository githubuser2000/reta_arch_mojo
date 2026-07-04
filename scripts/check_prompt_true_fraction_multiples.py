#!/usr/bin/env python3
"""Validate corrected true-fraction and mixed reciprocal Mojo contracts."""
from __future__ import annotations

import csv
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RS = "\x1e"
FS = "\x1f"

CASES = [
    "universum v2/3",
    "universum vielfache 2/3",
    "universum v2/3 teiler",
    "emotion v2/3",
    "groesse v2/3",
    "motive v2/3",
    "emotion v8/3",
    "groesse v17/3",
    "motive v22/3",
    "universum v20/3",
    "universum motive v2/3",
    "universum v1/2,2/3",
    "universum vielfache 1/2,2/3",
    "universum v-1/4,2/3",
    "universum v-2/3",
    "universum v-2/3,1/4",
    "universum v1/4,-2/3",
    "universum v1/4,-1/8,2/3",
]


def fail(message: str) -> None:
    raise SystemExit(message)


def parse_probe(binary: Path) -> dict[str, str]:
    completed = subprocess.run(
        [str(binary)],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=120,
    )
    result: dict[str, str] = {}
    # str.splitlines() treats the record separator U+001E as a line break.
    # Split bytes only on the actual newline emitted after each CASE instead.
    for raw_line in completed.stdout.split(b"\n"):
        if not raw_line:
            continue
        line = raw_line.decode("utf-8")
        prefix, command, payload = line.split("\t", 2)
        if prefix != "CASE":
            fail(f"unexpected probe line: {line!r}")
        result[command] = payload
    if list(result) != CASES:
        fail(f"unexpected probe cases: {list(result)!r}")
    return result


def records(payload: str) -> list[list[str]]:
    if payload == "FALLBACK":
        return []
    return [record.split(FS) for record in payload.split(RS)]


def option(records_: list[list[str]], prefix: str) -> list[str]:
    values: list[str] = []
    for record in records_:
        values.extend(field.removeprefix(prefix) for field in record if field.startswith(prefix))
    return values


def row_values(record: list[str]) -> list[int]:
    candidates = [
        field.removeprefix("--vorhervonausschnitt=")
        for field in record
        if field.startswith("--vorhervonausschnitt=")
    ]
    if len(candidates) != 1:
        fail(f"record has no unique row selector: {record!r}")
    return [int(value) for value in candidates[0].split(",") if value]


def assert_csv_rectangles() -> None:
    expected = {
        "gebrochen-rational-emotionen.csv": (7, 7),
        "gebrochen-rational-galaxie.csv": (21, 21),
        "gebrochen-rational-strukturgroesse.csv": (16, 16),
        "gebrochen-rational-universum.csv": (21, 19),
    }
    csv_root = ROOT / "python_reference" / "csv"
    for name, shape in expected.items():
        with (csv_root / name).open(encoding="utf-8", newline="") as handle:
            table = list(csv.reader(handle, delimiter=";"))
        actual = (len(table), len(table[0]))
        if actual != shape or any(len(row) != shape[1] for row in table):
            fail(f"fraction CSV shape drift for {name}: {actual}, expected {shape}")


def assert_python_bug_is_still_reproducible() -> None:
    environment = os.environ.copy()
    environment["PYTHONHASHSEED"] = "0"
    for command in (
        "universum v2/3",
        "universum v1/2,2/3",
        "universum v1/4,-1/8,2/3",
    ):
        completed = subprocess.run(
            [sys.executable, "python_reference/rpb", command],
            cwd=ROOT,
            env=environment,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=120,
        )
        if completed.returncode == 0:
            fail(
                "Python reference unexpectedly stopped reproducing PY-OPEN-002 "
                f"for {command!r}"
            )
        if "IndexError: string index out of range" not in completed.stderr:
            fail("Python reference failed differently; defect evidence must be reviewed")
        if "prompt_execution.py" not in completed.stderr:
            fail("Python traceback no longer points to prompt_execution.py")


def assert_python_negative_multiple_noops() -> None:
    environment = os.environ.copy()
    environment["PYTHONHASHSEED"] = "0"
    for command in (
        "universum v-1/4,2/3",
        "universum v-2/3",
        "universum v-2/3,1/4",
    ):
        completed = subprocess.run(
            [sys.executable, "python_reference/rpb", command],
            cwd=ROOT,
            env=environment,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=120,
        )
        if completed.returncode != 0 or completed.stderr:
            fail(f"negative multiple reference branch changed for {command!r}")
        lines = completed.stdout.splitlines()
        if len(lines) != 1 or not lines[0].endswith("reta-Befehl:"):
            fail(
                "negative multiple reference branch no longer emits exactly "
                f"one announcement and zero commands: {command!r}"
            )


def assert_domain_plan(
    payload: str,
    prefix: str,
    expected_numerators: list[int],
    expected_denominators: set[int],
    expected_count: int,
) -> list[list[str]]:
    plan = records(payload)
    if len(plan) != expected_count:
        fail(f"wrong invocation count for {prefix}: {len(plan)} != {expected_count}")
    numerators = [int(value) for value in option(plan, prefix)]
    if numerators != expected_numerators:
        fail(f"wrong numerator rectangle for {prefix}: {numerators}")
    fraction_records = [record for record in plan if any(field.startswith(prefix) for field in record)]
    for record in fraction_records:
        if set(row_values(record)) != expected_denominators:
            fail(f"wrong denominator rectangle in {record!r}")
    return plan


def assert_direct_execution(payload: str, runner: Path) -> None:
    environment = os.environ.copy()
    environment["RETA_PYTHON"] = "/definitely/not/available"
    total_bytes = 0
    plan = records(payload)
    for index, arguments in enumerate(plan):
        completed = subprocess.run(
            [str(runner), *arguments, "--art=csv", "--nocolor"],
            cwd=ROOT,
            env=environment,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            timeout=120,
        )
        if completed.returncode != 0:
            fail(
                f"direct true-fraction invocation {index} failed: "
                + completed.stderr.decode("utf-8", errors="replace")[:500]
            )
        total_bytes += len(completed.stdout)
    if len(plan) != 13 or total_bytes == 0:
        fail("direct true-fraction execution did not exercise the complete plan")


def main() -> int:
    if len(sys.argv) != 3:
        fail("usage: check_prompt_true_fraction_multiples.py PROBE NATIVE_RETA")
    assert_csv_rectangles()
    assert_python_bug_is_still_reproducible()
    assert_python_negative_multiple_noops()
    result = parse_probe(Path(sys.argv[1]).resolve())

    universe = assert_domain_plan(
        result["universum v2/3"],
        "--gebrochen-rational_Universum_n/m=",
        list(range(2, 21, 2)),
        set(range(3, 22, 3)),
        13,
    )
    if result["universum vielfache 2/3"] != result["universum v2/3"]:
        fail("compact and spelled true-fraction multiple plans differ")
    if set(row_values(universe[0])) != {1, 2, 3, 4, 6}:
        fail("wrong whole-number projection for Universe v2/3")
    if set(row_values(universe[1])) != {1, 2, 3, 6, 9}:
        fail("wrong reciprocal projection for Universe v2/3")
    if set(row_values(universe[-1])) != {6, 12, 18}:
        fail("wrong equal-axis projection for Universe v2/3")

    universe_divider = records(result["universum v2/3 teiler"])
    if len(universe_divider) != 13:
        fail("true fraction + divider lost an invocation")
    if "--spaltenreihenfolgeundnurdiese=1" not in universe_divider[0]:
        fail("divider command count did not narrow the Universe column pair")

    assert_domain_plan(
        result["emotion v2/3"],
        "--gebrochen-rational_Gefuehle_n/m=",
        [2, 4, 6, 8],
        {3, 6},
        6,
    )
    assert_domain_plan(
        result["groesse v2/3"],
        "--gebrochen-rational_Strukturgroesse_n/m=",
        list(range(2, 17, 2)),
        set(range(3, 17, 3)),
        12,
    )
    assert_domain_plan(
        result["motive v2/3"],
        "--gebrochen-rational_Galaxie_n/m=",
        list(range(2, 23, 2)),
        set(range(3, 22, 3)),
        13,
    )
    assert_domain_plan(
        result["emotion v8/3"],
        "--gebrochen-rational_Gefuehle_n/m=",
        [8],
        {3, 6},
        1,
    )
    assert_domain_plan(
        result["groesse v17/3"],
        "--gebrochen-rational_Strukturgroesse_n/m=",
        [17],
        {3, 6, 9, 12, 15},
        1,
    )
    assert_domain_plan(
        result["motive v22/3"],
        "--gebrochen-rational_Galaxie_n/m=",
        [22],
        set(range(3, 22, 3)),
        1,
    )
    assert_domain_plan(
        result["universum v20/3"],
        "--gebrochen-rational_Universum_n/m=",
        [20],
        set(range(3, 22, 3)),
        1,
    )
    if result["universum motive v2/3"] != "FALLBACK":
        fail("different fraction CSV rectangles must remain atomic fallback")

    mixed = assert_domain_plan(
        result["universum v1/2,2/3"],
        "--gebrochen-rational_Universum_n/m=",
        list(range(2, 21, 2)),
        set(range(3, 22, 3)),
        13,
    )
    if set(row_values(mixed[0])) != {1, 2, 3, 4, 6}:
        fail("wrong whole-number projection for mixed reciprocal/true fraction")
    expected_reciprocals = set(range(2, 1024, 2)) | {1, 3, 9}
    if set(row_values(mixed[1])) != expected_reciprocals:
        fail("mixed reciprocal axis did not preserve both independent bounds")
    if set(row_values(mixed[-1])) != {6, 12, 18}:
        fail("mixed equal-axis projection drifted")
    if result["universum vielfache 1/2,2/3"] != result["universum v1/2,2/3"]:
        fail("compact and spelled mixed-axis plans differ")

    # These negative-first historical branches print only the compact transformation
    # announcement.  An empty string is a handled zero-invocation plan;
    # FALLBACK would re-enter the Python child and duplicate that effect.
    for command in (
        "universum v-1/4,2/3",
        "universum v-2/3",
        "universum v-2/3,1/4",
    ):
        if result[command] != "":
            fail(f"stable negative multiple branch is not an empty native plan: {command}")
    if result["universum v1/4,-2/3"] != "FALLBACK":
        fail("positive-first excluded true fraction must remain atomic fallback")
    if result["universum v1/4,-1/8,2/3"] != "FALLBACK":
        fail("positive/excluded reciprocal collision must remain atomic fallback")

    runner = Path(sys.argv[2]).resolve()
    assert_direct_execution(result["universum v2/3"], runner)
    assert_direct_execution(result["universum v1/2,2/3"], runner)

    print(
        "true fraction multiples: Python crashes reproduced; "
        "Mojo contract 13/13, mixed bounds, negative no-op branches, "
        "and direct invocations valid"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
