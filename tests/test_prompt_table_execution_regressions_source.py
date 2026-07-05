from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEST = ROOT / "tests" / "test_prompt_table_execution.mojo"
FOCUSED = ROOT / "tests" / "test_prompt_table_execution_regressions.mojo"


def test_complete_output_parameter_tail_does_not_reinsert_default_selection() -> None:
    source = TEST.read_text()
    block = source.split(
        "def test_complete_output_parameter_tail_matches_python_whole_set_order() raises:",
        1,
    )[1].split("def test_prime_cross_uses_historical_minimum() raises:", 1)[0]
    assert "--spaltenreihenfolgeundnurdiese=3-6" not in block
    assert "--spaltenreihenfolgeundnurdiese=0,1" in block


def test_component_local_reciprocal_tail_matches_integer_set_order() -> None:
    source = TEST.read_text()
    block = source.split(
        "def test_fraction_exclusions_and_prefixed_reciprocals_are_native() raises:",
        1,
    )[1].split("def test_eign_properties_are_native_in_full_python_set_order() raises:", 1)[0]
    assert ",492,1004,496,1008,500,1012,504,508" in block
    assert 'assert_true(",500,1012,508"' not in block


def test_focused_mojo_regression_binary_covers_both_user_failures() -> None:
    source = FOCUSED.read_text()
    assert "test_explicit_output_column_order_replaces_internal_default" in source
    assert "test_component_local_reciprocal_tail_matches_python_integer_set" in source
    assert "--spaltenreihenfolgeundnurdiese=3-6" not in source
    assert "--spaltenreihenfolgeundnurdiese=0,1" in source
    assert ",492,1004,496,1008,500,1012,504,508" in source
