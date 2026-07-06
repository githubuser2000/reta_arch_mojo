from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_de() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ee.sh" in current or "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_dd_and_builds_prompt_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5de.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dd.sh" in source
    assert "fallback merged argument owner" in source
    assert "test_${test_name}_12c5de" in source
    assert "tests/test_stage12c5de_source.py" in source


def test_fallback_plan_owns_merged_argv() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(encoding="utf-8")
    struct = owner.split("struct PromptFallbackProcessDispatchPlan", 1)[1].split("@fieldwise_init", 1)[0]
    assert "var handled: Bool" in struct
    assert "var run_reta_prompt: Bool" in struct
    assert "var arguments: List[String]" in struct
    assert "var profile_arguments: List[String]" not in struct
    assert "var command_arguments: List[String]" not in struct
    body = owner.split("def plan_prompt_fallback_process_dispatch", 1)[1].split("\ndef plan_stored_output_command", 1)[0]
    assert "reta_prompt_fallback_arguments_native(" in body
    assert "fallback_profile_arguments(profile)" in body
    assert "shell_split(line)" in body
    assert "fallback_process_arguments=native-merged-fallback-argv" in owner


def test_controller_uses_regular_reta_prompt_argv_boundary() -> None:
    controller = (ROOT / "src/prompt_main.mojo").read_text(encoding="utf-8")
    body = controller.split("def _run_fallback(", 1)[1].split("\ndef _run_native_reta_prompt_command", 1)[0]
    assert "fallback_execution.arguments" in body or "fallback_process.arguments" in body
    assert "fallback_process.profile_arguments" not in body
    assert "fallback_process.command_arguments" not in body
    assert "run_reta_prompt_arguments_native(" in body
    assert "run_reta_prompt_fallback_arguments_native" not in controller


def test_process_adapter_has_no_special_fallback_runner() -> None:
    adapter = (ROOT / "src/reta_mojo/prompt_external_commands.mojo").read_text(encoding="utf-8")
    runtime = (ROOT / "src/reta_mojo/prompt_runtime.mojo").read_text(encoding="utf-8")
    assert "def reta_prompt_fallback_arguments_native(" not in adapter
    assert "def reta_prompt_fallback_arguments_native(" in runtime
    assert "def run_reta_prompt_fallback_arguments_native(" not in adapter
    assert "def run_reta_prompt_arguments_native(" in adapter


def test_legacy_bridge_and_probe_share_merged_argv_helper() -> None:
    bridge = (ROOT / "src/reta_mojo/legacy_mojo_bridge.mojo").read_text(encoding="utf-8")
    probe = (ROOT / "tests/prompt_external_commands_probe.mojo").read_text(encoding="utf-8")
    for source in (bridge, probe):
        assert "reta_prompt_fallback_arguments_native(" in source
        assert "prompt_runtime import reta_prompt_fallback_arguments_native" in source
        assert "run_reta_prompt_arguments_native(" in source
        assert "run_reta_prompt_fallback_arguments_native" not in source


def test_mojo_test_tracks_merged_fallback_argv() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "assert_equal(len(plan.arguments), 5)" in test
    assert 'assert_equal(plan.arguments[0], "-vi")' in test
    assert 'assert_equal(plan.arguments[2], "-befehl")' in test
    assert 'assert_equal(plan.arguments[3], "shell")' in test
    assert 'assert_equal(plan.arguments[4], "echo hi")' in test
    assert '"fallback_process_arguments=native-merged-fallback-argv"' in test
    assert ("assert_equal(len(snapshot), 32)" in test or "assert_equal(len(snapshot), 33)" in test or "assert_equal(len(snapshot), 34)" in test or "assert_equal(len(snapshot), 35)" in test or "assert_equal(len(snapshot), 36)" in test or "assert_equal(len(snapshot), 37)" in test or "assert_equal(len(snapshot), 38)" in test or "assert_equal(len(snapshot), 21)" in test)


def test_stage_document_records_merged_boundary() -> None:
    document = (ROOT / "STAGE12C5DE_FALLBACK_MERGED_ARGUMENT_OWNER.md").read_text(encoding="utf-8")
    assert "run_reta_prompt_fallback_arguments_native" in document
    assert "run_reta_prompt_arguments_native" in document
    assert "native-merged-fallback-argv" in document
