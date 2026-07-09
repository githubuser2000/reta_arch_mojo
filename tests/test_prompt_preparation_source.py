from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_prompt_preparation_has_typed_native_owner() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_preparation.mojo").read_text(encoding="utf-8")
    regex = (ROOT / "src/reta_mojo/prompt_regex.mojo").read_text(encoding="utf-8")
    catalog = (ROOT / "src/reta_mojo/prompt_preparation_catalog.mojo").read_text(
        encoding="utf-8"
    )
    assert "struct PromptPreparationBundle" in owner
    assert "def prepare_large_prompt_output(" in owner
    assert "def rotate_where_reta_command(" in owner
    assert "def regex_replace(" in regex
    assert "struct PromptPreparationCatalog" in catalog
    assert "std.python" not in owner + regex + catalog


def test_prompt_preparation_domains_are_reproducibly_generated() -> None:
    generator = (ROOT / "scripts/generate_prompt_nested_catalog.py").read_text(
        encoding="utf-8"
    )
    checker = (ROOT / "scripts/check_prompt_language_catalog.sh").read_text(
        encoding="utf-8"
    )
    asset = ROOT / "assets/prompt_preparation_domains.tsv"
    assert asset.is_file()
    assert "prompt_preparation_domains.tsv" in generator
    assert "prompt_preparation_domains.tsv" in checker
    assert asset.stat().st_size > 100_000


def test_full_prompt_preparation_parity_gate_exists() -> None:
    checker = (ROOT / "scripts/check_prompt_preparation_full_parity.sh").read_text(
        encoding="utf-8"
    )
    reference = (ROOT / "scripts/prompt_preparation_full_reference.py").read_text(
        encoding="utf-8"
    )
    probe = (ROOT / "tests/prompt_preparation_full_batch_probe.mojo").read_text(
        encoding="utf-8"
    )
    assert "deutsch english vietnamese chinese korean" in checker
    assert "bootstrap_prompt_preparation" in reference
    assert "bootstrap_prompt_preparation" in probe


def test_full_all_semantic_comparator_is_shape_strict() -> None:
    comparator = (ROOT / "scripts/compare_full_all_html.py").read_text(
        encoding="utf-8"
    )
    assert "STRUCTURE_MISMATCH" in comparator
    assert "SEMANTIC_PARITY" in comparator
    assert "semantic_cells_equal" in comparator

def test_front_parity_gate_is_source_archive_portable() -> None:
    checker = (ROOT / "scripts/check_prompt_preparation_parity.sh").read_text(
        encoding="utf-8"
    )
    assert "scripts/select_reference_python.sh" in checker
    assert 'PYTHON=$(' in checker
    assert "PYTHONHASHSEED=0 .venv/bin/python" not in checker

def test_legacy_prompt_preparation_surface_is_explicit_and_native() -> None:
    owner = (ROOT / "src/reta_mojo/prompt_preparation.mojo").read_text(encoding="utf-8")
    for declaration in (
        "struct PromptPreparationLegacySnapshot",
        "def legacy_snapshot(self)",
        "def configure_prompt_preparation(",
        "def verdreheWoReTaBefehl(",
        "def regExReplace(",
        "def promptVorbereitungGrosseAusgabe(",
        "def prepare_grosse_ausgabe(",
    ):
        assert declaration in owner
    assert "PythonObject" not in owner
    assert "std.python" not in owner
    package = (ROOT / "src/reta_mojo/__init__.mojo").read_text(encoding="utf-8")
    assert "from .prompt_preparation import (" in package
    assert "PromptPreparationLegacySnapshot," in package
    assert "promptVorbereitungGrosseAusgabe," in package


def test_prompt_preparation_is_claimed_as_fully_native() -> None:
    matrix = (ROOT / "PORTING_MATRIX.md").read_text(encoding="utf-8")
    row = next(
        line for line in matrix.splitlines()
        if "`reta_architecture/prompt_preparation.py`" in line
    )
    assert "| nativ |" in row



def test_prompt_regex_treats_plus_reta_as_reta_command_prefix() -> None:
    native_regex = (ROOT / "src/reta_mojo/prompt_regex.mojo").read_text(encoding="utf-8")
    reference = (ROOT / "python_reference/reta_architecture/prompt_preparation.py").read_text(encoding="utf-8")
    assert 'def _is_reta_command_token(token: String) -> Bool:' in native_regex
    assert 'token == "reta" or token == "+reta"' in native_regex
    assert 'def _is_reta_command_token(token: str) -> bool:' in reference
    assert 'return token in ("reta", "+reta")' in reference

def test_python_reference_prompt_preparation_accepts_plus_reta_column_wildcards() -> None:
    import sys

    sys.path.insert(0, str(ROOT / "python_reference"))
    from reta_architecture.prompt_language import PromptModus
    from reta_architecture.prompt_preparation import bootstrap_prompt_preparation

    preparation = bootstrap_prompt_preparation()
    main_result = preparation.prepare_grosse_ausgabe(
        "", PromptModus.normal, PromptModus.normal, PromptModus.normal,
        "+reta -spalten --*=motive", []
    )
    value_result = preparation.prepare_grosse_ausgabe(
        "", PromptModus.normal, PromptModus.normal, PromptModus.normal,
        "+reta -spalten --menschliches=*", []
    )
    main_tokens = main_result[5]
    value_tokens = value_result[5]
    assert main_tokens[0] == "+reta"
    assert value_tokens[0] == "+reta"
    assert any(token.lower() == "--menschliches=motive" for token in main_tokens)
    assert any(token.startswith("--menschliches=") and "motive" in token for token in value_tokens)
