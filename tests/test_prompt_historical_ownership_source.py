from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OWNER = ROOT / "src/reta_mojo/prompt_historical_ownership.mojo"
PROMPT_MAIN = ROOT / "src/prompt_main.mojo"
PARITY = ROOT / "scripts/check_prompt_historical_families_parity.sh"

NEW_FAMILIES = {
    "mond",
    "primzahlkreuz",
    "alles",
    "freiheit",
    "gleichheit",
    "kugeln",
    "kreise",
    "netzwerk",
    "komplex",
}


def _family_literals() -> list[str]:
    source = OWNER.read_text(encoding="utf-8")
    body = source.split("def historical_prompt_table_families()", 1)[1].split(
        "def _contains_string", 1
    )[0]
    return re.findall(r'^\s+"([^"]+)",$', body, flags=re.MULTILINE)


def test_historical_ownership_is_a_pure_typed_boundary() -> None:
    source = OWNER.read_text(encoding="utf-8")
    assert "def is_prompt_numeric_syntax_token(" in source
    assert "def historical_prompt_table_families()" in source
    assert "def historical_prompt_execution_supported(" in source
    assert "def is_historical_prompt_table_family(" in source
    assert "def is_classic_integer_prompt_table_family(" in source
    assert "def is_fraction_prompt_table_family(" in source
    assert "PromptLanguageCatalog" in source
    for forbidden in (
        "std.python",
        "PythonObject",
        "getenv(",
        "open(",
        "print(",
        "run_reta_prompt_fallback_native",
        "run_reta_arguments_native",
    ):
        assert forbidden not in source


def test_all_planned_historical_table_families_share_one_catalog() -> None:
    families = _family_literals()
    assert len(families) == 33
    assert len(set(families)) == 33
    assert families[0] == "mond"
    assert families[-1] == "u"
    assert NEW_FAMILIES <= set(families)
    planner = (ROOT / "src/reta_mojo/prompt_table_execution.mojo").read_text(
        encoding="utf-8"
    )
    assert "from .prompt_historical_ownership import (" in planner
    assert "return is_historical_prompt_table_family(canonical)" in planner
    assert "return is_fraction_prompt_table_family(canonical)" in planner
    assert "if not is_classic_integer_prompt_table_family(canonical):" in planner
    for family in families:
        assert planner.count(f'canonical == "{family}"') == 0


def test_prompt_controller_delegates_instead_of_duplicating_predicate() -> None:
    source = PROMPT_MAIN.read_text(encoding="utf-8")
    assert "from reta_mojo.prompt_historical_ownership import (" in source
    assert source.count("historical_prompt_execution_supported(") == 2
    assert "def _historical_prompt_execution_supported(" not in source
    assert "def _is_prompt_table_canonical(" not in source
    assert "def _canonical_prompt_command(" not in source
    assert "def _is_prompt_numeric_syntax_token(" not in source


def test_parity_gate_requires_a_fresh_prebuilt_binary_and_no_python_source() -> None:
    source = PARITY.read_text(encoding="utf-8")
    assert "scripts/build-all.sh" in source
    assert "check_mojo_binary_freshness.sh" in source
    assert "mojo build" not in source
    assert 'ln -s "$ROOT/python_reference/csv"' in source
    assert 'python_reference/retaPrompt.py' not in source
    assert "8/8 byte-identical without Python fallback" in source
    assert "all-column generator belongs to the reusable full-reference workflow" in source
    for family in sorted(NEW_FAMILIES - {"alles"}):
        assert re.search(rf"check_case\s+\w+\s+r\s+{family}\s+2", source)


def test_package_exports_the_historical_ownership_owner() -> None:
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .prompt_historical_ownership import *" in package
