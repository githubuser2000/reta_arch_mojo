from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "PROJECT_CONTENT_PROFILES.md"
ARCHIVE = ROOT / "scripts/create_source_archive.sh"


def test_content_profiles_state_required_and_forbidden_upload_roots() -> None:
    text = DOC.read_text(encoding="utf-8")
    for required in ("`src/`", "`python_reference/`", "`assets/`", "`tests/`", "`scripts/`", "`tools/`", "`bin/`"):
        assert required in text
    for forbidden in ("`target/`", "`.venv/`", "`.git/`", "`.pytest_cache/`", "`__pycache__/`", "`*.tmp`"):
        assert forbidden in text
    assert "scripts/create_source_archive.sh" in text


def test_source_archive_enforces_the_documented_exclusions() -> None:
    text = ARCHIVE.read_text(encoding="utf-8")
    for exclusion in (".venv", "target", "build", ".git", ".pytest_cache", "__pycache__", "middle.alx"):
        assert exclusion in text


def test_unchanged_source_does_not_require_another_upload() -> None:
    text = DOC.read_text(encoding="utf-8")
    assert "keine Quelldatei lokal geändert" in text
    assert "Reines Kompilieren oder Testen ändert nur `target/`" in text
    assert "setup_test_dependencies.sh" in text
