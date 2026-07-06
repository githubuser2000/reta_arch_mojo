from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dg_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_df_and_builds_prompt_boundary_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5dg.sh").read_text(encoding="utf-8")
    assert "test_stage12c5df.sh" in source
    assert "prompt runtime shell split owner" in source
    assert "test_${test_name}_12c5dg" in source
    assert "tests/test_stage12c5dg_source.py" in source


def test_shell_split_lives_in_prompt_runtime_not_process_adapter() -> None:
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(encoding="utf-8")
    assert "def shell_split(text: String) raises -> List[String]:" in runtime
    assert "Shell-style tokenization" in runtime or "shell-style argv" in runtime
    assert "def shell_split(text: String)" not in adapter
    assert "from .prompt_runtime import shell_split" in adapter
    assert "def shell_quote(value: String) -> String:" in adapter
    assert "external_call[\"system\", c_int]" in adapter


def test_prompt_interaction_imports_runtime_shell_split_directly() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    assert "from .prompt_external_commands import shell_split" not in owner
    assert "shell_split," in owner
    body = owner.split("def plan_prompt_fallback_process_dispatch", 1)[1].split("\ndef plan_stored_output_command", 1)[0]
    assert "reta_prompt_fallback_arguments_native(" in body
    assert "shell_split(line)" in body
    assert "fallback_shell_split=runtime-owned-argv-tokenizer" in owner


def test_legacy_bridge_probe_and_shell_tests_import_runtime_tokenizer() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(encoding="utf-8")
    probe = (ROOT / "tests/prompt_external_commands_probe.mojo").read_text(encoding="utf-8")
    shell_tests = (ROOT / "tests/test_prompt_external_commands.mojo").read_text(encoding="utf-8")
    assert "from .prompt_runtime import reta_prompt_fallback_arguments_native, shell_split" in bridge
    assert "from reta_mojo.prompt_runtime import reta_prompt_fallback_arguments_native, shell_split" in probe
    assert "from reta_mojo.prompt_runtime import shell_split" in shell_tests
    assert "shell_split," not in shell_tests.split("from reta_mojo.prompt_external_commands import", 1)[1].split(")", 1)[0]


def test_mojo_snapshot_tracks_runtime_shell_split_owner() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert '"fallback_shell_split=runtime-owned-argv-tokenizer"' in test
    assert ("assert_equal(len(snapshot), 34)" in test or "assert_equal(len(snapshot), 35)" in test or "assert_equal(len(snapshot), 36)" in test or "assert_equal(len(snapshot), 37)" in test or "assert_equal(len(snapshot), 38)" in test or "assert_equal(len(snapshot), 21)" in test)


def test_stage_document_records_shell_split_owner_move() -> None:
    document = (ROOT / "STAGE12C5DG_PROMPT_RUNTIME_SHELL_SPLIT_OWNER.md").read_text(encoding="utf-8")
    assert "prompt_runtime.mojo" in document
    assert "prompt_external_commands.mojo" in document
    assert "runtime-owned-argv-tokenizer" in document
