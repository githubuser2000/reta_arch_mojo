"""Lightweight native table-state and wrapping inspection CLI."""

from std.sys import argv
from std.collections.string import atol
from reta_mojo.table_state import create_table_state
from reta_mojo.table_wrapping import default_text_wrap_runtime, wrap_cell_text
from reta_mojo.csv_table import read_semicolon_csv


def main() raises:
    var args = argv()
    if len(args) < 2:
        print("--mojo-table-state [HOECHSTE_ZEILE]")
        print("--mojo-wrap BREITE TEXT")
        print("--mojo-csv-info [DATEI]")
        return

    var command = String(args[1])
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

    if command == "--mojo-csv-info":
        var path = String("python_reference/csv/religion.csv")
        if len(args) >= 3:
            path = String(args[2])
        var table = read_semicolon_csv(path)
        print("Zeilen:", len(table.rows))
        print("Spalten:", table.maximum_columns)
        print("Zellen:", len(table.rows) * table.maximum_columns)
        return

    raise Error("unbekannter Tabellen-Befehl: " + command)
