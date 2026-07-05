from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RUNTIME = ROOT / "src/reta_mojo/prompt_runtime.mojo"
REFERENCE = ROOT / "python_reference/reta_architecture/prompt_execution.py"


def test_python_reference_abc_branch_is_position_independent() -> None:
    source = REFERENCE.read_text(encoding="utf-8")
    block = source.split("if Txt.has({i18n.befehle2[\"abcd\"]", 1)[1].split(
        "if Txt.hasWithoutABC({i18n.befehle2[\"kurzbefehle\"]})", 1
    )[0]
    assert "befehlskette = Txt.text.split()" in block
    assert "len(befehlskette)" in block
    assert "== 2" in block
    assert "befehlskette[0] == i18n.befehle2[\"abc\"]" in block
    assert "buchstaben = befehlskette[0]" in block


def test_native_classifier_normalizes_suffix_abc_without_mutating_raw_text() -> None:
    source = RUNTIME.read_text(encoding="utf-8")
    hardcoded = source.split("def classify_prompt_command(", 1)[1].split(
        "def classify_prompt_command_localized", 1
    )[0]
    assert "var second_is_abc" in hardcoded
    assert "normalized.append(words[1])" in hardcoded
    assert "normalized.append(words[0])" in hardcoded
    block = source.split("def classify_prompt_command_localized(", 1)[1].split(
        "def command_payload", 1
    )[0]
    assert "if len(words) == 2:" in block
    assert "if second_kind == KIND_ABC:" in block
    assert "normalized.append(words[1])" in block
    assert "normalized.append(words[0])" in block
    assert "PromptCommand(KIND_ABC, text^, normalized^)" in block



def test_reference_checker_covers_abc_positions_and_logging_precedence() -> None:
    source = (
        ROOT / "scripts/check_prompt_position_independent_effects.py"
    ).read_text(encoding="utf-8")
    assert 'run_prompt("abc Haus")' in source
    assert 'run_prompt("Haus abc")' in source
    assert '(("loggen",), True)' in source
    assert '(("nichtloggen",), False)' in source
    assert '(("nichtloggen", "loggen"), True)' in source
    assert "PromptVonGrosserAusgabeSonderBefehlAusgaben(" in source
