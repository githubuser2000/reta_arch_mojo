from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_dl() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_dk_and_builds_prompt_boundary_tests() -> None:
    source = (ROOT / "scripts/test_stage12c5dl.sh").read_text(encoding="utf-8")
    assert "test_stage12c5dk.sh" in source
    assert "prompt reaction contract split" in source
    assert "test_${test_name}_12c5dl" in source
    assert "tests/test_stage12c5dl_source.py" in source
    assert "tests/test_stage12c5dk_source.py" in source


def test_interaction_contract_is_reaction_only() -> None:
    interaction = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    process = (ROOT / "src/reta_mojo/prompt_process_dispatch.mojo").read_text(
        encoding="utf-8"
    )
    body = interaction.split("def prompt_interaction_contract_snapshot", 1)[1]
    body = body.split("return [", 1)[1].split("    ]", 1)[0]
    assert "class=PromptInteractionBundle" in body
    assert "simple_output_dispatch=native-deterministic-prompt-output-plan" in body
    assert "stored_output_dispatch=native-session-output-execution-plan" in body
    assert "execution=delegated-native-dispatch" in body
    assert "external_process_dispatch=native-prompt-process-edge-plan" not in body
    assert "external_reta_arguments=native-prompt-reta-argv-plan" not in body
    assert "fallback_process_dispatch=native-interaction-argv-plan" not in body
    assert "external_command_arguments=runtime-owned-command-argv-builders" not in body
    assert "Process-dispatch details intentionally live" in interaction
    assert "prompt_process_dispatch_contract_snapshot" in interaction
    assert "class=PromptProcessDispatchBundle" in process
    assert "process_adapter=argv-execution-only" in process


def test_prompt_tests_cover_split_contracts() -> None:
    test = (ROOT / "tests/test_prompt_interaction.mojo").read_text(encoding="utf-8")
    assert "assert_equal(len(snapshot), 21)" in test
    assert "var process_snapshot = prompt_process_dispatch_contract_snapshot()" in test
    assert "assert_equal(len(process_snapshot), 19)" in test
    assert 'assert_equal(process_snapshot[18], "process_adapter=argv-execution-only")' in test
    assert 'assert_equal(snapshot[20], "execution=delegated-native-dispatch")' in test


def test_legacy_prompt_scope_composes_reaction_and_process_contracts() -> None:
    facade = (ROOT / "src/reta_mojo/legacy_reta_prompt.mojo").read_text(
        encoding="utf-8"
    )
    test = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    assert "from .prompt_process_dispatch import prompt_process_dispatch_contract_snapshot" in facade
    assert "def _legacy_prompt_scope_snapshot()" in facade
    assert "for index in range(15):" in facade
    assert "for index in range(2, len(process) - 1):" in facade
    assert "result.append(process[1].copy())" in facade
    assert "return _legacy_prompt_scope_snapshot()" in facade
    assert "assert_equal(len(interaction_scope), 21)" in test
    assert "assert_equal(len(scope), 38)" in test
    assert 'assert_equal(scope[15], "external_process_dispatch=native-prompt-process-edge-plan")' in test
    assert 'assert_equal(scope[31], "external_dispatch_owner=prompt-execution-process-plan")' in test


def test_stage_document_records_library_boundary() -> None:
    document = (ROOT / "STAGE12C5DL_PROMPT_REACTION_CONTRACT_SPLIT.md").read_text(
        encoding="utf-8"
    )
    assert "prompt-reaction" in document
    assert "libreta-prompt-reaction" in document
    assert "libreta-prompt-execution" in document
    assert ".so" in document and ".dll" in document
    assert "Keine `.so` oder `.dll`" in document
