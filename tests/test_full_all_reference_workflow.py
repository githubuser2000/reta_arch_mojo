from __future__ import annotations

import os
from pathlib import Path
import subprocess
import tarfile

ROOT = Path(__file__).resolve().parents[1]
CREATE = ROOT / "scripts/create_full_all_reference_bundle.sh"
CHECK = ROOT / "scripts/check_full_all_against_reference.sh"
PARITY = ROOT / "scripts/check_full_all_parity.sh"

HTML = """<!doctype html><table><tr><th>A</th><th>B</th></tr><tr><td>1</td><td><ul><li>x</li><li>y</li></ul></td></tr></table>\n"""


def test_reference_scripts_expose_reusable_bundle_contract() -> None:
    create = CREATE.read_text(encoding="utf-8")
    check = CHECK.read_text(encoding="utf-8")
    parity = PARITY.read_text(encoding="utf-8")
    assert "RETA_FULL_ALL_HTML" in create
    assert "reta-full-all-reference-v1" in create
    assert "RETA_NATIVE_BINARY" in check
    assert "compare_full_all_html.py" in check
    assert "RETA_FULL_ALL_REFERENCE" in parity


def test_provided_html_can_be_bundled_and_reused(tmp_path: Path) -> None:
    fixture = tmp_path / "python-all.html"
    fixture.write_text(HTML, encoding="utf-8")
    bundle = tmp_path / "reference.tar.bz2"
    work = tmp_path / "work"
    env = os.environ.copy()
    env.update(
        {
            "RETA_FULL_ALL_HTML": str(fixture),
            "RETA_FULL_ALL_REFERENCE_WORKDIR": str(work),
            "RETA_PYTHON": env.get("PYTHON", "python3"),
        }
    )
    result = subprocess.run(
        [str(CREATE), str(bundle)],
        cwd=ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=True,
    )
    assert "table_rows=2" in result.stdout
    assert "table_cells=4" in result.stdout
    with tarfile.open(bundle, "r:bz2") as archive:
        names = set(archive.getnames())
        assert names == {"python-all.html", "metadata.txt", "python.time"}
        metadata = archive.extractfile("metadata.txt")
        assert metadata is not None
        text = metadata.read().decode("utf-8")
    assert "format=reta-full-all-reference-v1" in text
    assert "table_rows=2" in text
    assert "table_cells=4" in text

    fake_native = tmp_path / "reta-native"
    fake_native.write_text(
        "#!/bin/sh\ncat " + subprocess.list2cmdline([str(fixture)]) + "\n",
        encoding="utf-8",
    )
    fake_native.chmod(0o755)
    env["RETA_NATIVE_BINARY"] = str(fake_native)
    checked = subprocess.run(
        [str(CHECK), str(bundle)],
        cwd=ROOT,
        env=env,
        text=True,
        capture_output=True,
        check=True,
    )
    assert "semantic_cells_equal=4/4 (100.000000%)" in checked.stdout
    assert "SEMANTIC_PARITY" in checked.stdout


def test_compact_parser_preserves_historical_nested_table_shape(tmp_path: Path) -> None:
    from scripts.compare_full_all_html import parse

    nested = tmp_path / "nested.html"
    nested.write_text(
        "<table><tr><td>A<table><tr><td>X</td></tr></table>B</td>"
        "<td>C</td></tr></table>",
        encoding="utf-8",
    )
    table = parse(nested)
    # The established full-all comparator treats the nested row as the row
    # contract and discards the interrupted outer row. Keep that behavior so
    # historical totals remain 198 rows / 149356 cells.
    assert table.shape == [1]
    assert len(table.records) // 96 == 1
