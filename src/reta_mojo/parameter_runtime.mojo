"""Native owner of the historical shell/CLI parameter runtime.

This module owns the deterministic contract of
``reta_architecture.parameter_runtime``: column resolution, row selectors,
width/output switches and upper-limit evaluation.  The mutable Python Program
object is represented by an explicit plan instead of callbacks or dynamic
attribute writes.
"""

from std.collections import List
from std.collections.string import ord
from .input_semantics import parse_cli_tokens, ParsedCliOption
from .runtime_aliases import load_runtime_alias_catalog, resolve_runtime_columns_pattern
from .resource_paths import asset_resource
from .row_ranges import range_to_numbers
from .all_columns import load_all_column_selection
from .kombi_join_columns import (
    KombiColumnRequest,
    append_unique_kombi_request,
    load_kombi_alias_catalog,
    remove_kombi_requests,
    resolve_kombi_alias,
    sort_kombi_requests,
)
from .generated_aliases import (
    FractionColumnRequest,
    GeneratedAliasEntry,
    MetaColumnRequest,
    ModalConcept,
    append_unique_fraction_request,
    append_unique_meta_request,
    append_unique_modal_concept,
    fraction_request_from_entry,
    load_generated_alias_catalog,
    meta_request_from_entry,
    modal_concept_from_entry,
    remove_fraction_requests,
    remove_meta_requests,
    sort_meta_requests_by_python_set,
    remove_modal_concepts,
    resolve_generated_aliases_pattern,
    sort_modal_concepts,
)


@fieldwise_init
struct ParameterRuntimeBundle(Copyable, Writable):
    var column_function: String
    var width_function: String
    var parse_function: String
    var upper_limit_argument_function: String
    var upper_limit_aggregate_function: String
    var upper_limit_apply_function: String

    def write_to[W: Writer](self, mut writer: W):
        writer.write(
            "ParameterRuntimeBundle(column_function=", self.column_function,
            ", width_function=", self.width_function,
            ", parse_function=", self.parse_function,
            ", upper_limit_argument_function=", self.upper_limit_argument_function,
            ", upper_limit_aggregate_function=", self.upper_limit_aggregate_function,
            ", upper_limit_apply_function=", self.upper_limit_apply_function, ")"
        )


def bootstrap_parameter_runtime() -> ParameterRuntimeBundle:
    return ParameterRuntimeBundle(
        "produce_all_spalten_numbers",
        "apply_width_parameter",
        "parameters_to_commands_and_numbers",
        "upper_limit_values_for_argument",
        "upper_limit_from_arguments",
        "apply_upper_limit_argument",
    )


@fieldwise_init
struct ParameterRuntimePlan(Copyable):
    var language: String
    var output_mode: String
    var width: Int
    var widths: List[Int]
    var highest: Int
    var number_rows: Bool
    var include_headings: Bool
    var color_rows: Bool
    var one_table: Bool
    var no_blank_contents: Bool
    var positive_rows: List[String]
    var negative_rows: List[String]
    var columns: List[Int]
    var explicit_order_requested: Bool
    var explicit_positions: List[Int]
    var modal_concepts: List[ModalConcept]
    var meta_requests: List[MetaColumnRequest]
    var fraction_requests: List[FractionColumnRequest]
    var kombi_requests: List[KombiColumnRequest]
    var generated_commands: List[String]
    var diagnostics: List[String]


def _row_has_visible_content(row: List[String]) -> Bool:
    for index in range(len(row)):
        if String(row[index].strip()).byte_length() > 0:
            return True
    return False


def _drop_empty_selected_rows(
    table: CsvTable, row_numbers: List[Int]
) -> Tuple[CsvTable, List[Int]]:
    var rows = List[List[String]]()
    var numbers = List[Int]()
    for index in range(len(table.rows)):
        var number = row_numbers[index] if index < len(row_numbers) else index
        var row = table.rows[index].copy()
        if number == 0 or _row_has_visible_content(row):
            rows.append(row^)
            numbers.append(number)
    return CsvTable(rows^, table.maximum_columns), numbers^


def _section_is(section: String, german: String, english: String) -> Bool:
    return section == german or section == english


def _section_is_lines(section: String) -> Bool:
    return section == "zeilen" or section == "lines" or section == "rows"


def _contains_int(values: List[Int], wanted: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique_int(mut values: List[Int], value: Int):
    if not _contains_int(values, value):
        values.append(value)


def _contains_string_native(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _is_unsigned_decimal_native(text: String) -> Bool:
    if text.byte_length() == 0:
        return False
    for index in range(text.byte_length()):
        var value = ord(text[byte=index])
        if value < 48 or value > 57:
            return False
    return True


def _parse_unsigned_decimal_native(text: String) -> Int:
    var result = 0
    for index in range(text.byte_length()):
        result = result * 10 + ord(text[byte=index]) - 48
    return result


def _replace_explicit_widths(
    option: ParsedCliOption, mut widths: List[Int]
):
    """Mirror the legacy ``--breiten`` parser.

    Every occurrence replaces the preceding list.  Only unsigned decimal
    entries survive; negative and non-decimal fragments are ignored rather
    than becoming zero-width columns.
    """
    widths.clear()
    for value_index in range(len(option.values)):
        var value = option.values[value_index].copy()
        if not value.negative and _is_unsigned_decimal_native(value.text):
            widths.append(_parse_unsigned_decimal_native(value.text))


def _append_unique_string_native(mut values: List[String], value: String):
    if not _contains_string_native(values, value):
        values.append(value)


def _remove_strings_native(
    values: List[String], excluded: List[String]
) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        if not _contains_string_native(excluded, values[index]):
            result.append(values[index])
    return result^


def _collect_generated_alias(
    entry: GeneratedAliasEntry,
    negative: Bool,
    mut positive_modal: List[ModalConcept],
    mut negative_modal: List[ModalConcept],
    mut positive_meta: List[MetaColumnRequest],
    mut negative_meta: List[MetaColumnRequest],
    mut positive_fractions: List[FractionColumnRequest],
    mut negative_fractions: List[FractionColumnRequest],
    mut positive_commands: List[String],
    mut negative_commands: List[String],
) raises:
    if entry.bucket == "modal":
        var concept = modal_concept_from_entry(entry)
        if negative:
            append_unique_modal_concept(negative_modal, concept)
        else:
            append_unique_modal_concept(positive_modal, concept)
    elif entry.bucket == "meta":
        var request = meta_request_from_entry(entry)
        if negative:
            append_unique_meta_request(negative_meta, request)
        else:
            append_unique_meta_request(positive_meta, request)
    elif entry.bucket.startswith("fraction_"):
        var request = fraction_request_from_entry(entry)
        if negative:
            append_unique_fraction_request(negative_fractions, request)
        else:
            append_unique_fraction_request(positive_fractions, request)
    elif entry.bucket == "generated_command":
        if negative:
            _append_unique_string_native(negative_commands, entry.payload)
        else:
            _append_unique_string_native(positive_commands, entry.payload)
    elif entry.bucket == "prime_effect":
        var command = (
            "prime_effect:none"
            if entry.payload.byte_length() == 0
            else "prime_effect:" + entry.payload
        )
        if negative:
            _append_unique_string_native(negative_commands, command)
        else:
            _append_unique_string_native(positive_commands, command)


def _sort_ints(mut values: List[Int]):
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def _remove_ints(values: List[Int], excluded: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(values)):
        if not _contains_int(excluded, values[index]):
            result.append(values[index])
    return result^


def _append_row_condition(
    mut positive: List[String],
    mut negative: List[String],
    marker: String,
    value: String,
    is_negative: Bool,
):
    if is_negative:
        negative.append(marker + value)
    else:
        positive.append(marker + value)


def _map_time(value: String) -> String:
    if value == "heute" or value == "today" or value == "present":
        return "="
    if value == "gestern" or value == "yesterday" or value == "frueher" or value == "früher" or value == "past":
        return "<"
    if value == "morgen" or value == "tomorrow" or value == "spaeter" or value == "später" or value == "future":
        return ">"
    return value



def _map_row_value(value: String) -> String:
    if value == "moon":
        return "mond"
    if value == "sun":
        return "sonne"
    if value == "blacksun":
        return "schwarzesonne"
    if value == "planet":
        return "planet"
    if value == "sunWithMoonParts":
        return "SonneMitMondanteil"
    if value == "outsidefirst":
        return "aussenerste"
    if value == "insidefirst":
        return "innenerste"
    if value == "outsideall":
        return "aussenalle"
    if value == "insideall":
        return "innenalle"
    return value


def _process_row_option(
    option: ParsedCliOption,
    mut positive: List[String],
    mut negative: List[String],
    mut highest: Int,
) raises:
    var name = option.name
    if name == "alles" or name == "all":
        positive.append("all")
        return
    if name == "vorhervonausschnittteiler" or name == "thisrangebeforedividers" or name == "divisors":
        positive.append("_w_")
        return
    if name == "invertieren" or name == "invert":
        positive.append("_i_")
        return
    if name == "oberesmaximum" or name == "uppermaximum" or name == "maximum":
        if len(option.values) > 0:
            highest = atol(option.values[0].text)
        return
    for value_index in range(len(option.values)):
        var value = option.values[value_index].copy()
        if name == "vorhervonausschnitt" or name == "thisrangebefore" or name == "range":
            _append_row_condition(positive, negative, "_a_", value.text, value.negative)
        elif name == "vorhervonausschnittvielfache" or name == "multiplerange":
            _append_row_condition(positive, negative, "_b_", value.text, value.negative)
        elif name == "zaehlung" or name == "zählung" or name == "ranges" or name == "counting":
            _append_row_condition(positive, negative, "_n_", value.text, value.negative)
        elif name == "nachtraeglichneuabzaehlung" or name == "retrospectiverecount" or name == "position":
            _append_row_condition(positive, negative, "_z_", value.text, value.negative)
        elif name == "nachtraeglichneuabzaehlungvielfache" or name == "retrospectiverecountmultiples" or name == "multipleposition":
            _append_row_condition(positive, negative, "_y_", value.text, value.negative)
        elif name == "potenzenvonzahlen" or name == "potenciesofnumbers" or name == "powers":
            _append_row_condition(positive, negative, "_^_", value.text, value.negative)
        elif name == "primzahlvielfache" or name == "primemultiples":
            _append_row_condition(positive, negative, "", value.text + "p", value.negative)
        elif name == "vielfachevonzahlen" or name == "multiplesofnumbers" or name == "multiples":
            _append_row_condition(positive, negative, "", value.text + "v", value.negative)
        elif name == "zeit" or name == "time":
            _append_row_condition(positive, negative, "", _map_time(value.text), value.negative)
        elif name == "typ" or name == "type" or name == "primzahlen" or name == "primenumbers" or name == "primes":
            _append_row_condition(positive, negative, "", _map_row_value(value.text), value.negative)


def build_parameter_runtime_plan(tokens: List[String], maximum_columns: Int, maximum_rows: Int) raises -> ParameterRuntimePlan:
    var parsed = parse_cli_tokens(tokens)
    var aliases = load_runtime_alias_catalog(asset_resource("parameter_aliases.tsv"))
    var generated_aliases = load_generated_alias_catalog(asset_resource("generated_aliases.tsv"))
    var kombi_aliases = load_kombi_alias_catalog(asset_resource("kombi_aliases.tsv"))
    var language = String("german")
    # Language affects the generated alias matrix itself, so resolve it before
    # processing any column option rather than after the option loop.
    for token_index in range(len(tokens)):
        var token = tokens[token_index]
        if token.startswith("-language="):
            language = String(StringSlice(token)[byte=10:])
        elif token.startswith("-sprache="):
            language = String(StringSlice(token)[byte=9:])
    var output_mode = String("shell")
    var width = 21
    var widths = List[Int]()
    var width_locked_zero = False
    var highest = maximum_rows
    var number_rows = True
    var include_headings = True
    var color_rows = True
    var one_table = False
    var no_blank_contents = False
    var positive_rows = List[String]()
    var negative_rows = List[String]()
    var positive_columns = List[Int]()
    var negative_columns = List[Int]()
    var explicit_order = List[Int]()
    var explicit_order_requested = False
    var positive_modal = List[ModalConcept]()
    var negative_modal = List[ModalConcept]()
    var positive_meta = List[MetaColumnRequest]()
    var negative_meta = List[MetaColumnRequest]()
    var positive_fractions = List[FractionColumnRequest]()
    var negative_fractions = List[FractionColumnRequest]()
    var positive_kombi = List[KombiColumnRequest]()
    var negative_kombi = List[KombiColumnRequest]()
    var positive_commands = List[String]()
    var negative_commands = List[String]()
    var all_columns_requested = False
    var diagnostics = parsed.diagnostics.copy()

    for option_index in range(len(parsed.options)):
        var option = parsed.options[option_index].copy()
        if _section_is_lines(option.section):
            _process_row_option(option, positive_rows, negative_rows, highest)
            continue
        if _section_is(option.section, "kombination", "combination"):
            for value_index in range(len(option.values)):
                var value = option.values[value_index].copy()
                var request = resolve_kombi_alias(
                    kombi_aliases, language, option.name, value.text
                )
                if request.column < 1:
                    diagnostics.append(
                        "unbekanntes Kombinationspaar: "
                        + option.name
                        + "/"
                        + value.text
                    )
                elif value.negative:
                    append_unique_kombi_request(negative_kombi, request)
                else:
                    append_unique_kombi_request(positive_kombi, request)
            continue
        if _section_is(option.section, "ausgabe", "output"):
            if option.name == "art" or option.name == "type":
                if len(option.values) > 0:
                    output_mode = option.values[0].text
            elif option.name == "breite" or option.name == "width":
                if len(option.values) > 0:
                    var requested_width = atol(option.values[0].text)
                    if width_locked_zero or requested_width == 0:
                        width = 0
                        width_locked_zero = True
                    else:
                        width = max(width, requested_width)
            elif option.name == "breiten" or option.name == "widths":
                _replace_explicit_widths(option, widths)
            elif option.name == "keinenummerierung" or option.name == "nonumbering":
                number_rows = False
            elif option.name == "keineueberschriften" or option.name == "noheadings":
                include_headings = False
            elif option.name == "nocolor" or option.name == "justtext":
                color_rows = False
            elif (
                option.name == "keineleereninhalte"
                or option.name == "noblankcontents"
            ):
                no_blank_contents = True
            elif (
                option.name == "onetable"
                or option.name == "endlessscreen"
                or option.name == "endless"
                or option.name == "dontwrap"
            ):
                one_table = True
            elif option.name == "spaltenreihenfolgeundnurdiese" or option.name == "columnorderandonlythese" or option.name == "columnorder":
                explicit_order_requested = True
                for value_index in range(len(option.values)):
                    var raw = option.values[value_index].text
                    var selected = List[Int]()
                    try:
                        var parsed_columns = range_to_numbers(raw, False, 0)
                        for parsed_column in parsed_columns:
                            selected.append(parsed_column)
                    except:
                        selected.append(atol(raw))
                    _sort_ints(selected)
                    for selected_index in range(len(selected)):
                        var column = selected[selected_index]
                        if column > 0 and column <= maximum_columns:
                            _append_unique_int(explicit_order, column - 1)
            continue
        if _section_is(option.section, "spalten", "columns"):
            if option.name == "alles" or option.name == "all":
                all_columns_requested = True
                continue
            if option.name == "breite" or option.name == "width":
                if len(option.values) > 0:
                    var requested_width = atol(option.values[0].text)
                    if width_locked_zero or requested_width == 0:
                        width = 0
                        width_locked_zero = True
                    else:
                        width = max(width, requested_width)
                continue
            if option.name == "breiten" or option.name == "widths":
                _replace_explicit_widths(option, widths)
                continue
            if option.name == "keinenummerierung" or option.name == "nonumbering":
                number_rows = False
                continue
            for value_index in range(len(option.values)):
                var value = option.values[value_index].copy()
                var resolved = resolve_runtime_columns_pattern(aliases, option.name, value.text)
                var generated_resolved = resolve_generated_aliases_pattern(
                    generated_aliases, language, option.name, value.text
                )
                if len(resolved) == 0 and len(generated_resolved) == 0:
                    diagnostics.append("unbekanntes Spaltenpaar: " + option.name + "/" + value.text)
                    continue
                for column_index in range(len(resolved)):
                    if value.negative:
                        _append_unique_int(negative_columns, resolved[column_index])
                    else:
                        _append_unique_int(positive_columns, resolved[column_index])
                for generated_index in range(len(generated_resolved)):
                    _collect_generated_alias(
                        generated_resolved[generated_index],
                        value.negative,
                        positive_modal,
                        negative_modal,
                        positive_meta,
                        negative_meta,
                        positive_fractions,
                        negative_fractions,
                        positive_commands,
                        negative_commands,
                    )

    if all_columns_requested:
        var all_selection = load_all_column_selection()
        for column_index in range(len(all_selection.columns)):
            _append_unique_int(positive_columns, all_selection.columns[column_index])
        for modal_index in range(len(all_selection.modal_concepts)):
            append_unique_modal_concept(positive_modal, all_selection.modal_concepts[modal_index])
        for meta_index in range(len(all_selection.meta_requests)):
            append_unique_meta_request(positive_meta, all_selection.meta_requests[meta_index])
        for fraction_index in range(len(all_selection.fraction_requests)):
            append_unique_fraction_request(positive_fractions, all_selection.fraction_requests[fraction_index])
        for kombi_index in range(len(all_selection.kombi_requests)):
            append_unique_kombi_request(positive_kombi, all_selection.kombi_requests[kombi_index])
        for command_index in range(len(all_selection.generated_commands)):
            _append_unique_string_native(positive_commands, all_selection.generated_commands[command_index])

    # Python removes row predicates that occur on both polarity sides before
    # evaluating the selector.  Exact 2/-2 cancellation therefore means that
    # no row predicate remains, which intentionally selects the full range.
    var resolved_positive_rows = _remove_strings_native(
        positive_rows, negative_rows
    )
    var resolved_negative_rows = _remove_strings_native(
        negative_rows, positive_rows
    )

    var has_explicit_order = explicit_order_requested
    var has_semantic_selection = (
        len(positive_columns) > 0
        or len(positive_modal) > 0
        or len(positive_meta) > 0
        or len(positive_fractions) > 0
        or len(positive_kombi) > 0
        or len(positive_commands) > 0
    )
    var columns = positive_columns^
    var explicit_positions = List[Int]()
    if has_explicit_order and has_semantic_selection:
        explicit_positions = explicit_order^
    elif has_explicit_order:
        columns = explicit_order^
    columns = _remove_ints(columns, negative_columns)
    if not (has_explicit_order and not has_semantic_selection):
        _sort_ints(columns)
    if highest < 1 or highest > maximum_rows:
        highest = maximum_rows
    var modal_concepts = remove_modal_concepts(positive_modal, negative_modal)
    sort_modal_concepts(modal_concepts)
    var meta_requests = remove_meta_requests(positive_meta, negative_meta)
    sort_meta_requests_by_python_set(meta_requests)
    var fraction_requests = remove_fraction_requests(
        positive_fractions, negative_fractions
    )
    var kombi_requests = remove_kombi_requests(positive_kombi, negative_kombi)
    sort_kombi_requests(kombi_requests)
    var generated_commands = _remove_strings_native(
        positive_commands, negative_commands
    )
    # A generated-only selection must not silently pull in physical column 0.
    # Keep the historical default only when no physical or generated column was
    # selected at all.
    if (
        len(columns) == 0
        and len(modal_concepts) == 0
        and len(meta_requests) == 0
        and len(fraction_requests) == 0
        and len(kombi_requests) == 0
        and len(generated_commands) == 0
        and not explicit_order_requested
    ):
        columns = [0]
    return ParameterRuntimePlan(
        language^,
        output_mode^,
        width,
        widths^,
        highest,
        number_rows,
        include_headings,
        color_rows,
        one_table,
        no_blank_contents,
        resolved_positive_rows^,
        resolved_negative_rows^,
        columns^,
        explicit_order_requested,
        explicit_positions^,
        modal_concepts^,
        meta_requests^,
        fraction_requests^,
        kombi_requests^,
        generated_commands^,
        diagnostics^,
    )




@fieldwise_init
struct UpperLimitArgument(Copyable, Equatable, Writable):
    var values: List[Int]
    var applies: Bool

    def __eq__(self, other: Self) -> Bool:
        return self.values == other.values and self.applies == other.applies

    def write_to[W: Writer](self, mut writer: W):
        writer.write("UpperLimitArgument(values=", self.values, ", applies=", self.applies, ")")


def _value_after_prefix(token: String, prefix: String) -> String:
    return String(StringSlice(token)[byte=prefix.byte_length():])


def upper_limit_values_for_argument(token: String) raises -> UpperLimitArgument:
    for prefix in [
        "--oberesmaximum=",
        "--uppermaximum=",
        "--maximum=",
    ]:
        if token.startswith(prefix):
            var value = _value_after_prefix(token, prefix)
            if _is_unsigned_decimal_native(value):
                return UpperLimitArgument([_parse_unsigned_decimal_native(value)], True)
            return UpperLimitArgument(List[Int](), False)

    for prefix in [
        "--vorhervonausschnitt=",
        "--thisrangebefore=",
        "--range=",
    ]:
        if token.startswith(prefix):
            var selected = range_to_numbers(_value_after_prefix(token, prefix), False, 0)
            var values = List[Int]()
            for value in selected:
                values.append(max(value + 1, 1024))
            return UpperLimitArgument(values^, False)

    return UpperLimitArgument(List[Int](), False)


def upper_limit_from_arguments(tokens: List[String], baseline: Int = -1) raises -> Int:
    var maximum = baseline
    for index in range(len(tokens)):
        var result = upper_limit_values_for_argument(tokens[index])
        for value_index in range(len(result.values)):
            maximum = max(maximum, result.values[value_index])
    return maximum


@fieldwise_init
struct AppliedUpperLimit(Copyable, Equatable, Writable):
    var maximum: Int
    var applied: Bool

    def __eq__(self, other: Self) -> Bool:
        return self.maximum == other.maximum and self.applied == other.applied

    def write_to[W: Writer](self, mut writer: W):
        writer.write("AppliedUpperLimit(maximum=", self.maximum, ", applied=", self.applied, ")")


def apply_upper_limit_argument(current: Int, token: String) raises -> AppliedUpperLimit:
    var result = upper_limit_values_for_argument(token)
    if not result.applies or len(result.values) == 0:
        return AppliedUpperLimit(current, False)
    var maximum = current
    for index in range(len(result.values)):
        maximum = max(maximum, result.values[index])
    return AppliedUpperLimit(maximum, True)


def parameter_runtime_effective_highest(
    tokens: List[String], baseline: Int
) raises -> Int:
    """Finite generated-table ceiling used before native CSV construction."""
    var highest = baseline
    for index in range(len(tokens)):
        var token = tokens[index]
        var raw: String
        if token.startswith("--vorhervonausschnitt="):
            raw = _value_after_prefix(token, "--vorhervonausschnitt=")
        elif token.startswith("--thisrangebefore="):
            raw = _value_after_prefix(token, "--thisrangebefore=")
        elif token.startswith("--range="):
            raw = _value_after_prefix(token, "--range=")
        elif token.startswith("--oberesmaximum="):
            highest = max(highest, atol(_value_after_prefix(token, "--oberesmaximum=")))
            continue
        elif token.startswith("--uppermaximum="):
            highest = max(highest, atol(_value_after_prefix(token, "--uppermaximum=")))
            continue
        elif token.startswith("--maximum="):
            highest = max(highest, atol(_value_after_prefix(token, "--maximum=")))
            continue
        else:
            continue

        var selected = range_to_numbers(raw, False, 0)
        for value in selected:
            highest = max(highest, value + 1)
    return highest



@fieldwise_init
struct ParameterRuntimeWidthResult(Copyable, Equatable):
    """Typed replacement for the mutating legacy width helper."""

    var handled: Bool
    var width: Int
    var widths: List[Int]
    var zero_locked: Bool


@fieldwise_init
struct ParameterRuntimeLegacySnapshot(Copyable, Equatable):
    var module_functions: Int
    var nested_helpers: Int
    var historical_globals: Int
    var dynamic_program_object: Bool
    var lazy_python_imports: Bool
    var diagnostics_are_values: Bool


def parameter_runtime_legacy_snapshot() -> ParameterRuntimeLegacySnapshot:
    return ParameterRuntimeLegacySnapshot(
        8,
        3,
        6,
        False,
        False,
        True,
    )


def produce_all_spalten_numbers(
    tokens: List[String],
    maximum_columns: Int,
    maximum_rows: Int,
) raises -> List[Int]:
    """Return the resolved physical columns without mutating a Program object."""
    var plan = build_parameter_runtime_plan(
        tokens, maximum_columns, maximum_rows
    )
    return plan.columns.copy()


def apply_width_parameter(
    command: String,
    negative_prefix: String = "",
    maximum_columns: Int = 746,
    maximum_rows: Int = 1024,
) raises -> ParameterRuntimeWidthResult:
    """Apply one historical width command through the shared typed parser."""
    if negative_prefix.byte_length() > 0:
        return ParameterRuntimeWidthResult(False, 21, List[Int](), False)
    var token = command if command.startswith("--") else "--" + command
    var tokens = ["-ausgabe", token]
    var plan = build_parameter_runtime_plan(
        tokens, maximum_columns, maximum_rows
    )
    var handled = (
        command.startswith("breite=")
        or command.startswith("width=")
        or command.startswith("breiten=")
        or command.startswith("widths=")
    )
    return ParameterRuntimeWidthResult(
        handled,
        plan.width,
        plan.widths.copy(),
        plan.width == 0,
    )


def parameters_to_commands_and_numbers(
    tokens: List[String],
    maximum_columns: Int,
    maximum_rows: Int,
) raises -> ParameterRuntimePlan:
    """Typed replacement for the six-value legacy mutation return contract."""
    return build_parameter_runtime_plan(tokens, maximum_columns, maximum_rows)


def parameter_runtime_owner_contract() -> List[String]:
    return [
        "python_owner=reta_architecture/parameter_runtime.py",
        "legacy_globals=explicit-values",
        "program_mutation=ParameterRuntimePlan",
        "column_resolution=produce_all_spalten_numbers",
        "width_resolution=apply_width_parameter",
        "parameter_parse=parameters_to_commands_and_numbers",
        "upper_limits=typed",
        "diagnostics=plan-values",
        "runtime_imports=static",
        "python_runtime=none",
    ]
