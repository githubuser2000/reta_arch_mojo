"""Compact runtime-loaded German/English parameter alias catalog."""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file
from .os_line_endings import split_os_lines


@fieldwise_init
struct RuntimeAliasEntry(Copyable):
    var main_alias: String
    var parameter_alias: String
    var columns: List[Int]


@fieldwise_init
struct RuntimeAliasCatalog(Copyable):
    var entries: List[RuntimeAliasEntry]


def load_runtime_alias_catalog(path: String) raises -> RuntimeAliasCatalog:
    var text = read_text_file(path)
    var lines = split_os_lines(text)
    var entries = List[RuntimeAliasEntry]()
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var pieces = line.split("\t")
        if len(pieces) != 3:
            continue
        var columns = List[Int]()
        var column_pieces = String(pieces[2]).split(",")
        for column_index in range(len(column_pieces)):
            var raw = String(column_pieces[column_index])
            if raw.byte_length() > 0:
                columns.append(atol(raw))
        entries.append(
            RuntimeAliasEntry(
                String(pieces[0]), String(pieces[1]), columns^
            )
        )
    return RuntimeAliasCatalog(entries^)


def resolve_runtime_columns(
    catalog: RuntimeAliasCatalog, main_alias: String, parameter_alias: String
) -> List[Int]:
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if entry.main_alias == main_alias and entry.parameter_alias == parameter_alias:
            return entry.columns.copy()
    return List[Int]()


def _runtime_side_matches(requested: String, actual: String) -> Bool:
    return requested == "*" or requested == actual


def _contains_int_runtime(values: List[Int], wanted: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique_int_runtime(mut values: List[Int], value: Int):
    if not _contains_int_runtime(values, value):
        values.append(value)


def resolve_runtime_columns_pattern(
    catalog: RuntimeAliasCatalog, main_alias: String, parameter_alias: String
) -> List[Int]:
    """Resolve one ordinary column alias pair, including ``*`` side wildcards.

    ``--menschliches=*`` expands every ordinary parameter alias under the
    requested main alias.  ``--*=motive`` expands every ordinary main alias
    that owns the requested parameter alias.  The returned column list is
    already de-duplicated but deliberately keeps first catalog order; the
    parameter runtime performs its normal final ordering afterwards.
    """
    if main_alias != "*" and parameter_alias != "*":
        return resolve_runtime_columns(catalog, main_alias, parameter_alias)

    var result = List[Int]()
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if (
            _runtime_side_matches(main_alias, entry.main_alias)
            and _runtime_side_matches(parameter_alias, entry.parameter_alias)
        ):
            for column_index in range(len(entry.columns)):
                _append_unique_int_runtime(result, entry.columns[column_index])
    return result^
