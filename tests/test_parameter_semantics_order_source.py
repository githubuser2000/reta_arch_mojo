from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/parameter_semantics.mojo"
TEST = ROOT / "tests/test_parameter_semantics.mojo"


def test_parameter_and_pair_catalogs_are_canonically_sorted():
    source = OWNER.read_text(encoding="utf-8")
    assert "def _sort_parameter_groups" in source
    assert "def _sort_pair_columns" in source
    assert "_sort_parameter_groups(parameter_groups)" in source
    assert "_sort_pair_columns(pair_columns)" in source
    assert "_sort_strings(parameter_groups[index].aliases)" not in source
    assert "Preserve Python alias insertion order" in source
    assert "left.parameter_canonical > right.parameter_canonical" in source


def test_order_regression_is_compiler_checked():
    source = TEST.read_text(encoding="utf-8")
    assert "test_parameter_groups_and_pair_storage_match_python_order" in source
    assert 'assert_equal(groups[0].parameter_canonical, "Alpha")' in source
    assert 'assert_equal(groups[0].aliases[1], "Größe")' in source
    assert 'assert_equal(groups[0].aliases[2], "groesse")' in source
    assert 'assert_equal(groups[0].aliases[3], "gross")' in source
    assert 'assert_equal(groups[0].aliases[4], "größe")' in source
    assert 'assert_equal(groups[2].parameter_canonical, "Zeta")' in source
