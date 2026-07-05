from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"
STAGE = ROOT / "scripts/test_stage12c5bf.sh"
DOC = ROOT / "STAGE12C5BF_MULTI_DOMAIN_FRACTION_PLANS.md"


def test_each_fraction_domain_has_an_explicit_physical_rectangle() -> None:
    source = MODULE.read_text(encoding="utf-8")
    for name, maximum_numerator, maximum_denominator in (
        ("emotion", 8, 7),
        ("size", 17, 16),
        ("motives", 22, 21),
        ("universe", 20, 21),
    ):
        assert f"def _{name}_fraction_domain()" in source
        assert (
            f"return _FractionMultipleDomain(True, {maximum_numerator}, "
            f"{maximum_denominator})"
        ) in source
    assert "def _fraction_multiple_domain_count(" in source
    assert "is_physical_fraction_prompt_table_family" in source
    assert "def _true_fraction_projection(" in source


def test_multi_domain_path_builds_independent_projection_plans() -> None:
    source = MODULE.read_text(encoding="utf-8")
    assert "def _plan_multi_domain_true_fraction_multiples(" in source
    assert "fraction_domain_count > 1" in source
    assert "_plan_multi_domain_true_fraction_multiples(" in source
    assert source.count("_true_fraction_projection(") >= 5
    for prefix in (
        "--gebrochen-rational_Gefuehle_n/m=",
        "--gebrochen-rational_Strukturgroesse_n/m=",
        "--gebrochen-rational_Galaxie_n/m=",
        "--gebrochen-rational_Universum_n/m=",
    ):
        assert prefix in source
    assert "More than one table domain plus the implicit multiple command" in source


def test_unproved_compositions_still_fall_back_atomically() -> None:
    source = MODULE.read_text(encoding="utf-8")
    test = MOJO_TEST.read_text(encoding="utf-8")
    assert "not _only_fraction_domain_table_commands(canonical_words)" in source
    assert "len(row_parts) > 0" in source
    assert 'assert_false(_plan("mond universum motive v2/3").handled)' in test
    assert 'assert_false(_plan("universum motive v2/3,5").handled)' in test


def test_runtime_contract_covers_two_four_and_mixed_domains() -> None:
    test = MOJO_TEST.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    for command in (
        "universum motive v2/3",
        "emotion groesse motive universum v2/3",
        "emotion universum v8/3",
        "emotion universum v1/2,2/3",
    ):
        assert command in test
        assert command in probe
        assert command in checker
    assert "len(multi_domain.invocations), 26" in test
    assert "len(all_domains.invocations), 44" in test
    assert "expected_count=26" in checker
    assert "Universe multi-domain rectangle leaked Galaxy numerator 22" in checker


def test_stage_extends_12c5be_and_is_the_current_entrypoint() -> None:
    stage = STAGE.read_text(encoding="utf-8")
    current = (ROOT / "scripts/test_current_stage.sh").read_text(encoding="utf-8")
    do_sh = (ROOT / "do.sh").read_text(encoding="utf-8")
    doc = DOC.read_text(encoding="utf-8")
    assert "test_stage12c5be.sh" in stage
    assert "RETA_STAGE_SKIP_PREVIOUS" in stage
    assert "tests/test_prompt_table_execution.mojo" in stage
    assert "tests/test_prompt_historical_ownership_source.py" in stage
    assert "check_prompt_true_fraction_multiples.sh" in stage
    assert "test_stage12c5bf.sh" in current
    assert "12c5bf" in do_sh
    assert "26" in doc and "44" in doc


def test_documented_multi_domain_invocation_counts_are_consistent() -> None:
    def count(maximum_numerator: int, maximum_denominator: int, axis_families: int, equal_axis: bool = False) -> int:
        numerators = list(range(2, maximum_numerator + 1, 2))
        denominators = list(range(3, maximum_denominator + 1, 3))
        whole = any(n % d == 0 for n in numerators for d in denominators)
        reciprocal = any(d % n == 0 for n in numerators for d in denominators)
        axis_calls = axis_families * (int(whole) + int(reciprocal))
        equal_calls = int(equal_axis and any(n == d for n in numerators for d in denominators))
        return len(numerators) + axis_calls + equal_calls

    emotion = count(8, 7, 1)
    size = count(17, 16, 2)
    motives = count(22, 21, 1)
    universe = count(20, 21, 1, True)
    assert (emotion, size, motives, universe) == (6, 12, 13, 13)
    assert motives + universe == 26
    assert emotion + size + motives + universe == 44
