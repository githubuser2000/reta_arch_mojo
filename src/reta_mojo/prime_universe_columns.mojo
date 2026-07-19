"""Integer prime-universe multiplication columns.

This ports the brr == 0 branch of concat_prim_universe_row.  Fractional-rational
multiplication columns remain a separate Stage-7 substage.
"""

from std.algorithm import parallelize
from std.collections import List
from std.collections.string import atol
from .csv_table import CsvTable, read_semicolon_csv, read_text_file
from .parallel_execution import ParallelExecutionConfig
from .resource_paths import asset_resource, csv_resource
from .arithmetic import factor_pairs
from .types import IntPair
from .os_line_endings import split_os_lines


@fieldwise_init
struct PrimeUniverseCoordinate(Copyable):
    var polygon: Int  # 0 star, 1 regular
    var combination: Int  # 0 MM, 1 MS, 2 SM, 3 SS


@fieldwise_init
struct PrimeUniverseColumns(Copyable):
    var coordinates: List[PrimeUniverseCoordinate]
    var columns: List[List[String]]


def _pu_english(language: String) -> Bool:
    return language == "english" or language == "en" or language == "englisch"


def _pu_contains_command(commands: List[String], wanted: String) -> Bool:
    for index in range(len(commands)):
        if commands[index] == wanted:
            return True
    return False


def _pu_coordinates(commands: List[String]) -> List[PrimeUniverseCoordinate]:
    var selected = List[Bool]()
    for _ in range(8):
        selected.append(False)

    if _pu_contains_command(commands, "primMotivStern"):
        selected[0] = True
        selected[1] = True
        selected[2] = True
    if _pu_contains_command(commands, "primStrukStern"):
        selected[1] = True
        selected[2] = True
        selected[3] = True
    if _pu_contains_command(commands, "primMotivGleichf"):
        selected[4] = True
        selected[5] = True
        selected[6] = True
    if _pu_contains_command(commands, "primStrukGleichf"):
        selected[5] = True
        selected[6] = True
        selected[7] = True

    var result = List[PrimeUniverseCoordinate]()
    for polygon in range(2):
        for combination in range(4):
            if selected[polygon * 4 + combination]:
                result.append(PrimeUniverseCoordinate(polygon, combination))
    return result^


def _pu_polygon_name(polygon: Int, language: String) -> String:
    if polygon == 0:
        return "star_polygons" if _pu_english(language) else "Sternpolygone"
    return "regular polygons" if _pu_english(language) else "gleichförmige Polygone"


def _pu_combination_name(combination: Int, language: String) -> String:
    if combination == 0:
        return "Motif -> Motif" if _pu_english(language) else "Motiv -> Motiv"
    if combination == 1:
        return "Motif -> Structure" if _pu_english(language) else "Motiv -> Strukur"
    if combination == 2:
        return "Structure -> Motif" if _pu_english(language) else "Struktur -> Motiv"
    return "Structure -> Structure" if _pu_english(language) else "Struktur -> Strukur"


def _pu_heading(coordinate: PrimeUniverseCoordinate, language: String) -> String:
    var prefix = (
        "generated multiplications"
        if _pu_english(language)
        else "generierte Multiplikationen "
    )
    return (
        prefix
        + _pu_polygon_name(coordinate.polygon, language)
        + " "
        + _pu_combination_name(coordinate.combination, language)
    )


def _pu_source_columns(coordinate: PrimeUniverseCoordinate) -> IntPair:
    var motivation = 10 if coordinate.polygon == 0 else 42
    var structure = 5 if coordinate.polygon == 0 else 131
    if coordinate.combination == 0:
        return IntPair(motivation, motivation)
    if coordinate.combination == 1:
        return IntPair(motivation, structure)
    if coordinate.combination == 2:
        return IntPair(structure, motivation)
    return IntPair(structure, structure)


def _pu_cell(table: CsvTable, row: Int, column: Int) -> String:
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    var text = table.rows[row][column]
    return text if String(text).strip().byte_length() > 3 else "..."


def _pu_sort_pairs(mut pairs: List[IntPair]):
    for index in range(1, len(pairs)):
        var key = pairs[index].copy()
        var position = index - 1
        while position >= 0 and (
            pairs[position].first > key.first
            or (
                pairs[position].first == key.first
                and pairs[position].second > key.second
            )
        ):
            pairs[position + 1] = pairs[position].copy()
            position -= 1
        pairs[position + 1] = key.copy()


def _pu_row_value(
    table: CsvTable,
    row: Int,
    coordinate: PrimeUniverseCoordinate,
    output_mode: String,
    language: String,
) -> String:
    var sources = _pu_source_columns(coordinate)
    var pairs = factor_pairs(row, True)
    _pu_sort_pairs(pairs)
    var result = String()
    if output_mode == "html":
        result = "<ul>"
    elif output_mode == "bbcode":
        result = "[list]"

    for index in range(len(pairs)):
        if output_mode == "html":
            result += "<li>"
        elif output_mode == "bbcode":
            result += "[*]"
        elif index > 0:
            result += ", furthermore: " if _pu_english(language) else ", außerdem: "
        result += "("
        result += _pu_cell(table, pairs[index].first, sources.first)
        result += ") * ("
        result += _pu_cell(table, pairs[index].second, sources.second)
        result += ")"
        if output_mode == "html":
            result += "</li>"

    if output_mode == "html":
        result += "</ul>"
    elif output_mode == "bbcode":
        result += "[/list]"
    return result^


def _pu_column(
    table: CsvTable,
    coordinate: PrimeUniverseCoordinate,
    last_row: Int,
    output_mode: String,
    language: String,
) -> List[String]:
    var stop = min(last_row, len(table.rows) - 1)
    var result = List[String]()
    result.append(_pu_heading(coordinate, language))
    for row in range(1, stop + 1):
        result.append(_pu_row_value(table, row, coordinate, output_mode, language))
    for _ in range(stop + 1, len(table.rows)):
        result.append("")
    return result^


def _pu_column_parallel(
    table: CsvTable,
    coordinate: PrimeUniverseCoordinate,
    last_row: Int,
    output_mode: String,
    language: String,
    config: ParallelExecutionConfig,
) -> List[String]:
    """Use row chunks when one expensive coordinate is selected."""
    var stop = min(last_row, len(table.rows) - 1)
    var row_count = max(0, stop)
    if not config.should_use_threads(row_count):
        return _pu_column(
            table, coordinate, last_row, output_mode, language
        )
    var chunks = (row_count + config.chunk_size - 1) // config.chunk_size
    if chunks <= 1:
        return _pu_column(
            table, coordinate, last_row, output_mode, language
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
            values.append(
                _pu_row_value(
                    table, row, coordinate, output_mode, language
                )
            )
        chunk_results[chunk_index] = values^

    parallelize[worker](
        chunks, min(config.resolved_workers(), chunks)
    )
    var result = List[String]()
    result.append(_pu_heading(coordinate, language))
    for chunk_index in range(chunks):
        for value in chunk_results[chunk_index]:
            result.append(value)
    for _ in range(stop + 1, len(table.rows)):
        result.append("")
    return result^


def generate_integer_prime_universe_columns(
    table: CsvTable,
    commands: List[String],
    last_row: Int,
    output_mode: String,
    language: String,
) -> PrimeUniverseColumns:
    var coordinates = _pu_coordinates(commands)
    var columns = List[List[String]]()
    for index in range(len(coordinates)):
        columns.append(
            _pu_column(
                table,
                coordinates[index],
                last_row,
                output_mode,
                language,
            )
        )
    return PrimeUniverseColumns(coordinates^, columns^)



def generate_integer_prime_universe_columns_parallel(
    table: CsvTable,
    commands: List[String],
    last_row: Int,
    output_mode: String,
    language: String,
    config: ParallelExecutionConfig,
) -> PrimeUniverseColumns:
    var coordinates = _pu_coordinates(commands)
    var columns = List[List[String]]()
    for _ in range(len(coordinates)):
        columns.append(List[String]())
    var work = len(coordinates) * max(
        1, min(last_row, len(table.rows) - 1) + 1
    )
    if len(coordinates) == 1 and config.should_use_threads(work):
        columns[0] = _pu_column_parallel(
            table,
            coordinates[0],
            last_row,
            output_mode,
            language,
            config,
        )
        return PrimeUniverseColumns(coordinates^, columns^)
    if len(coordinates) <= 1 or not config.should_use_threads(work):
        for index in range(len(coordinates)):
            columns[index] = _pu_column(
                table,
                coordinates[index],
                last_row,
                output_mode,
                language,
            )
        return PrimeUniverseColumns(coordinates^, columns^)

    var workers = min(config.resolved_workers(), len(coordinates))

    @parameter
    def worker(index: Int):
        columns[index] = _pu_column(
            table,
            coordinates[index],
            last_row,
            output_mode,
            language,
        )

    parallelize[worker](len(coordinates), workers)
    return PrimeUniverseColumns(coordinates^, columns^)


@fieldwise_init
struct FractionValue(Copyable):
    var numerator: Int
    var denominator: Int


@fieldwise_init
struct FractionPairEntry(Copyable):
    var combination: Int
    var polygon: Int
    var result_number: Int
    var order: Int
    var first: FractionValue
    var second: FractionValue


@fieldwise_init
struct FractionPrimeUniverseColumns(Copyable):
    var coordinates: List[PrimeUniverseCoordinate]
    var columns: List[List[String]]


def _pu_fractional_coordinates(commands: List[String]) -> List[PrimeUniverseCoordinate]:
    var selected = List[Bool]()
    for _ in range(8):
        selected.append(False)

    if _pu_contains_command(commands, "primMotivSternGebr"):
        selected[0] = True
        selected[1] = True
        selected[2] = True
    if _pu_contains_command(commands, "primStrukSternGebr"):
        selected[1] = True
        selected[2] = True
        selected[3] = True
    if _pu_contains_command(commands, "primMotivGleichfGebr"):
        selected[4] = True
        selected[5] = True
        selected[6] = True
    if _pu_contains_command(commands, "primStrukGleichfGebr"):
        selected[5] = True
        selected[6] = True
        selected[7] = True

    var result = List[PrimeUniverseCoordinate]()
    for polygon in range(2):
        for combination in range(4):
            if selected[polygon * 4 + combination]:
                result.append(PrimeUniverseCoordinate(polygon, combination))
    return result^


def _fpu_coordinate_selected(
    coordinates: List[PrimeUniverseCoordinate], polygon: Int, combination: Int
) -> Bool:
    for index in range(len(coordinates)):
        if (
            coordinates[index].polygon == polygon
            and coordinates[index].combination == combination
        ):
            return True
    return False


def _fpu_context_number(text: String) -> Int:
    if text == "GalGal":
        return 0
    if text == "GalUni":
        return 1
    if text == "UniGal":
        return 2
    if text == "UniUni":
        return 3
    return -1


def _fpu_polygon_number(text: String) -> Int:
    if text == "stern":
        return 0
    if text == "gleichf":
        return 1
    return -1


def load_fraction_pair_entries(
    path: String,
    coordinates: List[PrimeUniverseCoordinate],
    last_row: Int,
) raises -> List[FractionPairEntry]:
    """Load only relations needed by the selected fractional coordinates."""
    var result = List[FractionPairEntry]()
    var lines = split_os_lines(read_text_file(path))
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var pieces = line.split("\t")
        if len(pieces) != 8:
            continue
        var combination = _fpu_context_number(String(pieces[0]))
        var polygon = _fpu_polygon_number(String(pieces[1]))
        var result_number = atol(String(pieces[2]))
        if (
            combination < 0
            or polygon < 0
            or result_number < 0
            or result_number > last_row
            or not _fpu_coordinate_selected(coordinates, polygon, combination)
        ):
            continue
        result.append(
            FractionPairEntry(
                combination,
                polygon,
                result_number,
                atol(String(pieces[3])),
                FractionValue(atol(String(pieces[4])), atol(String(pieces[5]))),
                FractionValue(atol(String(pieces[6])), atol(String(pieces[7]))),
            )
        )
    return result^


def _fpu_main_cell(table: CsvTable, row: Int, column: Int) -> String:
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _fpu_fraction_cell(table: CsvTable, numerator: Int, denominator: Int) -> String:
    var row = numerator - 1
    var column = denominator - 1
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _fpu_source_columns(combination: Int, polygon: Int) -> IntPair:
    if combination == 0:
        return IntPair(10, 42)
    if combination == 1:
        return IntPair(10, 42) if polygon == 0 else IntPair(5, 131)
    if combination == 2:
        return IntPair(5, 131) if polygon == 0 else IntPair(10, 42)
    return IntPair(5, 131)


def _fpu_fraction_text(value: FractionValue) -> String:
    if value.denominator == 1:
        return String(value.numerator)
    return String(value.numerator) + "/" + String(value.denominator)


def _fpu_fraction_description(
    main_table: CsvTable,
    fraction_table: CsvTable,
    value: FractionValue,
    source_columns: IntPair,
    is_universe: Bool,
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
        var base = String(
            _fpu_main_cell(main_table, value.denominator, source_columns.second).strip()
        )
        if base.byte_length() <= 3:
            return ""
        if not is_universe:
            return base^
        var extra = _fpu_main_cell(main_table, value.denominator, 201)
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
        var base = String(
            _fpu_main_cell(main_table, value.numerator, source_columns.first).strip()
        )
        if base.byte_length() <= 3:
            return ""
        if not is_universe:
            return base^
        var extra = _fpu_main_cell(main_table, value.numerator, 198)
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
    return _fpu_fraction_cell(
        fraction_table, value.numerator, value.denominator
    )


def _fpu_suffix(language: String) -> String:
    return (
        ", with factors from fractional-rational numbers"
        if _pu_english(language)
        else ", mit Faktoren aus gebrochen-rationalen Zahlen"
    )


def _fpu_separator(language: String) -> String:
    return "| moreover:" if _pu_english(language) else "| außerdem: "


def _fpu_row_value(
    main_table: CsvTable,
    fraction_table: CsvTable,
    entries: List[FractionPairEntry],
    row: Int,
    coordinate: PrimeUniverseCoordinate,
    output_mode: String,
    language: String,
) -> String:
    var source_columns = _fpu_source_columns(
        coordinate.combination, coordinate.polygon
    )
    var first_is_universe = (
        coordinate.combination == 2 or coordinate.combination == 3
    )
    var second_is_universe = (
        coordinate.combination == 1 or coordinate.combination == 3
    )
    var result = String()
    if output_mode == "html":
        result = "<ul>"
    elif output_mode == "bbcode":
        result = "[list]"
    var has_item = False

    for entry_index in range(len(entries)):
        var entry = entries[entry_index].copy()
        if (
            entry.result_number != row
            or entry.combination != coordinate.combination
            or entry.polygon != coordinate.polygon
        ):
            continue
        var first = String(
            _fpu_fraction_description(
                main_table,
                fraction_table,
                entry.first,
                source_columns,
                first_is_universe,
                output_mode,
            ).strip()
        )
        var second = String(
            _fpu_fraction_description(
                main_table,
                fraction_table,
                entry.second,
                source_columns,
                second_is_universe,
                output_mode,
            ).strip()
        )
        if first.byte_length() <= 3 or second.byte_length() <= 3:
            continue
        if has_item and output_mode != "html" and output_mode != "bbcode":
            result += _fpu_separator(language)
        if output_mode == "html":
            result += "<li>"
        elif output_mode == "bbcode":
            result += "[*]"
        else:
            result += "\""
        result += "\"" + first + "\""
        if output_mode == "html" and (
            first.byte_length() > 30 or second.byte_length() > 30
        ):
            result += "<br>"
        else:
            result += " "
        result += (
            "("
            + _fpu_fraction_text(entry.first)
            + ")*("
            + _fpu_fraction_text(entry.second)
            + ")"
        )
        if output_mode == "html" and (
            first.byte_length() > 30 or second.byte_length() > 30
        ):
            result += "<br>"
        else:
            result += " "
        result += "\"" + second + "\"\""
        if output_mode == "html":
            result += "</li>"
        has_item = True

    if output_mode == "html":
        result += "</ul>"
    elif output_mode == "bbcode":
        result += "[/list]"
    return result^


def _fpu_column(
    main_table: CsvTable,
    fraction_table: CsvTable,
    entries: List[FractionPairEntry],
    coordinate: PrimeUniverseCoordinate,
    last_row: Int,
    output_mode: String,
    language: String,
) -> List[String]:
    var stop = min(last_row, len(main_table.rows) - 1)
    var result = List[String]()
    result.append(_pu_heading(coordinate, language) + _fpu_suffix(language))
    for row in range(1, stop + 1):
        result.append(
            _fpu_row_value(
                main_table,
                fraction_table,
                entries,
                row,
                coordinate,
                output_mode,
                language,
            )
        )
    for _ in range(stop + 1, len(main_table.rows)):
        result.append("")
    return result^


def _fpu_column_parallel(
    main_table: CsvTable,
    fraction_table: CsvTable,
    entries: List[FractionPairEntry],
    coordinate: PrimeUniverseCoordinate,
    last_row: Int,
    output_mode: String,
    language: String,
    config: ParallelExecutionConfig,
) -> List[String]:
    """Use row chunks for a single fractional coordinate."""
    var stop = min(last_row, len(main_table.rows) - 1)
    var row_count = max(0, stop)
    if not config.should_use_threads(row_count):
        return _fpu_column(
            main_table,
            fraction_table,
            entries,
            coordinate,
            last_row,
            output_mode,
            language,
        )
    var chunks = (row_count + config.chunk_size - 1) // config.chunk_size
    if chunks <= 1:
        return _fpu_column(
            main_table,
            fraction_table,
            entries,
            coordinate,
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
            values.append(
                _fpu_row_value(
                    main_table,
                    fraction_table,
                    entries,
                    row,
                    coordinate,
                    output_mode,
                    language,
                )
            )
        chunk_results[chunk_index] = values^

    parallelize[worker](
        chunks, min(config.resolved_workers(), chunks)
    )
    var result = List[String]()
    result.append(_pu_heading(coordinate, language) + _fpu_suffix(language))
    for chunk_index in range(chunks):
        for value in chunk_results[chunk_index]:
            result.append(value)
    for _ in range(stop + 1, len(main_table.rows)):
        result.append("")
    return result^


def generate_fractional_prime_universe_columns(
    table: CsvTable,
    commands: List[String],
    last_row: Int,
    output_mode: String,
    language: String,
    pair_catalog_path: String = "",
    fraction_csv_path: String = "",
) raises -> FractionPrimeUniverseColumns:
    var coordinates = _pu_fractional_coordinates(commands)
    if len(coordinates) == 0:
        return FractionPrimeUniverseColumns(
            coordinates^, List[List[String]]()
        )
    var pair_path = pair_catalog_path if pair_catalog_path.byte_length() > 0 else asset_resource("fraction_pairs.tsv")
    var entries = load_fraction_pair_entries(
        pair_path, coordinates, last_row
    )
    # The legacy lookup intentionally uses the galaxy fraction table for both
    # galaxy and universe proper-fraction content; universe identity is added
    # only for integer/reciprocal factors from the physical table.
    var fraction_path = fraction_csv_path if fraction_csv_path.byte_length() > 0 else csv_resource("gebrochen-rational-galaxie.csv")
    var fraction_table = read_semicolon_csv(fraction_path)
    var columns = List[List[String]]()
    for index in range(len(coordinates)):
        columns.append(
            _fpu_column(
                table,
                fraction_table,
                entries,
                coordinates[index],
                last_row,
                output_mode,
                language,
            )
        )
    return FractionPrimeUniverseColumns(coordinates^, columns^)


def generate_fractional_prime_universe_columns_parallel(
    table: CsvTable,
    commands: List[String],
    last_row: Int,
    output_mode: String,
    language: String,
    config: ParallelExecutionConfig,
    pair_catalog_path: String = "",
    fraction_csv_path: String = "",
) raises -> FractionPrimeUniverseColumns:
    var coordinates = _pu_fractional_coordinates(commands)
    if len(coordinates) == 0:
        return FractionPrimeUniverseColumns(
            coordinates^, List[List[String]]()
        )
    var pair_path = (
        pair_catalog_path
        if pair_catalog_path.byte_length() > 0
        else asset_resource("fraction_pairs.tsv")
    )
    var fraction_path = (
        fraction_csv_path
        if fraction_csv_path.byte_length() > 0
        else csv_resource("gebrochen-rational-galaxie.csv")
    )
    var entry_slots = List[List[FractionPairEntry]]()
    entry_slots.append(List[FractionPairEntry]())
    var table_slots = List[CsvTable]()
    table_slots.append(CsvTable(List[List[String]](), 0))
    table_slots.append(CsvTable(List[List[String]](), 0))
    var load_errors = [String(), String()]

    @parameter
    def load_worker(index: Int):
        try:
            if index == 0:
                entry_slots[0] = load_fraction_pair_entries(
                    pair_path, coordinates, last_row
                )
            else:
                table_slots[1] = read_semicolon_csv(fraction_path)
        except error:
            load_errors[index] = String(error)

    if config.enabled_by_mode() and config.resolved_workers() > 1:
        parallelize[load_worker](2, 2)
    else:
        try:
            entry_slots[0] = load_fraction_pair_entries(
                pair_path, coordinates, last_row
            )
        except error:
            load_errors[0] = String(error)
        try:
            table_slots[1] = read_semicolon_csv(fraction_path)
        except error:
            load_errors[1] = String(error)
    if load_errors[0].byte_length() > 0:
        raise Error(
            "fraction pair catalog load failed: " + load_errors[0]
        )
    if load_errors[1].byte_length() > 0:
        raise Error(
            "fraction table load failed: " + load_errors[1]
        )
    var entries = entry_slots[0].copy()
    var fraction_table = table_slots[1].copy()
    var columns = List[List[String]]()
    for _ in range(len(coordinates)):
        columns.append(List[String]())
    var work = len(coordinates) * max(
        1, min(last_row, len(table.rows) - 1) + 1
    )
    if len(coordinates) == 1 and config.should_use_threads(work):
        columns[0] = _fpu_column_parallel(
            table,
            fraction_table,
            entries,
            coordinates[0],
            last_row,
            output_mode,
            language,
            config,
        )
        return FractionPrimeUniverseColumns(coordinates^, columns^)
    if len(coordinates) <= 1 or not config.should_use_threads(work):
        for index in range(len(coordinates)):
            columns[index] = _fpu_column(
                table,
                fraction_table,
                entries,
                coordinates[index],
                last_row,
                output_mode,
                language,
            )
        return FractionPrimeUniverseColumns(coordinates^, columns^)

    var workers = min(config.resolved_workers(), len(coordinates))

    @parameter
    def worker(index: Int):
        columns[index] = _fpu_column(
            table,
            fraction_table,
            entries,
            coordinates[index],
            last_row,
            output_mode,
            language,
        )

    parallelize[worker](len(coordinates), workers)
    return FractionPrimeUniverseColumns(coordinates^, columns^)

