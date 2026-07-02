#!/usr/bin/env python3
"""Generate the complete native input catalog for ParameterSemanticsBuilder."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
PYREF = ROOT / "python_reference"
sys.path.insert(0, str(PYREF))

import i18n.words as words  # noqa: E402
from reta_architecture.schema import RetaContextSchema  # noqa: E402
from reta_architecture.semantics_builder import ParameterSemanticsBuilder  # noqa: E402
from reta_architecture.number_theory import primCreativity  # noqa: E402


def q(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def list_strings(values: Iterable[object]) -> str:
    return "[" + ", ".join(q(v) for v in values) + "]"


def stable_values(values: Iterable[object]) -> list[object]:
    def key(value: object) -> tuple[int, str]:
        if isinstance(value, bool):
            return (0, repr(value))
        if isinstance(value, int):
            return (1, f"{value:020d}")
        if isinstance(value, tuple):
            return (2, repr(value))
        if isinstance(value, str):
            return (3, value)
        if callable(value):
            return (4, getattr(value, "__qualname__", getattr(value, "__name__", repr(value))))
        return (5, repr(value))

    return sorted(values, key=key) if isinstance(values, (set, frozenset)) else list(values)


class StableSet(set):
    """Set semantics with deterministic iteration for reference generation."""

    def __iter__(self):
        return iter(stable_values(set.copy(self)))


def normalized_schema(schema: RetaContextSchema) -> RetaContextSchema:
    """Return the exact schema with unordered containers canonicalised.

    Python's historical matrix contains a few sets for parameter names and many
    sets for data values.  Their iteration order changes with PYTHONHASHSEED,
    while the generated Mojo catalog necessarily has a concrete order.  Sorting
    only set/frozenset containers makes generation reproducible without changing
    the order of lists and tuples, whose order is part of the public contract.
    """

    entries: list[tuple] = []
    for entry in schema.para_n_data_matrix:
        entries.append(
            (
                tuple(stable_values(entry[0])),
                tuple(stable_values(entry[1])),
                *(StableSet(values) for values in entry[2:]),
            )
        )

    def normalize_combinations(mapping):
        if mapping is None:
            return None
        return {key: tuple(stable_values(values)) for key, values in mapping.items()}

    return RetaContextSchema(
        language_aliases=dict(schema.language_aliases),
        translation_domains=dict(schema.translation_domains),
        parameters_main=list(schema.parameters_main),
        row_parameters=dict(schema.row_parameters),
        output_parameters=dict(schema.output_parameters),
        output_modes=dict(schema.output_modes),
        combination_parameters=dict(schema.combination_parameters),
        scopes=dict(schema.scopes),
        para_n_data_matrix=entries,
        kombi_para_n_data_matrix=normalize_combinations(schema.kombi_para_n_data_matrix),
        kombi_para_n_data_matrix2=normalize_combinations(schema.kombi_para_n_data_matrix2),
        tag_names=tuple(schema.tag_names),
        schema_modules=dict(schema.schema_modules),
    )


def semantic_expr(value: object) -> str:
    if isinstance(value, bool):
        return f"semantic_bool({'True' if value else 'False'})"
    if isinstance(value, int):
        return f"semantic_int({value})"
    if isinstance(value, str):
        return f"semantic_text({q(value)})"
    if isinstance(value, tuple):
        if len(value) == 1 and value[0] is None:
            return "semantic_null_tuple()"
        if len(value) == 1 and isinstance(value[0], int) and not isinstance(value[0], bool):
            return f"semantic_single_int_tuple({int(value[0])})"
        if len(value) == 2 and all(isinstance(v, int) and not isinstance(v, bool) for v in value):
            return f"semantic_int_tuple({int(value[0])}, {int(value[1])})"
        if len(value) == 2 and isinstance(value[0], bool) and isinstance(value[1], int):
            return f"semantic_bool_tuple({'True' if value[0] else 'False'}, {int(value[1])})"
    if callable(value):
        return f"semantic_callable({q(getattr(value, '__qualname__', getattr(value, '__name__', repr(value))))})"
    raise TypeError(f"unsupported semantic value: {type(value).__name__}: {value!r}")


def dataset_expr(values: Iterable[object]) -> str:
    items = [semantic_expr(value) for value in stable_values(values)]
    if not items:
        return "SemanticDataSet(List[SemanticValue]())"
    return "SemanticDataSet([" + ", ".join(items) + "])"


def generate_catalog(schema: RetaContextSchema) -> str:
    chunk_size = 24
    entry_lines: list[str] = []
    for entry in schema.para_n_data_matrix:
        mains = [str(value) for value in stable_values(entry[0])]
        parameters = [str(value) for value in stable_values(entry[1])]
        datasets = [dataset_expr(values) for values in entry[2:]]
        dataset_list = (
            "[" + ", ".join(datasets) + "]" if datasets else "List[SemanticDataSet]()"
        )
        entry_lines.append(
            "    entries.append(ParameterMatrixEntry("
            f"{list_strings(mains)}, {list_strings(parameters)}, {dataset_list}))"
        )

    lines = [
        '\"\"\"Generated full parameter-semantics input catalog.\n\nRegenerate with tools/generate_semantics_builder_catalog.py.\n\"\"\"',
        "",
        "from std.collections import List",
        "from .semantics_builder import *",
        "",
        "",
    ]

    chunk_names: list[str] = []
    for chunk_index, offset in enumerate(range(0, len(entry_lines), chunk_size)):
        name = f"_append_parameter_entries_{chunk_index:02d}"
        chunk_names.append(name)
        lines.append(
            f"def {name}(mut entries: List[ParameterMatrixEntry]) -> None:"
        )
        lines.extend(entry_lines[offset : offset + chunk_size])
        lines.extend(["", ""])

    lines.extend(
        [
            "def _append_combinations_1(mut combinations: List[CombinationEntry]) -> None:",
        ]
    )
    for key, values in (schema.kombi_para_n_data_matrix or {}).items():
        lines.append(
            f"    combinations.append(CombinationEntry({int(key)}, {list_strings(stable_values(values))}))"
        )
    lines.extend(["", "", "def _append_combinations_2(mut combinations: List[CombinationEntry]) -> None:"])
    for key, values in (schema.kombi_para_n_data_matrix2 or {}).items():
        lines.append(
            f"    combinations.append(CombinationEntry({int(key)}, {list_strings(stable_values(values))}))"
        )

    lines.extend(
        [
            "",
            "",
            "def bootstrap_parameter_semantics_schema() -> ParameterSemanticsSchema:",
            "    var entries = List[ParameterMatrixEntry]()",
        ]
    )
    for name in chunk_names:
        lines.append(f"    {name}(entries)")
    lines.extend(
        [
            "    var combinations1 = List[CombinationEntry]()",
            "    _append_combinations_1(combinations1)",
            "    var combinations2 = List[CombinationEntry]()",
            "    _append_combinations_2(combinations2)",
            "    return ParameterSemanticsSchema(entries^, combinations1^, combinations2^)",
            "",
            "",
            "def bootstrap_full_parameter_semantics(invert_alles: Bool = False) raises -> ParameterSemanticsBuildResult:",
            "    return build_parameter_semantics(",
            "        bootstrap_parameter_semantics_schema(),",
            f"        {int(words.gebrochenSpaltenMaximumPlus1)},",
            "        invert_alles,",
            f"        {list_strings(words.ParametersMain.alles)},",
            "    )",
            "",
        ]
    )
    return "\n".join(lines)



FINGERPRINT_MOD1 = 1_000_000_007
FINGERPRINT_MOD2 = 1_000_000_009


def _canonical_semantic(value: object, *, data_key: bool = False) -> str:
    if data_key and value == ("bool", 0):
        return "sentinel:bool:0"
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "bool:" + ("true" if value else "false")
    if isinstance(value, int):
        return f"int:{value}"
    if isinstance(value, str):
        return "text:" + value
    if isinstance(value, tuple):
        if len(value) == 1 and value[0] is None:
            return "tuple:(none,)"
        if len(value) == 1 and isinstance(value[0], int) and not isinstance(value[0], bool):
            return f"tuple:({value[0]},)"
        if len(value) == 2 and isinstance(value[0], bool) and isinstance(value[1], int):
            return f"booltuple:({'true' if value[0] else 'false'},{value[1]})"
        if len(value) == 2 and all(isinstance(item, int) and not isinstance(item, bool) for item in value):
            return f"tuple:({value[0]},{value[1]})"
    if callable(value):
        return "callable:" + getattr(value, "__qualname__", getattr(value, "__name__", repr(value)))
    raise TypeError(f"unsupported semantic fingerprint value: {value!r}")


def _fingerprint_field(value: object) -> str:
    text = str(value)
    return f"{len(text.encode('utf-8'))}:{text}"


def _fingerprint_record(tag: object, *fields: object) -> str:
    padded = list(fields[:5])
    padded.extend([""] * (5 - len(padded)))
    return "".join(_fingerprint_field(value) for value in (tag, *padded))


def _record_hash(value: str, modulus: int, base: int) -> int:
    result = 0
    for byte in value.encode("utf-8"):
        result = (result * base + byte + 1) % modulus
    return result


class _Fingerprint:
    __slots__ = ("records", "sum1", "sum2", "square1", "square2")

    def __init__(self) -> None:
        self.records = self.sum1 = self.sum2 = self.square1 = self.square2 = 0

    def add(self, record: str) -> None:
        first = _record_hash(record, FINGERPRINT_MOD1, 257)
        second = _record_hash(record, FINGERPRINT_MOD2, 263)
        self.records += 1
        self.sum1 = (self.sum1 + first) % FINGERPRINT_MOD1
        self.sum2 = (self.sum2 + second) % FINGERPRINT_MOD2
        self.square1 = (self.square1 + first * first) % FINGERPRINT_MOD1
        self.square2 = (self.square2 + second * second) % FINGERPRINT_MOD2

    def canonical(self) -> str:
        return f"{self.records}:{self.sum1}:{self.sum2}:{self.square1}:{self.square2}"


def _group_fingerprint(group: Iterable[tuple[object, object]]) -> str:
    result = _Fingerprint()
    for main_name, parameter_name in group:
        result.add(_fingerprint_record("pair", main_name, parameter_name))
    return result.canonical()


def semantics_fingerprint(result) -> str:
    fingerprint = _Fingerprint()
    matrix = list(result.para_n_data_matrix)
    for entry_index, entry in enumerate(matrix):
        mains = list(entry[0])
        parameters = list(entry[1])
        datasets = list(entry[2:])
        fingerprint.add(_fingerprint_record(
            "matrix-shape", entry_index, len(mains), len(parameters), len(datasets)
        ))
        for main_index, main_name in enumerate(mains):
            fingerprint.add(_fingerprint_record("matrix-main", entry_index, main_index, main_name))
        for parameter_index, parameter_name in enumerate(parameters):
            fingerprint.add(_fingerprint_record(
                "matrix-parameter", entry_index, parameter_index, parameter_name
            ))
        for dataset_index, dataset in enumerate(datasets):
            values = list(dataset)
            fingerprint.add(_fingerprint_record(
                "matrix-dataset-size", entry_index, dataset_index, len(values)
            ))
            for value in values:
                fingerprint.add(_fingerprint_record(
                    "matrix-value", entry_index, dataset_index, _canonical_semantic(value)
                ))

    for main_name, parameters in result.para_main_dict.items():
        values = list(parameters)
        fingerprint.add(_fingerprint_record("main-size", main_name, len(values)))
        for parameter_index, parameter_name in enumerate(values):
            fingerprint.add(_fingerprint_record(
                "main-parameter", main_name, parameter_index, parameter_name
            ))

    pair_to_index: dict[tuple[str, str], int] = {}
    for entry_index, entry in enumerate(matrix):
        mains = list(entry[0])
        parameters = list(entry[1]) or [""]
        for main_name in mains:
            for parameter_name in parameters:
                pair_to_index[(str(main_name), str(parameter_name))] = entry_index
    for (main_name, parameter_name), entry_index in pair_to_index.items():
        fingerprint.add(_fingerprint_record(
            "parameter-pair", main_name, parameter_name, entry_index
        ))

    for slot_index, slot in enumerate(result.data_dict):
        is_combination = slot_index in (3, 8)
        fingerprint.add(_fingerprint_record(
            "data-slot", slot_index, "combination" if is_combination else "binding", len(slot)
        ))
        if is_combination:
            for key, values in slot.items():
                values = list(values)
                fingerprint.add(_fingerprint_record(
                    "combination-size", slot_index, key, len(values)
                ))
                for value_index, value in enumerate(values):
                    fingerprint.add(_fingerprint_record(
                        "combination-value", slot_index, key, value_index, value
                    ))
            continue
        for key, groups in slot.items():
            key_text = _canonical_semantic(key, data_key=True)
            groups = list(groups)
            fingerprint.add(_fingerprint_record(
                "binding-size", slot_index, key_text, len(groups)
            ))
            for group in groups:
                fingerprint.add(_fingerprint_record(
                    "binding-group", slot_index, key_text, _group_fingerprint(group)
                ))

    for value, key in result.kombi_reverse_dict.items():
        fingerprint.add(_fingerprint_record("reverse-1", value, key))
    for value, key in result.kombi_reverse_dict2.items():
        fingerprint.add(_fingerprint_record("reverse-2", value, key))
    for value in result.all_simple_command_columns:
        fingerprint.add(_fingerprint_record("simple-column", value))
    for dataset_index, dataset in enumerate(result.all_values):
        values = list(dataset)
        fingerprint.add(_fingerprint_record("all-values-size", dataset_index, len(values)))
        for value in values:
            fingerprint.add(_fingerprint_record(
                "all-value", dataset_index, _canonical_semantic(value)
            ))
    return fingerprint.canonical()

def reference_summary(schema: RetaContextSchema, invert_alles: bool) -> dict[str, object]:
    result = ParameterSemanticsBuilder(
        schema,
        gebrochen_spalten_maximum_plus1=int(words.gebrochenSpaltenMaximumPlus1),
        invert_alles=invert_alles,
        initial_data_dict=[{} for _ in range(14)],
        prim_number_predicate=primCreativity,
        alles_parameter_names=words.ParametersMain.alles,
    ).build()
    return {
        "invert_alles": invert_alles,
        "fingerprint": semantics_fingerprint(result),
        "matrix_entries": len(result.para_n_data_matrix),
        "para_main": len(result.para_main_dict),
        "para_dict": len(result.para_dict),
        "data_dict_sizes": [len(value) for value in result.data_dict],
        "reverse1": len(result.kombi_reverse_dict),
        "reverse2": len(result.kombi_reverse_dict2),
        "simple_columns": len(result.all_simple_command_columns),
        "all_values_sizes": [len(value) for value in result.all_values],
    }


def main() -> None:
    schema = normalized_schema(RetaContextSchema.from_words_module(words))
    output = ROOT / "src/reta_mojo/semantics_builder_catalog.mojo"
    output.write_text(generate_catalog(schema), encoding="utf-8")
    summary = {
        "catalog_entries": len(schema.para_n_data_matrix),
        "combinations1": len(schema.kombi_para_n_data_matrix or {}),
        "combinations2": len(schema.kombi_para_n_data_matrix2 or {}),
        "normal": reference_summary(schema, False),
        "inverted": reference_summary(schema, True),
    }
    (ROOT / "assets/parameter_semantics_reference.json").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(summary, ensure_ascii=False, sort_keys=True))


if __name__ == "__main__":
    main()
