from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"


def test_owner_recognizes_only_the_proven_positive_first_class() -> None:
    source = OWNER.read_text(encoding="utf-8")
    assert "def _positive_reciprocal_multiple_with_excluded_true_fractions(" in source
    assert "if pair.numerator == 1:" in source
    assert "if pair.numerator != 1 or not pair.multiple:" in source
    assert "has_positive_reciprocal_multiple and has_excluded_true_fraction" in source
    assert "if _positive_reciprocal_multiple_with_excluded_true_fractions(pairs):" in source


def test_runtime_contract_covers_universe_emotion_and_divider_variants() -> None:
    mojo = MOJO_TEST.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    for command in (
        "universum v1/4,-2/3",
        "universum v1/2,-2/3",
        "emotion v1/4,-2/3",
        "universum v1/4,-2/3 teiler",
    ):
        assert command in mojo
        assert f'_emit("{command}")' in probe
        assert f'"{command}"' in checker
    assert "positive-first reciprocal-only and reciprocal-collision branches" in checker
    assert "--gebrochen-rational_" in checker
    assert 'var reciprocal_collision = _plan("universum v1/4,-1/8,2/3")' in mojo
    assert 'assert_equal(len(reciprocal_collision.invocations), 13)' in mojo


def test_direct_native_execution_is_required_for_the_new_single_axis_plan() -> None:
    checker = CHECKER.read_text(encoding="utf-8")
    assert 'result["universum v1/4,-2/3"], runner, expected_count=1' in checker
