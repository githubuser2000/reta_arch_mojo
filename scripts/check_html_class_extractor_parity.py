#!/usr/bin/env python3
"""Compare the native HTML-class extractor against the Python reference."""
from __future__ import annotations

import argparse
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
SMALL_FIXTURE = ROOT / "tests/fixtures/html_class_extractor.html"
SMALL_EXPECTED = ROOT / "tests/fixtures/html_class_extractor_expected.jsonl"
FULL_FIXTURE = ROOT / "tests/fixtures/generate_html/middle-all-row1-de.html"
PYTHON_OWNER = ROOT / "python_reference/reta_extract_html_classes.py"


def _load_python_owner():
    spec = importlib.util.spec_from_file_location("reta_html_extract", PYTHON_OWNER)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _python_jsonl(fixture: Path) -> bytes:
    module = _load_python_owner()
    cells = module._extract_header_cells(fixture.read_text(encoding="utf-8"))
    return "".join(
        json.dumps(cell, ensure_ascii=False, separators=(",", ":")) + "\n"
        for cell in cells
    ).encode()


def _native_jsonl(binary: Path, fixture: Path, output: Path) -> bytes:
    env = os.environ.copy()
    env["RETA_HTML_CLASSES_INPUT"] = str(fixture)
    completed = subprocess.run(
        [str(binary), str(output)],
        cwd=ROOT,
        env=env,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if completed.returncode != 0:
        raise SystemExit(completed.stderr or completed.stdout)
    return output.read_bytes()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--binary", type=Path, required=True)
    args = parser.parse_args()
    binary = args.binary.resolve()
    total = 0
    with tempfile.TemporaryDirectory(prefix="reta_html_class_parity_") as tmp:
        tmp_root = Path(tmp)
        cases = [
            (SMALL_FIXTURE, SMALL_EXPECTED.read_bytes()),
            (FULL_FIXTURE, _python_jsonl(FULL_FIXTURE)),
        ]
        for index, (fixture, expected) in enumerate(cases):
            actual = _native_jsonl(binary, fixture, tmp_root / f"actual-{index}.jsonl")
            if actual != expected:
                expected_lines = expected.decode().splitlines()
                actual_lines = actual.decode().splitlines()
                first = next(
                    (
                        line
                        for line in range(min(len(expected_lines), len(actual_lines)))
                        if expected_lines[line] != actual_lines[line]
                    ),
                    min(len(expected_lines), len(actual_lines)),
                )
                raise AssertionError(
                    f"{fixture}: first mismatch at record {first}; "
                    f"expected {len(expected_lines)}, actual {len(actual_lines)}"
                )
            total += len(expected.splitlines())
    print(f"HTML class extractor parity: {total}/{total} JSONL records byte-identical")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
