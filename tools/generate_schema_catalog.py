#!/usr/bin/env python3
"""Generate the native Reta schema and compact full-dataset parity constants."""
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parents[1]
PYREF = ROOT / "python_reference"
sys.path.insert(0, str(PYREF))

import i18n.words as words  # noqa: E402
import i18n.words_context as words_context  # noqa: E402
import i18n.words_matrix as words_matrix  # noqa: E402
import i18n.words_runtime as words_runtime  # noqa: E402
from reta_architecture.schema import RetaContextSchema  # noqa: E402
from reta_architecture.sheaves import ParameterSemanticsSheaf  # noqa: E402
from reta_architecture.tag_schema import ST, tableTags  # noqa: E402

MODULUS = 1_000_000_007


def q(value: object) -> str:
    return json.dumps(str(value), ensure_ascii=False)


def list_strings(values: Iterable[object]) -> str:
    return "[" + ", ".join(q(v) for v in values) + "]"


def list_ints(values: Iterable[object]) -> str:
    return "[" + ", ".join(str(int(v)) for v in values) + "]"


def direct_columns(entry: tuple) -> list[int]:
    if len(entry) < 3:
        return []
    try:
        return sorted({int(value) for value in entry[2]})
    except (TypeError, ValueError):
        return []


def stable_text_values(values: Iterable[object]) -> list[str]:
    """Preserve ordered schema sequences, but canonicalize unordered sets."""
    if isinstance(values, (set, frozenset)):
        def key(value: object) -> tuple[int, object]:
            text = str(value)
            try:
                return (0, int(text))
            except ValueError:
                return (1, text)
        return [str(value) for value in sorted(values, key=key)]
    return [str(value) for value in values if value is not None]


def deterministic_schema(schema: RetaContextSchema) -> RetaContextSchema:
    normalized = []
    for entry in schema.para_n_data_matrix:
        if len(entry) < 2:
            normalized.append(entry)
            continue
        normalized.append(
            (
                tuple(stable_text_values(entry[0])),
                tuple(stable_text_values(entry[1])),
                *entry[2:],
            )
        )
    schema.para_n_data_matrix = normalized
    return schema


def emit_named_values(lines: list[str], variable: str, mapping: dict) -> None:
    lines.append(f"    var {variable} = List[NamedValue]()")
    for key, value in mapping.items():
        lines.append(f"    {variable}.append(NamedValue({q(key)}, {q(value)}))")


def generate_catalog(schema: RetaContextSchema) -> str:
    lines = [
        '"""Generated native snapshot of reta i18n/schema data.\n\nRegenerate with tools/generate_schema_catalog.py.\n"""',
        "",
        "from std.collections import List",
        "from .schema import *",
        "",
        "",
        "def bootstrap_reta_schema() -> RetaContextSchema:",
    ]
    emit_named_values(lines, "language_aliases", schema.language_aliases)
    emit_named_values(lines, "translation_domains", schema.translation_domains)

    lines.append("    var parameters_main = List[AliasGroup]()")
    for group in schema.parameters_main:
        aliases = [str(v) for v in group if v is not None]
        if aliases:
            lines.append(
                f"    parameters_main.append(AliasGroup({q(aliases[0])}, {list_strings(aliases)}))"
            )

    emit_named_values(lines, "row_parameters", schema.row_parameters)
    emit_named_values(lines, "output_parameters", schema.output_parameters)
    emit_named_values(lines, "output_modes", schema.output_modes)
    emit_named_values(lines, "combination_parameters", schema.combination_parameters)
    emit_named_values(lines, "scopes", schema.scopes)

    lines.append("    var parameter_entries = List[ParameterEntry]()")
    for entry in schema.para_n_data_matrix:
        if len(entry) < 2:
            continue
        mains = stable_text_values(entry[0])
        parameters = stable_text_values(entry[1])
        lines.append(
            "    parameter_entries.append(ParameterEntry("
            f"{list_strings(mains)}, {list_strings(parameters)}, {list_ints(direct_columns(entry))}))"
        )

    lines.append("    var tag_names = List[String]()")
    for tag_name in schema.tag_names:
        lines.append(f"    tag_names.append({q(tag_name)})")

    modules = schema.schema_modules
    lines.extend(
        [
            "    return RetaContextSchema(",
            "        language_aliases^, translation_domains^, parameters_main^,",
            "        row_parameters^, output_parameters^, output_modes^,",
            "        combination_parameters^, scopes^, parameter_entries^,",
            f"        {len(schema.kombi_para_n_data_matrix or {})},",
            f"        {len(schema.kombi_para_n_data_matrix2 or {})},",
            "        tag_names^,",
            "        SchemaModuleNames(",
            f"            {q(modules.get('context', ''))},",
            f"            {q(modules.get('matrix', ''))},",
            f"            {q(modules.get('runtime', ''))},",
            f"            {q(modules.get('compatibility', ''))},",
            f"            {q(modules.get('compat:bootstrap', ''))},",
            f"            {q(modules.get('compat:context', ''))},",
            f"            {q(modules.get('compat:legacy_monolith', ''))},",
            f"            {q(modules.get('compat:matrix', ''))},",
            f"            {q(modules.get('compat:runtime', ''))},",
            "        ),",
            "    )",
            "",
        ]
    )
    return "\n".join(lines)


def string_hash_step(value: int, text: object) -> int:
    for byte in str(text).encode("utf-8"):
        value = (value * 257 + byte + 1) % MODULUS
    return (value * 257 + 257) % MODULUS


def record_hash(*fields: object) -> int:
    value = 17
    for field in fields:
        value = string_hash_step(value, field)
    return value


def fingerprint(records: Iterable[tuple[object, ...]]) -> tuple[int, int, int]:
    count = 0
    total = 0
    squares = 0
    for record in records:
        value = record_hash(*record)
        count += 1
        total = (total + value) % MODULUS
        squares = (squares + value * value) % MODULUS
    return count, total, squares


def generate_parity_constants(sheaf: ParameterSemanticsSheaf) -> str:
    main_records = [
        (source_alias, canonical)
        for source_alias, canonical in sheaf.main_alias_map.items()
    ]
    parameter_records = [
        (main, source_alias, str(group["canonical"]))
        for main, groups in sheaf.parameter_alias_groups.items()
        for group in groups
        for source_alias in group["aliases"]
    ]
    pair_records = [
        (main, parameter, *(str(column) for column in columns))
        for (main, parameter), columns in sheaf.pair_to_columns.items()
    ]
    main = fingerprint(main_records)
    parameter = fingerprint(parameter_records)
    pairs = fingerprint(pair_records)
    lines = [
        '"""Generated full-dataset fingerprints from Python semantics."""',
        "",
        f"comptime PYTHON_SCHEMA_FINGERPRINT_MODULUS = {MODULUS}",
        f"comptime EXPECTED_MAIN_ALIAS_COUNT = {main[0]}",
        f"comptime EXPECTED_MAIN_ALIAS_SUM = {main[1]}",
        f"comptime EXPECTED_MAIN_ALIAS_SQUARE_SUM = {main[2]}",
        f"comptime EXPECTED_PARAMETER_ALIAS_COUNT = {parameter[0]}",
        f"comptime EXPECTED_PARAMETER_ALIAS_SUM = {parameter[1]}",
        f"comptime EXPECTED_PARAMETER_ALIAS_SQUARE_SUM = {parameter[2]}",
        f"comptime EXPECTED_PAIR_COUNT = {pairs[0]}",
        f"comptime EXPECTED_PAIR_SUM = {pairs[1]}",
        f"comptime EXPECTED_PAIR_SQUARE_SUM = {pairs[2]}",
        "",
    ]
    return "\n".join(lines)


def main() -> None:
    schema = deterministic_schema(
        RetaContextSchema.from_words_parts(
            context_module=words_context,
            matrix_module=words_matrix,
            runtime_module=words_runtime,
            tag_enum=ST,
            table_tags=tableTags,
        )
    )
    schema.schema_modules.setdefault("compatibility", str(getattr(words, "__name__", "i18n.words")))
    if hasattr(words, "MODULE_SPLIT"):
        schema.schema_modules.update(
            {f"compat:{key}": value for key, value in dict(words.MODULE_SPLIT).items()}
        )
    sheaf = ParameterSemanticsSheaf.from_schema(schema)
    (ROOT / "src/reta_mojo/schema_catalog.mojo").write_text(
        generate_catalog(schema), encoding="utf-8"
    )
    (ROOT / "tests/schema_parity_constants.mojo").write_text(
        generate_parity_constants(sheaf), encoding="utf-8"
    )
    print(
        json.dumps(
            {
                "main_groups": len(schema.parameters_main),
                "parameter_entries": len(schema.para_n_data_matrix),
                "main_aliases": len(sheaf.main_alias_map),
                "parameter_aliases": sum(
                    len(group["aliases"])
                    for groups in sheaf.parameter_alias_groups.values()
                    for group in groups
                ),
                "canonical_pairs": len(sheaf.pair_to_columns),
                "direct_column_links": sum(len(v) for v in sheaf.pair_to_columns.values()),
            },
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()
