#!/usr/bin/env python3
"""Compare the Stage-12c5d native legacy facades with Python owners."""
from __future__ import annotations

import contextlib
import io
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
PYTHON_REFERENCE = ROOT / "python_reference"
PROBE = ROOT / "target" / "tests" / "legacy_facades_probe"

sys.path[:0] = [str(PYTHON_REFERENCE / "libs"), str(PYTHON_REFERENCE)]
os.environ.setdefault("PYTHONDONTWRITEBYTECODE", "1")

import center  # type: ignore  # noqa: E402
import lib4tables  # type: ignore  # noqa: E402


def bit(value: object) -> str:
    return "1" if bool(value) else "0"


def comma(values) -> str:
    return ",".join(str(value) for value in values)


def capture(function, *args) -> str:
    stream = io.StringIO()
    with contextlib.redirect_stdout(stream):
        function(*args)
    return stream.getvalue().rstrip("\n")


def python_snapshot() -> str:
    center.infoLog = True
    groups = (
        center.nPmEnum.gal(),
        center.nPmEnum.uni(),
        center.nPmEnum.emo(),
        center.nPmEnum.groe(),
        center.nPmEnum.n(),
        center.nPmEnum.einsPn(),
    )
    rows = center.BereichToNumbers2("1-4,-2")
    unique = list(center.unique_everseen(["a", "b", "a", "c", "b"]))
    chunked = list(center.chunks(["a", "b", "c", "d", "e"], 2))
    factors = center.primfaktoren(72)
    labels = center.primRepeat(factors.copy())
    grouped = center.primRepeat2(factors.copy())
    pairs = center.multiples(12)
    divisors = center.teiler("12")
    inverted = center.invert_dict_B({"a": ["2", "3"], "b": ["3"]})
    modulo_lines = capture(center.moduloA, [5]).splitlines()
    exports = list(lib4tables.__all__)
    lib_factors = lib4tables.primFak(360)
    lib_grouped = lib4tables.primRepeat(tuple(lib4tables.primFak(72)))
    lib_divisors = list(lib4tables.divisorGenerator(36))
    prime_multiples = lib4tables.primMultiple(12)
    moon = lib4tables.moonNumber(64)

    lines = [
        "npm=" + "|".join(comma(int(value) for value in group) for group in groups),
        "rowchecks=" + "".join(
            [
                bit(center.isZeilenBruchAngabe_betweenKommas("1/2-3/4")),
                bit(center.isZeilenBruchOrGanzZahlAngabe("1-3,4/5")),
                bit(center.isZeilenBruchAngabe("1/2,3/4")),
                bit(center.isZeilenAngabe("1-4,-2")),
                bit(center.isZeilenAngabe_betweenKommas("{1,3,5}")),
            ]
        ),
        "range=" + "".join(bit(value in rows) for value in [1, 2, 3, 4]) + f":{len(rows)}",
        "unique=" + comma(unique),
        f"chunks={len(chunked)}:{''.join(chunked[0])}:{chunked[2][0]}",
        "console="
        + "|".join(
            [
                capture(center.cliout, "  a\n  b  ", True),
                capture(center.x, "value", "42"),
                capture(center.alxp, "42"),
            ]
        ),
        "digits=" + "".join(bit(center.textHatZiffer(text)) for text in ["abc2", "abc٢", "abc²", "abc⑵", "abc四"]),
        "center-prime="
        + comma(factors)
        + "|"
        + comma(labels)
        + "|"
        + comma(f"{prime}^{exponent}" for prime, exponent in grouped),
        f"pairs={len(pairs)}:{pairs[0][0]}x{pairs[0][1]}:{pairs[-1][0]}x{pairs[-1][1]}",
        "teiler=" + "".join(bit(value in divisors[1]) for value in [1, 2, 3, 4, 6, 12]) + f":{len(divisors[1])}",
        # PY-OPEN-003: native Mojo intentionally keeps both source keys.
        f"invert={len(inverted[2])}:2",
        f"modulo={len(modulo_lines)}:{modulo_lines[0]}",
        "libexports=" + comma(exports),
        "syntax=" + ",".join([lib4tables.OutputSyntax.__name__, lib4tables.NichtsSyntax.__name__, "csv", "emacs", "markdown", "bbcode", "html"]),
        "libnumber="
        + f"{len(lib_factors)}:{len(lib_divisors)}:{lib_grouped[0][0]}^{lib_grouped[0][1]}:"
        + f"{lib4tables.primCreativity(36)}:{prime_multiples[0][0]}x{prime_multiples[0][1]}:"
        + bit(lib4tables.isPrimMultiple(12, [6]))
        + bit(lib4tables.isPrimMultiple(12, [7])),
        "libmatches="
        + "".join(bit(value) for value in lib4tables.isPrimMultiple(12, [6, 7], False))
        + f":{len(lib4tables.isPrimMultiple(12, [6, 7], False))}",
        "cross="
        + bit(lib4tables.couldBePrimeNumberPrimzahlkreuz(29))
        + bit(lib4tables.couldBePrimeNumberPrimzahlkreuz_fuer_innen(29))
        + bit(lib4tables.couldBePrimeNumberPrimzahlkreuz_fuer_aussen(29)),
        "moon=" + comma(moon[0]) + "|" + comma(moon[1]),
    ]
    return "\n".join(lines) + "\n"


def transformed_prompt_doc(path: Path) -> bytes:
    text = path.read_text(encoding="utf-8")
    start = text.find("+++", 2)
    text = re.sub(r"{#.*}", "", text)
    return text[start + 3 :].encode("utf-8")


def run_probe(*args: str) -> bytes:
    return subprocess.check_output([str(PROBE), *args], cwd=ROOT)


def main() -> int:
    if not PROBE.is_file():
        print(f"missing native probe: {PROBE}", file=sys.stderr)
        return 2

    # Guard the one intentional Python divergence applied above.
    buggy_inversion = center.invert_dict_B({"a": ["3"], "b": ["3"]})
    if len(buggy_inversion[3]) != 1:
        print("PY-OPEN-003 no longer reproduces; update the compatibility expectation", file=sys.stderr)
        return 1

    checks: list[tuple[str, bytes, bytes]] = [
        ("facade-snapshot-with-documented-fixes", run_probe(), python_snapshot().encode("utf-8")),
        (
            "reta-help-de",
            run_probe("reta-help-de"),
            (PYTHON_REFERENCE / "doc" / "readme-reta.md").read_bytes() + b"\n",
        ),
        (
            "reta-help-en",
            run_probe("reta-help-en"),
            (PYTHON_REFERENCE / "doc" / "readme-reta-en.md").read_bytes() + b"\n",
        ),
        (
            "prompt-help-de",
            run_probe("prompt-help-de"),
            transformed_prompt_doc(PYTHON_REFERENCE / "doc" / "readme-retaPrompt.md"),
        ),
        (
            "prompt-help-en",
            run_probe("prompt-help-en"),
            transformed_prompt_doc(PYTHON_REFERENCE / "doc" / "readme-retaPrompt-en.md"),
        ),
    ]
    passed = 0
    for name, actual, expected in checks:
        if actual != expected:
            print(f"FAIL {name}: native={len(actual)} bytes python={len(expected)} bytes", file=sys.stderr)
            mismatch = next((index for index, pair in enumerate(zip(actual, expected)) if pair[0] != pair[1]), min(len(actual), len(expected)))
            print(f"first mismatch at byte {mismatch}", file=sys.stderr)
            return 1
        passed += 1
        print(f"PASS {name}: {len(actual)} bytes")
    print(f"legacy facade parity: {passed}/{len(checks)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
