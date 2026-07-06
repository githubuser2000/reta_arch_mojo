from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "STAGE12C5BO_CANONICAL_EMOTION_OPTION_CHECK.md"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"


def test_current_stage_extends_bn_and_forwards_compiler_options() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5bo.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert 'test_stage12c5bn.sh" -- "$@"' in stage
    assert 'check_prompt_true_fraction_multiples.sh" -- "$@"' in stage
    assert "mojo_validate_build_options" in stage


def test_runtime_checker_distinguishes_reference_and_native_option_spelling() -> None:
    checker = CHECKER.read_text(encoding="utf-8")
    reference_start = checker.index("def assert_python_positive_first_reciprocal_only")
    reference_end = checker.index("def assert_multi_domain_extension_plans")
    reference_block = checker[reference_start:reference_end]
    assert '"--Grundstrukturen=emotion"' in reference_block

    native_start = checker.index('positive_emotion = records(result["emotion v1/4,-2/3"])')
    native_end = checker.index("positive_divisor = records(", native_start)
    native_block = checker[native_start:native_end]
    assert '"--grundstrukturen=emotion" not in positive_emotion[0]' in native_block
    assert '"--Grundstrukturen=emotion" not in positive_emotion[0]' not in native_block


def test_stage_document_and_defect_ledger_record_the_probe_only_fix() -> None:
    document = DOC.read_text(encoding="utf-8")
    assert "kein Produktionsfehler" in document
    assert "--grundstrukturen=emotion" in document
    assert "--Grundstrukturen=emotion" in document
    defects = json.loads((ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8"))
    item = next(entry for entry in defects["defects"] if entry["id"] == "TEST-FIXED-061")
    assert item["origin"] == "test_infrastructure"
    assert item["python_status"] == "not_applicable"
    assert item["mojo_status"] == "fixed"
