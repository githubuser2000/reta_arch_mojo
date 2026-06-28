"""Native table-architecture inspection CLI."""

from std.sys import argv
from std.collections import List
from std.collections.string import atol
from reta_mojo.tag_schema import *
from reta_mojo.tag_schema_catalog import bootstrap_tag_schema
from reta_mojo.table_state import create_table_state
from reta_mojo.table_wrapping import (
    default_text_wrap_runtime,
    wrap_cell_text,
)


def _selector(value: String) raises -> Int:
    if value == "primary" or value == "primaer" or value == "primär":
        return -1
    if value == "kombi" or value == "combination":
        return 0
    if value == "kombi2" or value == "combination2":
        return 1
    raise Error("unbekannte Tag-Tabelle: " + value)


def _tag_value(schema: TagSchemaBundle, name: String) -> Int:
    for index in range(len(schema.tag_names)):
        if schema.tag_names[index] == name:
            return index
    return -1


def _print_ints(values: List[Int]) -> None:
    print("[", end="")
    for index in range(len(values)):
        if index > 0:
            print(", ", end="")
        print(values[index], end="")
    print("]")


def _print_tags(schema: TagSchemaBundle, values: List[Int]) -> None:
    print("[", end="")
    for index in range(len(values)):
        if index > 0:
            print(", ", end="")
        print(tag_name(schema, values[index]), end="")
    print("]")


def main() raises:
    var args = argv()
    if len(args) < 2:
        print("--mojo-tags SPALTE [primary|kombi|kombi2]")
        print("--mojo-tag-columns TAG1,TAG2 [primary|kombi|kombi2]")
        print("--mojo-table-state [HOECHSTE_ZEILE]")
        print("--mojo-wrap BREITE TEXT")
        return

    var command = String(args[1])
    var schema = bootstrap_tag_schema()
    if command == "--mojo-tags":
        if len(args) < 3:
            raise Error("--mojo-tags benötigt eine Spaltennummer")
        var column = atol(String(args[2]))
        var selector = -1
        if len(args) >= 4:
            selector = _selector(String(args[3]))
        var tags = tags_for_column(schema, column, selector)
        print("Spalte:", column)
        print("Tags: ", end="")
        _print_tags(schema, tags)
        return

    if command == "--mojo-tag-columns":
        if len(args) < 3:
            raise Error("--mojo-tag-columns benötigt eine Kommaliste")
        var tags = List[Int]()
        var pieces = String(args[2]).split(",")
        for index in range(len(pieces)):
            var name = String(pieces[index].strip())
            var value = _tag_value(schema, name)
            if value < 0:
                raise Error("unbekannter Tabellen-Tag: " + name)
            tags.append(value)
        var selector = -1
        if len(args) >= 4:
            selector = _selector(String(args[3]))
        print("Spalten: ", end="")
        _print_ints(columns_for_tags(schema, tags, selector))
        return

    if command == "--mojo-table-state":
        var highest = -1
        if len(args) >= 3:
            highest = atol(String(args[2]))
        var state = create_table_state(highest)
        print("Höchste Zeile 1024:", state.highest_rows[1024])
        print("Höchste Zeile 114:", state.highest_rows[114])
        print("Generierte Parameter:", len(state.generated_columns.parameters))
        print("Zeilenabbildungen:", len(state.row_display_to_original))
        return

    if command == "--mojo-wrap":
        if len(args) < 4:
            raise Error("--mojo-wrap benötigt BREITE und TEXT")
        var width = atol(String(args[2]))
        var text = String(args[3])
        var runtime = default_text_wrap_runtime()
        runtime.has_fill = True
        var wrapped = wrap_cell_text(text, width, runtime)
        if not wrapped.wrapped:
            print(text)
            return
        for index in range(len(wrapped.parts)):
            print(wrapped.parts[index])
        return

    raise Error("unbekannter Tabellen-Befehl: " + command)
