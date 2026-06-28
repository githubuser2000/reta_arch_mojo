"""Compact runtime-loaded German/English parameter alias catalog."""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file


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
    var lines = text.split("\n")
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
