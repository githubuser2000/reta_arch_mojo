"""Native meta/concrete/theory/practice generated columns.

This is a direct port of the state machine in
``reta_architecture/meta_columns.py``.  Every selected bucket-11 coordinate
produces the historical pair of columns for ``n`` and ``1/n``.  The upper
branch follows integer multiplication chains while the lower branch follows
normalised rational coordinates and stops on the first repeated fraction.
"""

from std.collections import List
from .csv_table import CsvTable, read_semicolon_csv
from .resource_paths import csv_resource
from .generated_aliases import MetaColumnRequest


@fieldwise_init
struct MetaFraction(Copyable):
    var numerator: Int
    var denominator: Int


@fieldwise_init
struct MetaStep(Copyable):
    var upper_active: Bool
    var upper: Int
    var lower_active: Bool
    var lower: MetaFraction
    var lower_is_fraction: Bool
    var column: Int
    var depth: Int


@fieldwise_init
struct MetaColumnsResult(Copyable):
    var requests: List[MetaColumnRequest]
    var inversion_flags: List[Int]
    var columns: List[List[String]]


def _meta_english(language: String) -> Bool:
    return language == "english" or language == "en" or language == "englisch"


def _meta_abs(value: Int) -> Int:
    return -value if value < 0 else value


def _meta_gcd(first: Int, second: Int) -> Int:
    var a = _meta_abs(first)
    var b = _meta_abs(second)
    while b != 0:
        var remainder = a % b
        a = b
        b = remainder
    return 1 if a == 0 else a


def _meta_fraction(numerator: Int, denominator: Int) -> MetaFraction:
    if denominator == 0:
        return MetaFraction(0, 0)
    var n = numerator
    var d = denominator
    if d < 0:
        n = -n
        d = -d
    var divisor = _meta_gcd(n, d)
    return MetaFraction(n // divisor, d // divisor)


def _meta_fraction_equal(first: MetaFraction, second: MetaFraction) -> Bool:
    return (
        first.numerator == second.numerator
        and first.denominator == second.denominator
    )


def _meta_contains_fraction(
    values: List[MetaFraction], wanted: MetaFraction
) -> Bool:
    for index in range(len(values)):
        if _meta_fraction_equal(values[index], wanted):
            return True
    return False


def _meta_fraction_is_integer(value: MetaFraction) -> Bool:
    return value.denominator != 0 and value.numerator % value.denominator == 0


def _meta_fraction_is_one(value: MetaFraction) -> Bool:
    return value.denominator != 0 and value.numerator == value.denominator


def _meta_fraction_in_switch_range(value: MetaFraction) -> Bool:
    if value.denominator <= 0 or value.numerator <= 0:
        return False
    # Exact equivalent of ``0.01 < value < 100`` for the positive coordinates
    # produced by the legacy algorithm.
    return (
        value.numerator * 100 > value.denominator
        and value.numerator < value.denominator * 100
    )


def _meta_cell(table: CsvTable, row: Int, column: Int) -> String:
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _meta_fraction_cell(
    table: CsvTable, numerator: Int, denominator: Int
) -> String:
    var row = numerator - 1
    var column = denominator - 1
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _meta_repeat(text: String, amount: Int) -> String:
    var result = String()
    for _ in range(amount):
        result += text
    return result^


def _meta_topic_word(language: String) -> String:
    return "topic: " if _meta_english(language) else "Thema: "


def _meta_initial_prefix(
    metavariable: Int, side: Int, language: String
) -> String:
    var english = _meta_english(language)
    if metavariable == 2:
        if side == 0:
            return "meta-topic:" if english else "Meta-Thema: "
        return "sonrete things: " if english else "Konkretes: "
    if metavariable == 3:
        if side == 0:
            return "theory-topic: " if english else "Theorie-Thema: "
        return "practise: " if english else "Praxis: "
    if metavariable == 4:
        if side == 0:
            return "planning topic: " if english else "Planungs-Thema: "
        return "realization-topic: " if english else "Umsetzungs-Thema: "
    if metavariable == 5:
        if side == 0:
            return "occasion-topic: " if english else "Anlass-Thema: "
        return "effect-topic: " if english else "Wirkungs-Thema: "
    if metavariable == 6:
        if side == 0:
            return "power-geving: " if english else "Kraft-Gebung: "
        return "amplification-topic: " if english else "Verstärkungs-Thema: "
    if side == 0:
        return "rule: " if english else "Beherrschung: "
    return "direction-topic: " if english else "Richtung-Thema: "


def _meta_repeated_prefix(
    metavariable: Int, side: Int, language: String
) -> String:
    var english = _meta_english(language)
    if metavariable == 2:
        if side == 0:
            return "meta-" if english else "Meta-"
        return "concrete-" if english else "Konkret-"
    if metavariable == 3:
        if side == 0:
            return "theory-" if english else "Theorie-"
        return "practise-" if english else "Praxis-"
    if metavariable == 4:
        if side == 0:
            return "planing-" if english else "Planung-"
        return "realization-" if english else "Umsetzung-"
    if metavariable == 5:
        if side == 0:
            return "occasion-" if english else "Anlass-"
        return "effect-" if english else "wirkung-"
    if metavariable == 6:
        if side == 0:
            return "give-power-" if english else "Kraft-geben-"
        return "empower-" if english else "Verstärkung-"
    if side == 0:
        return "rule-" if english else "beherrschend-"
    return "direction-" if english else "Richtung-"


def _meta_prefix(
    metavariable: Int, side: Int, depth: Int, language: String
) -> String:
    if depth == 1:
        return _meta_initial_prefix(metavariable, side, language)
    return _meta_repeat(
        _meta_repeated_prefix(metavariable, side, language), depth
    )


def _meta_heading_base(
    metavariable: Int, side: Int, language: String
) -> String:
    var english = _meta_english(language)
    if side == 0:
        if metavariable == 2:
            return "meta" if english else "Meta"
        if metavariable == 3:
            return "theory" if english else "Theorie"
        if metavariable == 4:
            return "management" if english else "Management"
        if metavariable == 5:
            return "discrete" if english else "ganzheitlich"
        if metavariable == 6:
            return (
                "utilization, enterprise, business" if english else "Verwertung, Unternehmung, Geschäft"
            )
        return "rule, dominate" if english else "regieren, beherrschen"
    if metavariable == 2:
        return "concreteThings" if english else "Konkretes"
    if metavariable == 3:
        return "practice" if english else "Praxis"
    if metavariable == 4:
        return "changing" if english else "verändernd"
    if metavariable == 5:
        return "going beyond" if english else "darüber hinaus gehend"
    if metavariable == 6:
        return "valuable" if english else "wertvoll"
    return "direction" if english else "Richtung"


def _meta_heading(
    metavariable: Int, side: Int, inverse: Int, language: String
) -> String:
    var base = _meta_heading_base(metavariable, side, language)
    if inverse == 1:
        return (
            base
            + "for 1/n instead of n" if _meta_english(language) else base
            + " für 1/n statt n"
        )
    return base + (" for n" if _meta_english(language) else " für n")


def _meta_next_lower(
    current: MetaFraction,
    current_is_fraction: Bool,
    new_column: Int,
    inverse_target_column: Int,
    metavariable: Int,
) -> MetaFraction:
    var working = current.copy()
    if new_column == inverse_target_column and not current_is_fraction:
        working = _meta_fraction(working.denominator, working.numerator)
    if _meta_fraction_is_integer(working):
        # Fraction(metavariable, working)
        return _meta_fraction(
            metavariable * working.denominator, working.numerator
        )
    # Fraction(1, working) / Fraction(metavariable)
    return _meta_fraction(working.denominator, working.numerator * metavariable)


def _meta_steps(
    row: Int,
    table_row_count: Int,
    metavariable: Int,
    inverse: Int,
) -> List[MetaStep]:
    var first_column = 5 if inverse == 0 else 131
    var second_column = 131 if inverse == 0 else 5
    var inverse_target = first_column if inverse == 0 else second_column
    var current_column = first_column
    var upper_active = True
    var upper = row
    var lower_active = True
    var lower = MetaFraction(row, 1)
    var lower_is_fraction = False
    var seen = List[MetaFraction]()
    var steps = List[MetaStep]()
    var depth = 0

    while upper_active or lower_active:
        current_column = (
            first_column if current_column == second_column else second_column
        )
        if upper_active:
            var multiplied = upper * metavariable
            if multiplied < table_row_count:
                upper = multiplied
            else:
                upper_active = False
        if lower_active:
            if _meta_fraction_in_switch_range(lower):
                var candidate = _meta_next_lower(
                    lower,
                    lower_is_fraction,
                    current_column,
                    inverse_target,
                    metavariable,
                )
                if _meta_contains_fraction(seen, candidate):
                    lower_active = False
                else:
                    seen.append(candidate.copy())
                    lower = candidate.copy()
                    lower_is_fraction = True
            else:
                lower_active = False
        depth += 1
        steps.append(
            MetaStep(
                upper_active,
                upper,
                lower_active,
                lower.copy(),
                lower_is_fraction,
                current_column,
                depth,
            )
        )
    return steps^


def _meta_fraction_description(
    main_table: CsvTable,
    fraction_table: CsvTable,
    value: MetaFraction,
    output_mode: String,
) -> String:
    if (
        value.denominator == 0
        or value.numerator == 0
        or value.denominator > 100
        or value.numerator > 100
    ):
        return ""
    if value.numerator == 1:
        var base = _meta_cell(main_table, value.denominator, 131)
        if String(base.strip()).byte_length() <= 3:
            return ""
        var extra = _meta_cell(main_table, value.denominator, 201)
        var separator = String()
        if String(extra.strip()).byte_length() > 2:
            separator = "<br>" if output_mode == "html" else "; "
        return (
            base
            + " (1/"
            + String(value.denominator)
            + ")"
            + separator
            + extra
        )
    if value.denominator == 1:
        var base = _meta_cell(main_table, value.numerator, 5)
        if String(base.strip()).byte_length() <= 3:
            return ""
        var extra = _meta_cell(main_table, value.numerator, 198)
        var separator = String()
        if String(extra.strip()).byte_length() > 2:
            separator = "<br>" if output_mode == "html" else "; "
        return (
            base
            + " ("
            + String(value.numerator)
            + ")"
            + separator
            + extra
        )
    return _meta_fraction_cell(
        fraction_table, value.numerator, value.denominator
    )


def _meta_open_item(output_mode: String) -> String:
    if output_mode == "html":
        return "<li>"
    if output_mode == "bbcode":
        return "[*]"
    return ""


def _meta_close_item(output_mode: String) -> String:
    if output_mode == "html":
        return "</li>"
    if output_mode == "bbcode":
        return ""
    return " | "


def _meta_wrap(value: String, output_mode: String) -> String:
    if output_mode == "html":
        return "<ul>" + value + "</ul>"
    if output_mode == "bbcode":
        return "[list]" + value + "[/list]"
    return value


def _meta_upper_item(
    table: CsvTable,
    step: MetaStep,
    metavariable: Int,
    inverse: Int,
    topic: String,
    output_mode: String,
    language: String,
) -> String:
    if not step.upper_active:
        return ""
    var source = _meta_cell(table, step.upper, step.column)
    if String(source.strip()).byte_length() <= 3:
        return ""
    var first_column = 5 if inverse == 0 else 131
    var second_column = 131 if inverse == 0 else 5
    var inverse_target = first_column if inverse == 0 else second_column
    var reciprocal = step.column != inverse_target and not (
        step.lower_active and _meta_fraction_is_one(step.lower)
    )
    return (
        _meta_open_item(output_mode)
        + _meta_prefix(metavariable, 0, step.depth, language)
        + topic
        + source
        + " ("
        + ("1/" if reciprocal else "")
        + String(step.upper)
        + ")"
        + _meta_close_item(output_mode)
    )


def _meta_lower_item(
    table: CsvTable,
    fraction_table: CsvTable,
    step: MetaStep,
    metavariable: Int,
    inverse: Int,
    topic: String,
    output_mode: String,
    language: String,
) -> String:
    if not step.lower_active:
        return ""
    if not step.lower_is_fraction:
        var row = step.lower.numerator // step.lower.denominator
        var source = _meta_cell(table, row, step.column)
        if String(source.strip()).byte_length() <= 3:
            return ""
        var first_column = 5 if inverse == 0 else 131
        var second_column = 131 if inverse == 0 else 5
        var inverse_target = first_column if inverse == 0 else second_column
        var reciprocal = step.column != inverse_target and row != 1
        return (
            _meta_open_item(output_mode)
            + _meta_prefix(metavariable, 1, step.depth, language)
            + topic
            + source
            + " ("
            + ("1/" if reciprocal else "")
            + String(row)
            + ")"
            + _meta_close_item(output_mode)
        )
    var description = _meta_fraction_description(
        table, fraction_table, step.lower, output_mode
    )
    if String(description.strip()).byte_length() <= 3:
        return ""
    return (
        _meta_open_item(output_mode)
        + _meta_prefix(metavariable, 1, step.depth, language)
        + topic
        + description
        + "("
        + String(step.lower.numerator)
        + (
            "/" + String(step.lower.denominator) if step.lower.denominator
            > 1 else ""
        )
        + ")"
        + _meta_close_item(output_mode)
    )


def meta_column_value(
    table: CsvTable,
    fraction_table: CsvTable,
    row: Int,
    request: MetaColumnRequest,
    inverse: Int,
    output_mode: String,
    language: String,
) -> String:
    if row < 2:
        return ""
    var steps = _meta_steps(row, len(table.rows), request.metavariable, inverse)
    var result = String()
    var topic = String()
    # The final state is the terminal ``(None, None)`` record and is deliberately
    # excluded by the Python implementation's ``[:-1]`` slice.
    var usable = max(0, len(steps) - 1)
    for index in range(usable):
        var step = steps[index].copy()
        if request.side == 0:
            result += _meta_upper_item(
                table,
                step,
                request.metavariable,
                inverse,
                topic,
                output_mode,
                language,
            )
        else:
            result += _meta_lower_item(
                table,
                fraction_table,
                step,
                request.metavariable,
                inverse,
                topic,
                output_mode,
                language,
            )
        topic = _meta_topic_word(language)
    return _meta_wrap(result, output_mode)


def _meta_column(
    table: CsvTable,
    fraction_table: CsvTable,
    request: MetaColumnRequest,
    inverse: Int,
    last_row: Int,
    output_mode: String,
    language: String,
) -> List[String]:
    var result = List[String]()
    result.append(
        _meta_heading(request.metavariable, request.side, inverse, language)
    )
    if len(table.rows) > 1:
        result.append("")
    var stop = min(last_row, len(table.rows) - 1)
    for row in range(2, stop + 1):
        result.append(
            meta_column_value(
                table,
                fraction_table,
                row,
                request,
                inverse,
                output_mode,
                language,
            )
        )
    for _ in range(max(2, stop + 1), len(table.rows)):
        result.append("")
    return result^


def generate_meta_columns(
    table: CsvTable,
    requests: List[MetaColumnRequest],
    last_row: Int,
    output_mode: String,
    language: String,
    fraction_csv_path: String = "",
) raises -> MetaColumnsResult:
    var columns = List[List[String]]()
    var emitted_requests = List[MetaColumnRequest]()
    var inversions = List[Int]()
    if len(requests) == 0:
        return MetaColumnsResult(emitted_requests^, inversions^, columns^)
    var source_path = fraction_csv_path if fraction_csv_path.byte_length() > 0 else csv_resource("gebrochen-rational-universum.csv")
    var fraction_table = read_semicolon_csv(source_path)
    for request_index in range(len(requests)):
        var request = requests[request_index].copy()
        if (
            request.metavariable < 2
            or request.metavariable > 7
            or (request.side != 0 and request.side != 1)
        ):
            continue
        for inverse in range(2):
            emitted_requests.append(request.copy())
            inversions.append(inverse)
            columns.append(
                _meta_column(
                    table,
                    fraction_table,
                    request,
                    inverse,
                    last_row,
                    output_mode,
                    language,
                )
            )
    return MetaColumnsResult(emitted_requests^, inversions^, columns^)
