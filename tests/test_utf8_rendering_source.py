from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RENDERER = ROOT / "src/reta_mojo/table_rendering.mojo"
EXTRACTOR = ROOT / "src/reta_mojo/html_class_extractor.mojo"
MOJO_TEST = ROOT / "tests/test_native_reta_utf8_html.mojo"


def test_renderer_word_tokenizers_are_codepoint_based() -> None:
    source = RENDERER.read_text(encoding="utf-8")
    assert source.count("for character in clean.codepoint_slices():") >= 3
    assert "String(StringSlice(clean)[byte=start:cursor])" not in source
    assert "String(prefix[byte=1:])" not in source
    assert "String(text.removeprefix(prefix))" in source
    assert "if next_remainder == remainder:" in source
    assert source.count("if remainder == word:") >= 3


def test_renderer_digit_parser_never_indexes_utf8_bytes_as_characters() -> None:
    source = RENDERER.read_text(encoding="utf-8")
    body = source.split("def _render_parse_uint", 1)[1].split("\ndef ", 1)[0]
    assert "codepoint_slices" in body
    assert "text[byte=index]" not in body


def test_exact_user_command_is_a_compiled_mojo_regression() -> None:
    source = MOJO_TEST.read_text(encoding="utf-8")
    for token in (
        '"-zeilen"',
        '"--vorhervonausschnitt=1"',
        '"-spalten"',
        '"--alles"',
        '"-ausgabe"',
        '"--art=html"',
    ):
        assert token in source
    assert 'run_native_reta(tokens, csv_resource("religion.csv"))' in source
    assert "Überraschungs-漢字kombination" in source
    assert "emoji-🙂-Ende" in source


def test_html_extractor_unused_assignment_warning_is_removed() -> None:
    source = EXTRACTOR.read_text(encoding="utf-8")
    fragment = source.split("def _collapsed_text", 1)[1].split("\ndef ", 1)[0]
    assert "pending_space = False\n            var close" not in fragment
