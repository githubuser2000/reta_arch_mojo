from __future__ import annotations

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _defect_ids() -> set[str]:
    data = json.loads((ROOT / "KNOWN_DEFECTS.json").read_text(encoding="utf-8"))
    return {item["id"] for item in data["defects"]}


def test_dictionary_inversion_bug_is_reproducible_and_backlogged() -> None:
    code = (
        "from reta_architecture.arithmetic import invert_int_value_dict;"
        "print(invert_int_value_dict({'a':['1'],'b':['1']}))"
    )
    result = subprocess.run(
        ["python3", "-c", code],
        cwd=ROOT / "python_reference",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
        text=True,
    )
    assert result.stdout.strip() == "{1: ['b']}"
    assert "PY-OPEN-003" in _defect_ids()


def test_fixed_semantics_counts_and_remaining_red_baseline_are_documented() -> None:
    source = (
        ROOT / "python_reference" / "tests" / "test_architecture_refactor.py"
    ).read_text(encoding="utf-8")
    assert source.count("554") == 0
    assert source.count("556") >= 3
    assert 'self.assertIn("load_/religion_table"' in source
    ids = _defect_ids()
    assert {"PY-OPEN-004", "PY-OPEN-005", "TEST-FIXED-014"} <= ids


def test_float_moon_number_candidate_is_not_silently_forgotten() -> None:
    source = (
        ROOT / "python_reference" / "reta_architecture" / "number_theory.py"
    ).read_text(encoding="utf-8")
    assert "num ** (1 / i)" in source
    assert "round(oneResult * 100000)" in source
    assert "PY-CAND-004" in _defect_ids()


def test_prompt_toolkit_unicode_word_boundary_candidate_is_classified() -> None:
    code = (
        "from reta_architecture.completion_word import Document, word_before_cursor, "
        "iter_word_completions;"
        "d=Document('grö');"
        "print(repr(word_before_cursor(d)));"
        "print([x.text for x in iter_word_completions(['größe'], d)])"
    )
    result = subprocess.run(
        ["python3", "-c", code],
        cwd=ROOT / "python_reference",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=True,
        text=True,
    )
    # Older prompt_toolkit releases split the ASCII prefix from the Unicode
    # codepoint; newer releases correctly retain the complete word.  This is
    # an environment-sensitive upstream candidate, not a defect whose broken
    # behavior must remain reproducible forever.
    assert result.stdout.splitlines() in (
        ["'ö'", "[]"],
        ["'grö'", "['größe']"],
    )
    assert "PY-CAND-007" in _defect_ids()
