from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_true_fraction_multiple_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_true_fraction_multiples.py"
REFERENCE = ROOT / "scripts/check_prompt_combined_outer_order_reference.py"


def test_combined_gate_is_removed_without_broadening_unrelated_families() -> None:
    source = OWNER.read_text(encoding="utf-8")
    multi = source[
        source.index("if true_fraction_multiple_mode and fraction_domain_count > 1:"):
        source.index("var reciprocal_multiple_pairs =", source.index("if true_fraction_multiple_mode and fraction_domain_count > 1:"))
    ]
    assert "has_multi_domain_extension" not in multi
    assert "_has_classic_integer_table_command" not in source
    assert "_only_fraction_domains_or_inert_classic_commands" in multi
    assert "Numeric family 16 precedes family 15" not in multi
    assert "numeric family 16 precedes family 15" in multi


def test_complete_runtime_plan_freezes_34_and_35_invocation_orders() -> None:
    mojo = MOJO_TEST.read_text(encoding="utf-8")
    assert "assert_equal(len(combined.invocations), 34)" in mojo
    assert "assert_equal(len(combined_properties.invocations), 35)" in mojo
    markers = (
        'assert_true("--galaxie=thomas" in _tokens(combined, 0))',
        'assert_true("--konzept=gut" in _tokens(combined, 14))',
        'assert_true("--Universum=transzendentalien" in _tokens(combined, 15))',
        'assert_true("--Bedeutung=gestirn" in _tokens(combined, 28))',
        'assert_true("--alles" in _tokens(combined, 29))',
        'assert_true("--Bedeutung=primzahlkreuz" in _tokens(combined, 30))',
        'assert_true("--Multiversum=" in _tokens(combined, 32))',
        'assert_true("--Grundstrukturen=" in _tokens(combined, 33))',
    )
    for marker in markers:
        assert marker in mojo
    assert 'assert_true("--konzept2=werte" in _tokens(combined_properties, 15))' in mojo


def test_probe_and_checker_cover_every_new_combined_shape() -> None:
    probe = PROBE.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    fragments = (
        "mond motive EIGNgut universum v2/3,5",
        "mond motive universum 15_13 16_2 v2/3,5",
        "mond richtung primzahlkreuz alles thomas motive EIGNgut",
        "EIGRwerte universum 15_13 16_2 v2/3,5",
    )
    for fragment in fragments:
        assert fragment in probe
        assert fragment in checker
    assert "wrong complete combined outer plan count" in checker
    assert "wrong combined EIGN/EIGR outer plan count" in checker
    assert "combined classic/property/catalog outer order" in checker


def test_reference_probe_checks_order_shared_shell_and_prime_cross_exception() -> None:
    source = REFERENCE.read_text(encoding="utf-8")
    order = (
        "--Galaxie=thomas",
        "--Menschliches=motivation",
        "--konzept=gut",
        "--Universum=transzendentalien",
        "--Bedeutung=gestirn",
        "--alles",
        "--Bedeutung=primzahlkreuz",
        "--Primzahlwirkung=Galaxieabsicht",
        "--Multiversum=",
        "--Grundstrukturen=",
    )
    positions = [source.index(f'        "{marker}"') for marker in order]
    assert positions == sorted(positions)
    assert "shell != shells[0]" in source
    assert '"--oberesmaximum=1029" not in prime' in source
    assert "unexpectedly inherited projected whole rows" in source
    assert "combined outer-order reference: 14/14" in source
