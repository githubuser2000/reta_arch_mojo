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
    "emotion groesse motive universum v2/3",
    "emotion universum v8/3",
    "emotion universum v1/2,2/3",
    "mond universum motive v2/3",
    "universum v2/3,5",
    "universum v2/3,5 teiler",
    "universum motive v2/3,5",
    "emotion universum v8/3,5",
    "emotion universum v1/2,2/3,5",
    "universum motive v2/3,5-7",
    "universum motive v2/3,0",
    "universum motive v2/3,5,-10",
    "universum motive v2/3,-10",
    "universum v2/3,0,-10",
    "universum v2/3,5-7,-6",
    "universum motive v2/3 -10",
    "universum v2/3,0 teiler",
    "universum v2/3,5,-10 teiler",
    "universum v1/2,2/3",
    "universum vielfache 1/2,2/3",
    "universum v-1/4,2/3",
    "universum v-2/3",
    "universum v-2/3,1/4",
    "universum v1/4,-2/3",
    "universum v1/2,-2/3",
    "emotion v1/4,-2/3",
    "universum v1/4,-2/3 teiler",
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


def records_with(records_: list[list[str]], *needles: str) -> list[list[str]]:
    return [
        record
        for record in records_
        if all(any(needle in field for field in record) for needle in needles)
    ]


def assert_fraction_rectangle(
    plan: list[list[str]],
    prefix: str,
    expected_numerators: list[int],
    expected_denominators: set[int],
) -> list[list[str]]:
    numerators = [int(value) for value in option(plan, prefix)]
    if numerators != expected_numerators:
        fail(f"wrong numerator rectangle for {prefix}: {numerators}")
    fraction_records = [
        record for record in plan if any(field.startswith(prefix) for field in record)
    ]
    for record in fraction_records:
        if set(row_values(record)) != expected_denominators:
            fail(f"wrong denominator rectangle in {record!r}")
    return fraction_records


def row_values(record: list[str]) -> list[int]:
    candidates = [
        field.removeprefix("--vorhervonausschnitt=")
        for field in record
        if field.startswith("--vorhervonausschnitt=")
    ]
    if len(candidates) != 1:
        fail(f"record has no unique row selector: {record!r}")
    return [int(value) for value in candidates[0].split(",") if value]


def row_selector(record: list[str]) -> str:
    candidates = [
        field.removeprefix("--vorhervonausschnitt=")
        for field in record
        if field.startswith("--vorhervonausschnitt=")
    ]
    if len(candidates) != 1:
        fail(f"record has no unique raw row selector: {record!r}")
    return candidates[0]


def reference_records(command: str) -> list[list[str]]:
    environment = os.environ.copy()
    environment["PYTHONHASHSEED"] = "0"
    completed = subprocess.run(
        [
            sys.executable,
            "scripts/prompt_mixed_reciprocal_reference.py",
            command,
        ],
        cwd=ROOT,
        env=environment,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=120,
        check=True,
    )
    lines = [line for line in completed.stdout.split(b"\n") if line]
    if len(lines) != 1:
        fail(f"unexpected reference-plan line count for {command!r}")
    payload = lines[0].decode("utf-8")
    if payload == "FALLBACK":
        fail(f"Python reference unexpectedly rejected {command!r}")
    return records(payload)


def assert_python_integer_axis_composition() -> None:
    """Freeze the stable integer-axis shell around Python's faulty n/m grid."""
    ordinary = reference_records("universum v2/3,5")
    if "--vielfachevonzahlen=5" not in ordinary[0]:
        fail("Python reference lost the ordinary multiple option")
    if not row_selector(ordinary[0]).endswith(",5,v5"):
        fail("Python reference changed projected/integer/vN row ordering")

    divider = reference_records("universum v2/3,5 teiler")
    if any(field.startswith("--vielfachevonzahlen=") for field in divider[0]):
        fail("Python divider branch unexpectedly retained multiple option")
    if not row_selector(divider[0]).endswith(",5,v5"):
        fail("Python divider branch changed integer-axis row ordering")

    multi = reference_records("universum motive v2/3,5")
    motive = records_with(multi, "--Menschliches=motivation")
    universe = records_with(multi, "--Universum=transzendentalien")
    if not motive or not universe:
        fail("Python multi-domain integer composition lost a table family")
    if "--vielfachevonzahlen=5" not in motive[0] or "--vielfachevonzahlen=5" not in universe[0]:
        fail("Python multi-domain integer composition no longer duplicates the ordinary axis")


def assert_python_nonpositive_integer_axis_composition() -> None:
    """Freeze comma-local zero/exclusion spelling around Python's n/m bug."""
    cases = {
        "universum motive v2/3,0": (
            "--vielfachevonzahlen=0",
            ",0,v0",
        ),
        "universum motive v2/3,5,-10": (
            "--vielfachevonzahlen=5,-10",
            ",5,-10,v5,v-10",
        ),
        "universum motive v2/3,-10": (
            "--vielfachevonzahlen=-10",
            ",-10,v-10",
        ),
        "universum v2/3,0,-10": (
            "--vielfachevonzahlen=-10,0",
            ",-10,0,v-10,v0",
        ),
        "universum v2/3,5-7,-6": (
            "--vielfachevonzahlen=-6,5-7",
            ",-6,5-7,v-6,v5-7",
        ),
    }
    for command, (multiple_option, row_suffix) in cases.items():
        plan = reference_records(command)
        if not plan or multiple_option not in plan[0]:
            fail(f"Python reference changed non-positive multiple option for {command!r}")
        if not row_selector(plan[0]).endswith(row_suffix):
            fail(f"Python reference changed non-positive row ordering for {command!r}")

    # The standalone negative token is consumed as a parameter-like token by
    # the old prompt and reaches the known broken n/m branch.  It is not the
    # same grammar as a comma-local exclusion and remains an atomic boundary.
    environment = os.environ.copy()
    environment["PYTHONHASHSEED"] = "0"
    completed = subprocess.run(
        [sys.executable, "scripts/prompt_mixed_reciprocal_reference.py", "universum motive v2/3 -10"],
        cwd=ROOT,
        env=environment,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=120,
        check=True,
        text=True,
    )
    if completed.stdout.strip() != "FALLBACK":
        fail("standalone negative true-fraction boundary changed")


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
        "universum motive v2/3",
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


def assert_python_positive_first_reciprocal_only() -> None:
    environment = os.environ.copy()
    environment["PYTHONHASHSEED"] = "0"
    cases = {
        "universum v1/4,-2/3": (
            "--Universum=transzendentaliereziproke",
            "--spaltenreihenfolgeundnurdiese=1,2",
            set(range(4, 1024, 4)),
        ),
        "emotion v1/4,-2/3": (
            "--Grundstrukturen=emotion",
            "--spaltenreihenfolgeundnurdiese=4,5",
            set(range(4, 1024, 4)),
        ),
    }
    for command, (axis, columns, expected_rows) in cases.items():
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
            fail(f"positive-first reciprocal reference changed for {command!r}")
        reta_lines = [
            line for line in completed.stdout.splitlines() if line.startswith("reta ")
        ]
        if len(reta_lines) != 1:
            fail(f"expected exactly one reta invocation for {command!r}")
        arguments = reta_lines[0].split()
        if axis not in arguments or columns not in arguments:
            fail(f"wrong reciprocal output axis for {command!r}: {arguments!r}")
        if any("--gebrochen-rational_" in value for value in arguments):
            fail(f"excluded proper fraction leaked into a CSV axis for {command!r}")
        selectors = [
            value.removeprefix("--vorhervonausschnitt=")
            for value in arguments
            if value.startswith("--vorhervonausschnitt=")
        ]
        if len(selectors) != 1:
            fail(f"reference has no unique reciprocal selector for {command!r}")
        actual_rows = {int(value) for value in selectors[0].split(",") if value}
        if actual_rows != expected_rows:
            fail(f"wrong positive-first reciprocal rows for {command!r}")


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
    assert_fraction_rectangle(
        plan, prefix, expected_numerators, expected_denominators
    )
    return plan


def assert_direct_execution(
    payload: str, runner: Path, expected_count: int = 13
) -> None:
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
    if len(plan) != expected_count or total_bytes == 0:
        fail(
            "direct true-fraction execution did not exercise the complete plan: "
            f"{len(plan)} != {expected_count}"
        )


def main() -> int:
    if len(sys.argv) != 3:
        fail("usage: check_prompt_true_fraction_multiples.py PROBE NATIVE_RETA")
    assert_csv_rectangles()
    assert_python_bug_is_still_reproducible()
    assert_python_negative_multiple_noops()
    assert_python_positive_first_reciprocal_only()
    assert_python_integer_axis_composition()
    assert_python_nonpositive_integer_axis_composition()
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
    multi_domain = records(result["universum motive v2/3"])
    if len(multi_domain) != 26:
        fail(f"wrong Universe+motives invocation count: {len(multi_domain)}")
    assert_fraction_rectangle(
        multi_domain,
        "--gebrochen-rational_Galaxie_n/m=",
        list(range(2, 23, 2)),
        set(range(3, 22, 3)),
    )
    assert_fraction_rectangle(
        multi_domain,
        "--gebrochen-rational_Universum_n/m=",
        list(range(2, 21, 2)),
        set(range(3, 22, 3)),
    )
    if "--menschliches=motive" not in multi_domain[0]:
        fail("motives domain did not keep first execution ownership")
    if "--Universum=transzendentalien" not in multi_domain[13]:
        fail("Universe domain did not start after the complete Galaxy rectangle")
    if "--universum=verhaeltnisgleicherzahl" not in multi_domain[-1]:
        fail("Universe multi-domain equality axis is missing")
    if option(multi_domain, "--gebrochen-rational_Universum_n/m=")[-1] != "20":
        fail("Universe multi-domain rectangle leaked Galaxy numerator 22")

    all_domains = records(result["emotion groesse motive universum v2/3"])
    if len(all_domains) != 44:
        fail(f"wrong four-domain invocation count: {len(all_domains)}")
    assert_fraction_rectangle(
        all_domains,
        "--gebrochen-rational_Gefuehle_n/m=",
        list(range(2, 9, 2)),
        {3, 6},
    )
    assert_fraction_rectangle(
        all_domains,
        "--gebrochen-rational_Strukturgroesse_n/m=",
        list(range(2, 17, 2)),
        set(range(3, 17, 3)),
    )
    assert_fraction_rectangle(
        all_domains,
        "--gebrochen-rational_Galaxie_n/m=",
        list(range(2, 23, 2)),
        set(range(3, 22, 3)),
    )
    assert_fraction_rectangle(
        all_domains,
        "--gebrochen-rational_Universum_n/m=",
        list(range(2, 21, 2)),
        set(range(3, 22, 3)),
    )

    clipped_domains = records(result["emotion universum v8/3"])
    if len(clipped_domains) != 3:
        fail(f"wrong independently clipped v8/3 plan: {len(clipped_domains)}")
    assert_fraction_rectangle(
        clipped_domains,
        "--gebrochen-rational_Gefuehle_n/m=",
        [8],
        {3, 6},
    )
    assert_fraction_rectangle(
        clipped_domains,
        "--gebrochen-rational_Universum_n/m=",
        [8, 16],
        set(range(3, 22, 3)),
    )

    multi_mixed = records(result["emotion universum v1/2,2/3"])
    if len(multi_mixed) != 19:
        fail(f"wrong mixed two-domain invocation count: {len(multi_mixed)}")
    emotion_reciprocal = records_with(
        multi_mixed, "--grundstrukturen=emotion", "--spaltenreihenfolgeundnurdiese=4,5"
    )
    universe_reciprocal = records_with(
        multi_mixed,
        "--Universum=transzendentaliereziproke",
        "--spaltenreihenfolgeundnurdiese=1",
    )
    if len(emotion_reciprocal) != 1 or len(universe_reciprocal) != 1:
        fail("multi-domain reciprocal projections are not uniquely owned")
    if set(row_values(emotion_reciprocal[0])) != set(range(2, 1024, 2)) | {1, 3}:
        fail("Emotion reciprocal domain mixed the wrong true-fraction projection")
    if set(row_values(universe_reciprocal[0])) != set(range(2, 1024, 2)) | {1, 3, 9}:
        fail("Universe reciprocal domain mixed the wrong true-fraction projection")

    for command in (
        "mond universum motive v2/3",
        "universum motive v2/3 -10",
        "universum v2/3,0 teiler",
        "universum v2/3,5,-10 teiler",
    ):
        if result[command] != "FALLBACK":
            fail(f"unproved composition escaped atomically: {command}")

    zero_axis = records(result["universum motive v2/3,0"])
    if len(zero_axis) != 26:
        fail(f"wrong zero/fraction invocation count: {len(zero_axis)}")
    for index in (0, 13):
        if "--vielfachevonzahlen=0" not in zero_axis[index]:
            fail(f"zero multiple option missing from domain invocation {index}")
        if row_selector(zero_axis[index]) != "2,1,4,6,3,0,v0":
            fail(f"wrong corrected zero-axis ordering in domain invocation {index}")

    excluded_axis = records(result["universum motive v2/3,5,-10"])
    if len(excluded_axis) != 26:
        fail(f"wrong excluded integer/fraction invocation count: {len(excluded_axis)}")
    for index in (0, 13):
        if "--vielfachevonzahlen=5,-10" not in excluded_axis[index]:
            fail(f"excluded multiple option missing from domain invocation {index}")
        if row_selector(excluded_axis[index]) != "2,1,4,6,3,5,-10,v5,v-10":
            fail(f"wrong corrected exclusion-axis ordering in domain invocation {index}")

    exclusion_only = records(result["universum motive v2/3,-10"])
    if len(exclusion_only) != 26:
        fail("exclusion-only integer axis lost a fraction domain")
    if "--vielfachevonzahlen=-10" not in exclusion_only[0]:
        fail("exclusion-only multiple option is missing")
    if row_selector(exclusion_only[0]) != "2,1,4,6,3,-10,v-10":
        fail("exclusion-only corrected row ordering drifted")

    mixed_nonpositive = records(result["universum v2/3,0,-10"])
    if len(mixed_nonpositive) != 13:
        fail("mixed zero/exclusion axis lost a Universe invocation")
    if "--vielfachevonzahlen=-10,0" not in mixed_nonpositive[0]:
        fail("mixed zero/exclusion set order drifted")
    if row_selector(mixed_nonpositive[0]) != "2,1,4,6,3,-10,0,v-10,v0":
        fail("mixed zero/exclusion row ordering drifted")

    ranged_exclusion = records(result["universum v2/3,5-7,-6"])
    if len(ranged_exclusion) != 13:
        fail("range/exclusion axis lost a Universe invocation")
    if "--vielfachevonzahlen=-6,5-7" not in ranged_exclusion[0]:
        fail("range/exclusion source order drifted")
    if row_selector(ranged_exclusion[0]) != "2,1,4,6,3,-6,5-7,v-6,v5-7":
        fail("range/exclusion corrected row ordering drifted")

    single_integer = records(result["universum v2/3,5"])
    if len(single_integer) != 13:
        fail(f"wrong single-domain integer/fraction invocation count: {len(single_integer)}")
    if "--vielfachevonzahlen=5" not in single_integer[0]:
        fail("single-domain ordinary multiple option is missing")
    if row_selector(single_integer[0]) != "2,1,4,6,3,5,v5":
        fail("single-domain projected integer ordering drifted")
    if any(field.startswith("--oberesmaximum=") for field in single_integer[0]):
        fail("projected ordinary multiple base must not carry a synthetic maximum")

    single_divider = records(result["universum v2/3,5 teiler"])
    if len(single_divider) != 13:
        fail("single-domain divider composition lost an invocation")
    if any(field.startswith("--vielfachevonzahlen=") for field in single_divider[0]):
        fail("divider composition incorrectly retained --vielfachevonzahlen")
    if row_selector(single_divider[0]) != "2,1,4,6,3,5,v5":
        fail("divider composition changed projected integer ordering")

    multi_integer = records(result["universum motive v2/3,5"])
    if len(multi_integer) != 26:
        fail(f"wrong multi-domain integer/fraction invocation count: {len(multi_integer)}")
    for index in (0, 13):
        if "--vielfachevonzahlen=5" not in multi_integer[index]:
            fail(f"ordinary multiple option missing from domain invocation {index}")
        if row_selector(multi_integer[index]) != "2,1,4,6,3,5,v5":
            fail(f"wrong projected integer ordering in domain invocation {index}")

    clipped_integer = records(result["emotion universum v8/3,5"])
    if len(clipped_integer) != 5:
        fail(f"wrong clipped integer/fraction invocation count: {len(clipped_integer)}")
    if row_selector(clipped_integer[0]) != "5,v5":
        fail("Emotion empty whole projection did not retain ordinary multiples")
    if row_selector(clipped_integer[2]) != "5,v5":
        fail("Universe empty whole projection did not retain ordinary multiples")

    mixed_integer = records(result["emotion universum v1/2,2/3,5"])
    if len(mixed_integer) != 19:
        fail(f"wrong mixed reciprocal/integer/fraction count: {len(mixed_integer)}")
    if "--vielfachevonzahlen=5" not in mixed_integer[0] or "--vielfachevonzahlen=5" not in mixed_integer[7]:
        fail("ordinary multiple option did not reach both mixed fraction domains")
    if not row_selector(mixed_integer[0]).endswith(",5,v5"):
        fail("Emotion mixed integer axis lost the original/vN suffix")
    if not row_selector(mixed_integer[7]).endswith(",5,v5"):
        fail("Universe mixed integer axis lost the original/vN suffix")

    ranged_integer = records(result["universum motive v2/3,5-7"])
    if len(ranged_integer) != 26:
        fail("positive range did not retain complete multi-domain plan")
    if "--vielfachevonzahlen=5-7" not in ranged_integer[0]:
        fail("positive range spelling was not preserved")
    if not row_selector(ranged_integer[0]).endswith(",5-7,v5-7"):
        fail("positive range lost its original/vN selector suffix")

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
    positive_first = records(result["universum v1/4,-2/3"])
    if len(positive_first) != 1:
        fail("positive-first excluded true fraction must produce one reciprocal axis")
    if set(row_values(positive_first[0])) != set(range(4, 1024, 4)):
        fail("positive-first reciprocal axis lost its bounded multiples of four")
    if "--Universum=transzendentaliereziproke" not in positive_first[0]:
        fail("positive-first Universe reciprocal axis is missing")
    if any("--gebrochen-rational_" in field for field in positive_first[0]):
        fail("excluded true fraction leaked into a proper-fraction invocation")

    positive_half = records(result["universum v1/2,-2/3"])
    if len(positive_half) != 1 or set(row_values(positive_half[0])) != set(
        range(2, 1024, 2)
    ):
        fail("positive-first reciprocal half axis is not complete")

    positive_emotion = records(result["emotion v1/4,-2/3"])
    if len(positive_emotion) != 1:
        fail("emotion positive-first branch must have one reciprocal invocation")
    if "--Grundstrukturen=emotion" not in positive_emotion[0]:
        fail("emotion positive-first reciprocal axis is missing")
    if "--spaltenreihenfolgeundnurdiese=4,5" not in positive_emotion[0]:
        fail("emotion reciprocal columns drifted")

    positive_divisor = records(result["universum v1/4,-2/3 teiler"])
    if len(positive_divisor) != 1:
        fail("positive-first divider branch must have one reciprocal invocation")
    if "--spaltenreihenfolgeundnurdiese=1" not in positive_divisor[0]:
        fail("divider command did not narrow the Universe reciprocal columns")

    collision = assert_domain_plan(
        result["universum v1/4,-1/8,2/3"],
        "--gebrochen-rational_Universum_n/m=",
        list(range(2, 21, 2)),
        set(range(3, 22, 3)),
        13,
    )
    expected_collision_rows = {1, 2, 3, 6, 9} | {
        value for value in range(4, 1024, 4) if value % 8 != 0
    }
    if set(row_values(collision[1])) != expected_collision_rows:
        fail("reciprocal subtraction collision lost its independent row axis")
    if set(row_values(collision[0])) != {1, 2, 3, 4, 6}:
        fail("reciprocal collision changed the whole-number projection")
    if set(row_values(collision[-1])) != {6, 12, 18}:
        fail("reciprocal collision changed the equal-axis projection")

    runner = Path(sys.argv[2]).resolve()
    assert_direct_execution(result["universum v2/3"], runner)
    assert_direct_execution(
        result["universum motive v2/3"], runner, expected_count=26
    )
    assert_direct_execution(result["universum v1/2,2/3"], runner)
    assert_direct_execution(
        result["universum v1/4,-2/3"], runner, expected_count=1
    )
    assert_direct_execution(result["universum v1/4,-1/8,2/3"], runner)

    print(
        "true fraction multiples: Python crashes reproduced; "
        "Mojo contract 13/13, mixed bounds, negative no-op branches, "
        "positive-first reciprocal-only and reciprocal-collision branches, "
        "domain-specific 26/26 and 44-plan grids, and direct invocations valid"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
