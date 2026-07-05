from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEST = ROOT / "tests/test_presheaves_complete.mojo"
OWNER = ROOT / "src/reta_mojo/presheaves.mojo"


def test_filesystem_restriction_counts_explicit_and_neutral_sections() -> None:
    source = TEST.read_text(encoding="utf-8")
    assert "assert_equal(len(sections), 32)" in source
    assert "assert_equal(explicit_chinese, 16)" in source
    assert "assert_equal(inherited_neutral, 16)" in source
    assert 'assert_true("cn" in section.context.language.values)' in source
    assert 'assert_true(section.source.endswith(".csv"))' in source


def test_neutral_catalog_sections_remain_unrestricted_until_refinement() -> None:
    source = OWNER.read_text(encoding="utf-8")
    assert "if entry.language.byte_length() > 0:" in source
    assert "context.language = restricted_dimension([entry.language.copy()])" in source
    assert "var refined = refine_selection(section.context, context)" in source
    assert "if not selection_is_empty(refined):" in source
