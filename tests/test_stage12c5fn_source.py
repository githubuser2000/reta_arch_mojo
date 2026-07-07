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


def test_current_stage_points_to_fn() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5fn.sh" in current
    assert "test_stage12c5fm.sh" in current


def test_stage_script_chains_fm_and_source_tests() -> None:
    script = (ROOT / "scripts/test_stage12c5fn.sh").read_text(encoding="utf-8")
    assert "prompt execution native completion" in script
    assert "test_stage12c5fm.sh" in script
    assert "test_${test_name}_12c5fn" in script
    assert "tests/test_stage12c5fn_source.py" in script
    assert "tests/test_prompt_execution_source.py" in script
    assert "stage12c5fn prompt execution native completion complete" in script


def test_prompt_execution_native_completion_owner_exists() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_execution.mojo").read_text(encoding="utf-8")
    mojo_test = (ROOT / "tests/test_prompt_execution.mojo").read_text(encoding="utf-8")
    assert "struct PromptExecutionNativeCompletionPlan" in owner
    assert "def plan_prompt_execution_native_completion(" in owner
    assert "def prompt_execution_native_completion_valid(" in owner
    assert '"reta_architecture/prompt_execution.py"' in owner
    assert '"nativ"' in owner
    assert "plan.source_lines != 2516" in owner
    assert "plan.top_level_surfaces != 22" in owner
    assert "plan.native_owner_modules != 9" in owner
    assert "plan.historical_table_families != 33" in owner
    assert "plan.one_shot_pipeline_gates != 4" in owner
    assert "plan.compatibility_boundaries != 3" in owner
    assert "prompt_process_dispatch.mojo" in owner
    assert "std.python" not in owner
    assert "PythonObject" not in owner
    assert "test_prompt_execution_native_completion_witness_marks_owner_complete" in mojo_test


def test_porting_matrix_is_fully_native() -> None:
    mapping = _native_mapping()
    assert mapping["reta.py"][0] == "nativ"
    assert mapping["reta_architecture/facade.py"][0] == "nativ"
    assert mapping["reta_architecture/prompt_execution.py"][0] == "nativ"
    row = next(
        line
        for line in (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8").splitlines()
        if line.startswith("| `reta_architecture/prompt_execution.py` |")
    )
    assert "| nativ |" in row
    assert "PromptExecutionNativeCompletionPlan" in row
    assert "2516-Zeilen" in row


def test_porting_metrics_reach_all_files() -> None:
    import importlib.util

    module_path = ROOT / "tools/porting_metrics.py"
    spec = importlib.util.spec_from_file_location("porting_metrics", module_path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    data = module.compute()
    assert data["fully_native_files"] == 92
    assert data["reference_files"] == 92
    assert data["fully_native_percent"] == 100.0


def test_stage_is_documented() -> None:
    doc = (ROOT / "STAGE12C5FN_PROMPT_EXECUTION_NATIVE_COMPLETION.md").read_text(encoding="utf-8")
    assert "92/92" in doc
    assert "PromptExecutionNativeCompletionPlan" in doc
    assert "prompt_execution.py" in doc
    assert "100.0 %" in doc
