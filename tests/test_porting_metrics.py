from __future__ import annotations

import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "tools/porting_metrics.py"


def _load_module():
    spec = importlib.util.spec_from_file_location("porting_metrics", MODULE_PATH)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_porting_metrics_are_derived_from_complete_reference_inventory() -> None:
    data = _load_module().compute()
    assert data["reference_files"] == 92
    assert data["reference_lines"] == 48831
    assert data["fully_native_files"] >= 76
    assert data["at_least_partly_ported_files"] == 83
    assert data["touched_reference_lines"] == 38174
    assert data["fully_native_files"] <= data["at_least_partly_ported_files"]
    assert data["fully_native_reference_lines"] <= data["touched_reference_lines"]


def test_new_concat_owners_are_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/concat_csv.py"][0] == "nativ"
    assert mapping["libs/lib4tables_concat.py"][0] == "nativ"


def test_new_semantics_owners_are_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/semantics_builder.py"][0] == "generiert nativ"
    assert mapping["reta_architecture/column_selection.py"][0] == "nativ"
    assert mapping["reta_architecture/universal.py"][0] == "nativ"


def test_new_combi_join_owner_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/combi_join.py"][0] == "nativ"


def test_table_adapters_owner_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/table_adapters.py"][0] == "nativ"


def test_legacy_prepare_facade_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["libs/lib4tables_prepare.py"][0] == "nativ"


def test_legacy_prompt_facade_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["libs/LibRetaPrompt.py"][0] == "nativ"


def test_program_workflow_core_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/program_workflow.py"][0] == "nativ"


def test_architecture_facade_graph_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/facade.py"][0] == "teilweise nativ"


def test_readme_generator_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["libs/generate4readme.py"][0] == "generiert nativ"


def test_native_domain_probe_core_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_domain_probe_py.py"][0] == "teilweise nativ"


def test_html_class_extractor_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_extract_html_classes.py"][0] == "nativ"


def test_meta_columns_owner_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/meta_columns.py"][0] == "nativ"


def test_morphisms_owner_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/morphisms.py"][0] == "nativ"


def test_runtime_compat_owner_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/runtime_compat.py"][0] == "nativ"


def test_table_wrapping_owner_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/table_wrapping.py"][0] == "nativ"


def test_legacy_table_handling_owner_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["libs/tableHandling.py"][0] == "nativ"


def test_presheaf_and_sheaf_owners_are_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/presheaves.py"][0] == "nativ"
    assert mapping["reta_architecture/sheaves.py"][0] == "nativ"



def test_output_semantics_and_syntax_owners_are_complete() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/output_semantics.py"][0] == "nativ"
    assert mapping["reta_architecture/output_syntax.py"][0] == "nativ"

def test_table_generation_owner_is_in_the_authoritative_mapping() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/table_generation.py"][0] == "nativ"


def test_input_semantics_owner_is_complete() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/input_semantics.py"][0] == "generiert nativ"


def test_console_io_is_fully_native() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/console_io.py"][0] == "nativ"




def test_table_runtime_owner_is_complete() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/table_runtime.py"][0] == "nativ"

def test_table_preparation_owner_is_complete() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/table_preparation.py"][0] == "nativ"

def test_table_output_owner_is_complete() -> None:
    mapping = _load_module().native_mapping()
    assert mapping["reta_architecture/table_output.py"][0] == "nativ"


def test_generated_columns_owner_is_widely_native() -> None:
    mapping = _load_module().native_mapping()
    status, owner, note = mapping["reta_architecture/generated_columns.py"]
    assert status == "weitgehend nativ"
    assert "generated_columns.mojo" in owner
    assert "prime_universe_columns.mojo" in owner
    assert "vollständige typisierte Registry" in note
