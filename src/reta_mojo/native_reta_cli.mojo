"""Native subset of the historical Reta command-line table pipeline."""

from std.collections import List
from std.collections.string import ord
from .input_semantics import parse_cli_tokens
from .output_modes import canonicalize_output_mode
from .csv_table import CsvTable, read_semicolon_csv, select_zero_based_columns
from .row_filtering import RowFilterConfig
from .row_ranges import parse_explicit_int_set
from .table_preparation import select_display_lines, select_display_table
from .table_rendering import (
    add_numbering_columns,
    render_table_with_native_context,
)
from .generated_table_columns import apply_native_generated_columns
from .kombi_join_columns import apply_kombi_join_columns

from .parameter_runtime import (
    ParameterRuntimePlan,
    build_parameter_runtime_plan,
    parameter_runtime_effective_highest,
)

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

def build_native_reta_plan(
    tokens: List[String], maximum_columns: Int, maximum_rows: Int
) raises -> ParameterRuntimePlan:
    return build_parameter_runtime_plan(tokens, maximum_columns, maximum_rows)


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


def _looks_like_collection_expression(text: String) -> Bool:
    var stripped = String(text.strip())
    if stripped.byte_length() < 2:
        return False
    var first = ord(stripped[byte=0])
    return first == 40 or first == 91 or first == 123


def _safe_collection_expression_supported(text: String) raises -> Bool:
    if not _looks_like_collection_expression(text):
        return True
    return parse_explicit_int_set(text).valid


def _row_option_accepts_collection_expression(name: String) -> Bool:
    return (
        name == "vorhervonausschnitt"
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
    )


def _native_output_option_supported(name: String) -> Bool:
    return (
        name == "art"
        or name == "type"
        or name == "breite"
        or name == "width"
        or name == "breiten"
        or name == "widths"
        or name == "keinenummerierung"
        or name == "nonumbering"
        or name == "keineueberschriften"
        or name == "noheadings"
        or name == "nocolor"
        or name == "justtext"
        or name == "keineleereninhalte"
        or name == "noblankcontents"
        or name == "onetable"
        or name == "endlessscreen"
        or name == "endless"
        or name == "dontwrap"
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
    # A main section or language selector without any subordinate option does
    # not request a table.  The compatibility launcher handles the exact
    # language-only no-output surface before this predicate; all other
    # optionless vectors must remain on the reference path instead of silently
    # rendering the complete default table.
    if len(parsed.options) == 0:
        return False
    for section_index in range(len(parsed.sections)):
        if not _native_cli_section_supported(parsed.sections[section_index]):
            return False
    for option_index in range(len(parsed.options)):
        var option = parsed.options[option_index].copy()
        if _section_is_lines(option.section):
            if not _native_row_option_supported(option.name):
                return False
            for value_index in range(len(option.values)):
                var row_value = option.values[value_index].text
                if _looks_like_collection_expression(row_value) and (
                    not _row_option_accepts_collection_expression(option.name)
                    or not _safe_collection_expression_supported(row_value)
                ):
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
            if (
                option.name == "spaltenreihenfolgeundnurdiese"
                or option.name == "columnorderandonlythese"
                or option.name == "columnorder"
            ):
                for value_index in range(len(option.values)):
                    if not _safe_collection_expression_supported(
                        option.values[value_index].text
                    ):
                        return False
            var output_flag = (
                option.name == "keinenummerierung"
                or option.name == "nonumbering"
                or option.name == "keineueberschriften"
                or option.name == "noheadings"
                or option.name == "nocolor"
                or option.name == "justtext"
                or option.name == "keineleereninhalte"
                or option.name == "noblankcontents"
                or option.name == "onetable"
                or option.name == "endlessscreen"
                or option.name == "endless"
                or option.name == "dontwrap"
            )
            if not output_flag and len(option.values) == 0:
                return False
        elif _section_is(option.section, "spalten", "columns"):
            var column_flag = (
                option.name == "keinenummerierung"
                or option.name == "nonumbering"
                or option.name == "alles"
                or option.name == "all"
            )
            var column_value_option = (
                option.name == "breite"
                or option.name == "width"
                or option.name == "breiten"
                or option.name == "widths"
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
    # Per-column widths are owned for all renderers.  CSV, Markdown and Emacs
    # force the global width to zero but still expand logical rows according to
    # explicitly supplied data-column widths.
    # Explicit zero entries are owned as true no-wrap columns.  The renderer
    # reproduces both the historical shell pagination truncation and the raw
    # whitespace/exact-fit distinction of HTML and BBCode preparation.
    # ``--nocolor`` is also owned for HTML/BBCode: the Python reference bypasses
    # Rich in that mode, so the native renderer selects its exact raw multiline
    # serializer instead of the whitespace-normalized colored stream.
    # Shell, HTML and BBCode now share the historical one-table ownership
    # contract: the four aliases disable horizontal page splitting while
    # preserving each format's wrapping and metadata rules.
    return True


def _selector_value(token: String, prefix: String) -> String:
    return String(StringSlice(token)[byte=prefix.byte_length():])


def effective_runtime_highest(
    tokens: List[String], baseline: Int
) raises -> Int:
    return parameter_runtime_effective_highest(tokens, baseline)


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
        table, plan.kombi_requests, display_last_row, plan.output_mode
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
        # Preserve raw source whitespace for the preparation-width contract.
        # HTML/BBCode serialize normalized cells, but their historical wrapping
        # decision is made before that normalization (notably for exact-fit
        # double-space fragments such as ``(14)  (n)``).
        width_reference = add_numbering_columns(
            width_reference,
            width_reference_rows,
            False,
        )
        selected = add_numbering_columns(
            selected,
            selected_rows,
            plan.output_mode != "shell",
        )
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
        plan.one_table,
        plan.no_blank_contents,
        plan.widths,
    )
