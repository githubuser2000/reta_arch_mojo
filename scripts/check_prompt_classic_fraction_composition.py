#!/usr/bin/env python3
"""Freeze classic-table ordering beside true-fraction integer axes.

The frozen Python controller still owns the *outer* command order even though
its shared n/m rectangle is defective.  This probe deliberately compares each
classic command against a base fraction-domain call list, so it proves only the
stable composition law and does not bless the broken inner rectangle.
"""
from __future__ import annotations

import contextlib
import io
import os
import shlex
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = ROOT / "python_reference"
os.chdir(REFERENCE)
sys.path.insert(0, str(REFERENCE))

import retaPrompt  # noqa: E402
import reta_architecture.prompt_execution as prompt_execution  # noqa: E402

Call = tuple[str, str, tuple[str, ...], str | None]


def fail(message: str) -> None:
    raise SystemExit(message)


def collect_calls(command: str) -> list[Call]:
    calls: list[Call] = []

    def collect(*args: object) -> None:
        calls.append(
            (
                str(args[2]),
                str(args[3]),
                tuple(str(value) for value in args[4]),
                None if args[5] is None else str(args[5]),
            )
        )

    prompt_execution.retaExecuteNprint = collect
    argv = ["retaPrompt.py", "-vi", "-befehl", *shlex.split(command)]
    sink = io.StringIO()
    try:
        with contextlib.redirect_stdout(sink), contextlib.redirect_stderr(sink):
            retaPrompt.promptInteraction.run_scope(argv)
    except SystemExit:
        pass
    else:
        fail(f"reference command did not finish through SystemExit: {command}")
    return calls


def option(call: Call) -> str:
    if len(call[2]) != 1:
        fail(f"unexpected reference parameter vector: {call!r}")
    return call[2][0]


def assert_suffix(command: str, base: list[Call], marker: str) -> Call:
    calls = collect_calls(command)
    if calls[:-1] != base:
        fail(f"{command!r} changed the preceding fraction-domain sequence")
    if option(calls[-1]) != marker:
        fail(f"{command!r} produced the wrong classic suffix: {calls[-1]!r}")
    return calls[-1]


def main() -> None:
    base = collect_calls("universum motive v2/3,5")
    if len(base) != 19:
        fail(f"reference base invocation count drifted: {len(base)}")

    moon = assert_suffix(
        "mond universum motive v2/3,5", base, "--Bedeutung=gestirn"
    )
    all_table = assert_suffix(
        "alles universum motive v2/3,5", base, "--alles"
    )
    direction = assert_suffix(
        "richtung universum motive v2/3,5",
        base,
        "--Primzahlwirkung=Galaxieabsicht",
    )
    for name, call in (("moon", moon), ("all", all_table), ("direction", direction)):
        if call[:2] != base[0][:2]:
            fail(f"{name} did not reuse the ordinary integer axis")

    prime_cross = assert_suffix(
        "primzahlkreuz universum motive v2/3,5",
        base,
        "--Bedeutung=primzahlkreuz",
    )
    if prime_cross[0] != "--vielfachevonzahlen=5":
        fail("prime-cross lost the original ordinary multiple axis")
    if prime_cross[1] != "--oberesmaximum=1029":
        fail("prime-cross lost its historical upper maximum")

    thomas_calls = collect_calls("thomas universum motive v2/3,5")
    if thomas_calls[1:] != base:
        fail("Thomas did not precede the unchanged fraction-domain sequence")
    if option(thomas_calls[0]).lower() != "--galaxie=thomas":
        fail(f"wrong Thomas prefix: {thomas_calls[0]!r}")
    if thomas_calls[0][:2] != base[0][:2]:
        fail("Thomas did not reuse the ordinary integer axis")

    combined = collect_calls(
        "mond richtung primzahlkreuz alles thomas universum motive v2/3,5"
    )
    if combined[1:20] != base:
        fail("combined classic command changed the physical domain block")
    expected = (
        "--galaxie=thomas",
        "--Bedeutung=gestirn",
        "--alles",
        "--Bedeutung=primzahlkreuz",
        "--Primzahlwirkung=Galaxieabsicht",
    )
    actual = (
        option(combined[0]).lower(),
        option(combined[20]),
        option(combined[21]),
        option(combined[22]),
        option(combined[23]),
    )
    expected_normalized = (expected[0].lower(), *expected[1:])
    if actual != expected_normalized:
        fail(f"combined classic order drifted: {actual!r}")

    divider_base = collect_calls("universum motive v2/3,5 teiler")
    divider_moon = assert_suffix(
        "mond universum motive v2/3,5 teiler",
        divider_base,
        "--Bedeutung=gestirn",
    )
    if divider_moon[0] != "" or divider_moon[1] != divider_base[0][1]:
        fail("divider moon did not preserve the divider-only outer axis")

    for suffix in ("0", "-10"):
        integer_base = collect_calls(f"universum motive v2/3,{suffix}")
        integer_moon = assert_suffix(
            f"mond universum motive v2/3,{suffix}",
            integer_base,
            "--Bedeutung=gestirn",
        )
        if integer_moon[:2] != integer_base[0][:2]:
            fail(f"moon changed the comma-local {suffix} axis")

    print("classic fraction composition reference: 10/10")


if __name__ == "__main__":
    main()
