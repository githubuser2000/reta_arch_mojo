from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "src/reta_mojo/program_workflow.mojo"
MOJO_TEST = ROOT / "tests/test_program_workflow.mojo"
STAGE = ROOT / "scripts/test_stage12c5be.sh"
DOC = ROOT / "STAGE12C5BE_WORKFLOW_ROOT_OUTPUT_MODE_FULL_SUITE.md"


def test_program_workflow_owns_explicit_fixture_root() -> None:
    module = MODULE.read_text(encoding="utf-8")
    test = MOJO_TEST.read_text(encoding="utf-8")
    assert "program_workflow_csv_path(csv_file_name, self.repo_root)" in module
    assert "program_workflow_csv_path(filename, repo_root)" in module
    assert 'root == "."' in module
    assert '"tests/fixtures/program_workflow_root"' in test
    assert "bundle._load_religion_table(" in test


def test_rich_output_mode_is_shared_by_decode_and_renderer_plan() -> None:
    module = MODULE.read_text(encoding="utf-8")
    test = MOJO_TEST.read_text(encoding="utf-8")
    assert 'if requested_output_kind != "plain":' in module
    assert "runtime.output_mode = requested_output_kind" in module
    assert 'assert_equal(parameters.runtime.output_mode, "html")' in test
    assert 'assert_equal(rich_parameters.runtime.output_mode, "bbcode")' in test


def test_stage_reproduces_full_suite_environment_without_hidden_override() -> None:
    stage = STAGE.read_text(encoding="utf-8")
    assert '"$ROOT/scripts/test_stage12c5bd.sh"' in stage
    assert "RETA_STAGE_SKIP_PREVIOUS" in stage
    assert "tests/test_program_workflow.mojo" in stage
    assert "scripts/check_program_workflow_parity.py" in stage
    assert "RETA_DATA_DIR=" not in stage
    for historical_stage in (
        "test_stage12c5k.sh",
        "test_stage12c5l.sh",
        "test_stage12c5m.sh",
        "test_stage12c5n.sh",
        "test_stage12c5ae.sh",
    ):
        text = (ROOT / "scripts" / historical_stage).read_text(encoding="utf-8")
        assert "RETA_DATA_DIR=" not in text
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bf.sh" in current
    assert "test_stage12c5be.sh" in (ROOT / "scripts/test_stage12c5bf.sh").read_text(encoding="utf-8")


def test_reported_failures_and_ledger_entries_are_documented() -> None:
    doc = DOC.read_text(encoding="utf-8")
    assert "Jungfrau" in doc
    assert "한글 中文 Việt" in doc
    assert "shell" in doc and "html" in doc
    defects = json.loads((ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8"))[
        "defects"
    ]
    ids = {item["id"] for item in defects}
    assert {"MOJO-FIXED-057", "MOJO-FIXED-058", "TEST-FIXED-046"} <= ids
