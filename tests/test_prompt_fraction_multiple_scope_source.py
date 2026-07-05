from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
PYTHON_OWNER = ROOT / "python_reference/reta_architecture/prompt_execution.py"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"


def _text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def test_compact_v_is_component_local_after_top_level_comma_splitting() -> None:
    source = _text(OWNER)
    assert "component-local ``v`` prefixes" in source
    assert "var multiple = False" in source
    assert "inherited_multiple: Bool = False" not in source
    assert 'var comma_fraction_multiple = token.startswith("v")' not in source
    assert "top-level comma component therefore retains its own prefix" in source


def test_standalone_v_normalizes_every_fraction_pair_globally() -> None:
    source = _text(OWNER)
    assert "def _fraction_pairs_with_multiple_scope(" in source
    assert "position-independent v command globally" in source
    assert '_contains(canonical_words, "vielfache")' in source
    assert '_contains(canonical_words, "v")' in source
    assert "fraction_pairs = _fraction_pairs_with_multiple_scope(fraction_pairs)" in source


def test_python_reference_distinguishes_component_and_global_scope() -> None:
    source = _text(PYTHON_OWNER)
    assert 'for etwaBruch in custom_split2(a, ",")' in source
    assert 'bruchBereichsAngabe[:1] == i18n.befehle2["v"]' in source
    assert '(i18n.befehle2["v"] in stext)' in source
    assert '(i18n.befehle2["vielfache"] in stext)' in source


def test_local_and_global_collision_contracts_are_both_probed() -> None:
    mojo = _text(MOJO_TEST)
    probe = _text(PROBE)
    checker = _text(CHECKER)

    local = "universum v1/4,-1/8,2/3"
    global_middle = "universum v 1/4,-1/8,2/3"
    global_front = "v universum 1/4,-1/8,2/3"
    global_end = "universum 1/4,-1/8,2/3 v"
    long_form = "universum vielfache 1/4,-1/8,2/3"
    local_multi = "emotion universum v1/4,-1/8,2/3"
    global_multi = "emotion universum v 1/4,-1/8,2/3"

    assert f'var local_reciprocal_collision = _plan("{local}")' in mojo
    assert f'var global_reciprocal_collision = _plan("{global_middle}")' in mojo
    assert "assert_equal(len(local_reciprocal_collision.invocations), 2)" in mojo
    assert "assert_equal(len(global_reciprocal_collision.invocations), 13)" in mojo
    assert "assert_equal(len(local_multi_collision.invocations), 4)" in mojo
    assert "assert_equal(len(global_multi_collision.invocations), 19)" in mojo

    for command in (
        local,
        global_middle,
        global_front,
        global_end,
        long_form,
        local_multi,
        global_multi,
    ):
        assert f'_emit("{command}")' in probe

    for command in (local, global_middle, local_multi, global_multi):
        assert f'result["{command}"]' in checker
    assert "result[positioned]" in checker

    assert "position-independent global multiple command drifted" in checker
    assert "unprefixed 2/3 was incorrectly expanded" in checker
    assert "expected_count=4" in checker
    assert "expected_count=19" in checker
