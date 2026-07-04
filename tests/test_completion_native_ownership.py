from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_nested_completion_has_one_native_owner() -> None:
    prompt_language = (ROOT / "src/reta_mojo/prompt_language.mojo").read_text(
        encoding="utf-8"
    )
    nested = (ROOT / "src/reta_mojo/completion_nested.mojo").read_text(
        encoding="utf-8"
    )
    assert "def prompt_completion_candidates(" not in prompt_language
    assert "struct ArchitectureNestedCompleter" in nested
    assert "def nested_completion_candidates_from_catalog(" in nested


def test_production_completion_imports_the_owner_module() -> None:
    for relative in (
        "src/reta_mojo/prompt_line_editor.mojo",
        "src/prompt_completion_main.mojo",
    ):
        source = (ROOT / relative).read_text(encoding="utf-8")
        assert "from .completion_nested import" in source or (
            "from reta_mojo.completion_nested import" in source
        )
        assert "nested_completion_candidates_from_catalog" in source


def test_generated_line_completion_uses_python_dictionary_keys() -> None:
    generator = (
        ROOT / "scripts/generate_prompt_nested_catalog.py"
    ).read_text(encoding="utf-8")
    assert "for canonical in line_map.keys():" in generator
    assert "for canonical in line_map.values():" not in generator


def test_catalog_reproduction_check_is_source_archive_portable() -> None:
    script = (
        ROOT / "scripts/check_prompt_language_catalog.sh"
    ).read_text(encoding="utf-8")
    selector = (ROOT / "scripts/select_reference_python.sh").read_text(
        encoding="utf-8"
    )
    assert "select_reference_python.sh" in script
    assert "RETA_PYTHON" in selector
    assert "command -v" in selector and "python3" in selector
    assert '.venv/bin/python scripts/generate_prompt_nested_catalog.py' not in script
