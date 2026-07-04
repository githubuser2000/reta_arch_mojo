from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_execution.mojo"
REFERENCE = ROOT / "python_reference/reta_architecture/prompt_execution.py"


def test_prompt_execution_bundle_is_native_and_typed():
    source = OWNER.read_text(encoding="utf-8")
    assert "struct PromptExecutionBundle" in source
    assert "struct PromptExecutionSnapshot" in source
    assert "def bootstrap_prompt_execution()" in source
    assert "def prompt_execution_snapshot_json" in source
    assert "prompt_execution_runtime.mojo" in source
    assert "def prompt_execution_owners()" in source
    assert "bundle.ownership_count == 22" in source
    assert "prompt_fraction_execution.mojo" in source
    assert "native_reta_cli.mojo" in source
    assert "std.python" not in source
    assert "PythonObject" not in source


def test_snapshot_names_match_python_bundle():
    reference = REFERENCE.read_text(encoding="utf-8")
    source = OWNER.read_text(encoding="utf-8")
    for value in (
        "PromptExecutionBundle",
        "PromptGrosseAusgabe",
        "bruchBereichsManagementAndWbefehl",
        "retaExecuteNprint",
    ):
        assert value in reference
        assert value in source
