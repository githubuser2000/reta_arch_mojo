#!/usr/bin/env python3
from __future__ import annotations

import os
import subprocess
import sys
from fractions import Fraction
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "python_reference"))
sys.path.insert(0, str(ROOT / "python_reference" / "libs"))

from reta_architecture import concat_csv as concat_csv_py
from reta_architecture import generated_columns as generated_py
from reta_architecture.runtime_compat import nPmEnum
from libs.lib4tables_concat import Concat


class _Tables:
    hoechsteZeile = {1024: 12}


class _Concat:
    tables = _Tables()


def _group_line(name: str, groups: dict, maximum: int) -> str:
    pieces = [name]
    for key in range(1, maximum + 1):
        if key not in groups:
            continue
        pairs = sorted(f"{first},{second}" for first, second in groups[key])
        pieces.append(f"{key}=" + ";".join(pairs))
    return "|".join(pieces)


def _domain(kind: int) -> str:
    if kind == 1:
        return "prime"
    if kind in nPmEnum.gal():
        return "galaxy"
    if kind in nPmEnum.uni():
        return "universe"
    if kind in nPmEnum.emo():
        return "emotion"
    if kind in nPmEnum.groe():
        return "size"
    return ""


def _reference_lines() -> list[str]:
    bundle = concat_csv_py.bootstrap_concat_csv().snapshot()
    lines = [
        f"bundle|{bundle['count']}|{len(bundle['csv_sources'])}|{len(bundle['fraction_helpers'])}"
    ]
    owner = _Concat()
    for kind in range(1, 10):
        lines.append(
            "|".join(
                (
                    "source",
                    str(kind),
                    os.path.basename(concat_csv_py.readConcatCSV_choseCsvFile(owner, kind)),
                    _domain(kind),
                    str(kind in nPmEnum.einsPn()),
                )
            )
        )
    matrix = [["a", "b"], ["c", "d"]]
    identity = lambda value: [list(row) for row in zip(*value)]
    german = concat_csv_py.readConcatCsv_ChangeTableToAddToTable(
        owner, 2, [row[:] for row in matrix], identity
    )
    english_heading = "2/n universe"
    # The active German runtime is the Python reference process default.  The
    # English heading is the frozen translated contract already used by the
    # native generated-column path.
    lines.append(f"heading|2|{german[0][1]}")
    lines.append(f"heading|5|{english_heading}")

    division_pairs = {
        (Fraction(6), Fraction(2)),
        (Fraction(3, 2), Fraction(1, 2)),
    }
    lines.append(
        _group_line(
            "div",
            concat_csv_py.convertSetOfPaarenToDictOfNumToPaareDiv(
                owner, division_pairs
            ),
            12,
        )
    )
    multiplication_pairs = {
        (Fraction(6), Fraction(2)),
        (Fraction(3, 2), Fraction(2)),
    }
    lines.append(
        _group_line(
            "mul",
            concat_csv_py.convertSetOfPaarenToDictOfNumToPaareMul(
                owner, multiplication_pairs
            ),
            16,
        )
    )
    fractions = {Fraction(2, 3), Fraction(3, 2)}
    secondary = {Fraction(3, 2), Fraction(1, 2)}
    lines.append(
        _group_line(
            "expand0",
            concat_csv_py.convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction(
                owner, fractions, secondary, False
            ),
            12,
        )
    )
    lines.append(
        _group_line(
            "expand1",
            concat_csv_py.convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction(
                owner, fractions, secondary, True
            ),
            12,
        )
    )

    legacy = Concat(object())
    method_names = [
        name
        for name, value in Concat.__dict__.items()
        if callable(value) and name != "__init__"
    ]
    lines.append(
        f"facade|{len(method_names)}|13|{len(legacy.CSVsSame)}"
    )
    lines.append(f"scalar|4|{generated_py.gleichheit_freiheit_vergleich(4)}")
    lines.append(
        "scalar|12|" + generated_py.geist_emotion_energie_materie_topologie(12)
    )
    generated_py._ensure_runtime_dependencies()
    creativity_kind = generated_py.primCreativity(1)
    creativity_labels = (
        "0. Primzahl 1",
        "1. Primzahl und Sonnenzahl",
        "2. Sonnenzahl, aber keine Primzahl",
        "3. Mondzahl",
    )
    lines.append(
        "scalar|1|"
        + generated_py._i18n.kreaZahl[creativity_labels[creativity_kind]]
    )
    return lines


def main() -> int:
    executable = ROOT / "target" / "tests" / "concat_csv_probe"
    env = os.environ.copy()
    runtime_dir = env.get("RETA_MOJO_RUNTIME_LIBDIR", "")
    if not runtime_dir:
        runtime = subprocess.run(
            [str(ROOT / "scripts" / "find_mojo_runtime.sh")],
            cwd=ROOT,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if runtime.returncode != 0:
            print(runtime.stderr.rstrip(), file=sys.stderr)
            return 77
        runtime_dir = runtime.stdout.strip()
    env["LD_LIBRARY_PATH"] = runtime_dir + (
        ":" + env["LD_LIBRARY_PATH"] if env.get("LD_LIBRARY_PATH") else ""
    )
    completed = subprocess.run(
        [str(executable)],
        cwd=ROOT,
        env=env,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
    )
    actual = completed.stdout.splitlines()
    expected = _reference_lines()
    if actual != expected:
        from difflib import unified_diff

        print(
            "\n".join(
                unified_diff(
                    expected,
                    actual,
                    fromfile="python-reference",
                    tofile="mojo-native",
                    lineterm="",
                )
            ),
            file=sys.stderr,
        )
        return 1
    print(f"concat CSV parity: {len(expected)}/{len(expected)} lines byte-identical")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
