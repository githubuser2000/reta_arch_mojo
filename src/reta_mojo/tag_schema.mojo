"""Typed table-tag topology for the native Reta Mojo runtime.

The generated catalog lives in ``tag_schema_catalog.mojo``. This module owns
lookup and reverse-lookup semantics without Python ``Enum``/``frozenset``
objects.
"""

from std.collections import List


comptime TAG_STERN_POLYGON = 0
comptime TAG_GLEICHFOERMIGES_POLYGON = 1
comptime TAG_KEIN_POLYGON = 2
comptime TAG_GALAXIE = 3
comptime TAG_UNIVERSUM = 4
comptime TAG_KEIN_PARA_OD_META = 5
comptime TAG_GEBROCHEN_RATIONAL = 6


@fieldwise_init
struct TagGroup(Copyable):
    var tags: List[Int]
    var columns: List[Int]


@fieldwise_init
struct TagColumnEntry(Copyable):
    var column: Int
    var tags: List[Int]


@fieldwise_init
struct TagSchemaBundle(Copyable):
    var primary: List[TagGroup]
    var primary_reverse: List[TagColumnEntry]
    var combination: List[TagGroup]
    var combination_reverse: List[TagColumnEntry]
    var combination_two: List[TagGroup]
    var combination_two_reverse: List[TagColumnEntry]
    var tag_names: List[String]


def _contains_int(values: List[Int], value: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _same_int_set(first: List[Int], second: List[Int]) -> Bool:
    if len(first) != len(second):
        return False
    for index in range(len(first)):
        if not _contains_int(second, first[index]):
            return False
    return True


def _copy_ints(values: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _groups_for_selector(schema: TagSchemaBundle, selector: Int) -> List[TagGroup]:
    if selector == -1:
        return schema.primary.copy()
    if selector == 0:
        return schema.combination.copy()
    if selector == 1:
        return schema.combination_two.copy()
    return List[TagGroup]()


def _reverse_for_selector(
    schema: TagSchemaBundle,
    selector: Int,
) -> List[TagColumnEntry]:
    if selector == -1:
        return schema.primary_reverse.copy()
    if selector == 0:
        return schema.combination_reverse.copy()
    if selector == 1:
        return schema.combination_two_reverse.copy()
    return List[TagColumnEntry]()


def tags_for_column(
    schema: TagSchemaBundle,
    column_number: Int,
    selector: Int = -1,
) -> List[Int]:
    """Return Python-compatible reverse tags for a column."""
    var reverse = _reverse_for_selector(schema, selector)
    for index in range(len(reverse)):
        if reverse[index].column == column_number:
            return _copy_ints(reverse[index].tags)
    return List[Int]()

def columns_for_tags(
    schema: TagSchemaBundle,
    tags: List[Int],
    selector: Int = -1,
) -> List[Int]:
    var groups = _groups_for_selector(schema, selector)
    for group_index in range(len(groups)):
        var group = groups[group_index].copy()
        if _same_int_set(group.tags, tags):
            return _copy_ints(group.columns)
    return List[Int]()


def tag_name(schema: TagSchemaBundle, tag: Int) -> String:
    if tag < 0 or tag >= len(schema.tag_names):
        return ""
    return schema.tag_names[tag]


def reverse_entry_count(schema: TagSchemaBundle, selector: Int = -1) -> Int:
    return len(_reverse_for_selector(schema, selector))

def link_count(schema: TagSchemaBundle, selector: Int = -1) -> Int:
    var groups = _groups_for_selector(schema, selector)
    var result = 0
    for index in range(len(groups)):
        result += len(groups[index].columns)
    return result
