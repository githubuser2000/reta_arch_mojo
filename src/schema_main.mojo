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
    InputBundle,
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
        print("Spaltenoptionen:", len(vocabulary.spalten))
        print("Kanonische Spaltengruppen:", len(vocabulary.spalten_dict))
        print("Zeilenoptionen:", len(vocabulary.zeilen_paras))
        print("Ausgabeoptionen:", len(vocabulary.ausgabe_paras))
        print("Kombinationsoptionen:", len(vocabulary.kombi_main_paras))
        print("Ausgabemodi:", len(vocabulary.ausgabe_art))
        return

    if command == "--mojo-input-snapshot":
        var vocabulary = build_prompt_vocabulary(sheaf)
        var snapshot = vocabulary.snapshot()
        var input_bundle = InputBundle.from_schema(schema)
        var input_snapshot = input_bundle.snapshot()
        print("main_parameters_len=" + String(snapshot.main_parameters_len))
        print("spalten_len=" + String(snapshot.spalten_len))
        print("spalten_dict_keys=" + String(snapshot.spalten_dict_keys))
        print("ausgabe_paras_len=" + String(snapshot.ausgabe_paras_len))
        print("kombi_main_paras_len=" + String(snapshot.kombi_main_paras_len))
        print("zeilen_paras_len=" + String(snapshot.zeilen_paras_len))
        print("haupt_for_neben_len=" + String(snapshot.haupt_for_neben_len))
        print("ausgabe_art_len=" + String(snapshot.ausgabe_art_len))
        print("befehle_len=" + String(snapshot.befehle_len))
        print("befehle2_len=" + String(snapshot.befehle2_len))
        print(
            "gebrochen_erlaubte_zahlen_len="
            + String(snapshot.gebrochen_erlaubte_zahlen_len)
        )
        print("multiple_prefix=" + input_snapshot.row_ranges.multiple_prefix)
        print(
            "comma_split_pattern="
            + input_snapshot.row_ranges.comma_split_pattern
        )
        print(
            "prompt_vocabulary_builder_available="
            + (
                "true"
                if input_snapshot.prompt_vocabulary_builder_available
                else "false"
            )
        )
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
