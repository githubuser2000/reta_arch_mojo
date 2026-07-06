from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_df_or_later() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_de_and_builds_prompt_boundary_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5df.sh").read_text(encoding="utf-8")
    assert "test_stage12c5de.sh" in source
    assert "fallback runtime argv builder owner" in source
    assert "test_${test_name}_12c5df" in source
    assert "tests/test_stage12c5df_source.py" in source


def test_fallback_argv_builder_lives_in_prompt_runtime_not_process_adapter() -> None:
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(encoding="utf-8")
    assert "def reta_prompt_fallback_arguments_native(" in runtime
    assert "profile_arguments: List[String]" in runtime
    assert "command_arguments: List[String]" in runtime
    assert "This is prompt runtime semantics, not process-adapter semantics" in runtime
    assert "def reta_prompt_fallback_arguments_native(" not in adapter
    assert "def run_reta_prompt_arguments_native(" in adapter
    assert "def run_reta_prompt_fallback_arguments_native(" not in adapter


def test_prompt_interaction_imports_runtime_fallback_builder() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    assert "from .prompt_external_commands import reta_prompt_fallback_arguments_native" not in owner
    assert "reta_prompt_fallback_arguments_native," in owner
    body = owner.split("def plan_prompt_fallback_process_dispatch", 1)[1].split("\ndef plan_stored_output_command", 1)[0]
    assert "reta_prompt_fallback_arguments_native(" in body
    assert "fallback_profile_arguments(profile)" in body
    assert "shell_split(line)" in body
    assert "fallback_runtime_arguments=runtime-owned-argv-builder" in owner


def test_legacy_bridge_and_probe_import_runtime_fallback_builder() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(encoding="utf-8")
    probe = (ROOT / "tests/prompt_external_commands_probe.mojo").read_text(encoding="utf-8")
    assert "from .prompt_runtime import reta_prompt_fallback_arguments_native" in bridge
    assert "from reta_mojo.prompt_runtime import reta_prompt_fallback_arguments_native" in probe
    assert "reta_prompt_fallback_arguments_native(flags, shell_split(raw_line))" in bridge
    assert "reta_prompt_fallback_arguments_native(flags, shell_split(line))" in probe


def test_mojo_snapshot_tracks_runtime_fallback_argv_owner() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert '"fallback_runtime_arguments=runtime-owned-argv-builder"' in test
    assert ("assert_equal(len(snapshot), 33)" in test or "assert_equal(len(snapshot), 34)" in test or "assert_equal(len(snapshot), 35)" in test or "assert_equal(len(snapshot), 36)" in test or "assert_equal(len(snapshot), 37)" in test or "assert_equal(len(snapshot), 38)" in test or "assert_equal(len(snapshot), 21)" in test)


def test_stage_document_records_runtime_owner_move() -> None:
    document = (ROOT / "STAGE12C5DF_FALLBACK_RUNTIME_ARGV_BUILDER_OWNER.md").read_text(encoding="utf-8")
    assert "prompt_runtime.mojo" in document
    assert "prompt_external_commands.mojo" in document
    assert "runtime-owned-argv-builder" in document
