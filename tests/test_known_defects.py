from __future__ import annotations

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_known_defect_ledger_is_valid_and_generated_markdown_is_current() -> None:
    subprocess.run(
        ["python3", "tools/check_known_defects.py"],
        cwd=ROOT,
        check=True,
    )


def test_every_open_python_bug_has_a_future_fix_and_mojo_contract() -> None:
    data = json.loads((ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8"))
    open_items = [
        item for item in data["defects"] if item["python_status"] == "open"
    ]
    assert open_items
    for item in open_items:
        assert item["origin"] == "python_reference"
        assert item["mojo_status"] in {"fixed", "compatibility_preserved"}
        assert item["post_port_fix"].strip()
        assert item["reproducer"].strip()
        assert item["evidence"]


def test_policy_requires_every_python_original_defect_to_enter_the_backlog() -> None:
    data = json.loads((ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8"))
    policy = data["policy"]
    assert "Jeder bestätigte oder plausible Fehler" in policy["python_original_rule"]
    assert "Reproduktion" in policy["python_original_rule"]
    assert "vorübergehende" in policy["scope"]
    assert (ROOT / "PYTHON_CLEANUP_BACKLOG.md").exists()
