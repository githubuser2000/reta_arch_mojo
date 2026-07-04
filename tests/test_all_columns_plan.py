from __future__ import annotations

import os
import subprocess
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSET = ROOT / "assets" / "all_columns_plan.tsv"
GENERATOR = ROOT / "scripts" / "generate_all_columns_plan.py"


def _asset_lines() -> list[str]:
    return [
        line
        for line in ASSET.read_text(encoding="utf-8").splitlines()
        if line and not line.startswith("#")
    ]


def test_all_columns_plan_is_reproducible() -> None:
    env = dict(os.environ)
    env["PYTHONHASHSEED"] = "0"
    actual = subprocess.run(
        [sys.executable, str(GENERATOR), "--emit"],
        cwd=ROOT,
        env=env,
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    assert actual == ASSET.read_text(encoding="utf-8")


def test_all_columns_plan_bucket_shape() -> None:
    lines = _asset_lines()
    counts = Counter(line.split("\t", 1)[0] for line in lines)
    assert len(lines) == 756
    assert counts == {
        "ordinary": 556,
        "modal": 46,
        "concat": 11,
        "kombi": 12,
        "prime_effect": 7,
        "fraction_universe": 22,
        "fraction_galaxy": 22,
        "generated_command": 10,
        "kombi2": 14,
        "fraction_emotion": 22,
        "fraction_size": 22,
        "meta": 12,
    }


def test_generate_html_has_no_runtime_bridge() -> None:
    generate_html = (ROOT / "src" / "generate_html_main.mojo").read_text(
        encoding="utf-8"
    )
    html_document = (
        ROOT / "src" / "reta_mojo" / "html_document.mojo"
    ).read_text(encoding="utf-8")
    native_cli = (ROOT / "src" / "reta_mojo" / "native_reta_cli.mojo").read_text(
        encoding="utf-8"
    )
    parameter_runtime = (
        ROOT / "src" / "reta_mojo" / "parameter_runtime.mojo"
    ).read_text(encoding="utf-8")
    assert "std.subprocess" not in generate_html
    assert "std.python" not in generate_html
    assert "assemble_html_document" in generate_html
    assert "run_native_reta(tokens" in html_document
    # Stage 12c4y moved the all-columns owner from the productive CLI shell
    # into parameter_runtime.  The CLI must delegate instead of duplicating it.
    assert "load_all_column_selection" not in native_cli
    assert "from .parameter_runtime import" in native_cli
    assert "load_all_column_selection" in parameter_runtime
    assert 'option.name == "alles"' in parameter_runtime
    assert 'name == "onetable"' in native_cli


def test_one_row_reference_fixture_has_805_data_columns() -> None:
    fixture = (
        ROOT / "tests" / "fixtures" / "generate_html" / "middle-all-row1-de.html"
    ).read_text(encoding="utf-8")
    assert fixture.count("<tr") == 2
    assert fixture.count("</tr>") == 2
    assert fixture.count("<td") == 1614
    assert fixture.count("</td>") == 1614
    assert fixture.endswith("</table>\n\n")
