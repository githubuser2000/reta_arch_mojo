from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_and_default_commit_name_are_12c5bf() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    do_sh = (ROOT / "do.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bf.sh" in current
    assert "COMMIT_MESSAGE=${1:-12c5bf}" in do_sh


def test_stage_document_and_python_defect_evidence_are_linked() -> None:
    doc = (ROOT / "STAGE12C5BF_MULTI_DOMAIN_FRACTION_PLANS.md").read_text(
        encoding="utf-8"
    )
    defects = json.loads((ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8"))[
        "defects"
    ]
    defect = next(item for item in defects if item["id"] == "PY-OPEN-002")
    assert "26" in doc and "44" in doc
    assert "Mehrdom" in defect["current_contract"] or "Domäne" in defect["current_contract"]
    assert "STAGE12C5BF_MULTI_DOMAIN_FRACTION_PLANS.md" in defect["evidence"]
    assert "tests/test_prompt_multi_domain_fraction_source.py" in defect["evidence"]
