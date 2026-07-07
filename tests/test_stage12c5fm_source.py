from __future__ import annotations

import ast
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _native_mapping() -> dict[str, tuple[str, str, str]]:
    tree = ast.parse((ROOT / "tools/generate_porting_matrix.py").read_text(encoding="utf-8"))
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(
            isinstance(target, ast.Name) and target.id == "NATIVE"
            for target in node.targets
        ):
            value = ast.literal_eval(node.value)
            assert isinstance(value, dict)
            return value
    raise AssertionError("NATIVE mapping missing")


def test_current_stage_points_to_fm() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fn.sh" in current
    assert "test_stage12c5fm.sh" in current


def test_stage_script_chains_fl_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fm.sh").read_text(encoding="utf-8")
    assert "reta top-level native completion" in script
    assert "test_stage12c5fl.sh" in script
    assert "test_${test_name}_12c5fm" in script
    assert "tests/test_stage12c5fm_source.py" in script
    assert "tests/test_legacy_reta_program_source.py" in script
    assert "stage12c5fm reta top-level native completion complete" in script


def test_reta_program_native_completion_owner_exists() -> None:
    owner = (ROOT / "src/reta_mojo/legacy_reta_program.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_legacy_reta_program.mojo").read_text(encoding="utf-8")
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "struct LegacyRetaProgramNativeCompletionPlan" in owner
    assert "def plan_legacy_reta_program_native_completion(" in owner
    assert "def legacy_reta_program_native_completion_valid(" in owner
    assert '"reta.py"' in owner
    assert '"nativ"' in owner
    assert "plan.source_lines != 214" in owner
    assert "plan.public_names != 27" in owner
    assert "plan.method_definitions != 18" in owner
    assert "plan.owner_entries != 10" in owner
    assert "test_reta_program_native_completion_witness_marks_top_level_complete" in mojo_test
    assert "LegacyRetaProgramNativeCompletionPlan" in package
    assert "plan_legacy_reta_program_native_completion" in package
    assert "legacy_reta_program_native_completion_valid" in package


def test_porting_matrix_promotes_reta_without_promoting_prompt_execution() -> None:
    mapping = _native_mapping()
    assert mapping["reta.py"][0] == "nativ"
    assert mapping["reta_architecture/facade.py"][0] == "nativ"
    assert mapping["reta_architecture/prompt_execution.py"][0] == "nativ"
    reta_row = next(
        line
        for line in (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8").splitlines()
        if line.startswith("| `reta.py` |")
    )
    assert "| nativ |" in reta_row
    assert "LegacyRetaProgramNativeCompletionPlan" in reta_row


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FM_RETA_TOP_LEVEL_NATIVE_COMPLETION.md").read_text(encoding="utf-8")
    assert "91/92" in doc
    assert "LegacyRetaProgramNativeCompletionPlan" in doc
    assert "prompt_execution.py" in doc
