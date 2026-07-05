from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"
REFERENCE = ROOT / "scripts/check_prompt_multi_domain_extensions_reference.py"


def test_multi_domain_owner_builds_shared_outer_axes() -> None:
    source = OWNER.read_text(encoding="utf-8")
    assert "var shared_whole_rows = List[String]()" in source
    assert "var shared_reciprocal_rows = List[String]()" in source
    assert "emotion_shared_projection.reciprocal_rows" in source
    assert "motives_shared_projection.whole_rows" in source
    assert "universe_shared_projection.reciprocal_rows" in source
    assert "var has_shared_integer" in source
    assert "var has_shared_reciprocal" in source


def test_property_order_is_between_motives_and_universe() -> None:
    source = OWNER.read_text(encoding="utf-8")
    motives = source.index("if _motives_fraction_domain_selected(canonical_words):", source.index("def _plan_multi_domain_true_fraction_multiples"))
    property_branch = source.index("if has_property_command:", motives)
    universe = source.index("if _universe_fraction_domain_selected(canonical_words):", property_branch)
    assert motives < property_branch < universe
    assert "plan_prompt_property_commands(" in source[property_branch:universe]


def test_numeric_tail_keeps_16_before_15() -> None:
    source = OWNER.read_text(encoding="utf-8")
    helper = source[source.index("def _plan_multi_domain_true_fraction_multiples"):source.index("def plan_prompt_table_commands")]
    family16 = helper.index('if len(numeric16_values) > 0')
    family15 = helper.index('if len(numeric15_values) > 0')
    assert family16 < family15
    assert "projected whole rows" not in helper or "shared outer axes" in helper


def test_runtime_probe_covers_property_numeric_and_combined_classic_mix() -> None:
    mojo = MOJO_TEST.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    commands = (
        "motive EIGNgut universum v2/3",
        "motive EIGNgut EIGRwerte universum v2/3",
        "motive universum 15_13 16_2 v2/3,5",
        "motive universum 15_13 16_2 v2/3",
        "mond motive EIGNgut universum v2/3,5",
        "mond motive universum 15_13 16_2 v2/3,5",
    )
    for command in commands:
        assert command in mojo
        assert f'_emit("{command}")' in probe
        assert f'"{command}"' in checker
    assert "assert_equal(len(eign.invocations), 27)" in mojo
    assert "assert_equal(len(properties.invocations), 28)" in mojo
    assert "assert_equal(len(numeric.invocations), 28)" in mojo
    assert "wrong complete combined outer plan count" in checker
    assert "var combined = _plan(" in mojo
    assert "var combined_properties = _plan(" in mojo
    assert "combined classic/property/catalog outer order" in checker
    assert 'assert_true("--grundstrukturen=emotion" in _tokens(positive_first_emotion))' in mojo
    assert '--Grundstrukturen=emotion" in _tokens(positive_first_emotion)' not in mojo


def test_positive_first_reference_uses_collected_argv_not_rendered_stdout() -> None:
    checker = CHECKER.read_text(encoding="utf-8")
    function = checker[
        checker.index("def assert_python_positive_first_reciprocal_only"):
        checker.index("def assert_multi_domain_extension_plans")
    ]
    assert "load_reference_payloads(list(cases))" in function
    assert "plan = reference_records(command)" in function
    assert "python_reference/rpb" not in function
    assert "reta_lines" not in function


def test_reference_probe_freezes_python_branch_and_numeric_tail_order() -> None:
    source = REFERENCE.read_text(encoding="utf-8")
    assert 'source.index("eigN, eigR = [], []", motives)' in source
    assert "source.index('i18n.befehle2[\"universum\"]', properties)" in source
    assert 'value.startswith("--Multiversum=")' in source
    assert 'value.startswith("--Grundstrukturen=")' in source
    assert "multi-domain extension reference: 5/5" in source
