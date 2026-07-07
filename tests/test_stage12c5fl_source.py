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


def test_current_stage_points_to_fl() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fl.sh" in current
    assert "test_stage12c5fk.sh" in current


def test_stage_script_chains_fk_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fl.sh").read_text(encoding="utf-8")
    assert "architecture facade native completion" in script
    assert "test_stage12c5fk.sh" in script
    assert "test_${test_name}_12c5fl" in script
    assert "tests/test_stage12c5fl_source.py" in script
    assert "tests/test_architecture_facade_source.py" in script
    assert "stage12c5fl architecture facade native completion complete" in script


def test_architecture_facade_native_completion_owner_exists() -> None:
    owner = (ROOT / "src/reta_mojo/architecture_facade.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_architecture_facade.mojo").read_text(encoding="utf-8")
    assert "struct ArchitectureFacadeNativeCompletionPlan" in owner
    assert "def plan_architecture_facade_native_completion(" in owner
    assert "def architecture_facade_native_completion_valid(" in owner
    assert '"reta_architecture/facade.py"' in owner
    assert '"nativ"' in owner
    assert "snapshot.fields != 45" in owner
    assert "snapshot.methods != 49" in owner
    assert "snapshot.bootstrap_steps != 45" in owner
    assert "snapshot.snapshot_entries != 48" in owner
    assert "snapshot.force_rebuild_methods != 44" in owner
    assert "snapshot.dependency_edges != 98" in owner
    assert "test_facade_native_completion_witness_marks_graph_complete" in mojo_test


def test_porting_matrix_promotes_only_facade_to_native() -> None:
    mapping = _native_mapping()
    assert mapping["reta_architecture/facade.py"][0] == "nativ"
    assert mapping["reta.py"][0] in {"teilweise nativ", "nativ"}
    assert mapping["reta_architecture/prompt_execution.py"][0] == "nativ"
    row = next(
        line
        for line in (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8").splitlines()
        if line.startswith("| `reta_architecture/facade.py` |")
    )
    assert "| nativ |" in row
    assert "ArchitectureFacadeNativeCompletionPlan" in row


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FL_ARCHITECTURE_FACADE_NATIVE_COMPLETION.md").read_text(encoding="utf-8")
    assert "90/92" in doc
    assert "ArchitectureFacadeNativeCompletionPlan" in doc
    assert "reta.py" in doc
    assert "prompt_execution.py" in doc
