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
    "emotion universum v 1/2,2/3",
    "mond universum v2/3",
    "mond universum motive v2/3",
    "mond richtung primzahlkreuz alles thomas universum v2/3",
    "mond universum motive v2/3,5",
    "mond universum motive v2/3,5 teiler",
    "mond emotion universum v2/3,5",
    "mond richtung primzahlkreuz alles thomas universum motive v2/3,5",
    "universum v2/3,5",
    "universum v2/3,1 teiler",
    "universum v2/3,5 teiler",
    "universum motive v2/3,5",
    "emotion universum v8/3,5",
    "emotion universum v1/2,2/3,5",
    "emotion universum v 1/2,2/3,5",
    "universum motive v2/3,5-7",
    "universum motive v2/3,0",
    "universum motive v2/3,5,-10",
    "universum motive v2/3,-10",
    "universum v2/3,0,-10",
    "universum v2/3,5-7,-6",
    "universum motive v2/3 -10",
    "universum v2/3,0 teiler",
    "universum v2/3,5,-10 teiler",
    "universum motive v2/3,0 teiler",
    "universum v1/2,2/3",
    "universum v 1/2,2/3",
    "universum vielfache 1/2,2/3",
    "universum v-1/4,2/3",
    "universum v-2/3",
    "universum v-2/3,1/4",
    "universum v1/4,-2/3",
    "universum v1/2,-2/3",
    "emotion v1/4,-2/3",
    "universum v1/4,-2/3 teiler",
    "universum v1/4,-1/8,2/3",
    "universum v 1/4,-1/8,2/3",
    "v universum 1/4,-1/8,2/3",
    "universum 1/4,-1/8,2/3 v",
    "universum vielfache 1/4,-1/8,2/3",
    "emotion universum v1/4,-1/8,2/3",
    "emotion universum v 1/4,-1/8,2/3",
    "motive EIGNgut universum v2/3",
    "motive EIGNgut EIGRwerte universum v2/3",
    "motive universum 15_13 16_2 v2/3,5",
    "motive universum 15_13 16_2 v2/3",
    "mond motive EIGNgut universum v2/3,5",
    "mond motive universum 15_13 16_2 v2/3,5",
    (
        "mond richtung primzahlkreuz alles thomas motive EIGNgut "
        "universum 15_13 16_2 v2/3,5"
    ),
    (
        "mond richtung primzahlkreuz alles thomas motive EIGNgut "
        "EIGRwerte universum 15_13 16_2 v2/3,5"
    ),
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


_REFERENCE_PAYLOADS: dict[str, str] = {}


def load_reference_payloads(commands: list[str]) -> None:
    missing = [command for command in commands if command not in _REFERENCE_PAYLOADS]
    if not missing:
        return
    environment = os.environ.copy()
    environment["PYTHONHASHSEED"] = "0"
    completed = subprocess.run(
        [
            sys.executable,
            "scripts/prompt_mixed_reciprocal_reference.py",
            *missing,
        ],
        cwd=ROOT,
        env=environment,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=600,
        check=True,
    )
    lines = [line for line in completed.stdout.split(b"\n") if line]
    if len(lines) != len(missing):
        fail(
            "unexpected batched reference-plan line count: "
            f"{len(lines)} != {len(missing)}"
        )
    for command, line in zip(missing, lines, strict=True):
        _REFERENCE_PAYLOADS[command] = line.decode("utf-8")


def reference_payload(command: str) -> str:
    load_reference_payloads([command])
    return _REFERENCE_PAYLOADS[command]


def reference_records(command: str) -> list[list[str]]:
    payload = reference_payload(command)
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

    one_divider = reference_records("universum v2/3,1 teiler")
    if row_selector(one_divider[0]).split(",")[-2:] != ["1", "v1"]:
        fail("Python divider branch changed the value-one outer suffix")

    divider = reference_records("universum v2/3,5 teiler")
    if any(field.startswith("--vielfachevonzahlen=") for field in divider[0]):
        fail("Python divider branch unexpectedly retained multiple option")
    if row_selector(divider[0]).split(",")[-3:] != ["1", "5", "v5"]:
        fail("Python divider branch changed the row-1/divisor/vN suffix")

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

    divider_cases = {
        "universum v2/3,0 teiler": ",v0",
        "universum v2/3,5,-10 teiler": ",1,5,5,-10,v5,v-10",
        "universum v2/3,-10 teiler": ",-10,v-10",
        "universum v2/3,0,-10 teiler": ",-10,0,v-10,v0",
        "universum v2/3,5-7,-6 teiler": ",1,5,7,-6,5-7,v-6,v5-7",
    }
    for command, row_suffix in divider_cases.items():
        plan = reference_records(command)
        if any(field.startswith("--vielfachevonzahlen=") for field in plan[0]):
            fail(f"Python divider unexpectedly retained multiple option for {command!r}")
        if not row_selector(plan[0]).endswith(row_suffix):
            fail(f"Python divider changed its stable outer suffix for {command!r}")

    # The standalone negative token is consumed as a parameter-like no-op by
    # the old prompt and then reaches the known broken n/m rectangle.  The
    # reference therefore still reports FALLBACK, while native Mojo preserves
    # the consumed-token fact around its corrected rectangle.
    if reference_payload("universum motive v2/3 -10") != "FALLBACK":
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
        "universum v 1/2,2/3",
        "universum v1/4,-1/8,2/3",
        "universum v 1/4,-1/8,2/3",
        "v universum 1/4,-1/8,2/3",
        "universum 1/4,-1/8,2/3 v",
        "universum vielfache 1/4,-1/8,2/3",
        "emotion universum v1/4,-1/8,2/3",
        "emotion universum v 1/4,-1/8,2/3",
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
    """Freeze the argv plan without rendering the enormous reference table.

    Parsing the one-shot prompt's human-facing stdout is not hermetic: aliases,
    terminal policy and localized announcements can change how the printed
    command line is framed even when the executor argv is identical.  The
    shared reference probe replaces only ``retaExecuteNprint`` and records the
    exact call, which is the contract the Mojo planner must reproduce.
    """
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
    load_reference_payloads(list(cases))
    for command, (axis, columns, expected_rows) in cases.items():
        plan = reference_records(command)
        if len(plan) != 1:
            fail(
                "expected exactly one collected reta invocation for "
                f"{command!r}, got {len(plan)}"
            )
        arguments = plan[0]
        if axis not in arguments or columns not in arguments:
            fail(f"wrong reciprocal output axis for {command!r}: {arguments!r}")
        if any("--gebrochen-rational_" in value for value in arguments):
            fail(f"excluded proper fraction leaked into a CSV axis for {command!r}")
        actual_rows = set(row_values(arguments))
        if actual_rows != expected_rows:
            fail(f"wrong positive-first reciprocal rows for {command!r}")


def assert_multi_domain_extension_plans(result: dict[str, str]) -> None:
    eign = records(result["motive EIGNgut universum v2/3"])
    if len(eign) != 27:
        fail(f"wrong multi-domain EIGN invocation count: {len(eign)}")
    if "--konzept=gut" not in eign[13]:
        fail("multi-domain EIGN axis is not between Motives and Universe")
    if "--Universum=transzendentalien" not in eign[14]:
        fail("Universe block no longer follows multi-domain EIGN")

    properties = records(
        result["motive EIGNgut EIGRwerte universum v2/3"]
    )
    if len(properties) != 28:
        fail(f"wrong multi-domain property invocation count: {len(properties)}")
    if "--konzept=gut" not in properties[13]:
        fail("EIGN order drifted in multi-domain plan")
    if "--konzept2=werte" not in properties[14]:
        fail("EIGR order drifted in multi-domain plan")
    if "--Universum=transzendentalien" not in properties[15]:
        fail("Universe block no longer follows EIGN/EIGR")

    numeric = records(result["motive universum 15_13 16_2 v2/3,5"])
    if len(numeric) != 28:
        fail(f"wrong multi-domain numeric invocation count: {len(numeric)}")
    if not any(value.startswith("--Multiversum=") for value in numeric[26]):
        fail("numeric family 16 is not the first tail invocation")
    if not any(value.startswith("--Grundstrukturen=") for value in numeric[27]):
        fail("numeric family 15 is not the second tail invocation")
    if "--vielfachevonzahlen=5" not in numeric[26]:
        fail("numeric tail lost the explicit ordinary multiple axis")

    projected = records(result["motive universum 15_13 16_2 v2/3"])
    if len(projected) != 28:
        fail("projected-only numeric plan has the wrong invocation count")
    if any(
        value.startswith("--vielfachevonzahlen=")
        for value in projected[26]
    ):
        fail("projected whole rows were multiplied a second time")

    classic_property = records(
        result["mond motive EIGNgut universum v2/3,5"]
    )
    if len(classic_property) != 28:
        fail(
            "wrong classic/property multi-domain invocation count: "
            f"{len(classic_property)}"
        )
    if "--konzept=gut" not in classic_property[13]:
        fail("classic/property plan moved EIGN out of its physical position")
    if "--Bedeutung=gestirn" not in classic_property[27]:
        fail("classic/property plan lost the Moon suffix")

    classic_numeric = records(
        result["mond motive universum 15_13 16_2 v2/3,5"]
    )
    if len(classic_numeric) != 29:
        fail(
            "wrong classic/numeric multi-domain invocation count: "
            f"{len(classic_numeric)}"
        )
    if "--Bedeutung=gestirn" not in classic_numeric[26]:
        fail("classic/numeric plan moved Moon behind the catalog tail")
    if not any(
        value.startswith("--Multiversum=") for value in classic_numeric[27]
    ):
        fail("classic/numeric plan lost family-16 tail position")
    if not any(
        value.startswith("--Grundstrukturen=") for value in classic_numeric[28]
    ):
        fail("classic/numeric plan lost family-15 tail position")

    combined_command = (
        "mond richtung primzahlkreuz alles thomas motive EIGNgut "
        "universum 15_13 16_2 v2/3,5"
    )
    combined = records(result[combined_command])
    if len(combined) != 34:
        fail(f"wrong complete combined outer plan count: {len(combined)}")
    expected_markers = (
        (0, "--galaxie=thomas"),
        (14, "--konzept=gut"),
        (15, "--Universum=transzendentalien"),
        (28, "--Bedeutung=gestirn"),
        (29, "--alles"),
        (30, "--Bedeutung=primzahlkreuz"),
        (31, "--Primzahlwirkung=Galaxieabsicht"),
        (32, "--Multiversum="),
        (33, "--Grundstrukturen="),
    )
    for index, marker in expected_markers:
        if not any(value.startswith(marker) for value in combined[index]):
            fail(
                f"combined outer order drifted at {index}: "
                f"expected {marker!r}, got {combined[index]!r}"
            )

    combined_properties_command = (
        "mond richtung primzahlkreuz alles thomas motive EIGNgut "
        "EIGRwerte universum 15_13 16_2 v2/3,5"
    )
    combined_properties = records(result[combined_properties_command])
    if len(combined_properties) != 35:
        fail(
            "wrong combined EIGN/EIGR outer plan count: "
            f"{len(combined_properties)}"
        )
    if "--konzept=gut" not in combined_properties[14]:
        fail("combined property plan moved EIGN")
    if "--konzept2=werte" not in combined_properties[15]:
        fail("combined property plan moved EIGR")
    if "--Universum=transzendentalien" not in combined_properties[16]:
        fail("combined property plan moved Universe before EIGR")

    # The frozen Python controller executes numeric 16 before 15 after the
    # physical domain blocks.  Its n/m grid is known-bad, so only this stable
    # outer ordering is imported into the corrected native plan.
    reference = reference_records("motive universum 15_13 16_2 v2/3,5")
    if not any(value.startswith("--Multiversum=") for value in reference[-2]):
        fail("Python numeric family-16 tail order changed")
    if not any(
        value.startswith("--Grundstrukturen=") for value in reference[-1]
    ):
        fail("Python numeric family-15 tail order changed")


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


def assert_python_classic_fraction_guard() -> None:
    completed = subprocess.run(
        [sys.executable, "scripts/prompt_classic_fraction_guard_reference.py"],
        cwd=ROOT,
        env={**os.environ, "PYTHONHASHSEED": "0"},
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=600,
        check=True,
        text=True,
    )
    rows: dict[str, tuple[str, int, int]] = {}
    for line in completed.stdout.splitlines():
        command, error, call_count, classic_count = line.split("\t")
        rows[command] = (error, int(call_count), int(classic_count))
    pure_commands = [
        "universum motive v2/3",
        "mond universum motive v2/3",
        "richtung universum motive v2/3",
        "primzahlkreuz universum motive v2/3",
        "alles universum motive v2/3",
        "thomas universum motive v2/3",
    ]
    for command in pure_commands:
        if rows.get(command) != ("IndexError", 0, 0):
            fail(
                f"Python classic fraction guard drifted for {command!r}: "
                f"{rows.get(command)!r}"
            )
    explicit = rows.get("mond universum motive v2/3,5")
    if explicit is None or explicit[0] != "SystemExit" or explicit[2] != 1:
        fail(f"Python ordinary integer activation drifted: {explicit!r}")


def main() -> int:
    if len(sys.argv) != 3:
        fail("usage: check_prompt_true_fraction_multiples.py PROBE NATIVE_RETA")
    load_reference_payloads(
        [
            "universum v2/3,5",
            "universum v2/3,1 teiler",
            "universum v2/3,5 teiler",
            "universum motive v2/3,5",
            "universum motive v2/3,0",
            "universum motive v2/3,5,-10",
            "universum motive v2/3,-10",
            "universum v2/3,0,-10",
            "universum v2/3,5-7,-6",
            "universum v2/3,0 teiler",
            "universum v2/3,5,-10 teiler",
            "universum v2/3,-10 teiler",
            "universum v2/3,0,-10 teiler",
            "universum v2/3,5-7,-6 teiler",
            "universum motive v2/3 -10",
            "universum v1/4,-2/3",
            "emotion v1/4,-2/3",
            "motive universum 15_13 16_2 v2/3,5",
        ]
    )
    assert_csv_rectangles()
    assert_python_classic_fraction_guard()
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
    if len(multi_mixed) != 4:
        fail(f"wrong component-local mixed two-domain count: {len(multi_mixed)}")
    emotion_reciprocal = records_with(
        multi_mixed, "--grundstrukturen=emotion", "--spaltenreihenfolgeundnurdiese=4,5"
    )
    universe_reciprocal = records_with(
        multi_mixed,
        "--Universum=transzendentaliereziproke",
        "--spaltenreihenfolgeundnurdiese=1",
    )
    if len(emotion_reciprocal) != 1 or len(universe_reciprocal) != 1:
        fail("component-local multi-domain reciprocal projections are not unique")
    if set(row_values(emotion_reciprocal[0])) != set(range(2, 1024, 2)):
        fail("Emotion local reciprocal axis incorrectly inherited literal 2/3")
    if set(row_values(universe_reciprocal[0])) != set(range(2, 1024, 2)):
        fail("Universe local reciprocal axis incorrectly inherited literal 2/3")
    for prefix in (
        "--gebrochen-rational_Gefuehle_n/m=2",
        "--gebrochen-rational_Universum_n/m=2",
    ):
        literal = records_with(multi_mixed, prefix)
        if len(literal) != 1 or set(row_values(literal[0])) != {3}:
            fail(f"component-local 2/3 literal axis drifted for {prefix}")

    global_multi_mixed = records(result["emotion universum v 1/2,2/3"])
    if len(global_multi_mixed) != 19:
        fail(f"wrong global mixed two-domain invocation count: {len(global_multi_mixed)}")

    if result["mond universum motive v2/3"] != result["universum motive v2/3"]:
        fail("inert moon changed the corrected multi-domain fraction plan")

    moon_single = records(result["mond universum v2/3"])
    if len(moon_single) != 13:
        fail("inert moon changed the single-domain invocation count")
    if records_with(moon_single, "--Bedeutung=gestirn"):
        fail("projected fraction rows incorrectly activated the moon table")
    if "--spaltenreihenfolgeundnurdiese=1" not in moon_single[0]:
        fail("inert classic command did not preserve narrow Universe columns")

    all_classic = records(
        result["mond richtung primzahlkreuz alles thomas universum v2/3"]
    )
    if len(all_classic) != 13:
        fail("classic integer-only no-ops changed the fraction plan")
    forbidden = (
        "--Bedeutung=gestirn",
        "--Primzahlwirkung=Galaxieabsicht",
        "--Bedeutung=primzahlkreuz",
        "--alles",
        "--galaxie=thomas",
    )
    if any(
        any(marker in field for marker in forbidden)
        for record in all_classic
        for field in record
    ):
        fail("a classic integer-only table escaped its ordinary-number guard")

    moon_explicit = records(result["mond universum motive v2/3,5"])
    if len(moon_explicit) != 27:
        fail("classic moon composition lost the corrected two-domain plan")
    if "--Bedeutung=gestirn" not in moon_explicit[26]:
        fail("classic moon did not follow the corrected fraction domains")
    if "--vielfachevonzahlen=5" not in moon_explicit[26]:
        fail("classic moon lost the ordinary multiple axis")
    if row_selector(moon_explicit[26]) != "2,1,4,6,3,5,v5":
        fail("classic moon changed the ordered union projection")

    union_moon = records(result["mond emotion universum v2/3,5"])
    if len(union_moon) != 20:
        fail("classic moon lost the emotion/universe corrected plan")
    if row_selector(union_moon[19]) != "2,1,4,6,3,5,v5":
        fail("classic moon did not union domain projections in physical order")

    divider_moon = records(result["mond universum motive v2/3,5 teiler"])
    if len(divider_moon) != 27:
        fail("classic divider moon lost the corrected two-domain plan")
    if any(field.startswith("--vielfachevonzahlen=") for field in divider_moon[26]):
        fail("classic divider moon incorrectly retained multiples")
    if row_selector(divider_moon[26]) != "2,1,4,6,3,1,5,v5":
        fail("classic divider moon changed divisor/projection ordering")

    all_classic_explicit = records(
        result[
            "mond richtung primzahlkreuz alles thomas universum motive v2/3,5"
        ]
    )
    if len(all_classic_explicit) != 31:
        fail("complete classic composition has the wrong invocation count")
    expected_classic_order = (
        (0, "--galaxie=thomas"),
        (27, "--Bedeutung=gestirn"),
        (28, "--alles"),
        (29, "--Bedeutung=primzahlkreuz"),
        (30, "--Primzahlwirkung=Galaxieabsicht"),
    )
    for index, marker in expected_classic_order:
        if marker not in all_classic_explicit[index]:
            fail(f"classic invocation order drifted at {index}: {marker}")
    prime_cross = all_classic_explicit[29]
    if "--vielfachevonzahlen=5" not in prime_cross:
        fail("classic prime-cross lost the ordinary multiple axis")
    if "--oberesmaximum=1029" not in prime_cross:
        fail("classic prime-cross lost its historical upper maximum")
    if any(field.startswith("--vorhervonausschnitt=") for field in prime_cross):
        fail("classic prime-cross incorrectly inherited projected rows")

    if result["universum motive v2/3 -10"] != result["universum motive v2/3"]:
        fail("standalone negative no-op changed the corrected fraction plan")

    zero_divider = records(result["universum v2/3,0 teiler"])
    if len(zero_divider) != 13:
        fail("zero divider composition lost a Universe invocation")
    if any(field.startswith("--vielfachevonzahlen=") for field in zero_divider[0]):
        fail("zero divider incorrectly retained --vielfachevonzahlen")
    if row_selector(zero_divider[0]) != "2,1,4,6,3,v0":
        fail("zero divider did not retain exactly the corrected projection and v0")

    excluded_divider = records(result["universum v2/3,5,-10 teiler"])
    if len(excluded_divider) != 13:
        fail("excluded divider composition lost a Universe invocation")
    if any(field.startswith("--vielfachevonzahlen=") for field in excluded_divider[0]):
        fail("excluded divider incorrectly retained --vielfachevonzahlen")
    if row_selector(excluded_divider[0]) != "2,1,4,6,3,1,5,5,-10,v5,v-10":
        fail("excluded divider changed divisor/raw/v ordering")

    multi_zero_divider = records(result["universum motive v2/3,0 teiler"])
    if len(multi_zero_divider) != 26:
        fail("multi-domain zero divider lost a physical domain")
    for index in (0, 13):
        if row_selector(multi_zero_divider[index]) != "2,1,4,6,3,v0":
            fail(f"multi-domain zero divider drifted at invocation {index}")

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

    one_divider = records(result["universum v2/3,1 teiler"])
    if len(one_divider) != 13:
        fail("value-one divider composition lost an invocation")
    if row_selector(one_divider[0]) != "2,1,4,6,3,1,v1":
        fail("value-one divider duplicated or lost the outer row-1 sentinel")

    single_divider = records(result["universum v2/3,5 teiler"])
    if len(single_divider) != 13:
        fail("single-domain divider composition lost an invocation")
    if any(field.startswith("--vielfachevonzahlen=") for field in single_divider[0]):
        fail("divider composition incorrectly retained --vielfachevonzahlen")
    if row_selector(single_divider[0]) != "2,1,4,6,3,1,5,v5":
        fail("divider composition changed projected divisor ordering")

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
    if len(mixed_integer) != 6:
        fail(f"wrong component-local reciprocal/integer/fraction count: {len(mixed_integer)}")
    if "--vielfachevonzahlen=5" not in mixed_integer[0] or "--vielfachevonzahlen=5" not in mixed_integer[3]:
        fail("ordinary multiple option did not reach both local fraction domains")
    if "--Universum=transzendentaliereziproke" not in mixed_integer[4]:
        fail("local mixed fraction invocation 4 is no longer the Universe reciprocal axis")
    if any(field.startswith("--vielfachevonzahlen=") for field in mixed_integer[4]):
        fail("Universe reciprocal axis incorrectly inherited ordinary multiples")
    if not row_selector(mixed_integer[0]).endswith("5,v5"):
        fail("Emotion local mixed integer axis lost the original/vN suffix")
    if not row_selector(mixed_integer[3]).endswith("5,v5"):
        fail("Universe local mixed integer axis lost the original/vN suffix")

    global_mixed_integer = records(result["emotion universum v 1/2,2/3,5"])
    if len(global_mixed_integer) != 19:
        fail(f"wrong global reciprocal/integer/fraction count: {len(global_mixed_integer)}")

    ranged_integer = records(result["universum motive v2/3,5-7"])
    if len(ranged_integer) != 26:
        fail("positive range did not retain complete multi-domain plan")
    if "--vielfachevonzahlen=5-7" not in ranged_integer[0]:
        fail("positive range spelling was not preserved")
    if not row_selector(ranged_integer[0]).endswith(",5-7,v5-7"):
        fail("positive range lost its original/vN selector suffix")

    mixed = records(result["universum v1/2,2/3"])
    if len(mixed) != 2:
        fail(f"wrong component-local mixed reciprocal/fraction count: {len(mixed)}")
    local_reciprocals = records_with(
        mixed,
        "--Universum=transzendentaliereziproke",
        "--spaltenreihenfolgeundnurdiese=1",
    )
    local_literal = records_with(mixed, "--gebrochen-rational_Universum_n/m=2")
    if len(local_reciprocals) != 1 or set(row_values(local_reciprocals[0])) != set(range(2, 1024, 2)):
        fail("component-local reciprocal axis did not remain independent")
    if len(local_literal) != 1 or set(row_values(local_literal[0])) != {3}:
        fail("component-local 2/3 literal fraction drifted")

    global_mixed = assert_domain_plan(
        result["universum v 1/2,2/3"],
        "--gebrochen-rational_Universum_n/m=",
        list(range(2, 21, 2)),
        set(range(3, 22, 3)),
        13,
    )
    expected_reciprocals = set(range(2, 1024, 2)) | {1, 3, 9}
    if set(row_values(global_mixed[1])) != expected_reciprocals:
        fail("global mixed reciprocal axis did not preserve both bounds")
    if result["universum vielfache 1/2,2/3"] != result["universum v 1/2,2/3"]:
        fail("standalone v and spelled mixed-axis plans differ")
    if result["universum v1/2,2/3"] == result["universum v 1/2,2/3"]:
        fail("component-local compact v was incorrectly promoted to global scope")

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
    # Native typed table plans use the canonical lowercase parameter name.
    # The Python reference collector above intentionally retains the historical
    # mixed-case argv spelling; these are distinct contracts.
    if "--grundstrukturen=emotion" not in positive_emotion[0]:
        fail("emotion positive-first reciprocal axis is missing")
    if "--spaltenreihenfolgeundnurdiese=4,5" not in positive_emotion[0]:
        fail("emotion reciprocal columns drifted")

    positive_divisor = records(result["universum v1/4,-2/3 teiler"])
    if len(positive_divisor) != 1:
        fail("positive-first divider branch must have one reciprocal invocation")
    if "--spaltenreihenfolgeundnurdiese=1" not in positive_divisor[0]:
        fail("divider command did not narrow the Universe reciprocal columns")

    local_collision = records(result["universum v1/4,-1/8,2/3"])
    if len(local_collision) != 2:
        fail(f"wrong component-local reciprocal collision count: {len(local_collision)}")
    local_reciprocal = records_with(
        local_collision,
        "--Universum=transzendentaliereziproke",
        "--spaltenreihenfolgeundnurdiese=1",
    )
    local_fraction = records_with(
        local_collision,
        "--gebrochen-rational_Universum_n/m=2",
    )
    if len(local_reciprocal) != 1 or len(local_fraction) != 1:
        fail("component-local compact v lost its reciprocal or literal fraction axis")
    expected_local_rows = set(range(4, 1024, 4)) - {8}
    local_row_order = row_values(local_reciprocal[0])
    if set(local_row_order) != expected_local_rows:
        fail("component-local compact v expanded or subtracted the wrong reciprocal rows")
    if local_row_order[:6] != [512, 4, 516, 520, 12, 524]:
        fail("component-local compact v CPython-set row order drifted")
    if set(row_values(local_fraction[0])) != {3}:
        fail("unprefixed 2/3 was incorrectly expanded by an earlier compact v")

    global_payload = result["universum v 1/4,-1/8,2/3"]
    global_collision = assert_domain_plan(
        global_payload,
        "--gebrochen-rational_Universum_n/m=",
        list(range(2, 21, 2)),
        set(range(3, 22, 3)),
        13,
    )
    expected_global_rows = {1, 2, 3, 6, 9} | {
        value for value in range(4, 1024, 4) if value % 8 != 0
    }
    if set(row_values(global_collision[1])) != expected_global_rows:
        fail("standalone v lost the global reciprocal subtraction scope")
    if set(row_values(global_collision[0])) != {1, 2, 3, 4, 6}:
        fail("standalone v changed the global whole-number projection")
    if set(row_values(global_collision[-1])) != {6, 12, 18}:
        fail("standalone v changed the global equal-axis projection")

    for positioned in (
        "v universum 1/4,-1/8,2/3",
        "universum 1/4,-1/8,2/3 v",
        "universum vielfache 1/4,-1/8,2/3",
    ):
        if result[positioned] != global_payload:
            fail(f"position-independent global multiple command drifted: {positioned}")

    local_multi = records(result["emotion universum v1/4,-1/8,2/3"])
    if len(local_multi) != 4:
        fail(f"wrong component-local two-domain collision count: {len(local_multi)}")
    local_emotion_reciprocal = records_with(
        local_multi,
        "--grundstrukturen=emotion",
        "--spaltenreihenfolgeundnurdiese=4,5",
    )
    local_universe_reciprocal = records_with(
        local_multi,
        "--Universum=transzendentaliereziproke",
        "--spaltenreihenfolgeundnurdiese=1",
    )
    if len(local_emotion_reciprocal) != 1 or len(local_universe_reciprocal) != 1:
        fail("component-local two-domain collision lost a reciprocal projection")
    if set(row_values(local_emotion_reciprocal[0])) != expected_local_rows:
        fail("Emotion component-local reciprocal rows drifted")
    if set(row_values(local_universe_reciprocal[0])) != expected_local_rows:
        fail("Universe component-local reciprocal rows drifted")

    global_multi = records(result["emotion universum v 1/4,-1/8,2/3"])
    if len(global_multi) != 19:
        fail(f"wrong global two-domain reciprocal collision count: {len(global_multi)}")
    global_emotion_reciprocal = records_with(
        global_multi,
        "--grundstrukturen=emotion",
        "--spaltenreihenfolgeundnurdiese=4,5",
    )
    global_universe_reciprocal = records_with(
        global_multi,
        "--Universum=transzendentaliereziproke",
        "--spaltenreihenfolgeundnurdiese=1",
    )
    if len(global_emotion_reciprocal) != 1 or len(global_universe_reciprocal) != 1:
        fail("global two-domain collision lost a reciprocal projection")
    expected_global_emotion = {1, 3} | {
        value for value in range(4, 1024, 4) if value % 8 != 0
    }
    if set(row_values(global_emotion_reciprocal[0])) != expected_global_emotion:
        fail("Emotion global reciprocal subtraction scope drifted")
    if set(row_values(global_universe_reciprocal[0])) != expected_global_rows:
        fail("Universe global reciprocal subtraction scope drifted")
    assert_fraction_rectangle(
        global_multi,
        "--gebrochen-rational_Gefuehle_n/m=",
        list(range(2, 9, 2)),
        {3, 6},
    )
    assert_fraction_rectangle(
        global_multi,
        "--gebrochen-rational_Universum_n/m=",
        list(range(2, 21, 2)),
        set(range(3, 22, 3)),
    )

    assert_multi_domain_extension_plans(result)

    runner = Path(sys.argv[2]).resolve()
    assert_direct_execution(result["universum v2/3"], runner)
    assert_direct_execution(
        result["universum motive v2/3"], runner, expected_count=26
    )
    assert_direct_execution(result["universum v1/2,2/3"], runner, expected_count=2)
    assert_direct_execution(result["universum v 1/2,2/3"], runner)
    assert_direct_execution(
        result["universum v1/4,-2/3"], runner, expected_count=1
    )
    assert_direct_execution(
        result["universum v1/4,-1/8,2/3"], runner, expected_count=2
    )
    assert_direct_execution(result["universum v 1/4,-1/8,2/3"], runner)
    assert_direct_execution(
        result["emotion universum v1/4,-1/8,2/3"],
        runner,
        expected_count=4,
    )
    assert_direct_execution(
        result["emotion universum v 1/4,-1/8,2/3"],
        runner,
        expected_count=19,
    )
    # Execute the newly composed extension records themselves without
    # re-rendering all 55 already-covered physical domain invocations.
    assert_direct_execution(
        FS.join(records(result["motive EIGNgut universum v2/3"])[13]),
        runner,
        expected_count=1,
    )
    numeric_records = records(
        result["motive universum 15_13 16_2 v2/3,5"]
    )
    assert_direct_execution(
        RS.join((FS.join(numeric_records[-2]), FS.join(numeric_records[-1]))),
        runner,
        expected_count=2,
    )

    print(
        "true fraction multiples: Python crashes reproduced; "
        "Mojo contract 13/13, mixed bounds, negative no-op branches, "
        "positive-first reciprocal-only and reciprocal-collision branches with "
        "component-local compact-v and position-independent global-v scope, "
        "multi-domain property/numeric "
        "extensions, combined classic/property/catalog outer order, and direct "
        "invocations valid"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
