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
        assert item["origin"] in {"python_reference", "python_reference_tests"}
        if item["classification"] == "test_bug":
            assert item["mojo_status"] == "not_applicable"
        else:
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


def test_backfill_audit_covers_all_previously_scattered_confirmed_defects() -> None:
    data = json.loads((ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8"))
    ids = {item["id"] for item in data["defects"]}
    expected = {
        "PY-OPEN-003",
        "PY-CAND-004",
        "PY-OPEN-004",
        "PY-OPEN-005",
        "PY-OPEN-006",
        "PY-CAND-005",
        "PY-CAND-006",
        "MOJO-FIXED-006",
        "MOJO-FIXED-007",
        "MOJO-FIXED-008",
        "MOJO-FIXED-009",
        "MOJO-FIXED-010",
        "MOJO-FIXED-011",
        "MOJO-FIXED-012",
        "MOJO-FIXED-013",
        "MOJO-FIXED-014",
        "MOJO-FIXED-015",
        "MOJO-FIXED-016",
        "MOJO-FIXED-017",
        "MOJO-FIXED-018",
        "MOJO-FIXED-019",
        "MOJO-FIXED-020",
        "MOJO-FIXED-021",
        "MOJO-FIXED-022",
        "TEST-OPEN-001",
        "TEST-FIXED-001",
        "TEST-FIXED-002",
        "TEST-FIXED-003",
    }
    assert expected <= ids
    assert data["audit"]["last_full_backfill_stage"] == "12c4s"
    for source in data["audit"]["audited_sources"]:
        assert (ROOT / source).exists(), source


def test_removed_python_bridge_cannot_reappear_unnoticed() -> None:
    assert not (ROOT / "src" / "reta_mojo" / "prompt_python_bridge.mojo").exists()
    sources = (ROOT / "src").rglob("*.mojo")
    assert all("from std.python import" not in path.read_text(encoding="utf-8") for path in sources)


def test_source_manifest_excludes_nested_pytest_caches() -> None:
    script = (ROOT / "scripts" / "update_source_manifest.sh").read_text(encoding="utf-8")
    assert "-name '.pytest_cache'" in script
    manifest = (ROOT / "SOURCE_MANIFEST.sha256").read_text(encoding="utf-8")
    assert "/.pytest_cache/" not in manifest
