"""Native symbolic context topology.

Python represents unrestricted dimensions as ``None`` and restrictions as
``frozenset``. Mojo uses an explicit ``restricted`` bit so the distinction
between unrestricted and the empty open set cannot be lost in translation.
"""

from std.collections import List, Set


@fieldwise_init
struct AliasEntry(Copyable, Equatable, Writable):
    var source_alias: String
    var canonical: String


@fieldwise_init
struct SelectionDimension(Copyable):
    var restricted: Bool
    var values: Set[String]


@fieldwise_init
struct ContextSelection(Copyable):
    var language: SelectionDimension
    var main_parameters: SelectionDimension
    var sub_parameters: SelectionDimension
    var row_parameters: SelectionDimension
    var output_modes: SelectionDimension
    var tag_names: SelectionDimension
    var combination_parameters: SelectionDimension
    var scopes: SelectionDimension


@fieldwise_init
struct ContextDimension:
    var name: String
    var values: Set[String]
    var aliases: List[AliasEntry]


def unrestricted_dimension() -> SelectionDimension:
    return SelectionDimension(False, Set[String]())


def restricted_dimension(values: List[String]) -> SelectionDimension:
    var result = Set[String]()
    for index in range(len(values)):
        result.add(values[index])
    return SelectionDimension(True, result^)


def unrestricted_selection() -> ContextSelection:
    return ContextSelection(
        unrestricted_dimension(), unrestricted_dimension(),
        unrestricted_dimension(), unrestricted_dimension(),
        unrestricted_dimension(), unrestricted_dimension(),
        unrestricted_dimension(), unrestricted_dimension(),
    )


def _dimension_meet(left: SelectionDimension, right: SelectionDimension) -> SelectionDimension:
    if not left.restricted:
        return right.copy()
    if not right.restricted:
        return left.copy()
    var values = Set[String]()
    for value in left.values:
        if value in right.values:
            values.add(value)
    return SelectionDimension(True, values^)


def refine_selection(left: ContextSelection, right: ContextSelection) -> ContextSelection:
    return ContextSelection(
        _dimension_meet(left.language, right.language),
        _dimension_meet(left.main_parameters, right.main_parameters),
        _dimension_meet(left.sub_parameters, right.sub_parameters),
        _dimension_meet(left.row_parameters, right.row_parameters),
        _dimension_meet(left.output_modes, right.output_modes),
        _dimension_meet(left.tag_names, right.tag_names),
        _dimension_meet(left.combination_parameters, right.combination_parameters),
        _dimension_meet(left.scopes, right.scopes),
    )


def selection_is_empty(selection: ContextSelection) -> Bool:
    return (
        (selection.language.restricted and len(selection.language.values) == 0)
        or (selection.main_parameters.restricted and len(selection.main_parameters.values) == 0)
        or (selection.sub_parameters.restricted and len(selection.sub_parameters.values) == 0)
        or (selection.row_parameters.restricted and len(selection.row_parameters.values) == 0)
        or (selection.output_modes.restricted and len(selection.output_modes.values) == 0)
        or (selection.tag_names.restricted and len(selection.tag_names.values) == 0)
        or (selection.combination_parameters.restricted and len(selection.combination_parameters.values) == 0)
        or (selection.scopes.restricted and len(selection.scopes.values) == 0)
    )


def new_context_dimension(name: String) -> ContextDimension:
    return ContextDimension(name, Set[String](), List[AliasEntry]())


def include_dimension_value(mut dimension: ContextDimension, canonical: String, aliases: List[String]) -> None:
    dimension.values.add(canonical)
    dimension.aliases.append(AliasEntry(canonical, canonical))
    for index in range(len(aliases)):
        if aliases[index].byte_length() > 0:
            dimension.aliases.append(AliasEntry(aliases[index], canonical))


def canonicalize_dimension(dimension: ContextDimension, value: String) -> String:
    if value in dimension.values:
        return value
    for index in range(len(dimension.aliases)):
        if dimension.aliases[index].source_alias == value:
            return dimension.aliases[index].canonical
    return ""


def open_for(dimension_name: String, values: List[String], dimension: ContextDimension) -> ContextSelection:
    var canonical_values = List[String]()
    for index in range(len(values)):
        var canonical = canonicalize_dimension(dimension, values[index])
        if canonical.byte_length() == 0:
            canonical = values[index]
        canonical_values.append(canonical)

    var result = unrestricted_selection()
    var restricted = restricted_dimension(canonical_values)
    if dimension_name == "language":
        result.language = restricted^
    elif dimension_name == "main_parameters":
        result.main_parameters = restricted^
    elif dimension_name == "sub_parameters":
        result.sub_parameters = restricted^
    elif dimension_name == "row_parameters":
        result.row_parameters = restricted^
    elif dimension_name == "output_modes":
        result.output_modes = restricted^
    elif dimension_name == "tag_names":
        result.tag_names = restricted^
    elif dimension_name == "combination_parameters":
        result.combination_parameters = restricted^
    elif dimension_name == "scopes":
        result.scopes = restricted^
    return result^


def cover_for_main(main_name: String) -> List[ContextSelection]:
    var first = unrestricted_selection()
    first.main_parameters = restricted_dimension([main_name])
    var second = unrestricted_selection()
    second.scopes = restricted_dimension(["spalten"])
    return [first^, second^]
