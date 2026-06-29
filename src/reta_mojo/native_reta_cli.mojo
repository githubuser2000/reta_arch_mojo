"""Native subset of the historical Reta command-line table pipeline."""

from std.collections import List
from std.collections.string import atol
from .input_semantics import parse_cli_tokens, CliParseResult, ParsedCliOption
from .runtime_aliases import load_runtime_alias_catalog, resolve_runtime_columns
from .csv_table import read_semicolon_csv, select_zero_based_columns
from .row_filtering import RowFilterConfig
from .row_ranges import range_to_numbers
from .table_preparation import select_display_lines, select_display_table
from .table_rendering import (
    add_numbering_columns,
    render_table_with_native_context,
)
from .generated_table_columns import apply_native_generated_columns
from .kombi_join_columns import (
    KombiColumnRequest,
    append_unique_kombi_request,
    apply_kombi_join_columns,
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
    resolve_generated_aliases,
    sort_modal_concepts,
)


@fieldwise_init
struct NativeRetaPlan(Copyable):
    var language: String
    var output_mode: String
    var width: Int
    var highest: Int
    var number_rows: Bool
    var include_headings: Bool
    var color_rows: Bool
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


def build_native_reta_plan(tokens: List[String], maximum_columns: Int, maximum_rows: Int) raises -> NativeRetaPlan:
    var parsed = parse_cli_tokens(tokens)
    var aliases = load_runtime_alias_catalog("assets/parameter_aliases.tsv")
    var generated_aliases = load_generated_alias_catalog("assets/generated_aliases.tsv")
    var kombi_aliases = load_kombi_alias_catalog("assets/kombi_aliases.tsv")
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
    var highest = maximum_rows
    var number_rows = True
    var include_headings = True
    var color_rows = True
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
                    width = atol(option.values[0].text)
            elif option.name == "keinenummerierung" or option.name == "nonumbering":
                number_rows = False
            elif option.name == "keineueberschriften" or option.name == "noheadings":
                include_headings = False
            elif option.name == "nocolor":
                color_rows = False
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
            if option.name == "breite" or option.name == "width":
                if len(option.values) > 0:
                    width = atol(option.values[0].text)
                continue
            if option.name == "keinenummerierung" or option.name == "nonumbering":
                number_rows = False
                continue
            for value_index in range(len(option.values)):
                var value = option.values[value_index].copy()
                var resolved = resolve_runtime_columns(aliases, option.name, value.text)
                var generated_resolved = resolve_generated_aliases(
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
    return NativeRetaPlan(
        language^,
        output_mode^,
        width,
        highest,
        number_rows,
        include_headings,
        color_rows,
        positive_rows^,
        negative_rows^,
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


def _has_explicit_upper_maximum(tokens: List[String]) -> Bool:
    for index in range(len(tokens)):
        var token = tokens[index]
        if (
            token.startswith("--oberesmaximum=")
            or token.startswith("--uppermaximum=")
            or token.startswith("--maximum=")
        ):
            return True
    return False


def run_native_reta(tokens: List[String], csv_path: String) raises -> String:
    var table = read_semicolon_csv(csv_path)
    var maximum_rows = len(table.rows) - 1
    var plan = build_native_reta_plan(tokens, table.maximum_columns, maximum_rows)
    var rows_were_set = len(plan.positive_rows) > 0 or len(plan.negative_rows) > 0
    # Resolve displayed source rows before generating derived columns.  The
    # Python implementation uses its last displayed line as the annotation
    # boundary, while relation maps may still be built farther ahead.
    # The Python runtime keeps two historical row ceilings: 1024 for the
    # generated table and 163 for ordinary main-table rows.  Supplying an
    # explicit upper maximum assigns that value to both ceilings.
    var highest_multiple = min(plan.highest, 163)
    if _has_explicit_upper_maximum(tokens):
        highest_multiple = plan.highest
    var selection = select_display_lines(
        RowFilterConfig(plan.highest, highest_multiple, rows_were_set),
        table,
        plan.positive_rows,
        plan.negative_rows,
    )
    var display_last_row = 0
    for row_index in range(len(selection.rows)):
        display_last_row = max(display_last_row, selection.rows[row_index])
    var generated = apply_native_generated_columns(
        table,
        plan.columns,
        plan.modal_concepts,
        plan.meta_requests,
        plan.fraction_requests,
        plan.generated_commands,
        plan.language,
        plan.output_mode,
        display_last_row,
    )
    table = generated.table.copy()
    var output_columns = generated.output_columns.copy()
    var kombi = apply_kombi_join_columns(
        table, plan.kombi_requests, display_last_row
    )
    table = kombi.table.copy()
    for kombi_index in range(len(kombi.output_columns)):
        output_columns.append(kombi.output_columns[kombi_index])
    if plan.explicit_order_requested:
        var ordered_output = List[Int]()
        for position_index in range(len(plan.explicit_positions)):
            var position = plan.explicit_positions[position_index]
            if position >= 0 and position < len(output_columns):
                ordered_output.append(output_columns[position])
        output_columns = ordered_output^
        if len(output_columns) == 0:
            return ""
    var selected_rows = selection.rows.copy()
    var selected = select_display_table(table, selection)
    selected = select_zero_based_columns(selected, output_columns)
    var nonempty = _drop_empty_selected_rows(selected, selected_rows)
    selected = nonempty[0].copy()
    selected_rows = nonempty[1].copy()

    # Width calculation in the Python renderer still sees the heading even
    # when --keineueberschriften suppresses it.  Preserve that separate width
    # reference instead of changing pagination as a side effect of hiding row 0.
    var width_reference = selected.copy()
    var width_reference_rows = selected_rows.copy()
    if plan.number_rows:
        width_reference = add_numbering_columns(
            width_reference,
            width_reference_rows,
            plan.output_mode != "shell",
        )
        selected = width_reference.copy()
    if (
        not plan.include_headings
        and len(selected_rows) > 0
        and selected_rows[0] == 0
    ):
        selected_rows = List(selected_rows[1:])
        selected.rows = List(selected.rows[1:])
    return render_table_with_native_context(
        selected,
        width_reference,
        selected_rows,
        output_columns,
        plan.language,
        plan.output_mode,
        plan.width,
        plan.number_rows,
        plan.color_rows,
    )
