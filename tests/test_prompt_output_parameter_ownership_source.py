from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNERSHIP = ROOT / "src/reta_mojo/prompt_historical_ownership.mojo"
PLANNER = ROOT / "src/reta_mojo/prompt_table_execution.mojo"
MOJO_TEST = ROOT / "tests/test_prompt_historical_ownership.mojo"
TABLE_TEST = ROOT / "tests/test_prompt_table_execution.mojo"
PROBE = ROOT / "tests/prompt_output_parameter_probe.mojo"
CHECKER = ROOT / "scripts/check_prompt_output_parameters.py"
CONTROLLER = ROOT / "src/prompt_main.mojo"


EXPECTED = {
    "nocolor",
    "justtext",
    "art",
    "onetable",
    "spaltenreihenfolgeundnurdiese",
    "endlessscreen",
    "endless",
    "dontwrap",
    "breite",
    "breiten",
    "keineleereninhalte",
    "keinenummerierung",
    "keineueberschriften",
}


def test_ownership_uses_the_complete_generated_output_surface() -> None:
    source = OWNERSHIP.read_text(encoding="utf-8")
    block = source[
        source.index("def historical_prompt_output_parameters") :
        source.index("def historical_prompt_parameter_supported")
    ]
    for name in EXPECTED:
        assert f'"{name}"' in block
    assert block.count('        "') == 13
    assert "_contains_string(supported, entry.canonical)" in source


def test_parameter_order_filters_the_complete_python_token_set() -> None:
    source = PLANNER.read_text(encoding="utf-8")
    helper = source[
        source.index("def _ordered_prompt_parameters") :
        source.index("def _sort_ints")
    ]
    assert "tokens_are_prepared" in helper
    assert "words.copy() if tokens_are_prepared else python_string_set_order(words)" in helper
    assert "if _contains(candidates, token)" in helper
    assert "passthrough = _ordered_prompt_parameters(" in source
    assert "python_string_set_order(passthrough)" not in source


def test_runtime_contract_covers_all_languages_and_exact_argv_order() -> None:
    ownership_test = MOJO_TEST.read_text(encoding="utf-8")
    table_test = TABLE_TEST.read_text(encoding="utf-8")
    probe = PROBE.read_text(encoding="utf-8")
    checker = CHECKER.read_text(encoding="utf-8")
    assert "assert_equal(seen, 65)" in ownership_test
    assert "test_extended_output_parameters_no_longer_force_atomic_fallback" in ownership_test
    assert "test_complete_output_parameter_tail_matches_python_whole_set_order" in table_test
    for option in ("--justtext", "--onetable", "--endless", "--dontwrap", "--breiten=5,7"):
        assert option in probe
    assert "reta.Program = CollectProgram" in checker
    assert "output-parameter plan mismatch" in checker
    assert "prompt output-parameter ownership and argv order: 7/7" in checker
    controller = CONTROLLER.read_text(encoding="utf-8")
    assert controller.count("planning_tokens_are_prepared") >= 6
    assert controller.count("planning_tokens_are_prepared,") == 2
