#!/usr/bin/env python3
"""Compare the native ProgramWorkflow core with the Python reference."""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"
sys.path.insert(0, str(PYROOT))

from reta_architecture.parallel_execution import ParallelExecutionConfig  # noqa: E402
from reta_architecture.program_workflow import ProgramWorkflowBundle  # noqa: E402


CSV_NAMES = SimpleNamespace(
    religion="religion.csv",
    kombi13="kombi.csv",
    kombi15="kombi-meta.csv",
)
I18N = SimpleNamespace(
    ausgabeParas={"art": "art"},
    ausgabeArt={"bbcode": "bbcode", "html": "html"},
    sprachen={0: "de"},
    sprachenWahl=0,
    tomDecodedMotivesLang={"kr": "kr.csv", "cn": "cn.csv", "vn": "vn.csv"},
)


def native(binary: Path, *args: str) -> str:
    result = subprocess.run(
        [str(binary), *args],
        cwd=ROOT,
        env={**os.environ, "RETA_ROOT": str(ROOT)},
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return result.stdout


def python_bundle(argv: list[str] | None = None) -> ProgramWorkflowBundle:
    bundle = ProgramWorkflowBundle(PYROOT, I18N, CSV_NAMES, 0)
    if argv is not None:
        I18N.argv = argv
    return bundle


def parse_key_values(text: str) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in text.splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            result[key] = value
    return result


def check_cells(binary: Path) -> None:
    bundle = python_bundle()
    cases = [
        ("plain", "abc"),
        ("html", '<x & "y">'),
        ("plain", '|{"":"plain","html":"<b>html</b>","bbcode":"[b]bb[/b]"}|'),
        ("html", '|{"":"plain","html":"<b>html</b>","bbcode":"[b]bb[/b]"}|'),
        ("bbcode", '|{"":"plain","html":"<b>html</b>","bbcode":"[b]bb[/b]"}|'),
        ("plain", '|{"":"한글 中文 Việt","html":"<b>한글 中文 Việt</b>","bbcode":"[b]한글 中文 Việt[/b]"}|'),
        ("html", '|{"":"plain","html":"한글 中文 Việt","bbcode":"bb"}|'),
    ]
    for kind, cell in cases:
        expected = bundle._decode_religion_cell(cell, kind)
        actual = native(binary, "--decode-cell", kind, cell).rstrip("\n")
        if actual != expected:
            raise AssertionError((kind, cell, expected, actual))


def check_output_kind(binary: Path) -> None:
    bundle = python_bundle()
    cases = [
        ["reta"],
        ["reta", "--art=html"],
        ["reta", "--art=bbcode"],
        ["reta", "--art=html", "--art=bbcode"],
    ]
    for argv in cases:
        program = SimpleNamespace(argv=argv)
        expected = bundle._requested_religion_output_kind(program)
        actual = native(binary, "--output-kind", "art", "bbcode", "html", *argv).strip()
        if actual != expected:
            raise AssertionError((argv, expected, actual))


def check_kombi(binary: Path) -> None:
    cases = [
        ("kombi.csv", 40, 3, 5, {"valid": "true", "csv_number": "0", "row_source": "rowsOfcombi", "reli_table_len_until_now": "32"}),
        ("kombi-meta.csv", 40, 3, 5, {"valid": "true", "csv_number": "1", "row_source": "rowsOfcombi2", "reli_table_len_until_now": "35"}),
        ("other.csv", 40, 3, 5, {"valid": "false", "csv_number": "-1", "row_source": "", "reli_table_len_until_now": "-1"}),
    ]
    for filename, columns, rows13, rows15, expected in cases:
        actual = parse_key_values(
            native(
                binary,
                "--kombi-plan",
                filename,
                str(columns),
                str(rows13),
                str(rows15),
            )
        )
        if actual != expected:
            raise AssertionError((filename, expected, actual))


def check_religion_summary(binary: Path) -> None:
    bundle = python_bundle()
    program = SimpleNamespace(
        argv=["reta"],
        tables=SimpleNamespace(hoechsteZeile={1024: 1024}),
        parallel_config=ParallelExecutionConfig(mode="off"),
    )
    bundle._load_religion_table(program)
    expected = {
        "rows": str(len(program.relitable)),
        "rows_len": str(program.RowsLen),
        "maximum_columns": str(max(map(len, program.relitable))),
        "mode": "serial",
    }
    actual = parse_key_values(native(binary, "--load-religion", "plain", "1024"))
    if actual != expected:
        raise AssertionError((expected, actual))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path, default=ROOT / "target/bin/reta-mojo-workflow")
    args = parser.parse_args()
    check_cells(args.binary)
    check_output_kind(args.binary)
    check_kombi(args.binary)
    check_religion_summary(args.binary)
    print(json.dumps({"cases": 7 + 4 + 3 + 1, "status": "ok"}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
