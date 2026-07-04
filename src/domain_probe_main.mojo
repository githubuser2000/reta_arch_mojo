"""Native core CLI for the historical reta_domain_probe_py.py surface.

The native stage owns parameter aliases, canonical pairs, exact column
metadata, HTML-reference queries and their compact JSON representations.
The complete schema snapshot is serialized from the native typed catalog.
The full architecture aggregate is loaded from the reproducibly generated
immutable architecture-probe snapshot; no Python runtime is invoked.
"""

from std.collections import List
from std.collections.string import atol
from std.sys import argv

from reta_mojo.schema_catalog import bootstrap_reta_schema
from reta_mojo.schema_snapshot import schema_snapshot_json
from reta_mojo.architecture_probe_assets import load_architecture_snapshot_json
from reta_mojo.parameter_semantics import (
    CanonicalPair,
    ColumnCanonicalPairs,
    ColumnParameterMeta,
    ParameterAliasGroup,
    ParameterSemanticsSheaf,
    build_parameter_semantics,
    canonicalize_pair,
    column_numbers_for_pair,
    parameter_alias_groups_for_main,
    resolve_main_alias,
    reverse_map_canonical_pairs,
)
from reta_mojo.sheaves import HtmlReferenceSheaf, load_html_reference_sheaf


def _json_escape(text: String) -> String:
    return (
        text.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\b", "\\b")
        .replace("\f", "\\f")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )


def _print_json_string(text: String) -> None:
    print('"' + _json_escape(text) + '"', end="")


def _print_string_list(values: List[String]) -> None:
    print("[", end="")
    for index in range(len(values)):
        if index > 0:
            print(",", end="")
        _print_json_string(values[index])
    print("]", end="")


def _print_int_list(values: List[Int]) -> None:
    print("[", end="")
    for index in range(len(values)):
        if index > 0:
            print(",", end="")
        print(values[index], end="")
    print("]", end="")


def _print_python_int_list(values: List[Int]) -> None:
    print("[", end="")
    for index in range(len(values)):
        if index > 0:
            print(", ", end="")
        print(values[index], end="")
    print("]")


def _python_repr_escape(text: String) -> String:
    return (
        text.replace("\\", "\\\\")
        .replace("'", "\\'")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
        .replace("\t", "\\t")
    )


def _print_python_string(text: String) -> None:
    print("'" + _python_repr_escape(text) + "'", end="")


def _print_python_string_list(values: List[String]) -> None:
    print("[", end="")
    for index in range(len(values)):
        if index > 0:
            print(", ", end="")
        _print_python_string(values[index])
    print("]", end="")


def _contains_int(values: List[Int], value: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _sort_ints(mut values: List[Int]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _aliases_for_main(
    sheaf: ParameterSemanticsSheaf, canonical_main: String
) -> List[String]:
    for index in range(len(sheaf.main_alias_groups)):
        if sheaf.main_alias_groups[index].canonical == canonical_main:
            return sheaf.main_alias_groups[index].aliases.copy()
    return List[String]()


def _aliases_for_parameter(
    groups: List[ParameterAliasGroup], canonical_parameter: String
) -> List[String]:
    for index in range(len(groups)):
        if groups[index].parameter_canonical == canonical_parameter:
            return groups[index].aliases.copy()
    return List[String]()


def _main_columns(
    sheaf: ParameterSemanticsSheaf, canonical_main: String
) -> List[Int]:
    var result = List[Int]()
    var groups = parameter_alias_groups_for_main(sheaf, canonical_main)
    for group_index in range(len(groups)):
        var columns = column_numbers_for_pair(
            sheaf, canonical_main, groups[group_index].parameter_canonical
        )
        for column_index in range(len(columns)):
            if not _contains_int(result, columns[column_index]):
                result.append(columns[column_index])
    _sort_ints(result)
    return result^


def _print_alias_text(canonical: String, aliases: List[String]) -> None:
    print(canonical + " => ", end="")
    for index in range(len(aliases)):
        if index > 0:
            print(", ", end="")
        print(aliases[index], end="")
    print()


def _print_pairs_json(
    sheaf: ParameterSemanticsSheaf, canonical_main: String
) -> None:
    var groups = parameter_alias_groups_for_main(sheaf, canonical_main)
    print("[", end="")
    var emitted = 0
    for index in range(len(groups)):
        var group = groups[index].copy()
        var columns = column_numbers_for_pair(
            sheaf, canonical_main, group.parameter_canonical
        )
        if len(columns) == 0:
            continue
        if emitted > 0:
            print(",", end="")
        print('{"main":', end="")
        _print_json_string(canonical_main)
        print(',"parameter":', end="")
        _print_json_string(group.parameter_canonical)
        print(',"columns":', end="")
        _print_int_list(columns)
        print("}", end="")
        emitted += 1
    print("]")


def _print_main_json(
    sheaf: ParameterSemanticsSheaf, canonical_main: String
) -> None:
    var aliases = _aliases_for_main(sheaf, canonical_main)
    var columns = _main_columns(sheaf, canonical_main)
    var groups = parameter_alias_groups_for_main(sheaf, canonical_main)
    print('{"main":', end="")
    _print_json_string(canonical_main)
    print(',"aliases":', end="")
    _print_string_list(aliases)
    print(',"columns":', end="")
    _print_int_list(columns)
    print(',"pairs":[', end="")
    var emitted = 0
    for index in range(len(groups)):
        var group = groups[index].copy()
        var pair_columns = column_numbers_for_pair(
            sheaf, canonical_main, group.parameter_canonical
        )
        if len(pair_columns) == 0:
            continue
        if emitted > 0:
            print(",", end="")
        print('{"parameter":', end="")
        _print_json_string(group.parameter_canonical)
        print(',"aliases":', end="")
        _print_string_list(group.aliases)
        print(',"columns":', end="")
        _print_int_list(pair_columns)
        print("}", end="")
        emitted += 1
    print("]}")


def _print_pair_json(
    sheaf: ParameterSemanticsSheaf,
    input_main: String,
    input_parameter: String,
    pair: CanonicalPair,
) -> None:
    var main_aliases = _aliases_for_main(sheaf, pair.main_name)
    var groups = parameter_alias_groups_for_main(sheaf, pair.main_name)
    var parameter_aliases = _aliases_for_parameter(groups, pair.parameter_name)
    var columns = column_numbers_for_pair(
        sheaf, pair.main_name, pair.parameter_name
    )
    print('{"input_main":', end="")
    _print_json_string(input_main)
    print(',"input_parameter":', end="")
    _print_json_string(input_parameter)
    print(',"canonical_main":', end="")
    _print_json_string(pair.main_name)
    print(',"canonical_parameter":', end="")
    _print_json_string(pair.parameter_name)
    print(',"main_aliases":', end="")
    _print_string_list(main_aliases)
    print(',"parameter_aliases":', end="")
    _print_string_list(parameter_aliases)
    print(',"columns":', end="")
    _print_int_list(columns)
    print("}")


def _print_column_meta_json(meta: ColumnParameterMeta) -> None:
    print('{"column_number":', end="")
    print(meta.column_number, end="")
    print(',"parameter_main":', end="")
    _print_json_string(meta.parameter_main)
    print(',"parameter_main_aliases":', end="")
    _print_string_list(meta.parameter_main_aliases)
    print(',"parameter":', end="")
    _print_json_string(meta.parameter_name)
    print(',"parameter_aliases":', end="")
    _print_string_list(meta.parameter_aliases)
    print("}", end="")


def _print_column_meta_python(meta: ColumnParameterMeta) -> None:
    print("{'column_number': ", end="")
    print(meta.column_number, end="")
    print(", 'parameter_main': ", end="")
    _print_python_string(meta.parameter_main)
    print(", 'parameter_main_aliases': ", end="")
    _print_python_string_list(meta.parameter_main_aliases)
    print(", 'parameter': ", end="")
    _print_python_string(meta.parameter_name)
    print(", 'parameter_aliases': ", end="")
    _print_python_string_list(meta.parameter_aliases)
    print("}", end="")


def _empty_html_json(column_number: Int) -> String:
    return (
        '{"column_number":' + String(column_number)
        + ',"classes":[],"class_string":"","class_attributes":[]'
        + ',"extra_class_strings":[],"all_classes":[],"data_attributes":{}'
        + ',"attributes":[],"attributes_first":{},"text":""'
        + ',"raw_open_tag":"","raw_html":"","html_elements":[]}'
    )


def _html_payload(
    html_sheaf: HtmlReferenceSheaf, column_number: Int
) -> String:
    var payload = html_sheaf.html_meta_for_column(column_number)
    if payload == "{}":
        return _empty_html_json(column_number)
    return payload^


def _print_column_json(
    sheaf: ParameterSemanticsSheaf,
    html_sheaf: HtmlReferenceSheaf,
    column_number: Int,
) -> None:
    var matches = sheaf.exact_meta_for_column(column_number)
    var pairs = _pairs_for_column(
        reverse_map_canonical_pairs(sheaf), column_number
    )
    print('{"column_number":', end="")
    print(column_number, end="")
    print(',"matches":[', end="")
    for index in range(len(matches)):
        if index > 0:
            print(",", end="")
        _print_column_meta_json(matches[index])
    print('],"summary_pairs":[', end="")
    for index in range(len(pairs)):
        if index > 0:
            print(",", end="")
        print('{"main":', end="")
        _print_json_string(pairs[index].main_name)
        print(',"parameter":', end="")
        _print_json_string(pairs[index].parameter_name)
        print("}", end="")
    print('],"html":', end="")
    print(_html_payload(html_sheaf, column_number), end="")
    print("}")


def _print_pair_html_json(
    sheaf: ParameterSemanticsSheaf,
    html_sheaf: HtmlReferenceSheaf,
    input_main: String,
    input_parameter: String,
    pair: CanonicalPair,
) -> None:
    var columns = column_numbers_for_pair(
        sheaf, pair.main_name, pair.parameter_name
    )
    print('{"input_main":', end="")
    _print_json_string(input_main)
    print(',"input_parameter":', end="")
    _print_json_string(input_parameter)
    print(',"canonical_main":', end="")
    _print_json_string(pair.main_name)
    print(',"canonical_parameter":', end="")
    _print_json_string(pair.parameter_name)
    print(',"columns":', end="")
    _print_int_list(columns)
    print(',"html":[', end="")
    for index in range(len(columns)):
        if index > 0:
            print(",", end="")
        print(_html_payload(html_sheaf, columns[index]), end="")
    print("]}")


def _pairs_for_column(
    reverse: List[ColumnCanonicalPairs], column: Int
) -> List[CanonicalPair]:
    for index in range(len(reverse)):
        if reverse[index].column == column:
            return reverse[index].pairs.copy()
    return List[CanonicalPair]()


def _print_reverse_text(pairs: List[CanonicalPair]) -> None:
    print("summary_pairs=[", end="")
    for index in range(len(pairs)):
        if index > 0:
            print(", ", end="")
        print("('", end="")
        print(pairs[index].main_name, end="")
        print("', '", end="")
        print(pairs[index].parameter_name, end="")
        print("')", end="")
    print("]")


def _help(program_name: String) -> None:
    print(program_name + " - native Reta-Domäneninspektion")
    print("Aufruf:")
    print("  " + program_name + " mains")
    print("  " + program_name + " params <hauptparameter>")
    print("  " + program_name + " pairs <hauptparameter>")
    print("  " + program_name + " pairs-json <hauptparameter>")
    print("  " + program_name + " main-columns <hauptparameter>")
    print("  " + program_name + " main-json <hauptparameter>")
    print("  " + program_name + " pair <hauptparameter> <unterparameter>")
    print("  " + program_name + " pair-json <hauptparameter> <unterparameter>")
    print("  " + program_name + " column <spaltennummer>")
    print("  " + program_name + " column-json <spaltennummer>")
    print("  " + program_name + " reverse <spaltennummer>")
    print("  " + program_name + " html-json <spaltennummer>")
    print("  " + program_name + " html-all-json")
    print("  " + program_name + " pair-html-json <hauptparameter> <unterparameter>")
    print("  " + program_name + " schema-json")
    print("  " + program_name + " architecture-json")


def main() raises:
    var args = argv()
    var program_name = "reta-mojo-domain-probe"
    if len(args) <= 1 or String(args[1]) == "-h" or String(args[1]) == "--help" or String(args[1]) == "help":
        _help(program_name)
        return

    var schema = bootstrap_reta_schema()
    var sheaf = build_parameter_semantics(schema)
    var command = String(args[1])

    if command == "mains":
        for index in range(len(sheaf.main_alias_groups)):
            var group = sheaf.main_alias_groups[index].copy()
            _print_alias_text(group.canonical, group.aliases)
        return

    if command == "params":
        if len(args) != 3:
            raise Error("params benötigt einen Hauptparameter")
        var groups = parameter_alias_groups_for_main(sheaf, String(args[2]))
        for index in range(len(groups)):
            _print_alias_text(
                groups[index].parameter_canonical,
                groups[index].aliases,
            )
        return

    if command == "pairs" or command == "pairs-json" or command == "main-columns" or command == "main-json":
        if len(args) != 3:
            raise Error(command + " benötigt einen Hauptparameter")
        var input_main = String(args[2])
        var canonical_main = resolve_main_alias(sheaf, input_main)
        if canonical_main.byte_length() == 0:
            raise Error("Unbekannter Hauptparameter: " + input_main)
        if command == "pairs-json":
            _print_pairs_json(sheaf, canonical_main)
            return
        if command == "main-columns":
            print("main_columns=", end="")
            _print_python_int_list(_main_columns(sheaf, canonical_main))
            return
        if command == "main-json":
            _print_main_json(sheaf, canonical_main)
            return
        var groups = parameter_alias_groups_for_main(sheaf, canonical_main)
        for index in range(len(groups)):
            var columns = column_numbers_for_pair(
                sheaf, canonical_main, groups[index].parameter_canonical
            )
            if len(columns) == 0:
                continue
            print(
                canonical_main + " / " + groups[index].parameter_canonical + " => ",
                end="",
            )
            _print_python_int_list(columns)
        return

    if command == "pair" or command == "pair-json":
        if len(args) != 4:
            raise Error(command + " benötigt Haupt- und Unterparameter")
        var input_main = String(args[2])
        var input_parameter = String(args[3])
        var pair = canonicalize_pair(sheaf, input_main, input_parameter)
        if not pair.valid:
            raise Error(
                "Unbekanntes Paar: " + input_main + " / " + input_parameter
            )
        if command == "pair-json":
            _print_pair_json(sheaf, input_main, input_parameter, pair)
            return
        print("canonical=" + pair.main_name + " / " + pair.parameter_name)
        print("columns=", end="")
        _print_python_int_list(
            column_numbers_for_pair(sheaf, pair.main_name, pair.parameter_name)
        )
        return

    if command == "column" or command == "column-json":
        if len(args) != 3:
            raise Error(command + " benötigt eine Spaltennummer")
        var column = atol(String(args[2]))
        var matches = sheaf.exact_meta_for_column(column)
        if len(matches) == 0:
            raise Error(
                "Unbekannte oder nicht-direkte Spalte: " + String(column)
            )
        var html_sheaf = load_html_reference_sheaf()
        if command == "column-json":
            _print_column_json(sheaf, html_sheaf, column)
            return
        for index in range(len(matches)):
            print(String(column) + " => ", end="")
            _print_column_meta_python(matches[index])
            print()
        _print_reverse_text(
            _pairs_for_column(reverse_map_canonical_pairs(sheaf), column)
        )
        return

    if command == "reverse":
        if len(args) != 3:
            raise Error("reverse benötigt eine Spaltennummer")
        var column = atol(String(args[2]))
        _print_reverse_text(
            _pairs_for_column(reverse_map_canonical_pairs(sheaf), column)
        )
        return

    if command == "html-json":
        if len(args) != 3:
            raise Error("html-json benötigt eine Spaltennummer")
        var html_sheaf = load_html_reference_sheaf()
        print(_html_payload(html_sheaf, atol(String(args[2]))))
        return

    if command == "html-all-json":
        if len(args) != 2:
            raise Error("html-all-json akzeptiert keine Argumente")
        var html_sheaf = load_html_reference_sheaf()
        for index in range(len(html_sheaf.reference_map)):
            print(html_sheaf.reference_map[index].payload_json)
        return

    if command == "schema-json":
        if len(args) != 2:
            raise Error("schema-json akzeptiert keine Argumente")
        print(schema_snapshot_json(schema))
        return

    if command == "architecture-json":
        if len(args) != 2:
            raise Error("architecture-json akzeptiert keine Argumente")
        print(load_architecture_snapshot_json(), end="")
        return

    if command == "pair-html-json":
        if len(args) != 4:
            raise Error(
                "pair-html-json benötigt Haupt- und Unterparameter"
            )
        var input_main = String(args[2])
        var input_parameter = String(args[3])
        var pair = canonicalize_pair(sheaf, input_main, input_parameter)
        if not pair.valid:
            raise Error(
                "Unbekanntes Paar: " + input_main + " / " + input_parameter
            )
        var html_sheaf = load_html_reference_sheaf()
        _print_pair_html_json(
            sheaf, html_sheaf, input_main, input_parameter, pair
        )
        return

    raise Error("Unbekannter Befehl: " + command)
