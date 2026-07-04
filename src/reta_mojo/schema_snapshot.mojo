"""Deterministic JSON snapshot of the native Reta context schema.

The field order and sorted mapping order intentionally match
``RetaContextSchema.snapshot`` in the Python reference.  The implementation
serializes the typed native schema directly and does not load a frozen JSON
blob or invoke Python at runtime.
"""

from std.collections import List

from .schema import NamedValue, RetaContextSchema, named_value_lookup


def _hex_nibble(value: Int) -> String:
    if value < 10:
        return String(value)
    return chr(87 + value)


def _json_quote(value: String) -> String:
    var escaped = value.replace("\\", "\\\\")
    escaped = escaped.replace('"', '\\"')
    escaped = escaped.replace(chr(8), "\\b")
    escaped = escaped.replace(chr(12), "\\f")
    escaped = escaped.replace("\n", "\\n")
    escaped = escaped.replace("\r", "\\r")
    escaped = escaped.replace("\t", "\\t")
    for code in range(32):
        if code == 8 or code == 9 or code == 10 or code == 12 or code == 13:
            continue
        escaped = escaped.replace(
            chr(code),
            "\\u00" + _hex_nibble((code >> 4) & 15)
            + _hex_nibble(code & 15),
        )
    return '"' + escaped + '"'


def _sort_strings(mut values: List[String]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key^


def _string_list_json(values: List[String], sort_values: Bool = False) -> String:
    var copied = List[String]()
    for index in range(len(values)):
        copied.append(values[index].copy())
    if sort_values:
        _sort_strings(copied)
    var result = String("[")
    for index in range(len(copied)):
        if index > 0:
            result += ","
        result += _json_quote(copied[index])
    result += "]"
    return result^


def _named_mapping_json(values: List[NamedValue]) -> String:
    var names = List[String]()
    for index in range(len(values)):
        names.append(values[index].name.copy())
    _sort_strings(names)
    var result = String("{")
    for index in range(len(names)):
        if index > 0:
            result += ","
        result += _json_quote(names[index]) + ":"
        result += _json_quote(named_value_lookup(values, names[index]))
    result += "}"
    return result^


def _main_alias_groups_json(schema: RetaContextSchema) -> String:
    var result = String("[")
    for index in range(len(schema.parameters_main)):
        if index > 0:
            result += ","
        var group = schema.parameters_main[index].copy()
        result += '{"canonical":' + _json_quote(group.canonical)
        result += ',"aliases":' + _string_list_json(group.aliases) + "}"
    result += "]"
    return result^


def _schema_modules_json(schema: RetaContextSchema) -> String:
    # Python uses dict(sorted(...)); preserve the exact lexicographic key order.
    var modules = schema.schema_modules.copy()
    var result = String("{")
    result += '"compat:bootstrap":' + _json_quote(modules.compat_bootstrap)
    result += ',"compat:context":' + _json_quote(modules.compat_context)
    result += ',"compat:legacy_monolith":' + _json_quote(
        modules.compat_legacy_monolith
    )
    result += ',"compat:matrix":' + _json_quote(modules.compat_matrix)
    result += ',"compat:runtime":' + _json_quote(modules.compat_runtime)
    result += ',"compatibility":' + _json_quote(modules.compatibility)
    result += ',"context":' + _json_quote(modules.context)
    result += ',"matrix":' + _json_quote(modules.matrix)
    result += ',"runtime":' + _json_quote(modules.runtime)
    result += "}"
    return result^


def schema_snapshot_json(schema: RetaContextSchema) -> String:
    var result = String('{"languages":')
    result += _named_mapping_json(schema.language_aliases)
    result += ',"translation_domains":'
    result += _named_mapping_json(schema.translation_domains)
    result += ',"main_alias_groups":' + _main_alias_groups_json(schema)
    result += ',"row_parameters":' + _named_mapping_json(schema.row_parameters)
    result += ',"output_parameters":' + _named_mapping_json(
        schema.output_parameters
    )
    result += ',"output_modes":' + _named_mapping_json(schema.output_modes)
    result += ',"combination_parameters":' + _named_mapping_json(
        schema.combination_parameters
    )
    result += ',"scopes":' + _named_mapping_json(schema.scopes)
    result += ',"tag_names":' + _string_list_json(schema.tag_names, True)
    result += ',"para_n_data_matrix_size":' + String(
        len(schema.parameter_entries)
    )
    result += ',"kombi_para_n_data_matrix_size":' + String(
        schema.kombi_parameter_matrix_size
    )
    result += ',"kombi_para_n_data_matrix2_size":' + String(
        schema.kombi_parameter_matrix2_size
    )
    result += ',"schema_modules":' + _schema_modules_json(schema)
    result += "}"
    return result^
