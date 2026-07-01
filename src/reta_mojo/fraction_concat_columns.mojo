"""Fraction-indexed CSV presheaf gluing for native Reta.

This ports the four ``readConcatCsv`` paths for universe, galaxy, emotion and
structure size.  Every selected denominator contributes the historical pair of
columns ``n/d`` and ``d/n``.  Integer and unit-fraction coordinates are resolved
through the main table; proper fractions are resolved through the corresponding
fraction CSV matrix.
"""

from std.collections import List
from .csv_table import CsvTable, read_semicolon_csv
from .resource_paths import csv_resource
from .generated_aliases import FractionColumnRequest


@fieldwise_init
struct FractionCoordinate(Copyable):
    var numerator: Int
    var denominator: Int


@fieldwise_init
struct FractionConcatColumns(Copyable):
    var requests: List[FractionColumnRequest]
    var reciprocal_flags: List[Int]
    var columns: List[List[String]]


def _abs_fraction(value: Int) -> Int:
    return -value if value < 0 else value


def _gcd_fraction(first: Int, second: Int) -> Int:
    var a = _abs_fraction(first)
    var b = _abs_fraction(second)
    while b != 0:
        var remainder = a % b
        a = b
        b = remainder
    return 1 if a == 0 else a


def _coordinate(numerator: Int, denominator: Int) -> FractionCoordinate:
    if denominator == 0:
        return FractionCoordinate(0, 0)
    var n = numerator
    var d = denominator
    if d < 0:
        n = -n
        d = -d
    var divisor = _gcd_fraction(n, d)
    return FractionCoordinate(n // divisor, d // divisor)


def _cell_fraction(table: CsvTable, row: Int, column: Int) -> String:
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _domain_rank(domain: String) -> Int:
    # Historical table-generation order: galaxy, universe, emotion, size.
    if domain == "galaxy":
        return 0
    if domain == "universe":
        return 1
    if domain == "emotion":
        return 2
    if domain == "size":
        return 3
    return 99


def _sort_fraction_requests(mut values: List[FractionColumnRequest]):
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and (
            _domain_rank(values[position].domain) > _domain_rank(key.domain)
            or (
                _domain_rank(values[position].domain) == _domain_rank(key.domain)
                and values[position].denominator > key.denominator
            )
        ):
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key.copy()


def _domain_source_path(domain: String) -> String:
    if domain == "galaxy":
        return csv_resource("gebrochen-rational-galaxie.csv")
    if domain == "emotion":
        return csv_resource("gebrochen-rational-emotionen.csv")
    if domain == "size":
        return csv_resource("gebrochen-rational-strukturgroesse.csv")
    return csv_resource("gebrochen-rational-universum.csv")


def _fraction_request_limit(domain: String, reciprocal: Int) raises -> Int:
    """Return the largest denominator physically present in the source CSV.

    Python attaches the matrix as-is for ``n/d`` and transposes it for ``d/n``.
    The selectable heading count is therefore the first-row width in the direct
    direction and the row count in the reciprocal direction.  Requests beyond
    that shape are silently ignored; emitting synthetic empty headings was the
    source of 56 spurious ``--alles`` columns.
    """
    var source = read_semicolon_csv(_domain_source_path(domain))
    if reciprocal != 0:
        return len(source.rows)
    if len(source.rows) == 0:
        return 0
    return len(source.rows[0])


def _domain_first_column(domain: String) -> Int:
    if domain == "galaxy":
        return 10
    if domain == "emotion":
        return 243
    if domain == "size":
        return 4
    return 5


def _domain_inverse_column(domain: String) -> Int:
    if domain == "galaxy":
        return 42
    if domain == "emotion":
        return 284
    if domain == "size":
        return 197
    return 131


def _domain_label(domain: String, language: String) -> String:
    var english = language == "english" or language == "en" or language == "englisch"
    if domain == "galaxy":
        return "galaxy" if english else "Galaxie"
    if domain == "emotion":
        return "emotion" if english else "Emotion"
    if domain == "size":
        return "structuresize" if english else "Strukturgroesse"
    return "universe" if english else "Universum"


def _fraction_matrix_cell(
    fraction_table: CsvTable, value: FractionCoordinate
) -> String:
    var row = value.numerator - 1
    var column = value.denominator - 1
    if row < 0 or row >= len(fraction_table.rows):
        return ""
    if column < 0 or column >= len(fraction_table.rows[row]):
        return ""
    return fraction_table.rows[row][column]


def fraction_domain_value(
    main_table: CsvTable,
    fraction_table: CsvTable,
    value: FractionCoordinate,
    domain: String,
    output_mode: String,
) -> String:
    if (
        value.denominator == 0
        or value.numerator == 0
        or value.denominator > 100
        or value.numerator > 100
    ):
        return ""
    var first_column = _domain_first_column(domain)
    var inverse_column = _domain_inverse_column(domain)
    var is_universe = domain == "universe"
    if value.numerator == 1:
        var base = _cell_fraction(main_table, value.denominator, inverse_column)
        if String(base.strip()).byte_length() <= 3:
            return ""
        if not is_universe:
            return base
        var extra = _cell_fraction(main_table, value.denominator, 201)
        var separator = String()
        if extra.byte_length() > 2:
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
        var base = _cell_fraction(main_table, value.numerator, first_column)
        if String(base.strip()).byte_length() <= 3:
            return ""
        if not is_universe:
            return base
        var extra = _cell_fraction(main_table, value.numerator, 198)
        var separator = String()
        if extra.byte_length() > 2:
            separator = "<br>" if output_mode == "html" else "; "
        return (
            base
            + " ("
            + String(value.numerator)
            + ")"
            + separator
            + extra
        )
    return _fraction_matrix_cell(fraction_table, value)


def _fraction_column(
    main_table: CsvTable,
    request: FractionColumnRequest,
    reciprocal: Int,
    last_row: Int,
    output_mode: String,
    language: String,
) raises -> List[String]:
    var source = read_semicolon_csv(_domain_source_path(request.domain))
    var result = List[String]()
    var denominator = request.denominator
    var label = _domain_label(request.domain, language)
    if reciprocal == 0:
        result.append("n/" + String(denominator) + " " + label)
    else:
        result.append(String(denominator) + "/n " + label)
    var stop = min(last_row, len(main_table.rows) - 1)
    for row in range(1, len(main_table.rows)):
        if row > stop:
            result.append("")
            continue
        var coordinate = (
            _coordinate(row, denominator)
            if reciprocal == 0
            else _coordinate(denominator, row)
        )
        result.append(
            fraction_domain_value(
                main_table, source, coordinate, request.domain, output_mode
            )
        )
    return result^


def generate_fraction_concat_columns(
    main_table: CsvTable,
    requests: List[FractionColumnRequest],
    last_row: Int,
    output_mode: String,
    language: String,
) raises -> FractionConcatColumns:
    var ordered = requests.copy()
    _sort_fraction_requests(ordered)
    var emitted = List[FractionColumnRequest]()
    var reciprocal_flags = List[Int]()
    var columns = List[List[String]]()
    # readConcatCsv is called twice per domain.  Therefore all n/d columns for
    # one domain precede all d/n columns for that domain.
    for domain_rank in range(4):
        for reciprocal in range(2):
            for index in range(len(ordered)):
                var request = ordered[index].copy()
                if _domain_rank(request.domain) != domain_rank:
                    continue
                if request.denominator > _fraction_request_limit(
                    request.domain, reciprocal
                ):
                    continue
                emitted.append(request.copy())
                reciprocal_flags.append(reciprocal)
                columns.append(
                    _fraction_column(
                        main_table,
                        request,
                        reciprocal,
                        last_row,
                        output_mode,
                        language,
                    )
                )
    return FractionConcatColumns(emitted^, reciprocal_flags^, columns^)
