from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCHEMA = ROOT / "src/reta_mojo/schema.mojo"
CATALOG = ROOT / "src/reta_mojo/schema_catalog.mojo"
SNAPSHOT = ROOT / "src/reta_mojo/schema_snapshot.mojo"
DOMAIN = ROOT / "src/domain_probe_main.mojo"
REFERENCE = ROOT / "assets/schema_snapshot_reference.json"
GENERATOR = ROOT / "tools/generate_schema_catalog.py"


def test_schema_snapshot_reference_is_valid_and_complete() -> None:
    data = json.loads(REFERENCE.read_text(encoding="utf-8"))
    assert data["para_n_data_matrix_size"] == 431
    assert data["kombi_para_n_data_matrix_size"] == 12
    assert data["kombi_para_n_data_matrix2_size"] == 14
    assert len(data["main_alias_groups"]) == 33
    assert data["schema_modules"]["context"] == "i18n.words_context"
    assert data["schema_modules"]["compat:legacy_monolith"] == "i18n.words_legacy_monolith"


def test_native_schema_snapshot_is_typed_not_a_frozen_runtime_blob() -> None:
    source = SNAPSHOT.read_text(encoding="utf-8")
    assert "def schema_snapshot_json(schema: RetaContextSchema) -> String:" in source
    assert "schema.language_aliases" in source
    assert "schema.parameters_main" in source
    assert "schema.parameter_entries" in source
    assert "read_text_file" not in source
    assert "std.python" not in source
    assert "PythonObject" not in source
    assert 'if command == "schema-json":' in DOMAIN.read_text(encoding="utf-8")


def test_schema_catalog_generator_uses_the_real_split_modules() -> None:
    generator = GENERATOR.read_text(encoding="utf-8")
    assert "RetaContextSchema.from_words_parts" in generator
    assert "context_module=words_context" in generator
    assert "matrix_module=words_matrix" in generator
    assert "runtime_module=words_runtime" in generator
    assert 'i18n.words_legacy_monolith' in CATALOG.read_text(encoding="utf-8")
    schema = SCHEMA.read_text(encoding="utf-8")
    assert "kombi_parameter_matrix_size: Int" in schema
    assert "compat_legacy_monolith: String" in schema
