"""Dedicated native CLI for the generated Reta parameter schema."""

from std.sys import argv
from std.collections import List
from reta_mojo.schema_catalog import bootstrap_reta_schema
from reta_mojo.input_semantics import (
    parse_cli_tokens,
    canonicalize_column_options,
    positive_columns,
    negative_columns,
    build_prompt_vocabulary,
)
from reta_mojo.parameter_semantics import (
    build_parameter_semantics,
    resolve_main_alias,
    resolve_parameter_alias,
    canonicalize_pair,
    column_numbers_for_pair,
)


def _print_int_list(values: List[Int]) -> None:
    print("[", end="")
    for index in range(len(values)):
        if index > 0:
            print(", ", end="")
        print(values[index], end="")
    print("]")


def main() raises:
    var args = argv()
    var schema = bootstrap_reta_schema()
    var sheaf = build_parameter_semantics(schema)
    if len(args) < 2 or String(args[1]) == "--mojo-schema":
        print("Hauptparametergruppen:", len(schema.parameters_main))
        print("Hauptaliasnamen:", len(sheaf.main_aliases))
        print("Parametereinträge:", len(schema.parameter_entries))
        print("Kanonische Parameterpaare:", len(sheaf.pair_to_columns))
        return

    var command = String(args[1])
    if command == "--mojo-columns":
        if len(args) < 4:
            raise Error("--mojo-columns benötigt HAUPTPARAMETER und PARAMETER")
        var main_name = String(args[2])
        var parameter_name = String(args[3])
        var pair = canonicalize_pair(sheaf, main_name, parameter_name)
        if not pair.valid:
            raise Error(
                "unbekanntes Parameterpaar: " + main_name + "/" + parameter_name
            )
        print("Kanonisch:", pair.main_name, "/", pair.parameter_name)
        print("Spalten: ", end="")
        _print_int_list(column_numbers_for_pair(sheaf, main_name, parameter_name))
        return

    if command == "--mojo-vocabulary":
        var vocabulary = build_prompt_vocabulary(sheaf)
        print("Hauptparameter:", len(vocabulary.main_parameters))
        print("Spaltenoptionen:", len(vocabulary.column_options))
        print("Kanonische Spaltengruppen:", len(vocabulary.values_by_main))
        print("Zeilenoptionen:", len(vocabulary.row_options))
        print("Ausgabeoptionen:", len(vocabulary.output_options))
        print("Kombinationsoptionen:", len(vocabulary.combination_options))
        print("Ausgabemodi:", len(vocabulary.output_modes))
        return

    if command == "--mojo-parse-cli":
        var tokens = List[String]()
        for index in range(2, len(args)):
            tokens.append(String(args[index]))
        var parsed = parse_cli_tokens(tokens)
        print("Hauptbereiche:", len(parsed.sections))
        print("Optionen:", len(parsed.options))
        print("Positionsargumente:", len(parsed.positional))
        print("Diagnosen:", len(parsed.diagnostics))
        for index in range(len(parsed.diagnostics)):
            print("Diagnose:", parsed.diagnostics[index])
        var selections = canonicalize_column_options(parsed, sheaf)
        print("Kanonische Spaltenauswahlen:", len(selections))
        for index in range(len(selections)):
            var selection = selections[index].copy()
            if not selection.valid:
                print(
                    "Ungültig:",
                    selection.source_main,
                    "/",
                    selection.source_parameter,
                )
                continue
            print(
                "Auswahl:",
                selection.main_canonical,
                "/",
                selection.parameter_canonical,
                "negativ=" + String(selection.negative),
            )
            print("  Spalten: ", end="")
            _print_int_list(selection.columns)
        print("Positive Spalten: ", end="")
        _print_int_list(positive_columns(selections))
        print("Negative Spalten: ", end="")
        _print_int_list(negative_columns(selections))
        return

    if command == "--mojo-alias":
        if len(args) < 3:
            raise Error("--mojo-alias benötigt mindestens einen Aliasnamen")
        var main_name = String(args[2])
        var main_canonical = resolve_main_alias(sheaf, main_name)
        if main_canonical.byte_length() == 0:
            raise Error("unbekannter Hauptparameteralias: " + main_name)
        print("Hauptparameter:", main_canonical)
        if len(args) >= 4:
            var parameter_name = String(args[3])
            var parameter_canonical = resolve_parameter_alias(
                sheaf, main_name, parameter_name
            )
            if parameter_canonical.byte_length() == 0:
                raise Error("unbekannter Unterparameteralias: " + parameter_name)
            print("Unterparameter:", parameter_canonical)
        return

    raise Error("unbekannter Schema-Befehl: " + command)
