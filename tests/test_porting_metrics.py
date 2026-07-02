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
    assert data["fully_native_files"] == 57
    assert data["at_least_partly_ported_files"] == 77
    assert data["touched_reference_lines"] == 35194
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
