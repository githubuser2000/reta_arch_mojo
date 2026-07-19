"""Native meta/concrete/theory/practice generated columns.

This is a direct port of the state machine in
``reta_architecture/meta_columns.py``.  Every selected bucket-11 coordinate
produces the historical pair of columns for ``n`` and ``1/n``.  The upper
branch follows integer multiplication chains while the lower branch follows
normalised rational coordinates and stops on the first repeated fraction.
"""

from std.algorithm import parallelize
from std.collections import List
from std.collections.string import atol
from .csv_table import CsvTable, read_semicolon_csv, read_text_file
from .parallel_execution import ParallelExecutionConfig
from .resource_paths import asset_resource, csv_resource
from .generated_aliases import MetaColumnRequest
from .prime_effect_columns import PrimeEffectColumns, generate_prime_effect_columns
from .os_line_endings import split_os_lines
from .tag_schema import (
    TAG_GEBROCHEN_RATIONAL,
    TAG_GLEICHFOERMIGES_POLYGON,
    TAG_STERN_POLYGON,
    TAG_UNIVERSUM,
)


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


@fieldwise_init
struct MetaColumnSpec(Copyable):
    var method_name: String
    var description: String
    var tags: List[String]


@fieldwise_init
struct MetaColumnsBundle(Copyable):
    var specs: List[MetaColumnSpec]


@fieldwise_init
struct MetaColumnsSnapshot(Copyable):
    var class_name: String
    var count: Int
    var morphisms: List[MetaColumnSpec]


@fieldwise_init
struct MetaColumnsSurfaceEntry(Copyable):
    var python_name: String
    var native_entry: String
    var owner_module: String


@fieldwise_init
struct MetaFractionSource(Copyable):
    var domain: String
    var filename: String
    var sha256: String
    var count: Int


@fieldwise_init
struct MetaFractionEntry(Copyable):
    var domain: String
    var order: Int
    var value: MetaFraction


@fieldwise_init
struct MetaFractionCombination(Copyable):
    var context: String
    var polygon: String
    var operation: String
    var order: Int
    var first: MetaFraction
    var second: MetaFraction


@fieldwise_init
struct MetaColumnsCatalog(Copyable):
    var sources: List[MetaFractionSource]
    var fractions: List[MetaFractionEntry]
    var combinations: List[MetaFractionCombination]


@fieldwise_init
struct MetaColumnMetadata(Copyable):
    var heading: String
    var tags: List[Int]


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


def bootstrap_meta_columns() -> MetaColumnsBundle:
    return MetaColumnsBundle(
        [
            MetaColumnSpec(
                "spalteMetaKontretTheorieAbstrakt_etc_1",
                "Entry point for generated meta/concrete/theory/abstract columns.",
                ["meta", "theorie", "abstrakt", "konkret"],
            ),
            MetaColumnSpec(
                "spalteFuerGegenInnenAussenSeitlichPrim",
                "Classifies prime-cross generated columns as pro/contra/inside/outside/sideways.",
                ["primzahlkreuz", "meta"],
            ),
            MetaColumnSpec(
                "readOneCSVAndReturn",
                "CSV section cache used by meta and fractional generated-column morphisms.",
                ["prägarbe", "csv"],
            ),
        ]
    )


def meta_columns_snapshot(bundle: MetaColumnsBundle) -> MetaColumnsSnapshot:
    var specs = List[MetaColumnSpec]()
    for index in range(len(bundle.specs)):
        specs.append(bundle.specs[index].copy())
    var count = len(specs)
    return MetaColumnsSnapshot("MetaColumnsBundle", count, specs^)


def meta_columns_surface() -> List[MetaColumnsSurfaceEntry]:
    return [
        MetaColumnsSurfaceEntry("bootstrap_meta_columns", "bootstrap_meta_columns", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKontretTheorieAbstrakt_etc_1", "spalteMetaKontretTheorieAbstrakt_etc_1", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKonkretAbstrakt_isGanzZahlig", "spalteMetaKonkretAbstrakt_isGanzZahlig", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKontretTheorieAbstrakt_etc", "spalteMetaKontretTheorieAbstrakt_etc", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKonkretTheorieAbstrakt_SetHtmlParameters", "spalteMetaKonkretTheorieAbstrakt_SetHtmlParameters", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKonkretTheorieAbstrakt_mainPart", "spalteMetaKonkretTheorieAbstrakt_mainPart", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKonkretTheorieAbstrakt_VorwortBehandlungWieVorwortMeta", "spalteMetaKonkretTheorieAbstrakt_VorwortBehandlungWieVorwortMeta", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKonkretTheorieAbstrakt_mainPart_InsertingText", "spalteMetaKonkretTheorieAbstrakt_mainPart_InsertingText", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("getAllBrueche", "getAllBrueche", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("readOneCSVAndReturn", "readOneCSVAndReturn", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("findAllBruecheAndTheirCombinations", "findAllBruecheAndTheirCombinations", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie", "spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteMetaKonkretAbstrakt_UeberschriftenUndTags", "spalteMetaKonkretAbstrakt_UeberschriftenUndTags", "meta_columns.mojo"),
        MetaColumnsSurfaceEntry("spalteFuerGegenInnenAussenSeitlichPrim", "spalteFuerGegenInnenAussenSeitlichPrim", "prime_effect_columns.mojo"),
    ]


def _meta_fraction_is_integer(value: MetaFraction) -> Bool:
    return value.denominator != 0 and value.numerator % value.denominator == 0


def meta_fraction_is_integral(
    value: MetaFraction, reciprocal: Bool = False
) -> Bool:
    if value.denominator == 0:
        return False
    if reciprocal:
        return value.numerator != 0 and value.denominator % value.numerator == 0
    return value.numerator % value.denominator == 0


def discover_meta_fractions(table: CsvTable) -> List[MetaFraction]:
    """Return the mathematical fraction set discovered by ``getAllBrueche``.

    The scan order is deterministic row/column order.  Exact legacy CPython
    set iteration is separately frozen in ``meta_columns_catalog.tsv``.
    """
    var result = List[MetaFraction]()
    for row in range(1, len(table.rows)):
        for column in range(1, len(table.rows[row])):
            if String(table.rows[row][column].strip()).byte_length() <= 3:
                continue
            var value = _meta_fraction(row + 1, column + 1)
            if value.denominator == 1 or value.numerator == 1:
                continue
            if not _meta_contains_fraction(result, value):
                result.append(value.copy())
    return result^


def load_meta_columns_catalog(path: String = "") raises -> MetaColumnsCatalog:
    var source_path = path if path.byte_length() > 0 else asset_resource("meta_columns_catalog.tsv")
    var sources = List[MetaFractionSource]()
    var fractions = List[MetaFractionEntry]()
    var combinations = List[MetaFractionCombination]()
    var lines = split_os_lines(read_text_file(source_path))
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) == 0:
            continue
        var kind = String(fields[0])
        if len(fields) == 5 and kind == "source":
            sources.append(
                MetaFractionSource(
                    String(fields[1]),
                    String(fields[2]),
                    String(fields[3]),
                    atol(String(fields[4])),
                )
            )
        elif len(fields) == 5 and kind == "fraction":
            fractions.append(
                MetaFractionEntry(
                    String(fields[1]),
                    atol(String(fields[2])),
                    _meta_fraction(
                        atol(String(fields[3])), atol(String(fields[4]))
                    ),
                )
            )
        elif len(fields) == 9 and kind == "combination":
            combinations.append(
                MetaFractionCombination(
                    String(fields[1]),
                    String(fields[2]),
                    String(fields[3]),
                    atol(String(fields[4])),
                    _meta_fraction(
                        atol(String(fields[5])), atol(String(fields[6]))
                    ),
                    _meta_fraction(
                        atol(String(fields[7])), atol(String(fields[8]))
                    ),
                )
            )
    return MetaColumnsCatalog(sources^, fractions^, combinations^)


def meta_catalog_fractions(
    catalog: MetaColumnsCatalog, domain: String
) -> List[MetaFraction]:
    var result = List[MetaFraction]()
    for index in range(len(catalog.fractions)):
        var entry = catalog.fractions[index].copy()
        if entry.domain == domain:
            result.append(entry.value.copy())
    return result^


def meta_catalog_combinations(
    catalog: MetaColumnsCatalog,
    context: String,
    polygon: String,
    operation: String,
) -> List[MetaFractionCombination]:
    var result = List[MetaFractionCombination]()
    for index in range(len(catalog.combinations)):
        var entry = catalog.combinations[index].copy()
        if (
            entry.context == context
            and entry.polygon == polygon
            and entry.operation == operation
        ):
            result.append(entry.copy())
    return result^


def read_meta_fraction_csv(domain: String, path: String = "") raises -> CsvTable:
    var filename: String
    if domain == "galaxy":
        filename = "gebrochen-rational-galaxie.csv"
    elif domain == "emotion":
        filename = "gebrochen-rational-emotionen.csv"
    elif domain == "size":
        filename = "gebrochen-rational-strukturgroesse.csv"
    else:
        filename = "gebrochen-rational-universum.csv"
    var source_path = path if path.byte_length() > 0 else csv_resource(filename)
    return read_semicolon_csv(source_path)


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


def meta_column_metadata(
    request: MetaColumnRequest,
    inverse: Int,
    language: String,
) -> MetaColumnMetadata:
    var tags = List[Int]()
    tags.append(
        TAG_GLEICHFOERMIGES_POLYGON if inverse == 1 else TAG_STERN_POLYGON
    )
    tags.append(TAG_UNIVERSUM)
    if request.side == 1:
        tags.append(TAG_GEBROCHEN_RATIONAL)
    return MetaColumnMetadata(
        _meta_heading(request.metavariable, request.side, inverse, language),
        tags^,
    )


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


def meta_fraction_structure_value(
    main_table: CsvTable,
    fraction_table: CsvTable,
    value: MetaFraction,
    first_column: Int = 5,
    inverse_column: Int = 131,
    output_mode: String = "plain",
    is_not_universe: Bool = False,
) -> String:
    """Typed owner of ``getGebrRatUnivStrukturalie``.

    ``is_not_universe`` mirrors the historical inverted boolean: when true,
    integer and unit-fraction coordinates return only the selected domain cell;
    universe mode additionally appends the structural annotation columns.
    """
    if (
        value.denominator == 0
        or value.numerator == 0
        or value.denominator > 100
        or value.numerator > 100
    ):
        return ""
    if value.numerator == 1:
        var base = _meta_cell(main_table, value.denominator, inverse_column)
        if String(base.strip()).byte_length() <= 3:
            return ""
        if is_not_universe:
            return base
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
        var base = _meta_cell(main_table, value.numerator, first_column)
        if String(base.strip()).byte_length() <= 3:
            return ""
        if is_not_universe:
            return base
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


def _meta_fraction_description(
    main_table: CsvTable,
    fraction_table: CsvTable,
    value: MetaFraction,
    output_mode: String,
) -> String:
    return meta_fraction_structure_value(
        main_table,
        fraction_table,
        value,
        5,
        131,
        output_mode,
        False,
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


def _meta_column_parallel(
    table: CsvTable,
    fraction_table: CsvTable,
    request: MetaColumnRequest,
    inverse: Int,
    last_row: Int,
    output_mode: String,
    language: String,
    config: ParallelExecutionConfig,
) -> List[String]:
    """Use row chunks when only one meta column job exists."""
    var stop = min(last_row, len(table.rows) - 1)
    var row_count = max(0, stop - 1)
    if not config.should_use_threads(row_count):
        return _meta_column(
            table,
            fraction_table,
            request,
            inverse,
            last_row,
            output_mode,
            language,
        )
    var chunks = (row_count + config.chunk_size - 1) // config.chunk_size
    if chunks <= 1:
        return _meta_column(
            table,
            fraction_table,
            request,
            inverse,
            last_row,
            output_mode,
            language,
        )
    var chunk_results = List[List[String]]()
    for _ in range(chunks):
        chunk_results.append(List[String]())

    @parameter
    def worker(chunk_index: Int):
        var start_row = 2 + chunk_index * config.chunk_size
        var end_row = min(stop + 1, start_row + config.chunk_size)
        var values = List[String]()
        for row in range(start_row, end_row):
            values.append(
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
        chunk_results[chunk_index] = values^

    parallelize[worker](
        chunks, min(config.resolved_workers(), chunks)
    )
    var result = List[String]()
    result.append(
        _meta_heading(request.metavariable, request.side, inverse, language)
    )
    if len(table.rows) > 1:
        result.append("")
    for chunk_index in range(chunks):
        for value in chunk_results[chunk_index]:
            result.append(value)
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



def generate_meta_columns_parallel(
    table: CsvTable,
    requests: List[MetaColumnRequest],
    last_row: Int,
    output_mode: String,
    language: String,
    config: ParallelExecutionConfig,
    fraction_csv_path: String = "",
) raises -> MetaColumnsResult:
    var columns = List[List[String]]()
    var emitted_requests = List[MetaColumnRequest]()
    var inversions = List[Int]()
    if len(requests) == 0:
        return MetaColumnsResult(emitted_requests^, inversions^, columns^)
    var source_path = (
        fraction_csv_path
        if fraction_csv_path.byte_length() > 0
        else csv_resource("gebrochen-rational-universum.csv")
    )
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
            columns.append(List[String]())

    var work = len(columns) * max(
        1, min(last_row, len(table.rows) - 1) + 1
    )
    if len(columns) == 1 and config.should_use_threads(work):
        columns[0] = _meta_column_parallel(
            table,
            fraction_table,
            emitted_requests[0],
            inversions[0],
            last_row,
            output_mode,
            language,
            config,
        )
        return MetaColumnsResult(
            emitted_requests^, inversions^, columns^
        )
    if len(columns) <= 1 or not config.should_use_threads(work):
        for index in range(len(columns)):
            columns[index] = _meta_column(
                table,
                fraction_table,
                emitted_requests[index],
                inversions[index],
                last_row,
                output_mode,
                language,
            )
        return MetaColumnsResult(
            emitted_requests^, inversions^, columns^
        )

    var workers = min(config.resolved_workers(), len(columns))

    @parameter
    def worker(index: Int):
        columns[index] = _meta_column(
            table,
            fraction_table,
            emitted_requests[index],
            inversions[index],
            last_row,
            output_mode,
            language,
        )

    parallelize[worker](len(columns), workers)
    return MetaColumnsResult(emitted_requests^, inversions^, columns^)


# Typed historical surface -------------------------------------------------
#
# These entry points intentionally preserve the Python owner names while
# replacing its mutable ``self`` object graph with explicit values.


def spalteMetaKontretTheorieAbstrakt_etc_1(
    table: CsvTable,
    requests: List[MetaColumnRequest],
    last_row: Int,
    output_mode: String,
    language: String,
    fraction_csv_path: String = "",
) raises -> MetaColumnsResult:
    return generate_meta_columns(
        table,
        requests,
        last_row,
        output_mode,
        language,
        fraction_csv_path,
    )


def spalteMetaKonkretAbstrakt_isGanzZahlig(
    value: MetaFraction, reciprocal: Bool = False
) -> Bool:
    return meta_fraction_is_integral(value, reciprocal)


def spalteMetaKontretTheorieAbstrakt_etc(
    table: CsvTable,
    fraction_table: CsvTable,
    request: MetaColumnRequest,
    inverse: Int,
    last_row: Int,
    output_mode: String,
    language: String,
) -> List[String]:
    return _meta_column(
        table,
        fraction_table,
        request,
        inverse,
        last_row,
        output_mode,
        language,
    )


def spalteMetaKonkretTheorieAbstrakt_SetHtmlParameters(
    request: MetaColumnRequest,
    inverse: Int,
    language: String,
) -> MetaColumnMetadata:
    return meta_column_metadata(request, inverse, language)


def spalteMetaKonkretTheorieAbstrakt_mainPart(
    table: CsvTable,
    fraction_table: CsvTable,
    request: MetaColumnRequest,
    inverse: Int,
    last_row: Int,
    output_mode: String,
    language: String,
) -> List[String]:
    return _meta_column(
        table,
        fraction_table,
        request,
        inverse,
        last_row,
        output_mode,
        language,
    )


def spalteMetaKonkretTheorieAbstrakt_VorwortBehandlungWieVorwortMeta(
    metavariable: Int,
    side: Int,
    depth: Int,
    language: String,
) -> String:
    return _meta_prefix(metavariable, side, depth, language)


def spalteMetaKonkretTheorieAbstrakt_mainPart_InsertingText(
    table: CsvTable,
    fraction_table: CsvTable,
    row: Int,
    request: MetaColumnRequest,
    inverse: Int,
    output_mode: String,
    language: String,
) -> String:
    return meta_column_value(
        table,
        fraction_table,
        row,
        request,
        inverse,
        output_mode,
        language,
    )


def getAllBrueche(table: CsvTable) -> List[MetaFraction]:
    return discover_meta_fractions(table)


def readOneCSVAndReturn(domain: String, path: String = "") raises -> CsvTable:
    return read_meta_fraction_csv(domain, path)


def findAllBruecheAndTheirCombinations(
    path: String = "",
) raises -> MetaColumnsCatalog:
    return load_meta_columns_catalog(path)


def spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie(
    main_table: CsvTable,
    fraction_table: CsvTable,
    value: MetaFraction,
    first_column: Int = 5,
    inverse_column: Int = 131,
    output_mode: String = "plain",
    is_not_universe: Bool = False,
) -> String:
    return meta_fraction_structure_value(
        main_table,
        fraction_table,
        value,
        first_column,
        inverse_column,
        output_mode,
        is_not_universe,
    )


def spalteMetaKonkretAbstrakt_UeberschriftenUndTags(
    request: MetaColumnRequest,
    inverse: Int,
    language: String,
) -> MetaColumnMetadata:
    return meta_column_metadata(request, inverse, language)


def spalteFuerGegenInnenAussenSeitlichPrim(
    table: CsvTable,
    commands: List[String],
    last_row: Int,
    language: String,
) -> PrimeEffectColumns:
    return generate_prime_effect_columns(table, commands, last_row, language)
