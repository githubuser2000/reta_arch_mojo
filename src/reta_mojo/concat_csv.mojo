"""Typed native owner for CSV/fraction concatenation.

This module replaces the mutable Python ``reta_architecture.concat_csv``
object boundary with explicit values.  It owns three contracts:

* exact rational-pair grouping used by generated fraction relations;
* source selection/transposition/headings for the five historical CSV files;
* deterministic attachment of one CSV presheaf section to a ``CsvTable``.

No Python object, shell process, or dynamic ``Any`` metadata crosses this
boundary.  Legacy generated-column metadata is represented by
``ConcatColumnMetadata`` and can be translated by the outer table runtime.
"""

from std.collections import Dict, List
from .csv_table import CsvTable, empty_csv_table
from .fraction_concat_columns import FractionCoordinate, fraction_domain_value
from .resource_paths import csv_resource
from .runtime_compat import (
    NPM_EMO_1_PLUS_N,
    NPM_EMO_N,
    NPM_GAL_1_PLUS_N,
    NPM_GAL_N,
    NPM_GROE_1_PLUS_N,
    NPM_GROE_N,
    NPM_UNI_1_PLUS_N,
    NPM_UNI_N,
)


@fieldwise_init
struct ConcatCsvSpec(Copyable):
    var method_name: String
    var description: String
    var tags: List[String]


@fieldwise_init
struct ConcatCsvBundle(Copyable):
    var specs: List[ConcatCsvSpec]
    var csv_sources: List[String]
    var fraction_helpers: List[String]


@fieldwise_init
struct RationalValue(Copyable):
    var numerator: Int
    var denominator: Int


@fieldwise_init
struct RationalPair(Copyable):
    var first: RationalValue
    var second: RationalValue


@fieldwise_init
struct ConcatColumnMetadata(Copyable):
    """Typed replacement for one dynamic ``generatedSpaltenParameter`` item."""

    var output_column: Int
    var table_kind: Int
    var heading: String
    var source_bucket: Int
    var source_index: Int
    var tag_group: String
    var tag_name: String


@fieldwise_init
struct ConcatCsvResult(Copyable):
    var table: CsvTable
    var selected_columns: List[Int]
    var concat_columns: List[Int]
    var metadata: List[ConcatColumnMetadata]


def bootstrap_concat_csv() -> ConcatCsvBundle:
    return ConcatCsvBundle(
        [
            ConcatCsvSpec(
                "readConcatCsv",
                "Glues an external CSV presheaf section into the current global table section.",
                ["csv", "presheaf", "gluing"],
            ),
            ConcatCsvSpec(
                "readConcatCsv_tabelleDazuColchange",
                "Transforms fraction-indexed CSV columns into meta/concrete cell content.",
                ["fraction", "meta", "morphism"],
            ),
            ConcatCsvSpec(
                "readConcatCsv_SetHtmlParamaters",
                "Registers generated CSV columns in the HTML/tag parameter sheaf.",
                ["html", "tags", "generated-column"],
            ),
            ConcatCsvSpec(
                "convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction",
                "Builds number-indexed fraction-pair sections used by generated prime-universe columns.",
                ["fraction", "brueche", "relation"],
            ),
        ],
        ["prim", "bruch13", "bruch15", "bruch7", "bruchStrukGroesse"],
        [
            "convertSetOfPaarenToDictOfNumToPaareDiv",
            "convertSetOfPaarenToDictOfNumToPaareMul",
            "convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction",
            "combineDicts",
        ],
    )


def _abs_int(value: Int) -> Int:
    return -value if value < 0 else value


def _gcd(first: Int, second: Int) -> Int:
    var a = _abs_int(first)
    var b = _abs_int(second)
    while b != 0:
        var rest = a % b
        a = b
        b = rest
    return a if a != 0 else 1


def rational(numerator: Int, denominator: Int = 1) raises -> RationalValue:
    if denominator == 0:
        raise Error("rational denominator must not be zero")
    var n = numerator
    var d = denominator
    if d < 0:
        n = -n
        d = -d
    var divisor = _gcd(n, d)
    return RationalValue(n // divisor, d // divisor)


def _same_rational(first: RationalValue, second: RationalValue) -> Bool:
    return (
        first.numerator == second.numerator
        and first.denominator == second.denominator
    )


def _same_pair(first: RationalPair, second: RationalPair) -> Bool:
    return _same_rational(first.first, second.first) and _same_rational(
        first.second, second.second
    )


def _contains_rational(values: List[RationalValue], wanted: RationalValue) -> Bool:
    for index in range(len(values)):
        if _same_rational(values[index], wanted):
            return True
    return False


def _append_unique_pair(
    mut grouped: Dict[Int, List[RationalPair]], key: Int, pair: RationalPair
) raises:
    if key not in grouped:
        grouped[key] = List[RationalPair]()
    for index in range(len(grouped[key])):
        if _same_pair(grouped[key][index], pair):
            return
    grouped[key].append(pair.copy())


def _integer_quotient(numerator: Int, denominator: Int) raises -> Int:
    if denominator == 0 or numerator % denominator != 0:
        raise Error("legacy concat ratio is not integral")
    return numerator // denominator


def group_pairs_by_division(
    pairs: List[RationalPair], reversed: Bool = False
) raises -> Dict[Int, List[RationalPair]]:
    var result = Dict[Int, List[RationalPair]]()
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        var numerator = pair.first.numerator * pair.second.denominator
        var denominator = pair.first.denominator * pair.second.numerator
        if reversed:
            var swap = numerator
            numerator = denominator
            denominator = swap
        var key = _integer_quotient(numerator, denominator)
        _append_unique_pair(result, key, pair)
    return result^


def group_pairs_by_multiplication(
    pairs: List[RationalPair], reciprocal: Bool = False
) raises -> Dict[Int, List[RationalPair]]:
    var result = Dict[Int, List[RationalPair]]()
    for index in range(len(pairs)):
        var pair = pairs[index].copy()
        var numerator = pair.first.numerator * pair.second.numerator
        var denominator = pair.first.denominator * pair.second.denominator
        if reciprocal:
            var swap = numerator
            numerator = denominator
            denominator = swap
        var key = _integer_quotient(numerator, denominator)
        _append_unique_pair(result, key, pair)
    return result^


def combine_pair_groups(
    first: Dict[Int, List[RationalPair]],
    second: Dict[Int, List[RationalPair]],
) raises -> Dict[Int, List[RationalPair]]:
    var result = Dict[Int, List[RationalPair]]()
    for item in first.items():
        var values = item.value.copy()
        for index in range(len(values)):
            _append_unique_pair(result, item.key, values[index])
    for item in second.items():
        var values = item.value.copy()
        for index in range(len(values)):
            _append_unique_pair(result, item.key, values[index])
    return result^


def _product_integer(first: RationalValue, second: RationalValue) -> Int:
    var numerator = first.numerator * second.numerator
    var denominator = first.denominator * second.denominator
    if denominator == 0 or numerator % denominator != 0:
        return -1
    return numerator // denominator


def _reciprocal_product_integer(
    first: RationalValue, second: RationalValue
) -> Int:
    var numerator = first.denominator * second.denominator
    var denominator = first.numerator * second.numerator
    if denominator == 0 or numerator % denominator != 0:
        return -1
    return numerator // denominator


def expand_fraction_pairs(
    fractions: List[RationalValue],
    secondary: List[RationalValue],
    highest_row: Int,
    reciprocal: Bool = False,
) raises -> Dict[Int, List[RationalPair]]:
    """Typed equivalent of the historical nested ``Fraction`` loops."""
    var result = Dict[Int, List[RationalPair]]()
    if highest_row <= 0:
        return result^
    if not reciprocal:
        for fraction_index in range(len(fractions)):
            var fraction = fractions[fraction_index].copy()
            for multiplier in range(1, highest_row + 1):
                var factor = rational(fraction.denominator * multiplier)
                var pair = RationalPair(fraction.copy(), factor.copy())
                var key = _product_integer(pair.first, pair.second)
                if key > highest_row:
                    break
                if key >= 0:
                    _append_unique_pair(result, key, pair)
            for offset in range(highest_row):
                var multiplier = highest_row - offset
                var factor = rational(fraction.denominator, multiplier)
                if _contains_rational(secondary, factor) or factor.numerator == 1:
                    var pair = RationalPair(fraction.copy(), factor.copy())
                    var key = _product_integer(pair.first, pair.second)
                    if key > highest_row:
                        break
                    if key >= 0:
                        _append_unique_pair(result, key, pair)
    else:
        for fraction_index in range(len(fractions)):
            var fraction = fractions[fraction_index].copy()
            for divisor in range(1, highest_row + 1):
                var factor = rational(1, fraction.numerator * divisor)
                var pair = RationalPair(fraction.copy(), factor.copy())
                var key = _reciprocal_product_integer(pair.first, pair.second)
                if key > highest_row:
                    break
                if key >= 0:
                    _append_unique_pair(result, key, pair)
            for divisor in range(1, highest_row + 1):
                var factor = rational(
                    fraction.denominator, fraction.numerator * divisor
                )
                if _contains_rational(secondary, factor) or factor.numerator == 1:
                    var pair = RationalPair(fraction.copy(), factor.copy())
                    var key = _reciprocal_product_integer(pair.first, pair.second)
                    # Preserve Python's unusual ``if 1 / mul > highest`` guard.
                    # For positive integral keys this can only trigger at zero,
                    # which is already excluded by the exact helper above.
                    if key >= 0:
                        _append_unique_pair(result, key, pair)
    return result^


def concat_csv_filename(table_kind: Int) -> String:
    if table_kind == 1:
        return "primenumbers.csv"
    if table_kind == NPM_GAL_N or table_kind == NPM_GAL_1_PLUS_N:
        return "gebrochen-rational-galaxie.csv"
    if table_kind == NPM_UNI_N or table_kind == NPM_UNI_1_PLUS_N:
        return "gebrochen-rational-universum.csv"
    if table_kind == NPM_EMO_N or table_kind == NPM_EMO_1_PLUS_N:
        return "gebrochen-rational-emotionen.csv"
    if table_kind == NPM_GROE_N or table_kind == NPM_GROE_1_PLUS_N:
        return "gebrochen-rational-strukturgroesse.csv"
    return ""


def concat_csv_path(table_kind: Int) -> String:
    var filename = concat_csv_filename(table_kind)
    if filename.byte_length() == 0:
        return ""
    return csv_resource(filename)


def concat_csv_domain(table_kind: Int) -> String:
    if table_kind == NPM_GAL_N or table_kind == NPM_GAL_1_PLUS_N:
        return "galaxy"
    if table_kind == NPM_UNI_N or table_kind == NPM_UNI_1_PLUS_N:
        return "universe"
    if table_kind == NPM_EMO_N or table_kind == NPM_EMO_1_PLUS_N:
        return "emotion"
    if table_kind == NPM_GROE_N or table_kind == NPM_GROE_1_PLUS_N:
        return "size"
    return "prime" if table_kind == 1 else ""


def concat_csv_is_reciprocal(table_kind: Int) -> Bool:
    return (
        table_kind == NPM_GAL_1_PLUS_N
        or table_kind == NPM_UNI_1_PLUS_N
        or table_kind == NPM_EMO_1_PLUS_N
        or table_kind == NPM_GROE_1_PLUS_N
    )


def _english(language: String) -> Bool:
    return language == "english" or language == "en" or language == "englisch"


def _domain_label(table_kind: Int, language: String) -> String:
    var english = _english(language)
    var domain = concat_csv_domain(table_kind)
    if domain == "galaxy":
        return "galaxy" if english else "Galaxie"
    if domain == "universe":
        return "universe" if english else "Universum"
    if domain == "emotion":
        return "emotion" if english else "Emotion"
    if domain == "size":
        return "structuresize" if english else "Strukturgroesse"
    return "error" if english else "Fehler"


def concat_csv_heading(table_kind: Int, source_index: Int, language: String) -> String:
    var number = source_index + 1
    var prefix = (
        String(number) + "/n"
        if concat_csv_is_reciprocal(table_kind)
        else "n/" + String(number)
    )
    return prefix + " " + _domain_label(table_kind, language)


def transpose_csv_table(table: CsvTable) -> CsvTable:
    if len(table.rows) == 0:
        return empty_csv_table()
    var width = len(table.rows[0])
    var rows = List[List[String]]()
    for column_index in range(width):
        var row = List[String]()
        for row_index in range(len(table.rows)):
            if column_index < len(table.rows[row_index]):
                row.append(table.rows[row_index][column_index])
            else:
                row.append("")
        rows.append(row^)
    return CsvTable(rows^, len(table.rows))


def prepare_fraction_concat_source(
    source: CsvTable, table_kind: Int, language: String
) -> CsvTable:
    var body = transpose_csv_table(source) if concat_csv_is_reciprocal(table_kind) else source.copy()
    if len(body.rows) == 0:
        return body^
    var heading = List[String]()
    for column_index in range(len(body.rows[0])):
        heading.append(concat_csv_heading(table_kind, column_index, language))
    var rows = List[List[String]]()
    rows.append(heading^)
    for row_index in range(len(body.rows)):
        rows.append(body.rows[row_index].copy())
    return CsvTable(rows^, body.maximum_columns)


def _prime_heading(language: String) -> String:
    if _english(language):
        return "prime multiples, not generated"
    return "Primzahlvielfache, nicht generiert"


def _compact_prime_row(row: List[String], output_mode: String) -> String:
    var content = String()
    var item_count = 0
    if output_mode == "html":
        content = "<ul>"
    elif output_mode == "bbcode":
        content = "[list]"
    for column_index in range(len(row)):
        var cell = row[column_index]
        if String(cell.strip()).byte_length() <= 3:
            continue
        if output_mode == "html":
            content += "<li>" + cell + "</li>"
        elif output_mode == "bbcode":
            content += "[*]" + cell
        else:
            if item_count == 0:
                content = "| " + cell
            else:
                content += " | " + cell
        item_count += 1
    if output_mode == "html":
        content += "</ul>"
    elif output_mode == "bbcode":
        content += "[/list]"
    elif item_count == 0:
        content = "|"
    else:
        content += " |"
    return content^


def prepare_prime_concat_source(
    source: CsvTable, output_mode: String, language: String
) -> CsvTable:
    var rows = List[List[String]]()
    rows.append([_prime_heading(language)])
    for row_index in range(1, len(source.rows)):
        rows.append([_compact_prime_row(source.rows[row_index], output_mode)])
    return CsvTable(rows^, 1)


def prepare_concat_source(
    source: CsvTable,
    table_kind: Int,
    output_mode: String,
    language: String,
) -> CsvTable:
    if table_kind == 1:
        return prepare_prime_concat_source(source, output_mode, language)
    if table_kind >= 2 and table_kind <= 9:
        return prepare_fraction_concat_source(source, table_kind, language)
    return empty_csv_table()


def transform_fraction_concat_row(
    main_table: CsvTable,
    raw_fraction_source: CsvTable,
    source_row: List[String],
    row_number: Int,
    table_kind: Int,
    output_mode: String,
) -> List[String]:
    var result = List[String]()
    var domain = concat_csv_domain(table_kind)
    var reciprocal = concat_csv_is_reciprocal(table_kind)
    for column_index in range(len(source_row)):
        var coordinate = (
            FractionCoordinate(column_index + 1, row_number)
            if reciprocal
            else FractionCoordinate(row_number, column_index + 1)
        )
        result.append(
            fraction_domain_value(
                main_table,
                raw_fraction_source,
                coordinate,
                domain,
                output_mode,
            )
        )
    return result^


def _append_unique_int(mut values: List[Int], value: Int):
    for index in range(len(values)):
        if values[index] == value:
            return
    values.append(value)


def _metadata_bucket(table_kind: Int) -> Int:
    if table_kind == NPM_GAL_N or table_kind == NPM_GAL_1_PLUS_N:
        return 6
    if table_kind == NPM_UNI_N or table_kind == NPM_UNI_1_PLUS_N:
        return 5
    if table_kind == NPM_EMO_N or table_kind == NPM_EMO_1_PLUS_N:
        return 9
    if table_kind == NPM_GROE_N or table_kind == NPM_GROE_1_PLUS_N:
        return 10
    return -1


def append_concat_csv(
    main_table: CsvTable,
    raw_source: CsvTable,
    selected_table_columns: List[Int],
    table_kind: Int = 1,
    output_mode: String = "csv",
    language: String = "german",
) -> ConcatCsvResult:
    """Attach a prepared source while preserving Python's selection offsets."""
    if len(selected_table_columns) == 0 or table_kind < 1 or table_kind > 9:
        return ConcatCsvResult(
            main_table.copy(), List[Int](), List[Int](), List[ConcatColumnMetadata]()
        )
    var source = prepare_concat_source(raw_source, table_kind, output_mode, language)
    var row_count = max(len(main_table.rows), len(source.rows))
    var base_columns = 0
    if len(main_table.rows) > 0:
        base_columns = len(main_table.rows[0])
    var rows = List[List[String]]()
    var max_source_width = 0
    for row_index in range(row_count):
        var row = (
            main_table.rows[row_index].copy()
            if row_index < len(main_table.rows)
            else List[String]()
        )
        var addition = (
            source.rows[row_index].copy()
            if row_index < len(source.rows)
            else List[String]()
        )
        if len(addition) > max_source_width:
            max_source_width = len(addition)
        while len(addition) < max_source_width:
            addition.append("")
        if row_index > 0 and table_kind >= 2:
            addition = transform_fraction_concat_row(
                main_table,
                raw_source,
                addition,
                row_index,
                table_kind,
                output_mode,
            )
        for column_index in range(len(addition)):
            row.append(addition[column_index])
        rows.append(row^)

    var selected = List[Int]()
    var concat_columns = List[Int]()
    var metadata = List[ConcatColumnMetadata]()
    var heading_width = 0
    if len(source.rows) > 0:
        heading_width = len(source.rows[0])
    for source_index in range(heading_width):
        var should_select = table_kind == 1
        if table_kind >= 2:
            var selection_number = source_index + 2
            for selection_index in range(len(selected_table_columns)):
                if selected_table_columns[selection_index] == selection_number:
                    should_select = True
                    break
            if source_index + 1 == heading_width:
                should_select = False
        if not should_select:
            continue
        var output_column = (
            base_columns + source_index
            if table_kind == 1
            else base_columns + source_index + 1
        )
        _append_unique_int(selected, output_column)
        _append_unique_int(concat_columns, output_column)
        var heading = source.rows[0][source_index]
        if table_kind == 1:
            metadata.append(
                ConcatColumnMetadata(
                    output_column,
                    table_kind,
                    heading,
                    -1,
                    -1,
                    "Multiplikationen",
                    "Nicht_generiert",
                )
            )
        else:
            metadata.append(
                ConcatColumnMetadata(
                    output_column,
                    table_kind,
                    heading,
                    _metadata_bucket(table_kind),
                    source_index + 2,
                    "",
                    "",
                )
            )
    return ConcatCsvResult(
        CsvTable(rows^, base_columns + max_source_width),
        selected^,
        concat_columns^,
        metadata^,
    )
