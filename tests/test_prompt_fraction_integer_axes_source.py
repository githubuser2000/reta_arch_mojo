from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"


def test_projected_integer_multiple_and_divider_bases_are_explicit() -> None:
    source = MODULE.read_text(encoding="utf-8")
    assert "def _projected_fraction_divisor_rows(" in source
    assert "def _base_projected_fraction_multiple_tokens(" in source
    assert source.count("_base_projected_fraction_multiple_tokens(") == 3
    assert 'result.append("--vielfachevonzahlen=" + _join_rows(row_parts))' in source
    assert 'selected.append("v" + row_parts[index])' in source
    assert "var value_set = range_to_numbers(" in source
    assert "var values = List[Int]()" in source
    assert "for value in value_set:" in source
    assert "values.append(value)" in source
    assert "python_divisor_set_order(values)" in source
    assert 'result.append("1")' in source
    assert "if divisors[index] != 1:" in source
    assert "if _join_rows(row_parts).byte_length() > 1:" in source
    assert "if divisor_mode:" in source
    helper = source[
        source.index("def _base_projected_fraction_multiple_tokens(") :
        source.index("def _base_multiple_divisor_tokens(")
    ]
    assert "--oberesmaximum=" not in helper


def test_all_proven_integer_component_grammars_enter_true_fraction_plans() -> None:
    source = MODULE.read_text(encoding="utf-8")
    assert "def _integer_fraction_axis_supported(" in source
    helper = source[
        source.index("def _integer_fraction_axis_supported(") :
        source.index("def _copy_fraction_pairs(")
    ]
    assert "return True" in helper
    assert "separately written negative token" in helper
    assert "explicit\n    plain-multiple and divider laws" in helper
    assert "and not _integer_fraction_axis_supported(" in source


def test_single_and_multi_domain_runtime_contracts_are_bound() -> None:
    test = MOJO_TEST.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    for command in (
        "universum v2/3,5",
        "universum v2/3,1 teiler",
        "universum v2/3,5 teiler",
        "universum motive v2/3,5",
        "emotion universum v8/3,5",
        "emotion universum v1/2,2/3,5",
        "universum motive v2/3,5-7",
        "universum motive v2/3,0",
        "universum motive v2/3,5,-10",
        "universum motive v2/3,-10",
        "universum v2/3,0,-10",
        "universum v2/3,5-7,-6",
        "universum motive v2/3 -10",
        "universum v2/3,0 teiler",
        "universum v2/3,5,-10 teiler",
        "universum motive v2/3,0 teiler",
    ):
        assert command in test
        assert command in probe
        assert command in checker
    assert '"--vorhervonausschnitt=2,1,4,6,3,5,v5"' in test
    assert '"--vorhervonausschnitt=2,1,4,6,3,1,v1"' in test
    assert '"--vorhervonausschnitt=2,1,4,6,3,1,5,v5"' in test
    assert '"--vorhervonausschnitt=2,1,4,6,3,v0"' in test
    assert '"--vorhervonausschnitt=2,1,4,6,3,1,5,5,-10,v5,v-10"' in test
    assert "standalone_negative_base" in test
    assert "assert_python_integer_axis_composition" in checker
    assert "assert_python_nonpositive_integer_axis_composition" in checker
    assert "wrong multi-domain integer/fraction invocation count" in checker


def test_classic_family_requires_an_explicit_integer_axis() -> None:
    source = MODULE.read_text(encoding="utf-8")
    test = MOJO_TEST.read_text(encoding="utf-8")
    assert "_only_fraction_domains_or_inert_classic_commands(" in source
    assert "var has_explicit_integer_axis = len(row_parts) > 0" in source
    assert 'var moon_multi = _plan("mond universum motive v2/3")' in test
    assert 'assert_false(_plan("mond universum motive v2/3,5").handled)' in test
