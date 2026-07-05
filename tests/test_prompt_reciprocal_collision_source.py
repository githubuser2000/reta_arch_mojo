from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"


def test_owner_recognizes_only_the_positive_first_collision_class() -> None:
    source = OWNER.read_text(encoding="utf-8")
    assert "def _positive_first_reciprocal_collision_with_true_fraction(" in source
    assert "if first.excluded or first.numerator != 1 or not first.multiple:" in source
    assert "positive_reciprocals == 1" in source
    assert "excluded_reciprocals > 0" in source
    assert "positive_true_fractions > 0" in source
    assert "if _positive_first_reciprocal_collision_with_true_fraction(pairs):" in source
    assert "if not pair.multiple:\n            return False" not in source


def test_runtime_contract_separates_local_two_call_and_global_thirteen_call_plans() -> None:
    mojo = MOJO_TEST.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    local = "universum v1/4,-1/8,2/3"
    global_ = "universum v 1/4,-1/8,2/3"
    assert f'var local_reciprocal_collision = _plan("{local}")' in mojo
    assert "assert_equal(len(local_reciprocal_collision.invocations), 2)" in mojo
    assert f'var global_reciprocal_collision = _plan("{global_}")' in mojo
    assert "assert_equal(len(global_reciprocal_collision.invocations), 13)" in mojo
    for command in (local, global_):
        assert f'_emit("{command}")' in probe
        assert f'result["{command}"]' in checker
    assert "expected_local_rows" in checker
    assert "expected_global_rows" in checker
    assert 'result["universum v1/4,-1/8,2/3"], runner, expected_count=2' in checker
    assert 'assert_direct_execution(result["universum v 1/4,-1/8,2/3"], runner)' in checker


def test_python_crash_remains_explicit_evidence_not_fallback_semantics() -> None:
    checker = CHECKER.read_text(encoding="utf-8")
    assert '"universum v1/4,-1/8,2/3",' in checker
    assert '"universum v 1/4,-1/8,2/3",' in checker
    assert "IndexError: string index out of range" in checker
    assert "reciprocal-collision branches" in checker
    assert "positive/excluded reciprocal collision must remain atomic fallback" not in checker
