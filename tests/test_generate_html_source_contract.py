from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_native_generator_does_not_write_middle_alx_implicitly() -> None:
    source = (ROOT / "src" / "generate_html_main.mojo").read_text(encoding="utf-8")
    assert '_write_text_file("middle.alx", middle)' not in source
    assert "RETA_GENERATE_HTML_MIDDLE_OUTPUT" in source
    assert "RETA_GENERATE_HTML_LEGACY_MIDDLE" in source


def test_public_launcher_is_cwd_neutral_and_fhs_safe() -> None:
    launcher = (ROOT / "bin" / "generate_html").read_text(encoding="utf-8")
    assert 'cd "$ROOT"' not in launcher
    assert "--middle-file" in launcher
    assert "--middle-output" in launcher
    assert "--no-clobber" in launcher
    assert "mojo-runtime-exec" in launcher


def test_generate_html_manpage_is_shipped() -> None:
    manpage = ROOT / "man" / "generate_html.1"
    assert manpage.is_file()
    text = manpage.read_text(encoding="utf-8")
    assert ".TH GENERATE_HTML 1" in text
    assert "--middle-file" in text
    assert "/usr/share/reta/assets" in text
