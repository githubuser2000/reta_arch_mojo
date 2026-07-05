from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
STAGE = ROOT / "scripts/test_stage12c5az.sh"


def test_mixed_axes_have_separate_typed_bounds() -> None:
    source = OWNER.read_text(encoding="utf-8")
    assert "def _has_positive_true_fraction(" in source
    assert "def _fraction_pairs_for_axis(" in source
    assert "def _merge_expanded_reciprocal_multiple_rows(" in source
    assert ") raises -> List[String]:" in source
    assert "reciprocal rows use the historical 1024" in source
    assert "proper fractions expand only inside this domain rectangle" in source
    assert "Mixed reciprocal and true-fraction multiple axes have two incompatible" not in source
    assert "Keep that compound form atomic" not in source


def test_mixed_universe_contract_is_no_longer_a_fallback() -> None:
    test_source = MOJO_TEST.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    command = "universum v1/2,2/3"
    assert f'var mixed_axes = _plan("{command}")' in test_source
    assert "assert_true(mixed_axes.handled)" in test_source
    assert "assert_equal(len(mixed_axes.invocations), 2)" in test_source
    assert f'_emit("{command}")' in probe
    assert '_emit("universum vielfache 1/2,2/3")' in probe
    assert f'result["{command}"] != "FALLBACK"' not in checker
    assert "component-local reciprocal axis did not remain independent" in checker
    assert 'result["universum v 1/2,2/3"]' in checker
    assert "assert_direct_execution(result[\"universum v1/2,2/3\"], runner, expected_count=2)" in checker
    assert 'result["universum vielfache 1/2,2/3"] != result["universum v 1/2,2/3"]' in checker
    assert 'result["universum v1/2,2/3"] == result["universum v 1/2,2/3"]' in checker
    assert 'var excluded_reciprocal = _plan("universum v-1/4,2/3")' in test_source
    assert 'assert_true(excluded_reciprocal.handled)' in test_source
    assert 'var negative_true_fraction = _plan("universum v-2/3")' in test_source
    assert 'assert_true(negative_true_fraction.handled)' in test_source
    assert 'var negative_first_mixed = _plan("universum v-2/3,1/4")' in test_source
    assert 'assert_true(negative_first_mixed.handled)' in test_source
    assert 'var positive_first = _plan("universum v1/4,-2/3")' in test_source
    assert 'assert_true(positive_first.handled)' in test_source
    assert 'assert_equal(len(positive_first.invocations), 1)' in test_source
    assert 'var positive_first_half = _plan("universum v1/2,-2/3")' in test_source
    assert 'var positive_first_emotion = _plan("emotion v1/4,-2/3")' in test_source
    assert 'var positive_first_divisor = _plan("universum v1/4,-2/3 teiler")' in test_source
    assert 'var local_reciprocal_collision = _plan("universum v1/4,-1/8,2/3")' in test_source
    assert 'assert_equal(len(local_reciprocal_collision.invocations), 2)' in test_source
    assert 'var global_reciprocal_collision = _plan("universum v 1/4,-1/8,2/3")' in test_source
    assert 'assert_equal(len(global_reciprocal_collision.invocations), 13)' in test_source
    assert '"universum v-2/3,1/4",' in checker
    assert 'positive_first = records(result["universum v1/4,-2/3"])' in checker
    assert 'set(range(4, 1024, 4))' in checker
    assert 'assert_python_positive_first_reciprocal_only()' in checker
    assert 'expected_count=1' in checker
    assert 'if result[command] != ""' in checker


def test_cross_domain_fraction_rectangles_are_now_independent() -> None:
    test_source = MOJO_TEST.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    assert 'var multi_domain = _plan("universum motive v2/3")' in test_source
    assert 'assert_true(multi_domain.handled)' in test_source
    assert 'assert_equal(len(multi_domain.invocations), 26)' in test_source
    assert 'multi_domain = records(result["universum motive v2/3"])' in checker
    assert 'wrong Universe+motives invocation count' in checker


def test_stage_compiles_runtime_contract_and_runs_direct_parity() -> None:
    source = STAGE.read_text(encoding="utf-8")
    assert '"$ROOT/scripts/test_stage12c5ay.sh"' in source
    assert "tests/test_prompt_table_execution.mojo" in source
    assert '"$ROOT/scripts/check_prompt_true_fraction_multiples.sh"' in source
    assert "tests/test_prompt_mixed_fraction_multiple_source.py" in source
