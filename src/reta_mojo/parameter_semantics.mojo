"""Native canonical parameter-semantics sheaf.

This ports the deterministic alias and direct-column part of
``reta_architecture.sheaves.ParameterSemanticsSheaf``.  Dynamic callables and
later generated-column slots deliberately remain outside this module.
"""

from std.collections import List
from .schema import RetaContextSchema, ParameterEntry, AliasGroup


@fieldwise_init
struct CanonicalPair(Copyable, Equatable, Writable):
    var valid: Bool
    var main_name: String
    var parameter_name: String

    def __eq__(self, other: Self) -> Bool:
        return (
            self.valid == other.valid
            and self.main_name == other.main_name
            and self.parameter_name == other.parameter_name
        )

    def write_to[W: Writer](self, mut writer: W):
        if self.valid:
            writer.write("(", self.main_name, ", ", self.parameter_name, ")")
        else:
            writer.write("<invalid>")


@fieldwise_init
struct MainAliasEntry(Copyable):
    var source_alias: String
    var canonical: String


@fieldwise_init
struct ParameterAliasGroup(Copyable):
    var main_canonical: String
    var parameter_canonical: String
    var aliases: List[String]


@fieldwise_init
struct PairColumns(Copyable):
    var main_canonical: String
    var parameter_canonical: String
    var columns: List[Int]


@fieldwise_init
struct ColumnCanonicalPairs(Copyable):
    var column: Int
    var pairs: List[CanonicalPair]


@fieldwise_init
struct ParameterSemanticsSheaf(Copyable):
    var main_alias_groups: List[AliasGroup]
    var main_aliases: List[MainAliasEntry]
    var parameter_alias_groups: List[ParameterAliasGroup]
    var pair_to_columns: List[PairColumns]


def _contains_string(values: List[String], value: String) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _contains_int(values: List[Int], value: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _sort_strings(mut values: List[String]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key^


def _sort_ints(mut values: List[Int]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _resolve_main_alias_entries(entries: List[MainAliasEntry], source_alias: String) -> String:
    for index in range(len(entries)):
        if entries[index].source_alias == source_alias:
            return entries[index].canonical
    return ""


def _parameter_group_index(
    groups: List[ParameterAliasGroup],
    main_canonical: String,
    parameter_canonical: String,
) -> Int:
    for index in range(len(groups)):
        if (
            groups[index].main_canonical == main_canonical
            and groups[index].parameter_canonical == parameter_canonical
        ):
            return index
    return -1


def _pair_columns_index(
    pairs: List[PairColumns],
    main_canonical: String,
    parameter_canonical: String,
) -> Int:
    for index in range(len(pairs)):
        if (
            pairs[index].main_canonical == main_canonical
            and pairs[index].parameter_canonical == parameter_canonical
        ):
            return index
    return -1


def build_parameter_semantics(schema: RetaContextSchema) -> ParameterSemanticsSheaf:
    var groups = List[AliasGroup]()
    var main_aliases = List[MainAliasEntry]()
    for group_index in range(len(schema.parameters_main)):
        var group = schema.parameters_main[group_index].copy()
        if group.canonical.byte_length() == 0:
            continue
        groups.append(group.copy())
        if not _contains_main_alias(main_aliases, group.canonical):
            main_aliases.append(MainAliasEntry(group.canonical, group.canonical))
        for alias_index in range(len(group.aliases)):
            var source_alias = group.aliases[alias_index]
            if not _contains_main_alias(main_aliases, source_alias):
                main_aliases.append(MainAliasEntry(source_alias, group.canonical))

    var parameter_groups = List[ParameterAliasGroup]()
    var pair_columns = List[PairColumns]()
    for entry_index in range(len(schema.parameter_entries)):
        var entry = schema.parameter_entries[entry_index].copy()
        if len(entry.main_aliases) == 0 or len(entry.parameter_aliases) == 0:
            continue
        var main_canonical = _resolve_main_alias_entries(main_aliases, entry.main_aliases[0])
        if main_canonical.byte_length() == 0:
            main_canonical = entry.main_aliases[0]
        var parameter_canonical = entry.parameter_aliases[0]

        var group_index = _parameter_group_index(
            parameter_groups, main_canonical, parameter_canonical
        )
        if group_index < 0:
            var aliases = List[String]()
            for alias_index in range(len(entry.parameter_aliases)):
                if not _contains_string(aliases, entry.parameter_aliases[alias_index]):
                    aliases.append(entry.parameter_aliases[alias_index])
            parameter_groups.append(
                ParameterAliasGroup(main_canonical, parameter_canonical, aliases^)
            )
        else:
            for alias_index in range(len(entry.parameter_aliases)):
                if not _contains_string(
                    parameter_groups[group_index].aliases,
                    entry.parameter_aliases[alias_index],
                ):
                    parameter_groups[group_index].aliases.append(
                        entry.parameter_aliases[alias_index]
                    )

        var pair_index = _pair_columns_index(
            pair_columns, main_canonical, parameter_canonical
        )
        if pair_index < 0:
            var columns = List[Int]()
            for column_index in range(len(entry.direct_columns)):
                if not _contains_int(columns, entry.direct_columns[column_index]):
                    columns.append(entry.direct_columns[column_index])
            _sort_ints(columns)
            pair_columns.append(PairColumns(main_canonical, parameter_canonical, columns^))
        else:
            for column_index in range(len(entry.direct_columns)):
                if not _contains_int(
                    pair_columns[pair_index].columns,
                    entry.direct_columns[column_index],
                ):
                    pair_columns[pair_index].columns.append(
                        entry.direct_columns[column_index]
                    )
            _sort_ints(pair_columns[pair_index].columns)

    for index in range(len(parameter_groups)):
        _sort_strings(parameter_groups[index].aliases)

    return ParameterSemanticsSheaf(
        groups^, main_aliases^, parameter_groups^, pair_columns^
    )


def _contains_main_alias(entries: List[MainAliasEntry], source_alias: String) -> Bool:
    for index in range(len(entries)):
        if entries[index].source_alias == source_alias:
            return True
    return False


def resolve_main_alias(sheaf: ParameterSemanticsSheaf, main_name: String) -> String:
    return _resolve_main_alias_entries(sheaf.main_aliases, main_name)


def resolve_parameter_alias(
    sheaf: ParameterSemanticsSheaf,
    main_name: String,
    parameter_name: String,
) -> String:
    var main_canonical = resolve_main_alias(sheaf, main_name)
    if main_canonical.byte_length() == 0:
        main_canonical = main_name
    for group_index in range(len(sheaf.parameter_alias_groups)):
        var group = sheaf.parameter_alias_groups[group_index].copy()
        if group.main_canonical != main_canonical:
            continue
        for alias_index in range(len(group.aliases)):
            if group.aliases[alias_index] == parameter_name:
                return group.parameter_canonical
    return ""


def canonicalize_pair(
    sheaf: ParameterSemanticsSheaf,
    main_name: String,
    parameter_name: String,
) -> CanonicalPair:
    var main_canonical = resolve_main_alias(sheaf, main_name)
    if main_canonical.byte_length() == 0:
        return CanonicalPair(False, "", "")
    var parameter_canonical = resolve_parameter_alias(
        sheaf, main_canonical, parameter_name
    )
    if parameter_canonical.byte_length() == 0:
        return CanonicalPair(False, "", "")
    return CanonicalPair(True, main_canonical, parameter_canonical)


def column_numbers_for_pair(
    sheaf: ParameterSemanticsSheaf,
    main_name: String,
    parameter_name: String,
) -> List[Int]:
    var pair = canonicalize_pair(sheaf, main_name, parameter_name)
    if not pair.valid:
        return List[Int]()
    var index = _pair_columns_index(
        sheaf.pair_to_columns, pair.main_name, pair.parameter_name
    )
    if index < 0:
        return List[Int]()
    return sheaf.pair_to_columns[index].columns.copy()


def parameter_alias_groups_for_main(
    sheaf: ParameterSemanticsSheaf,
    main_name: String,
) -> List[ParameterAliasGroup]:
    var canonical = resolve_main_alias(sheaf, main_name)
    if canonical.byte_length() == 0:
        canonical = main_name
    var result = List[ParameterAliasGroup]()
    for index in range(len(sheaf.parameter_alias_groups)):
        if sheaf.parameter_alias_groups[index].main_canonical == canonical:
            result.append(sheaf.parameter_alias_groups[index].copy())
    return result^


def reverse_map_canonical_pairs(
    sheaf: ParameterSemanticsSheaf
) -> List[ColumnCanonicalPairs]:
    var result = List[ColumnCanonicalPairs]()
    for pair_index in range(len(sheaf.pair_to_columns)):
        var pair_columns = sheaf.pair_to_columns[pair_index].copy()
        for column_index in range(len(pair_columns.columns)):
            var column = pair_columns.columns[column_index]
            var result_index = -1
            for index in range(len(result)):
                if result[index].column == column:
                    result_index = index
                    break
            if result_index < 0:
                result.append(ColumnCanonicalPairs(column, List[CanonicalPair]()))
                result_index = len(result) - 1
            var pair = CanonicalPair(
                True, pair_columns.main_canonical, pair_columns.parameter_canonical
            )
            if not _contains_pair(result[result_index].pairs, pair):
                result[result_index].pairs.append(pair^)
    _sort_reverse_map(result)
    return result^


def _contains_pair(values: List[CanonicalPair], value: CanonicalPair) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _sort_pairs(mut values: List[CanonicalPair]) -> None:
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and _pair_greater(values[position], key):
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key^


def _pair_greater(left: CanonicalPair, right: CanonicalPair) -> Bool:
    if left.main_name > right.main_name:
        return True
    if left.main_name < right.main_name:
        return False
    return left.parameter_name > right.parameter_name


def _sort_reverse_map(mut values: List[ColumnCanonicalPairs]) -> None:
    for index in range(len(values)):
        _sort_pairs(values[index].pairs)
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and values[position].column > key.column:
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key^
