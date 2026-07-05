from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"


def test_projected_integer_multiple_base_is_explicit_and_single_owned() -> None:
    source = MODULE.read_text(encoding="utf-8")
    assert "def _base_projected_fraction_multiple_tokens(" in source
    assert source.count("_base_projected_fraction_multiple_tokens(") == 3
    assert 'result.append("--vielfachevonzahlen=" + _join_rows(row_parts))' in source
    assert 'selected.append("v" + row_parts[index])' in source
    assert "if not divisor_mode:" in source
    assert "--oberesmaximum=" not in source[
        source.index("def _base_projected_fraction_multiple_tokens(") :
        source.index("def _base_multiple_divisor_tokens(")
    ]


def test_only_proven_integer_component_grammars_enter_true_fraction_plans() -> None:
    source = MODULE.read_text(encoding="utf-8")
    assert "def _integer_fraction_axis_supported(" in source
    helper = source[
        source.index("def _integer_fraction_axis_supported(") :
        source.index("def _copy_fraction_pairs(")
    ]
    assert "if saw_ignored_negative_integer:" in helper
    assert "if divisor_mode:" in helper
    assert "if saw_integer_component_exclusion:" in helper
    assert 'if row_parts[index] == "0":' in helper
    assert "and not _integer_fraction_axis_supported(" in source
    assert "len(row_parts) > 0\n            or len(row_values) > 0" not in source


def test_single_and_multi_domain_runtime_contracts_are_bound() -> None:
    test = MOJO_TEST.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    for command in (
        "universum v2/3,5",
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
    ):
        assert command in test
        assert command in probe
        assert command in checker
    assert '"--vorhervonausschnitt=2,1,4,6,3,5,v5"' in test
    assert '"--vorhervonausschnitt=2,1,4,6,3,0,v0"' in test
    assert '"--vorhervonausschnitt=2,1,4,6,3,5,-10,v5,v-10"' in test
    assert "assert_python_integer_axis_composition" in checker
    assert "assert_python_nonpositive_integer_axis_composition" in checker
    assert "wrong multi-domain integer/fraction invocation count" in checker


def test_unrelated_table_family_remains_atomic() -> None:
    source = MODULE.read_text(encoding="utf-8")
    test = MOJO_TEST.read_text(encoding="utf-8")
    assert "not _only_fraction_domain_table_commands(canonical_words)" in source
    assert 'assert_false(_plan("mond universum motive v2/3").handled)' in test
