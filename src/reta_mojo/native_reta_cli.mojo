"""Native subset of the historical Reta command-line table pipeline."""

from std.collections import List
from std.collections.string import atol
from .input_semantics import parse_cli_tokens, CliParseResult, ParsedCliOption
from .runtime_aliases import load_runtime_alias_catalog, resolve_runtime_columns
from .csv_table import read_semicolon_csv, select_zero_based_columns
from .row_filtering import RowFilterConfig
from .table_preparation import select_display_lines, select_display_table
from .table_rendering import add_numbering_columns, render_table


@fieldwise_init
struct NativeRetaPlan(Copyable):
    var language: String
    var output_mode: String
    var width: Int
    var highest: Int
    var number_rows: Bool
    var include_headings: Bool
    var positive_rows: List[String]
    var negative_rows: List[String]
    var columns: List[Int]
    var diagnostics: List[String]


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
    var language = String("german")
    var output_mode = String("shell")
    var width = 21
    var highest = maximum_rows
    var number_rows = True
    var include_headings = True
    var positive_rows = List[String]()
    var negative_rows = List[String]()
    var positive_columns = List[Int]()
    var negative_columns = List[Int]()
    var explicit_order = List[Int]()
    var diagnostics = parsed.diagnostics.copy()

    for option_index in range(len(parsed.options)):
        var option = parsed.options[option_index].copy()
        if _section_is_lines(option.section):
            _process_row_option(option, positive_rows, negative_rows, highest)
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
            elif option.name == "spaltenreihenfolgeundnurdiese" or option.name == "columnorderandonlythese" or option.name == "columnorder":
                for value_index in range(len(option.values)):
                    var raw = option.values[value_index].text
                    var column = atol(raw)
                    if column > 0 and column <= maximum_columns:
                        explicit_order.append(column - 1)
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
                if len(resolved) == 0:
                    diagnostics.append("unbekanntes Spaltenpaar: " + option.name + "/" + value.text)
                    continue
                for column_index in range(len(resolved)):
                    if value.negative:
                        _append_unique_int(negative_columns, resolved[column_index])
                    else:
                        _append_unique_int(positive_columns, resolved[column_index])

    # Top-level language tokens are represented as pseudo-sections by the
    # historical single-dash surface form. Inspect them independently.
    for token_index in range(len(tokens)):
        var token = tokens[token_index]
        if token.startswith("-language="):
            language = String(StringSlice(token)[byte=10:])
        elif token.startswith("-sprache="):
            language = String(StringSlice(token)[byte=9:])

    var has_explicit_order = len(explicit_order) > 0
    var columns: List[Int]
    if has_explicit_order:
        columns = explicit_order^
    else:
        columns = positive_columns^
    if len(columns) == 0:
        columns = [0]
    columns = _remove_ints(columns, negative_columns)
    if not has_explicit_order:
        _sort_ints(columns)
    if highest < 1 or highest > maximum_rows:
        highest = maximum_rows
    return NativeRetaPlan(
        language^,
        output_mode^,
        width,
        highest,
        number_rows,
        include_headings,
        positive_rows^,
        negative_rows^,
        columns^,
        diagnostics^,
    )


def run_native_reta(tokens: List[String], csv_path: String) raises -> String:
    var table = read_semicolon_csv(csv_path)
    var maximum_rows = len(table.rows) - 1
    var plan = build_native_reta_plan(tokens, table.maximum_columns, maximum_rows)
    var rows_were_set = len(plan.positive_rows) > 0 or len(plan.negative_rows) > 0
    var selection = select_display_lines(
        RowFilterConfig(plan.highest, min(plan.highest, 114), rows_were_set),
        table,
        plan.positive_rows,
        plan.negative_rows,
    )
    var selected_rows = selection.rows.copy()
    if not plan.include_headings and len(selected_rows) > 0 and selected_rows[0] == 0:
        selected_rows = List(selected_rows[1:])
    var selected = select_display_table(table, selection)
    if not plan.include_headings and len(selected.rows) > 0:
        selected.rows = List(selected.rows[1:])
    selected = select_zero_based_columns(selected, plan.columns)
    if plan.number_rows:
        selected = add_numbering_columns(selected, selected_rows)
    return render_table(selected, selected_rows, plan.output_mode)
