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
    assert "assert_equal(len(mixed_axes.invocations), 13)" in test_source
    assert f'_emit("{command}")' in probe
    assert '_emit("universum vielfache 1/2,2/3")' in probe
    assert f'result["{command}"] != "FALLBACK"' not in checker
    assert "expected_reciprocals = set(range(2, 1024, 2)) | {1, 3, 9}" in checker
    assert "assert_direct_execution(result[\"universum v1/2,2/3\"], runner)" in checker
    assert 'result["universum vielfache 1/2,2/3"] != result["universum v1/2,2/3"]' in checker
    assert 'assert_false(_plan("universum v-1/4,2/3").handled)' in test_source


def test_cross_domain_fraction_rectangles_remain_atomic() -> None:
    test_source = MOJO_TEST.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    assert 'assert_false(_plan("universum motive v2/3").handled)' in test_source
    assert 'result["universum motive v2/3"] != "FALLBACK"' in checker


def test_stage_compiles_runtime_contract_and_runs_direct_parity() -> None:
    source = STAGE.read_text(encoding="utf-8")
    assert '"$ROOT/scripts/test_stage12c5ay.sh"' in source
    assert "tests/test_prompt_table_execution.mojo" in source
    assert '"$ROOT/scripts/check_prompt_true_fraction_multiples.sh"' in source
    assert "tests/test_prompt_mixed_fraction_multiple_source.py" in source
