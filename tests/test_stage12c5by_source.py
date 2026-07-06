from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_points_to_a_stage_script() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    if "test_stage12c5ed.sh" in current:
        return
    assert "test_stage12c5" in current
    assert ".sh" in current


def test_stage_wraps_bx_and_rebuilds_legacy_prompt_facade() -> None:
    source = (ROOT / "scripts/test_stage12c5by.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bx.sh" in source
    assert "legacy_reta_prompt" in source
    assert "test_${test_name}_12c5by" in source
    assert "prompt_interaction" in source
    assert "for test_name in legacy_reta_prompt prompt_interaction" in source


def test_legacy_prompt_scope_no_longer_hardcodes_old_count() -> None:
    test = (ROOT / "tests/test_legacy_reta_prompt.mojo").read_text(encoding="utf-8")
    assert "prompt_interaction_contract_snapshot" in test
    assert "assert_equal(len(scope), len(interaction_scope))" in test
    assert "assert_equal(len(PromptScope(facade)), 9)" not in test
    assert "storage_output=native-position-independent-addition-policy" in test


def test_legacy_prompt_scope_delegates_to_interaction_owner() -> None:
    facade = (ROOT / "src/reta_mojo/legacy_reta_prompt.mojo").read_text(
        encoding="utf-8"
    )
    assert "def PromptScope(" in facade
    assert "return prompt_interaction_contract_snapshot()" in facade
    owner = (ROOT / "src/reta_mojo/prompt_interaction.mojo").read_text(
        encoding="utf-8"
    )
    assert "inline_storage=native-position-and-history-policy" in owner
    assert "storage_output=native-position-independent-addition-policy" in owner
