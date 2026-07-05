from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_current_stage_extends_bi_and_uses_read_only_pinned_assets() -> None:
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    stage = (ROOT / "scripts/test_stage12c5bj.sh").read_text(encoding="utf-8")
    assert "test_stage12c5bk.sh" in current
    next_stage = (ROOT / "scripts/test_stage12c5bk.sh").read_text(encoding="utf-8")
    assert 'test_stage12c5bj.sh" -- "$@"' in next_stage
    assert 'test_stage12c5bi.sh" -- "$@"' in stage
    assert "generate_command_parity_assets.py --check" in stage
    assert "--migrate-legacy" not in stage
    assert 'parser.add_argument("--check-reference"' in (ROOT / "tools/generate_command_parity_assets.py").read_text(encoding="utf-8")


def test_all_historical_stage_gates_are_read_only_for_command_assets() -> None:
    for name in ("12c5aq", "12c5bg", "12c5bh"):
        stage = (ROOT / f"scripts/test_stage{name}.sh").read_text(encoding="utf-8")
        assert "generate_command_parity_assets.py --check" in stage
        assert "--migrate-legacy" not in stage


def test_generator_separates_pinned_and_interpreter_reference_checks() -> None:
    source = (ROOT / "tools/generate_command_parity_assets.py").read_text(
        encoding="utf-8"
    )
    assert "CANONICAL_ASSET_HASHES" in source
    assert 'parser.add_argument("--check-reference"' in source
    check_branch = source[source.index("if args.check:") : source.index("if args.migrate_legacy:")]
    assert "canonical_asset_mismatches()" in check_branch
    assert "expected_files()" not in check_branch
    assert "pinned canonical contract" in source


def test_divisor_set_is_materialized_before_list_only_helper() -> None:
    source = (ROOT / "src/reta_mojo/prompt_table_execution.mojo").read_text(
        encoding="utf-8"
    )
    helper = source[
        source.index("def _projected_fraction_divisor_rows(") :
        source.index("def _base_projected_fraction_multiple_tokens(")
    ]
    assert "var value_set = range_to_numbers(" in helper
    assert "var values = List[Int]()" in helper
    assert "for value in value_set:" in helper
    assert "values.append(value)" in helper
    assert "python_divisor_set_order(values)" in helper
    assert 'result.append("1")' in helper
    assert "if divisors[index] != 1:" in helper
    assert "python_divisor_set_order(value_set)" not in helper


def test_stage_rebuilds_fraction_probe_even_when_previous_stages_are_skipped() -> None:
    stage = (ROOT / "scripts/test_stage12c5bj.sh").read_text(encoding="utf-8")
    assert 'check_prompt_true_fraction_multiples.sh" -- "$@"' in stage
