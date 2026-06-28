"""Typed native representation of reta's context/schema layer.

The Python implementation extracts dynamic modules.  The Mojo core receives a
fully owned snapshot, so alias resolution and direct-column semantics do not
need Python objects at runtime.
"""

from std.collections import List


@fieldwise_init
struct NamedValue(Copyable, Equatable, Writable):
    var name: String
    var value: String

    def __eq__(self, other: Self) -> Bool:
        return self.name == other.name and self.value == other.value

    def write_to[W: Writer](self, mut writer: W):
        writer.write(self.name, "=", self.value)


@fieldwise_init
struct AliasGroup(Copyable):
    var canonical: String
    var aliases: List[String]


@fieldwise_init
struct ParameterEntry(Copyable):
    """The statically useful prefix of a paraNdataMatrix entry.

    ``direct_columns`` is the integer-only third slot consumed by
    ``ParameterSemanticsSheaf._rebuild_alias_maps`` in Python.  Later dynamic
    slots stay outside this type until their generated-column subsystem is
    ported.
    """

    var main_aliases: List[String]
    var parameter_aliases: List[String]
    var direct_columns: List[Int]


@fieldwise_init
struct SchemaModuleNames(Copyable):
    var context: String
    var matrix: String
    var runtime: String


@fieldwise_init
struct RetaContextSchema(Copyable):
    var language_aliases: List[NamedValue]
    var translation_domains: List[NamedValue]
    var parameters_main: List[AliasGroup]
    var row_parameters: List[NamedValue]
    var output_parameters: List[NamedValue]
    var output_modes: List[NamedValue]
    var combination_parameters: List[NamedValue]
    var scopes: List[NamedValue]
    var parameter_entries: List[ParameterEntry]
    var tag_names: List[String]
    var schema_modules: SchemaModuleNames


def empty_schema() -> RetaContextSchema:
    return RetaContextSchema(
        List[NamedValue](),
        List[NamedValue](),
        List[AliasGroup](),
        List[NamedValue](),
        List[NamedValue](),
        List[NamedValue](),
        List[NamedValue](),
        List[NamedValue](),
        List[ParameterEntry](),
        List[String](),
        SchemaModuleNames("", "", ""),
    )


def named_value_lookup(values: List[NamedValue], name: String) -> String:
    for index in range(len(values)):
        if values[index].name == name:
            return values[index].value
    return ""


def main_alias_groups(schema: RetaContextSchema) -> List[AliasGroup]:
    var result = List[AliasGroup]()
    for index in range(len(schema.parameters_main)):
        if schema.parameters_main[index].canonical.byte_length() != 0:
            result.append(schema.parameters_main[index].copy())
    return result^


def resolve_schema_main_alias(schema: RetaContextSchema, source_alias: String) -> String:
    for group_index in range(len(schema.parameters_main)):
        var group = schema.parameters_main[group_index].copy()
        if source_alias == group.canonical:
            return group.canonical
        for alias_index in range(len(group.aliases)):
            if source_alias == group.aliases[alias_index]:
                return group.canonical
    return ""


def schema_direct_column_count(schema: RetaContextSchema) -> Int:
    var count = 0
    for entry_index in range(len(schema.parameter_entries)):
        count += len(schema.parameter_entries[entry_index].direct_columns)
    return count
