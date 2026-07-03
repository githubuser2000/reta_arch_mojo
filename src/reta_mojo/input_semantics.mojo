"""Typed native normalization of Reta command-line input.

The historical parser carries a mutable ``lastMainCmd`` integer through a
large method.  This module turns the same surface form into owned values first:
section switches, long options, comma-separated values and per-value polarity.
Column selections can then be canonicalized through ``ParameterSemanticsSheaf``
without importing Python.
"""

from std.collections import List
from std.collections.string import atol, ord
from .csv_table import read_text_file
from .resource_paths import asset_resource
from .row_ranges import (
    RowRangeSyntax,
    RowRangeSyntaxSnapshot,
    split_top_level_commas,
)
from .schema import RetaContextSchema
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
struct PromptVocabularyMapEntry(Copyable):
    var key: String
    var values: List[String]


@fieldwise_init
struct PromptVocabularySnapshot(Copyable, Equatable):
    var main_parameters_len: Int
    var spalten_len: Int
    var spalten_dict_keys: Int
    var ausgabe_paras_len: Int
    var kombi_main_paras_len: Int
    var zeilen_paras_len: Int
    var haupt_for_neben_len: Int
    var ausgabe_art_len: Int
    var befehle_len: Int
    var befehle2_len: Int
    var gebrochen_erlaubte_zahlen_len: Int


@fieldwise_init
struct PromptVocabulary(Copyable):
    """Complete typed counterpart of Python ``PromptVocabulary``.

    Python sets become deterministically sorted lists.  ``spalten_dict`` keeps
    insertion order through explicit key/value entries and preserves every
    duplicate value exactly as produced by the reference builder.
    """

    var main_parameters: List[String]
    var spalten: List[String]
    var eigs_n: List[String]
    var eigs_r: List[String]
    var spalten_dict: List[PromptVocabularyMapEntry]
    var ausgabe_paras: List[String]
    var kombi_main_paras: List[String]
    var zeilen_paras: List[String]
    var haupt_for_neben: List[String]
    var not_parameter_values: List[String]
    var haupt_for_neben_set: List[String]
    var ausgabe_art: List[String]
    var zeilen_typen: List[String]
    var zeilen_zeit: List[String]
    var zeilen_typen_b: List[String]
    var gebrochen_erlaubte_zahlen: List[Int]
    var befehle: List[String]
    var befehle2: List[String]

    def snapshot(self) -> PromptVocabularySnapshot:
        return PromptVocabularySnapshot(
            len(self.main_parameters),
            len(self.spalten),
            len(self.spalten_dict),
            len(self.ausgabe_paras),
            len(self.kombi_main_paras),
            len(self.zeilen_paras),
            len(self.haupt_for_neben),
            len(self.ausgabe_art),
            len(self.befehle),
            len(self.befehle2),
            len(self.gebrochen_erlaubte_zahlen),
        )

    def values_for_main(self, main_name: String) -> List[String]:
        for index in range(len(self.spalten_dict)):
            if self.spalten_dict[index].key == main_name:
                return self.spalten_dict[index].values.copy()
        return List[String]()


@fieldwise_init
struct PromptVocabularyBuilder(Copyable):
    var schema: RetaContextSchema
    var row_ranges: RowRangeSyntax

    def build(self) raises -> PromptVocabulary:
        return load_prompt_vocabulary()


@fieldwise_init
struct InputBundleSnapshot(Copyable, Equatable):
    var row_ranges: RowRangeSyntaxSnapshot
    var prompt_vocabulary_builder_available: Bool


@fieldwise_init
struct InputBundle(Copyable):
    var schema: RetaContextSchema
    var row_ranges: RowRangeSyntax
    var prompt_vocabulary_builder: PromptVocabularyBuilder

    @staticmethod
    def from_schema(
        schema: RetaContextSchema, multiple_prefix: String = "v"
    ) -> Self:
        var row_ranges = RowRangeSyntax.from_schema(multiple_prefix)
        return Self(
            schema.copy(),
            row_ranges.copy(),
            PromptVocabularyBuilder(schema.copy(), row_ranges^),
        )

    def build_prompt_vocabulary(self) raises -> PromptVocabulary:
        return self.prompt_vocabulary_builder.build()

    def snapshot(self) -> InputBundleSnapshot:
        return InputBundleSnapshot(self.row_ranges.snapshot(), True)


def _empty_prompt_vocabulary() -> PromptVocabulary:
    return PromptVocabulary(
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        List[PromptVocabularyMapEntry](),
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        List[String](),
        List[Int](),
        List[String](),
        List[String](),
    )


def _append_map_value(
    mut entries: List[PromptVocabularyMapEntry],
    key: String,
    value: String,
) -> None:
    for index in range(len(entries)):
        if entries[index].key == key:
            entries[index].values.append(value)
            return
    entries.append(PromptVocabularyMapEntry(key, [value]))


def _append_catalog_string(
    mut vocabulary: PromptVocabulary,
    field_name: String,
    value: String,
) -> None:
    if field_name == "main_parameters":
        vocabulary.main_parameters.append(value)
    elif field_name == "spalten":
        vocabulary.spalten.append(value)
    elif field_name == "eigs_n":
        vocabulary.eigs_n.append(value)
    elif field_name == "eigs_r":
        vocabulary.eigs_r.append(value)
    elif field_name == "ausgabe_paras":
        vocabulary.ausgabe_paras.append(value)
    elif field_name == "kombi_main_paras":
        vocabulary.kombi_main_paras.append(value)
    elif field_name == "zeilen_paras":
        vocabulary.zeilen_paras.append(value)
    elif field_name == "haupt_for_neben":
        vocabulary.haupt_for_neben.append(value)
    elif field_name == "not_parameter_values":
        vocabulary.not_parameter_values.append(value)
    elif field_name == "haupt_for_neben_set":
        vocabulary.haupt_for_neben_set.append(value)
    elif field_name == "ausgabe_art":
        vocabulary.ausgabe_art.append(value)
    elif field_name == "zeilen_typen":
        vocabulary.zeilen_typen.append(value)
    elif field_name == "zeilen_zeit":
        vocabulary.zeilen_zeit.append(value)
    elif field_name == "zeilen_typen_b":
        vocabulary.zeilen_typen_b.append(value)
    elif field_name == "befehle":
        vocabulary.befehle.append(value)
    elif field_name == "befehle2":
        vocabulary.befehle2.append(value)


def load_prompt_vocabulary(
    path: String = "",
) raises -> PromptVocabulary:
    """Load the generated full Python vocabulary without a Python runtime."""
    var catalog_path = path
    if catalog_path.byte_length() == 0:
        catalog_path = asset_resource("input_semantics_catalog.tsv")
    var vocabulary = _empty_prompt_vocabulary()
    var lines = read_text_file(catalog_path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 5:
            continue
        var kind = String(fields[0])
        var field_name = String(fields[1])
        var key = String(fields[2])
        var value = String(fields[4])
        if kind == "list" or kind == "set":
            _append_catalog_string(vocabulary, field_name, value)
        elif kind == "intset" and field_name == "gebrochen_erlaubte_zahlen":
            vocabulary.gebrochen_erlaubte_zahlen.append(atol(value))
        elif kind == "map" and field_name == "spalten_dict":
            _append_map_value(vocabulary.spalten_dict, key, value)
        elif kind == "map-empty" and field_name == "spalten_dict":
            _append_map_value(vocabulary.spalten_dict, key, "")
            vocabulary.spalten_dict[len(vocabulary.spalten_dict) - 1].values = List[String]()
    return vocabulary^


def build_prompt_vocabulary(
    sheaf: ParameterSemanticsSheaf,
) raises -> PromptVocabulary:
    """Compatibility entry point backed by the complete immutable catalog."""
    if len(sheaf.main_alias_groups) == 0:
        return _empty_prompt_vocabulary()
    return load_prompt_vocabulary()


def vocabulary_values_for_main(
    vocabulary: PromptVocabulary, main_canonical: String
) -> List[String]:
    return vocabulary.values_for_main(main_canonical)


def bootstrap_input_bundle(
    schema: RetaContextSchema, multiple_prefix: String = "v"
) -> InputBundle:
    return InputBundle.from_schema(schema, multiple_prefix)
