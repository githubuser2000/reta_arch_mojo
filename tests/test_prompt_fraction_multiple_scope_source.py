from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"


def _text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_compact_v_scope_survives_top_level_comma_splitting() -> None:
    source = _text(OWNER)
    assert "inherited_multiple: Bool = False" in source
    assert "var multiple = inherited_multiple" in source
    assert 'var comma_fraction_multiple = token.startswith("v")' in source
    assert "comma_fraction_multiple," in source
    assert "must not narrow the leading v" in source


def test_long_form_modifier_normalizes_every_fraction_pair() -> None:
    source = _text(OWNER)
    assert "def _fraction_pairs_with_multiple_scope(" in source
    assert "Apply a standalone vielfache/v modifier to every parsed fraction" in source
    assert '_contains(canonical_words, "vielfache")' in source
    assert '_contains(canonical_words, "v")' in source
    assert "fraction_pairs = _fraction_pairs_with_multiple_scope(fraction_pairs)" in source


def test_reciprocal_collision_is_reachable_in_single_and_multi_domain_plans() -> None:
    mojo = _text(MOJO_TEST)
    probe = _text(PROBE)
    checker = _text(CHECKER)
    compact = "universum v1/4,-1/8,2/3"
    long_form = "universum vielfache 1/4,-1/8,2/3"
    multi = "emotion universum v1/4,-1/8,2/3"

    assert f'var reciprocal_collision = _plan("{compact}")' in mojo
    assert f'"{long_form}"' in mojo
    assert "serialize_prompt_table_plan(long_reciprocal_collision)" in mojo
    assert f'"{multi}"' in mojo
    assert "assert_equal(len(multi_reciprocal_collision.invocations), 19)" in mojo

    for command in (compact, long_form, multi):
        assert f'_emit("{command}")' in probe
        assert f'result["{command}"]' in checker

    assert "long-form vielfache did not inherit the complete fraction scope" in checker
    assert "wrong two-domain reciprocal collision count" in checker
    assert "Emotion collision did not preserve compact-v subtraction scope" in checker
    assert "expected_count=19" in checker
