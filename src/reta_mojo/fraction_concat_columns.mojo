"""Fraction-indexed CSV presheaf gluing for native Reta.

This ports the four ``readConcatCsv`` paths for universe, galaxy, emotion and
structure size.  Every selected denominator contributes the historical pair of
columns ``n/d`` and ``d/n``.  Integer and unit-fraction coordinates are resolved
through the main table; proper fractions are resolved through the corresponding
fraction CSV matrix.
"""

from std.algorithm import parallelize
from std.collections import List
from .csv_table import CsvTable, empty_csv_table, read_semicolon_csv
from .parallel_execution import ParallelExecutionConfig
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


def _fraction_domain_name(rank: Int) -> String:
    if rank == 0:
        return "galaxy"
    if rank == 1:
        return "universe"
    if rank == 2:
        return "emotion"
    return "size"


def _load_fraction_source_by_rank(rank: Int) raises -> CsvTable:
    return read_semicolon_csv(
        _domain_source_path(_fraction_domain_name(rank))
    )


def _fraction_request_limit_from_source(
    source: CsvTable, reciprocal: Int
) -> Int:
    if reciprocal != 0:
        return len(source.rows)
    if len(source.rows) == 0:
        return 0
    return len(source.rows[0])


def _fraction_column_from_source(
    main_table: CsvTable,
    source: CsvTable,
    request: FractionColumnRequest,
    reciprocal: Int,
    last_row: Int,
    output_mode: String,
    language: String,
) -> List[String]:
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


def _fraction_column_from_source_parallel(
    main_table: CsvTable,
    source: CsvTable,
    request: FractionColumnRequest,
    reciprocal: Int,
    last_row: Int,
    output_mode: String,
    language: String,
    config: ParallelExecutionConfig,
) -> List[String]:
    """Use private row chunks when only one fraction column is requested."""
    var stop = min(last_row, len(main_table.rows) - 1)
    var row_count = max(0, stop)
    if not config.should_use_threads(row_count):
        return _fraction_column_from_source(
            main_table,
            source,
            request,
            reciprocal,
            last_row,
            output_mode,
            language,
        )
    var chunks = (row_count + config.chunk_size - 1) // config.chunk_size
    if chunks <= 1:
        return _fraction_column_from_source(
            main_table,
            source,
            request,
            reciprocal,
            last_row,
            output_mode,
            language,
        )
    var chunk_results = List[List[String]]()
    for _ in range(chunks):
        chunk_results.append(List[String]())

    @parameter
    def worker(chunk_index: Int):
        var start_row = 1 + chunk_index * config.chunk_size
        var end_row = min(stop + 1, start_row + config.chunk_size)
        var values = List[String]()
        for row in range(start_row, end_row):
            var coordinate = (
                _coordinate(row, request.denominator)
                if reciprocal == 0
                else _coordinate(request.denominator, row)
            )
            values.append(
                fraction_domain_value(
                    main_table,
                    source,
                    coordinate,
                    request.domain,
                    output_mode,
                )
            )
        chunk_results[chunk_index] = values^

    parallelize[worker](
        chunks, min(config.resolved_workers(), chunks)
    )
    var result = List[String]()
    var label = _domain_label(request.domain, language)
    if reciprocal == 0:
        result.append("n/" + String(request.denominator) + " " + label)
    else:
        result.append(String(request.denominator) + "/n " + label)
    for chunk_index in range(chunks):
        for value in chunk_results[chunk_index]:
            result.append(value)
    for _ in range(stop + 1, len(main_table.rows)):
        result.append("")
    return result^


def generate_fraction_concat_columns_parallel(
    main_table: CsvTable,
    requests: List[FractionColumnRequest],
    last_row: Int,
    output_mode: String,
    language: String,
    config: ParallelExecutionConfig,
) raises -> FractionConcatColumns:
    """Load independent fraction matrices and generate ordered columns."""
    var ordered = requests.copy()
    _sort_fraction_requests(ordered)
    var sources = List[CsvTable]()
    for _ in range(4):
        sources.append(empty_csv_table())
    var load_ranks = List[Int]()
    for rank in range(4):
        for request_index in range(len(ordered)):
            if _domain_rank(ordered[request_index].domain) == rank:
                load_ranks.append(rank)
                break
    var load_errors = List[String]()
    for _ in range(len(load_ranks)):
        load_errors.append(String())

    @parameter
    def load_worker(index: Int):
        var rank = load_ranks[index]
        try:
            sources[rank] = _load_fraction_source_by_rank(rank)
        except error:
            load_errors[index] = String(error)

    if (
        len(load_ranks) > 1
        and config.enabled_by_mode()
        and config.resolved_workers() > 1
    ):
        parallelize[load_worker](
            len(load_ranks),
            min(config.resolved_workers(), len(load_ranks)),
        )
    else:
        for index in range(len(load_ranks)):
            var rank = load_ranks[index]
            try:
                sources[rank] = _load_fraction_source_by_rank(rank)
            except error:
                load_errors[index] = String(error)
    for index in range(len(load_errors)):
        if load_errors[index].byte_length() > 0:
            raise Error(
                "fraction source load failed: " + load_errors[index]
            )

    var emitted = List[FractionColumnRequest]()
    var reciprocal_flags = List[Int]()
    var source_ranks = List[Int]()
    for domain_rank in range(4):
        for reciprocal in range(2):
            for index in range(len(ordered)):
                var request = ordered[index].copy()
                if _domain_rank(request.domain) != domain_rank:
                    continue
                if request.denominator > _fraction_request_limit_from_source(
                    sources[domain_rank], reciprocal
                ):
                    continue
                emitted.append(request.copy())
                reciprocal_flags.append(reciprocal)
                source_ranks.append(domain_rank)

    var columns = List[List[String]]()
    for _ in range(len(emitted)):
        columns.append(List[String]())
    var work = len(emitted) * max(
        1, min(last_row, len(main_table.rows) - 1) + 1
    )
    if len(emitted) == 1 and config.should_use_threads(work):
        columns[0] = _fraction_column_from_source_parallel(
            main_table,
            sources[source_ranks[0]],
            emitted[0],
            reciprocal_flags[0],
            last_row,
            output_mode,
            language,
            config,
        )
        return FractionConcatColumns(
            emitted^, reciprocal_flags^, columns^
        )
    if len(emitted) <= 1 or not config.should_use_threads(work):
        for index in range(len(emitted)):
            columns[index] = _fraction_column_from_source(
                main_table,
                sources[source_ranks[index]],
                emitted[index],
                reciprocal_flags[index],
                last_row,
                output_mode,
                language,
            )
        return FractionConcatColumns(
            emitted^, reciprocal_flags^, columns^
        )

    var workers = min(config.resolved_workers(), len(emitted))

    @parameter
    def column_worker(index: Int):
        columns[index] = _fraction_column_from_source(
            main_table,
            sources[source_ranks[index]],
            emitted[index],
            reciprocal_flags[index],
            last_row,
            output_mode,
            language,
        )

    parallelize[column_worker](len(emitted), workers)
    return FractionConcatColumns(emitted^, reciprocal_flags^, columns^)

