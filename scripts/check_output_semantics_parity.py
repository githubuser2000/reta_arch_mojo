#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PYROOT = ROOT / "python_reference"


def _run(command: list[str], cwd: Path) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(result.stderr)
    return result.stdout


def _python_snapshot(python: str) -> dict[str, object]:
    code = (
        "import json;"
        "from reta_architecture.output_semantics import bootstrap_output_semantics;"
        "from reta_architecture.output_syntax import output_syntax_snapshot;"
        "s=bootstrap_output_semantics().snapshot();"
        "print(json.dumps({'semantics':s,'syntax':output_syntax_snapshot()},"
        "ensure_ascii=False,sort_keys=True))"
    )
    return json.loads(_run([python, "-c", code], PYROOT))


def _native_summary(binary: str) -> dict[str, object]:
    lines = _run([binary, "--summary"], ROOT).splitlines()
    values: dict[str, str] = {}
    modes: list[dict[str, object]] = []
    for line in lines:
        if line.startswith("mode="):
            parts = dict(part.split("=", 1) for part in line.split("|"))
            modes.append(
                {
                    "canonical_name": parts["mode"],
                    "syntax_class": parts["class"],
                    "force_one_table": parts["one"].lower() == "true",
                    "force_zero_width": parts["zero"].lower() == "true",
                    "marks_html_or_bbcode": parts["markup"].lower() == "true",
                    "aliases_len": int(parts["aliases"]),
                }
            )
        elif "=" in line:
            key, value = line.split("=", 1)
            values[key] = value
    return {"values": values, "modes": modes}


def _expected_compact(snapshot: dict[str, object]) -> dict[str, object]:
    semantics = snapshot["semantics"]
    syntax = snapshot["syntax"]
    mode_specs = semantics["mode_specs"]
    modes = []
    for name in semantics["available_modes"]:
        spec = mode_specs[name]
        modes.append(
            {
                "canonical_name": spec["canonical_name"],
                "syntax_class": spec["syntax_class"],
                "force_one_table": spec["force_one_table"],
                "force_zero_width": spec["force_zero_width"],
                "marks_html_or_bbcode": spec["marks_html_or_bbcode"],
                "aliases_len": len(spec["aliases"]),
            }
        )
    return {
        "values": {
            "semantics_class": "RetaOutputSemantics",
            "semantics_modes": str(len(modes)),
            "syntax_class": syntax["class"],
            "syntax_modes": str(len(syntax["modes"])),
            "legacy_owner": syntax["legacy_owner"],
            "architecture_owner": syntax["architecture_owner"],
        },
        "modes": modes,
    }


def _check_applications(python: str, binary: str) -> None:
    cases = [
        ("csv", 33, False, False),
        ("csv", 33, False, True),
        ("html", 21, True, True),
        ("unbekannt", 17, False, True),
    ]
    for mode, width, one_table, callback in cases:
        output = _run(
            [
                binary,
                "--apply",
                mode,
                str(width),
                "true" if one_table else "false",
                "true" if callback else "false",
            ],
            ROOT,
        )
        values = dict(line.split("=", 1) for line in output.splitlines())
        # The reference callback only changes width when supplied.
        code = f"""
from types import SimpleNamespace
from reta_architecture.output_semantics import bootstrap_output_semantics
from reta_architecture.output_syntax import OutputSyntax
state=SimpleNamespace(outType=OutputSyntax(),getOut=SimpleNamespace(oneTable={one_table!r}))
called=[]
a=bootstrap_output_semantics().apply_mode_to_tables(state,{mode!r},(lambda: called.append(True)) if {callback!r} else None)
print('None' if a is None else a.canonical_name)
print(state.getOut.oneTable)
print(bool(called))
"""
        expected = _run([python, "-c", code], PYROOT).splitlines()
        assert (values["applied"].lower() == "true") == (expected[0] != "None")
        assert (values["one_table"].lower() == "true") == (expected[1] == "True")
        assert (values["text_width"] == "0") == (expected[2] == "True")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--python", required=True)
    parser.add_argument("--binary", required=True)
    args = parser.parse_args()
    expected = _expected_compact(_python_snapshot(args.python))
    actual = _native_summary(args.binary)
    if expected != actual:
        raise AssertionError((expected, actual))
    _check_applications(args.python, args.binary)
    print(json.dumps({"snapshot": "identical", "application_cases": 4}, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
