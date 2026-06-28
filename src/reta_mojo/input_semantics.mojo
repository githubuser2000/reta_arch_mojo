"""Typed native normalization of Reta command-line input.

The historical parser carries a mutable ``lastMainCmd`` integer through a
large method.  This module turns the same surface form into owned values first:
section switches, long options, comma-separated values and per-value polarity.
Column selections can then be canonicalized through ``ParameterSemanticsSheaf``
without importing Python.
"""

from std.collections import List
from std.collections.string import ord
from .row_ranges import split_top_level_commas
from .parameter_semantics import (
    ParameterSemanticsSheaf,
    canonicalize_pair,
    column_numbers_for_pair,
)


@fieldwise_init
struct CliValue(Copyable, Equatable, Writable):
    var text: String
    var negative: Bool

    def __eq__(self, other: Self) -> Bool:
        return self.text == other.text and self.negative == other.negative

    def write_to[W: Writer](self, mut writer: W):
        if self.negative:
            writer.write("-")
        writer.write(self.text)


@fieldwise_init
struct ParsedCliOption(Copyable):
    var valid: Bool
    var section: String
    var name: String
    var has_equals: Bool
    var values: List[CliValue]
    var original: String


@fieldwise_init
struct CliParseResult(Copyable):
    var sections: List[String]
    var options: List[ParsedCliOption]
    var positional: List[String]
    var diagnostics: List[String]


@fieldwise_init
struct CanonicalColumnSelection(Copyable):
    var valid: Bool
    var source_main: String
    var source_parameter: String
    var main_canonical: String
    var parameter_canonical: String
    var negative: Bool
    var columns: List[Int]


def _slice_input(text: String, start: Int, end: Int) -> String:
    return String(StringSlice(text)[byte=start:end])


def _tail_input(text: String, start: Int) -> String:
    return String(StringSlice(text)[byte=start:])


def _find_equals(text: String) -> Int:
    for index in range(text.byte_length()):
        if ord(text[byte=index]) == 61:
            return index
    return -1


def _contains_string_input(values: List[String], value: String) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _parse_cli_value(raw: String) -> CliValue:
    var text = String(raw.strip())
    if text.byte_length() > 1 and text.startswith("-"):
        return CliValue(_tail_input(text, 1), True)
    return CliValue(text^, False)


def parse_long_option(section: String, token: String) -> ParsedCliOption:
    """Parse one ``--name`` or ``--name=value,...`` token."""
    var no_values = List[CliValue]()
    if not token.startswith("--") or token.byte_length() <= 2:
        return ParsedCliOption(False, section, "", False, no_values^, token)

    var body = _tail_input(token, 2)
    var equals = _find_equals(body)
    if equals < 0:
        var name = String(body.strip())
        return ParsedCliOption(
            name.byte_length() > 0,
            section,
            name^,
            False,
            List[CliValue](),
            token,
        )

    var name = String(_slice_input(body, 0, equals).strip())
    var raw_values = _tail_input(body, equals + 1)
    var split_values = split_top_level_commas(raw_values)
    var values = List[CliValue]()
    for index in range(len(split_values)):
        var value = _parse_cli_value(split_values[index])
        if value.text.byte_length() > 0:
            values.append(value^)
    return ParsedCliOption(
        name.byte_length() > 0,
        section,
        name^,
        True,
        values^,
        token,
    )


def parse_cli_tokens(tokens: List[String]) -> CliParseResult:
    """Normalize command tokens without consulting global runtime state."""
    var sections = List[String]()
    var options = List[ParsedCliOption]()
    var positional = List[String]()
    var diagnostics = List[String]()
    var current_section = String()

    for index in range(len(tokens)):
        var token = String(tokens[index].strip())
        if token.byte_length() == 0:
            continue

        if token.startswith("--"):
            var option = parse_long_option(current_section, token)
            if not option.valid:
                diagnostics.append("ungültige Langoption: " + token)
            elif current_section.byte_length() == 0:
                diagnostics.append("Langoption ohne Hauptbereich: " + token)
            options.append(option^)
            continue

        if token.startswith("-") and token.byte_length() > 1:
            current_section = _tail_input(token, 1)
            if not _contains_string_input(sections, current_section):
                sections.append(current_section)
            continue

        positional.append(token^)

    return CliParseResult(sections^, options^, positional^, diagnostics^)


def canonicalize_column_options(
    parsed: CliParseResult,
    sheaf: ParameterSemanticsSheaf,
) -> List[CanonicalColumnSelection]:
    """Resolve all ``-spalten --main=value`` choices to canonical pairs."""
    var selections = List[CanonicalColumnSelection]()
    for option_index in range(len(parsed.options)):
        var option = parsed.options[option_index].copy()
        if option.section != "spalten" or not option.has_equals:
            continue
        for value_index in range(len(option.values)):
            var value = option.values[value_index].copy()
            var pair = canonicalize_pair(sheaf, option.name, value.text)
            if not pair.valid:
                selections.append(
                    CanonicalColumnSelection(
                        False,
                        option.name,
                        value.text,
                        "",
                        "",
                        value.negative,
                        List[Int](),
                    )
                )
                continue
            selections.append(
                CanonicalColumnSelection(
                    True,
                    option.name,
                    value.text,
                    pair.main_name,
                    pair.parameter_name,
                    value.negative,
                    column_numbers_for_pair(sheaf, option.name, value.text),
                )
            )
    return selections^


def positive_columns(selections: List[CanonicalColumnSelection]) -> List[Int]:
    return _columns_for_polarity(selections, False)


def negative_columns(selections: List[CanonicalColumnSelection]) -> List[Int]:
    return _columns_for_polarity(selections, True)


def _contains_int_input(values: List[Int], value: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _sort_ints_input(mut values: List[Int]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _columns_for_polarity(
    selections: List[CanonicalColumnSelection], negative: Bool
) -> List[Int]:
    var columns = List[Int]()
    for selection_index in range(len(selections)):
        var selection = selections[selection_index].copy()
        if not selection.valid or selection.negative != negative:
            continue
        for column_index in range(len(selection.columns)):
            if not _contains_int_input(columns, selection.columns[column_index]):
                columns.append(selection.columns[column_index])
    _sort_ints_input(columns)
    return columns^


@fieldwise_init
struct VocabularyValuesForMain(Copyable):
    var main_canonical: String
    var values: List[String]


@fieldwise_init
struct PromptVocabulary(Copyable):
    var main_parameters: List[String]
    var column_options: List[String]
    var values_by_main: List[VocabularyValuesForMain]
    var output_options: List[String]
    var combination_options: List[String]
    var row_options: List[String]
    var output_modes: List[String]


def _append_unique_string(mut values: List[String], value: String) -> None:
    if not _contains_string_input(values, value):
        values.append(value)


def _parameter_aliases_for_main(
    sheaf: ParameterSemanticsSheaf, main_canonical: String
) -> List[String]:
    var values = List[String]()
    for group_index in range(len(sheaf.parameter_alias_groups)):
        var group = sheaf.parameter_alias_groups[group_index].copy()
        if group.main_canonical != main_canonical:
            continue
        for alias_index in range(len(group.aliases)):
            _append_unique_string(values, group.aliases[alias_index])
    return values^


def build_prompt_vocabulary(
    sheaf: ParameterSemanticsSheaf,
) -> PromptVocabulary:
    """Build the deterministic completion vocabulary available without Python.

    The dynamic prompt runtime still remains a migration boundary, but its
    schema-derived words no longer require ``program.paraDict`` or i18n globals.
    """
    var main_parameters: List[String] = [
        "-zeilen",
        "-spalten",
        "-kombination",
        "-ausgabe",
        "-debug",
        "-h",
        "-help",
    ]

    var column_options = List[String]()
    for alias_index in range(len(sheaf.main_aliases)):
        _append_unique_string(
            column_options,
            "--" + sheaf.main_aliases[alias_index].source_alias + "=",
        )
    column_options.append("--breite=")
    column_options.append("--breiten=")
    column_options.append("--keinenummerierung")
    column_options.append("--*=")

    var values_by_main = List[VocabularyValuesForMain]()
    for group_index in range(len(sheaf.main_alias_groups)):
        var canonical = sheaf.main_alias_groups[group_index].canonical
        values_by_main.append(
            VocabularyValuesForMain(
                canonical,
                _parameter_aliases_for_main(sheaf, canonical),
            )
        )

    var output_options: List[String] = [
        "--nocolor",
        "--justtext",
        "--art=",
        "--onetable",
        "--spaltenreihenfolgeundnurdiese=",
        "--endlessscreen",
        "--endless",
        "--dontwrap",
        "--breite=",
        "--breiten=",
        "--keineleereninhalte",
        "--keinenummerierung",
        "--keineueberschriften",
        "--*=",
    ]
    var combination_options: List[String] = [
        "--galaxie=", "--universum=", "--*="
    ]
    var row_options: List[String] = [
        "--zeit=",
        "--zaehlung=",
        "--vorhervonausschnitt=",
        "--vorhervonausschnittteiler",
        "--primzahlvielfache=",
        "--nachtraeglichneuabzaehlung=",
        "--nachtraeglichneuabzaehlungvielfache=",
        "--alles",
        "--potenzenvonzahlen=",
        "--typ=",
        "--vielfachevonzahlen=",
        "--oberesmaximum=",
        "--primzahlen=",
        "--invertieren",
        "--*=",
    ]
    var output_modes: List[String] = [
        "shell", "nichts", "csv", "bbcode", "html", "emacs", "markdown"
    ]
    return PromptVocabulary(
        main_parameters^,
        column_options^,
        values_by_main^,
        output_options^,
        combination_options^,
        row_options^,
        output_modes^,
    )


def vocabulary_values_for_main(
    vocabulary: PromptVocabulary, main_canonical: String
) -> List[String]:
    for index in range(len(vocabulary.values_by_main)):
        if vocabulary.values_by_main[index].main_canonical == main_canonical:
            return vocabulary.values_by_main[index].values.copy()
    return List[String]()
