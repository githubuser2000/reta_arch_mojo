"""Native core CLI for the historical reta_domain_probe_py.py surface.

The native stage owns parameter aliases, canonical pairs, direct-column
queries and their compact JSON representations. HTML-reference and complete
architecture snapshots remain separate owners and are intentionally rejected
instead of silently invoking Python.
"""

from std.collections import List
from std.collections.string import atol
from std.sys import argv

from reta_mojo.schema_catalog import bootstrap_reta_schema
from reta_mojo.parameter_semantics import (
    CanonicalPair,
    ColumnCanonicalPairs,
    ParameterAliasGroup,
    ParameterSemanticsSheaf,
    build_parameter_semantics,
    canonicalize_pair,
    column_numbers_for_pair,
    parameter_alias_groups_for_main,
    resolve_main_alias,
    reverse_map_canonical_pairs,
)


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
    print("  " + program_name + " reverse <spaltennummer>")


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

    if command == "reverse":
        if len(args) != 3:
            raise Error("reverse benötigt eine Spaltennummer")
        var column = atol(String(args[2]))
        _print_reverse_text(
            _pairs_for_column(reverse_map_canonical_pairs(sheaf), column)
        )
        return

    raise Error(
        "Befehl noch nicht nativ besessen: " + command
        + "; HTML- und Gesamtsnapshots bleiben vorerst Referenzgrenze"
    )
