from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_prompt_language_has_a_complete_native_owner() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_language.mojo").read_text(encoding="utf-8")
    assert "struct PromptLanguageCatalog" in owner
    assert "struct PromptLanguageSnapshot" in owner
    assert "struct PromptLegacyValue" in owner
    assert "prompt_language_legacy.tsv" in owner
    assert "def prompt_parameter_tokens" in owner
    assert "def prompt_is_reta_parameter" in owner
    assert "def custom_split" in owner
    assert "def custom_split2" in owner
    assert "def isReTaParameter" in owner
    assert "def is15or16command" in owner
    assert "from std.python import" not in owner
    assert "PythonObject" not in owner


def test_legacy_prompt_language_catalog_is_frozen_and_regenerable() -> None:
    asset = ROOT / "assets/prompt_language_legacy.tsv"
    generator = ROOT / "tools/generate_prompt_language_legacy_catalog.py"
    parity = ROOT / "scripts/check_prompt_language_legacy_parity.sh"
    assert asset.is_file() and asset.stat().st_size > 500_000
    assert generator.is_file()
    assert parity.is_file()
    rows = asset.read_text(encoding="utf-8").splitlines()
    assert len(rows) == 17_123
    assert {row.split("\t", 1)[0] for row in rows} == {
        "deutsch", "english", "vietnamese", "chinese", "korean"
    }


def test_reference_scripts_do_not_prefer_the_mojo_virtualenv() -> None:
    selector = (ROOT / "scripts/select_reference_python.sh").read_text(encoding="utf-8")
    assert "for candidate in pypy3 python3" in selector
    assert selector.index("for candidate in pypy3 python3") < selector.index(".venv/bin/python")
    for path in (ROOT / "scripts").glob("check_*parity.sh"):
        text = path.read_text(encoding="utf-8")
        assert '.venv/bin/python' not in text, path
