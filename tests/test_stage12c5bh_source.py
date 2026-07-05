from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_extends_bg_and_checks_new_runtime_contracts() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5bh.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bi.sh" in current
    assert "test_stage12c5bg.sh" in stage
    assert "generate_command_parity_assets.py --check" in stage
    assert "--migrate-legacy" not in stage
    assert "test_prompt_table_execution_12c5bh" in stage
    assert "check_prompt_true_fraction_multiples.sh" in stage
    assert "test_split_test_pipeline.py" in stage


def test_historical_aq_gate_checks_pinned_assets_without_mutation() -> None:
    stage = (ROOT / "scripts/test_stage12c5aq.sh").read_text(encoding="utf-8")
    generator = (ROOT / "tools/generate_command_parity_assets.py").read_text(
        encoding="utf-8"
    )
    assert "--migrate-legacy" not in stage
    assert "generate_command_parity_assets.py --check" in stage
    assert "LEGACY_ASSET_HASHES" in generator
    assert "refusing to migrate unknown command parity assets" in generator
    assert "--check-reference" in generator
    assert "CANONICAL_ASSET_HASHES" in generator


def test_full_suite_wrapper_keeps_old_entrypoint_while_phases_are_reusable() -> None:
    wrapper = (ROOT / "scripts/test_all.sh").read_text(encoding="utf-8")
    assert "scripts/build-tests.sh" in wrapper
    assert "scripts/run-tests.sh" in wrapper
    assert "RETA_TEST_RUN_JOBS" in wrapper
    assert "--run-jobs" in wrapper
    assert 'build-tests.sh" -- "$@"' in wrapper
