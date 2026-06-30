"""Native subset of the historical Reta command-line table pipeline."""

from std.collections import List
from std.collections.string import atol
from .input_semantics import parse_cli_tokens, CliParseResult, ParsedCliOption
from .output_modes import canonicalize_output_mode
from .runtime_aliases import load_runtime_alias_catalog, resolve_runtime_columns
from .csv_table import CsvTable, read_semicolon_csv, select_zero_based_columns
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
    return NativeRetaPlan(
        language^,
        output_mode^,
        width,
        highest,
        number_rows,
        include_headings,
        color_rows,
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



def _native_cli_section_supported(section: String) -> Bool:
    return (
        _section_is_lines(section)
        or _section_is(section, "spalten", "columns")
        or _section_is(section, "kombination", "combination")
        or _section_is(section, "ausgabe", "output")
        or section.startswith("language=")
        or section.startswith("sprache=")
    )


def _native_row_option_supported(name: String) -> Bool:
    return (
        name == "alles"
        or name == "all"
        or name == "vorhervonausschnittteiler"
        or name == "thisrangebeforedividers"
        or name == "divisors"
        or name == "invertieren"
        or name == "invert"
        or name == "oberesmaximum"
        or name == "uppermaximum"
        or name == "maximum"
        or name == "vorhervonausschnitt"
        or name == "thisrangebefore"
        or name == "range"
        or name == "vorhervonausschnittvielfache"
        or name == "multiplerange"
        or name == "zaehlung"
        or name == "zählung"
        or name == "ranges"
        or name == "counting"
        or name == "nachtraeglichneuabzaehlung"
        or name == "retrospectiverecount"
        or name == "position"
        or name == "nachtraeglichneuabzaehlungvielfache"
        or name == "retrospectiverecountmultiples"
        or name == "multipleposition"
        or name == "potenzenvonzahlen"
        or name == "potenciesofnumbers"
        or name == "powers"
        or name == "primzahlvielfache"
        or name == "primemultiples"
        or name == "vielfachevonzahlen"
        or name == "multiplesofnumbers"
        or name == "multiples"
        or name == "zeit"
        or name == "time"
        or name == "typ"
        or name == "type"
        or name == "primzahlen"
        or name == "primenumbers"
        or name == "primes"
    )


def _native_output_option_supported(name: String) -> Bool:
    return (
        name == "art"
        or name == "type"
        or name == "breite"
        or name == "width"
        or name == "keinenummerierung"
        or name == "nonumbering"
        or name == "keineueberschriften"
        or name == "noheadings"
        or name == "nocolor"
        or name == "spaltenreihenfolgeundnurdiese"
        or name == "columnorderandonlythese"
        or name == "columnorder"
    )


def native_reta_tokens_supported(tokens: List[String], csv_path: String) raises -> Bool:
    """Conservatively prove that a raw prompt ``reta`` call is Mojo-owned.

    The normal CLI parser intentionally tolerates not-yet-owned options.  The
    prompt fast path must be stricter: every supplied section and option has to
    be understood before Python may be skipped.
    """
    var parsed = parse_cli_tokens(tokens)
    if len(parsed.diagnostics) > 0 or len(parsed.positional) > 0:
        return False
    for section_index in range(len(parsed.sections)):
        if not _native_cli_section_supported(parsed.sections[section_index]):
            return False
    for option_index in range(len(parsed.options)):
        var option = parsed.options[option_index].copy()
        if _section_is_lines(option.section):
            if not _native_row_option_supported(option.name):
                return False
            var row_flag = (
                option.name == "alles"
                or option.name == "all"
                or option.name == "vorhervonausschnittteiler"
                or option.name == "thisrangebeforedividers"
                or option.name == "divisors"
                or option.name == "invertieren"
                or option.name == "invert"
            )
            if not row_flag and len(option.values) == 0:
                return False
        elif _section_is(option.section, "ausgabe", "output"):
            if not _native_output_option_supported(option.name):
                return False
            var output_flag = (
                option.name == "keinenummerierung"
                or option.name == "nonumbering"
                or option.name == "keineueberschriften"
                or option.name == "noheadings"
                or option.name == "nocolor"
            )
            if not output_flag and len(option.values) == 0:
                return False
        elif _section_is(option.section, "spalten", "columns"):
            var column_flag = (
                option.name == "keinenummerierung"
                or option.name == "nonumbering"
            )
            var column_value_option = (
                option.name == "breite" or option.name == "width"
            )
            if column_value_option and len(option.values) == 0:
                return False
            if not column_flag and not column_value_option and (
                not option.has_equals or len(option.values) == 0
            ):
                return False
            # All value-bearing column pairs are validated by the owning
            # runtime/generated alias catalogs in build_native_reta_plan below.
        elif _section_is(option.section, "kombination", "combination"):
            if not option.has_equals or len(option.values) == 0:
                return False
        else:
            return False

    var table = read_semicolon_csv(csv_path)
    var effective_highest = effective_runtime_highest(
        tokens, len(table.rows) - 1
    )
    var plan = build_native_reta_plan(
        tokens, table.maximum_columns, effective_highest
    )
    if len(plan.diagnostics) > 0:
        return False
    var mode = canonicalize_output_mode(plan.output_mode)
    if mode.byte_length() == 0:
        return False
    # Positive-width shell, HTML and BBCode rendering is owned by the native
    # renderer and covered by byte fixtures; no prompt-only Python gate remains.
    return True


def _selector_value(token: String, prefix: String) -> String:
    return String(StringSlice(token)[byte=prefix.byte_length():])


def effective_runtime_highest(
    tokens: List[String], baseline: Int
) raises -> Int:
    """Mirror parameter_runtime.upper_limit_from_arguments for native runs.

    Absolute selectors are expanded before table construction.  Embedded
    ``vN`` ranges use the historical finite 1028 generator and then raise the
    runtime ceiling to ``max(selected) + 1``.  This is why ``v2-4`` can display
    rows 1028 and 1029 even though the physical CSV ends at row 1024.
    """
    var highest = baseline
    for index in range(len(tokens)):
        var token = tokens[index]
        var raw: String
        if token.startswith("--vorhervonausschnitt="):
            raw = _selector_value(token, "--vorhervonausschnitt=")
        elif token.startswith("--thisrangebefore="):
            raw = _selector_value(token, "--thisrangebefore=")
        elif token.startswith("--range="):
            raw = _selector_value(token, "--range=")
        elif token.startswith("--oberesmaximum="):
            highest = max(
                highest,
                atol(_selector_value(token, "--oberesmaximum=")),
            )
            continue
        elif token.startswith("--uppermaximum="):
            highest = max(
                highest,
                atol(_selector_value(token, "--uppermaximum=")),
            )
            continue
        elif token.startswith("--maximum="):
            highest = max(
                highest,
                atol(_selector_value(token, "--maximum=")),
            )
            continue
        else:
            continue

        var selected = range_to_numbers(raw, False, 0)
        for value in selected:
            highest = max(highest, value + 1)
    return highest


def _extend_table_to_row(table: CsvTable, highest: Int) -> CsvTable:
    if highest < len(table.rows):
        return table.copy()
    var rows = table.rows.copy()
    while len(rows) <= highest:
        var row = List[String]()
        for _ in range(table.maximum_columns):
            row.append("")
        rows.append(row^)
    return CsvTable(rows^, table.maximum_columns)


def _requested_upper_maximum(tokens: List[String]) raises -> Int:
    for index in range(len(tokens)):
        var token = tokens[index]
        if token.startswith("--oberesmaximum="):
            return atol(String(StringSlice(token)[byte=16:]))
        if token.startswith("--uppermaximum="):
            return atol(String(StringSlice(token)[byte=15:]))
        if token.startswith("--maximum="):
            return atol(String(StringSlice(token)[byte=10:]))
    return 0


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


def has_absolute_multiple_row_selector(
    positive_rows: List[String], negative_rows: List[String]
) -> Bool:
    """Detect legacy ``vN`` components inside an absolute row selector.

    ``--vorhervonausschnitt=12,v12`` is not the same as the dedicated
    ``--vielfachevonzahlen=12`` filter.  The embedded ``vN`` form expands over
    the full generated-table ceiling (normally 1024), while the dedicated row
    filter keeps the historical short main-table ceiling.  Both positive and
    negative conditions matter for all-rows-minus-multiples selectors.
    """
    for index in range(len(positive_rows)):
        if positive_rows[index].startswith("_a_v"):
            return True
    for index in range(len(negative_rows)):
        if negative_rows[index].startswith("_a_v"):
            return True
    return False


def run_native_reta(tokens: List[String], csv_path: String) raises -> String:
    var table = read_semicolon_csv(csv_path)
    var maximum_rows = effective_runtime_highest(
        tokens, len(table.rows) - 1
    )
    var plan = build_native_reta_plan(
        tokens, table.maximum_columns, maximum_rows
    )
    table = _extend_table_to_row(table, plan.highest)
    var rows_were_set = len(plan.positive_rows) > 0 or len(plan.negative_rows) > 0
    # Resolve displayed source rows before generating derived columns.  The
    # Python implementation uses its last displayed line as the annotation
    # boundary, while relation maps may still be built farther ahead.
    # The Python runtime keeps two historical row ceilings: 1024 for the
    # generated table and 163 for ordinary main-table rows.  Supplying an
    # explicit upper maximum assigns that value to both ceilings.
    var highest_multiple = min(plan.highest, 163)
    if (
        _has_explicit_upper_maximum(tokens)
        or has_absolute_multiple_row_selector(
            plan.positive_rows, plan.negative_rows
        )
    ):
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
    # A row selector whose positive and negative predicates cancel is the
    # legacy all-rows path.  Only that path retains the requested row ceiling
    # for shell-numbering width; finite selections size from displayed rows.
    var numbering_highest = 0
    if (
        plan.include_headings
        and plan.explicit_order_requested
        and not rows_were_set
    ):
        numbering_highest = _requested_upper_maximum(tokens)
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
        numbering_highest,
    )
