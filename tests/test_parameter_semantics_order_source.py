from pathlib import Path
import os
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/parameter_semantics.mojo"
TEST = ROOT / "tests/test_parameter_semantics.mojo"


def test_parameter_and_pair_catalogs_are_canonically_sorted():
    source = OWNER.read_text(encoding="utf-8")
    assert "def _sort_parameter_groups" in source
    assert "def _sort_pair_columns" in source
    assert "_sort_parameter_groups(parameter_groups)" in source
    assert "_sort_pair_columns(pair_columns)" in source
    assert "_sort_strings(parameter_groups[index].aliases)" in source
    assert "raw_parameter_entries: List[ParameterEntry]" in source
    assert "for index in range(len(sheaf.raw_parameter_entries))" in source
    assert "left.parameter_canonical > right.parameter_canonical" in source


def test_order_regression_is_compiler_checked():
    source = TEST.read_text(encoding="utf-8")
    assert "test_parameter_groups_and_pair_storage_match_python_order" in source
    assert 'assert_equal(groups[0].parameter_canonical, "Alpha")' in source
    assert 'assert_equal(groups[0].aliases, ["Alpha", "Mitte", "alpha", "zeta"])' in source
    assert 'assert_equal(metadata[0].parameter_aliases, ["Alpha", "zeta", "alpha", "Mitte"])' in source
    assert 'assert_equal(groups[2].parameter_canonical, "Zeta")' in source


def test_python_reference_has_two_distinct_alias_orders():
    env = dict(os.environ)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    probe = ROOT / "python_reference/reta_domain_probe_py.py"
    params = subprocess.run(
        [sys.executable, str(probe), "params", "religionen"],
        cwd=ROOT, env=env, check=True, text=True, capture_output=True,
    ).stdout
    column = subprocess.run(
        [sys.executable, str(probe), "column", "4"],
        cwd=ROOT, env=env, check=True, text=True, capture_output=True,
    ).stdout
    assert "Messias => Messias, heptagramm, hund, messias" in params
    assert "Superkräfte => Superkraefte, Superkräfte" in params
    assert "'parameter_aliases': ['Strukturgrösse', 'Größenordnung', 'größe', 'groesse', 'gross'" in column
