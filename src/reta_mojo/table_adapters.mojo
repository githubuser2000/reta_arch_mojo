"""Native architecture-owned facades for ``table_adapters.py``.

The Python module is intentionally thin: four module functions and the two
historical stateful classes only forward into row filtering, table preparation,
wrapping, generated-column, meta-column and concat-CSV owners.  The native
version keeps that boundary explicit.  It provides a reproducible surface
snapshot, typed state for the observable ``Prepare`` constructor contract and
native convenience aliases.  The 34 ``Concat`` call aliases are re-exported
from ``legacy_lib4tables_concat.mojo``, which already owns the same historical
method surface.
"""

from std.collections import List, Set
from .csv_table import CsvTable
from .legacy_lib4tables_concat import *
from .number_theory import moon_number
from .row_filtering import (
    RowFilterConfig,
    counting_groups,
    default_row_filter_config,
    filter_original_lines,
)
from .row_ranges import is_row_range
from .table_preparation import (
    DisplaySelection,
    ParallelRowPreparationContext,
    PreparedIndexedRow,
    PreparedRowsSerialResult,
    prepare_cell_fragments,
    prepare_indexed_row,
    prepare_rows_serial,
    select_display_lines,
)
from .tag_schema import TagSchemaBundle, tags_for_column
from .table_wrapping import (
    TextWrapRuntime,
    default_text_wrap_runtime,
    split_more_if_not_small,
    width_for_row,
    wrap_cell_text,
)


@fieldwise_init
struct TableAdapterMethod(Copyable):
    var facade: String
    var legacy_name: String
    var owner_module: String
    var native_entry: String


@fieldwise_init
struct TableAdaptersSnapshot(Copyable):
    var module_functions: List[TableAdapterMethod]
    var prepare_methods: List[TableAdapterMethod]
    var concat_methods: List[TableAdapterMethod]
    var prepare_state_sections: List[String]
    var concat_state_sections: List[String]


def _method(
    facade: String,
    name: String,
    owner: String,
    entry: String,
) -> TableAdapterMethod:
    return TableAdapterMethod(facade, name, owner, entry)


def table_adapters_snapshot() -> TableAdaptersSnapshot:
    """Return the exact active Python facade surface in source order."""
    var concat_snapshot = legacy_concat_snapshot()
    return TableAdaptersSnapshot(
        [
            _method("module", "setShellRowsAmount", "table_wrapping.mojo", "TextWrapRuntime.shell_rows_amount"),
            _method("module", "chunks", "table_adapters.mojo", "chunks"),
            _method("module", "splitMoreIfNotSmall", "table_wrapping.mojo", "split_more_if_not_small"),
            _method("module", "alxwrap", "table_wrapping.mojo", "wrap_cell_text"),
        ],
        [
            _method("Prepare", "setZaehlungen", "row_filtering.mojo", "counting_groups"),
            _method("Prepare", "breitenn", "table_adapters.mojo", "widths_enabled"),
            _method("Prepare", "nummeriere", "table_adapters.mojo", "numbering"),
            _method("Prepare", "textWidth", "table_adapters.mojo", "text_width"),
            _method("Prepare", "wrapping", "table_wrapping.mojo", "wrap_cell_text"),
            _method("Prepare", "setWidth", "table_wrapping.mojo", "width_for_row"),
            _method("Prepare", "parametersCmdWithSomeBereich", "table_adapters.mojo", "parametersCmdWithSomeBereich"),
            _method("Prepare", "deleteDoublesInSets", "table_adapters.mojo", "deleteDoublesInSets"),
            _method("Prepare", "fromUntil", "table_adapters.mojo", "fromUntil"),
            _method("Prepare", "zeileWhichZaehlung", "row_filtering.mojo", "counting_groups"),
            _method("Prepare", "moonsun", "number_theory.mojo", "moon_number"),
            _method("Prepare", "FilterOriginalLines", "row_filtering.mojo", "filter_original_lines"),
            _method("Prepare", "prepare4out", "table_preparation.mojo", "prepare_indexed_row"),
            _method("Prepare", "prepare4out_beforeForLoop_SpaltenZeilenBestimmen", "table_preparation.mojo", "select_display_lines"),
            _method("Prepare", "prepare4out_LoopBody", "table_preparation.mojo", "prepare_indexed_row"),
            _method("Prepare", "prepare4out_Tagging", "tag_schema.mojo", "typed column tags"),
            _method("Prepare", "cellWork", "table_preparation.mojo", "prepare_cell_fragments"),
        ],
        [
            _method("Concat", "concatLovePolygon", "generated_table_columns.mojo", "love_polygon_value"),
            _method("Concat", "gleichheitFreiheitVergleich", "generated_columns.mojo", "equality_freedom_value"),
            _method("Concat", "geistEmotionEnergieMaterieTopologie", "generated_columns.mojo", "mind_energy_topology_value"),
            _method("Concat", "concatGleichheitFreiheitDominieren", "generated_table_columns.mojo", "apply_native_generated_columns"),
            _method("Concat", "concatGeistEmotionEnergieMaterieTopologie", "generated_table_columns.mojo", "apply_native_generated_columns"),
            _method("Concat", "concatPrimCreativityType", "generated_columns.mojo", "prime_creativity_value"),
            _method("Concat", "concatMondExponzierenLogarithmusTyp", "generated_table_columns.mojo", "moon_relation_value"),
            _method("Concat", "concatVervielfacheZeile", "generated_table_columns.mojo", "propagate_multiples_column"),
            _method("Concat", "concatModallogik", "generated_table_columns.mojo", "modal_logic_column"),
            _method("Concat", "convertSetOfPaarenToDictOfNumToPaareDiv", "concat_csv.mojo", "group_pairs_by_division"),
            _method("Concat", "convertSetOfPaarenToDictOfNumToPaareMul", "concat_csv.mojo", "group_pairs_by_multiplication"),
            _method("Concat", "convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction", "concat_csv.mojo", "expand_fraction_pairs"),
            _method("Concat", "combineDicts", "concat_csv.mojo", "combine_pair_groups"),
            _method("Concat", "concat1PrimzahlkreuzProContra", "prime_cross_columns.mojo", "generate_prime_cross_columns"),
            _method("Concat", "concat1RowPrimUniverse2", "prime_universe_columns.mojo", "generate_integer_prime_universe_columns + generate_fractional_prime_universe_columns"),
            _method("Concat", "spalteMetaKontretTheorieAbstrakt_etc_1", "meta_columns.mojo", "generate_meta_columns"),
            _method("Concat", "spalteMetaKonkretAbstrakt_isGanzZahlig", "meta_columns.mojo", "typed rational integrality"),
            _method("Concat", "spalteMetaKontretTheorieAbstrakt_etc", "meta_columns.mojo", "generate_meta_columns"),
            _method("Concat", "spalteMetaKonkretTheorieAbstrakt_SetHtmlParameters", "meta_columns.mojo", "MetaColumnsResult requests/inversions"),
            _method("Concat", "spalteMetaKonkretTheorieAbstrakt_mainPart", "meta_columns.mojo", "generate_meta_columns"),
            _method("Concat", "spalteMetaKonkretTheorieAbstrakt_VorwortBehandlungWieVorwortMeta", "meta_columns.mojo", "meta_column_value"),
            _method("Concat", "spalteMetaKonkretTheorieAbstrakt_mainPart_InsertingText", "meta_columns.mojo", "meta_column_value"),
            _method("Concat", "getAllBrueche", "meta_columns.mojo", "typed MetaFraction traversal"),
            _method("Concat", "readOneCSVAndReturn", "csv_table.mojo", "read_semicolon_csv"),
            _method("Concat", "findAllBruecheAndTheirCombinations", "concat_csv.mojo", "expand_fraction_pairs"),
            _method("Concat", "spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie", "fraction_concat_columns.mojo", "fraction_domain_value"),
            _method("Concat", "spalteMetaKonkretAbstrakt_UeberschriftenUndTags", "meta_columns.mojo", "generate_meta_columns"),
            _method("Concat", "spalteFuerGegenInnenAussenSeitlichPrim", "prime_cross_columns.mojo", "generate_prime_cross_columns"),
            _method("Concat", "readConcatCsv_tabelleDazuColchange", "concat_csv.mojo", "transform_fraction_concat_row"),
            _method("Concat", "readConcatCsv", "concat_csv.mojo", "append_concat_csv"),
            _method("Concat", "readConcatCSV_choseCsvFile", "concat_csv.mojo", "concat_csv_path"),
            _method("Concat", "readConcatCsv_ChangeTableToAddToTable", "concat_csv.mojo", "prepare_concat_source"),
            _method("Concat", "readConcatCsv_LoopBody", "concat_csv.mojo", "append_concat_csv selection plan"),
            _method("Concat", "readConcatCsv_SetHtmlParamaters", "concat_csv.mojo", "ConcatColumnMetadata"),
        ],
        [
            "tables",
            "hoechsteZeile",
            "originalLinesRange",
            "shellRowsAmount",
            "zaehlungen",
            "religionNumbers",
            "gezaehlt",
            "ifZeilenSetted",
        ],
        concat_snapshot.state_sections.copy(),
    )


@fieldwise_init
struct PrepareAdapterState(Copyable):
    """Typed observable state of the historical ``Prepare`` constructor."""
    var row_filter: RowFilterConfig
    var original_lines: List[Int]
    var shell_rows_amount: Int
    var counting_group_by_row: List[Int]
    var religion_numbers: List[Int]
    var counted: Bool
    var rows_were_set: Bool
    var widths_enabled: Bool
    var numbering: Bool
    var text_width: Int
    var widths: List[Int]
    var rows_as_numbers: Set[Int]
    var wrapping_runtime: TextWrapRuntime


def create_prepare_adapter_state(
    highest_main: Int = 1024,
    highest_multiple: Int = 163,
    shell_rows_amount: Int = 0,
) -> PrepareAdapterState:
    var original_lines = List[Int]()
    for value in range(highest_main + 4):
        original_lines.append(value)
    var runtime = default_text_wrap_runtime()
    runtime.shell_rows_amount = shell_rows_amount
    return PrepareAdapterState(
        RowFilterConfig(highest_main, highest_multiple, False),
        original_lines^,
        shell_rows_amount,
        List[Int](),
        List[Int](),
        False,
        False,
        False,
        False,
        21,
        List[Int](),
        Set[Int](),
        runtime^,
    )


def setShellRowsAmount(
    mut state: PrepareAdapterState,
    shell_rows_amount: Int,
) -> None:
    state.shell_rows_amount = shell_rows_amount
    state.wrapping_runtime.shell_rows_amount = shell_rows_amount


def chunks(values: List[String], size: Int) -> List[List[String]]:
    var result = List[List[String]]()
    if size <= 0:
        return result^
    var index = 0
    while index < len(values):
        var part = List[String]()
        var stop = min(index + size, len(values))
        for position in range(index, stop):
            part.append(values[position])
        result.append(part^)
        index += size
    return result^


def splitMoreIfNotSmall(
    values: List[String],
    target_length: Int,
) -> List[String]:
    return split_more_if_not_small(values, target_length)


def alxwrap(
    text: String,
    length: Int,
    runtime: TextWrapRuntime = default_text_wrap_runtime(),
) -> List[String]:
    var wrapped = wrap_cell_text(text, length, runtime)
    if wrapped.wrapped:
        return wrapped.parts.copy()
    return [text]


def setZaehlungen(mut state: PrepareAdapterState, _num: Int = 0) -> None:
    if state.counted:
        return
    state.counting_group_by_row = counting_groups(state.row_filter.highest_main)
    state.counted = True


def breitenn(state: PrepareAdapterState) -> Bool:
    return state.widths_enabled


def set_breitenn(mut state: PrepareAdapterState, value: Bool) -> None:
    state.widths_enabled = value


def nummeriere(state: PrepareAdapterState) -> Bool:
    return state.numbering


def set_nummeriere(mut state: PrepareAdapterState, value: Bool) -> None:
    state.numbering = value


def textWidth(state: PrepareAdapterState) -> Int:
    return state.text_width


def set_textWidth(mut state: PrepareAdapterState, value: Int) -> None:
    state.text_width = value


def wrapping(
    state: PrepareAdapterState,
    text: String,
    length: Int,
) -> List[String]:
    return alxwrap(text, length, state.wrapping_runtime)


def setWidth(
    state: PrepareAdapterState,
    row_to_display: Int,
    combi_rows: Int = 0,
) -> Int:
    return width_for_row(
        state.shell_rows_amount,
        len(state.rows_as_numbers),
        state.widths,
        state.text_width,
        row_to_display,
        combi_rows,
    )


def parametersCmdWithSomeBereich(
    ranges: String,
    symbol: String,
    negative_prefix: String,
    ignore_negative: Bool = False,
) raises -> Set[String]:
    var result = Set[String]()
    if ignore_negative:
        if is_row_range(ranges):
            result.add("_" + symbol + "_" + ranges)
        return result^

    var pieces = ranges.split(",")
    for index in range(len(pieces)):
        var piece = String(pieces[index])
        if piece.byte_length() == 0:
            continue
        var has_negative_prefix = negative_prefix.byte_length() > 0
        var accepted = (
            piece.startswith(negative_prefix)
            if has_negative_prefix
            else not piece.startswith("-")
        )
        if not accepted:
            continue
        if has_negative_prefix:
            piece = String(StringSlice(piece)[byte=negative_prefix.byte_length():])
        if is_row_range(piece):
            result.add("_" + symbol + "_" + piece)
    return result^


def deleteDoublesInSets(
    first: Set[Int],
    second: Set[Int],
) -> Tuple[Set[Int], Set[Int]]:
    var clean_first = Set[Int]()
    var clean_second = Set[Int]()
    for value in first:
        if value not in second:
            clean_first.add(value)
    for value in second:
        if value not in first:
            clean_second.add(value)
    return (clean_first^, clean_second^)


def fromUntil(values: List[Int]) -> Tuple[Int, Int]:
    if len(values) == 1:
        return (1, values[0])
    if len(values) == 2:
        return (values[0], values[1])
    return (1, 1)


def zeileWhichZaehlung(
    mut state: PrepareAdapterState,
    row: Int,
) -> Int:
    if not state.counted:
        setZaehlungen(state)
    if row >= 0 and row < len(state.counting_group_by_row):
        return state.counting_group_by_row[row]
    return 0


def moonsun(
    values: Set[Int],
    moon_not_sun: Bool,
) -> Set[Int]:
    var result = Set[Int]()
    for value in values:
        var is_moon = len(moon_number(value)[0]) > 0
        if is_moon == moon_not_sun:
            result.add(value)
    return result^


def FilterOriginalLines(
    state: PrepareAdapterState,
    initial: Set[Int],
    conditions: List[String],
) raises -> Set[Int]:
    var config = state.row_filter.copy()
    config.rows_were_set = state.rows_were_set
    return filter_original_lines(config, initial, conditions)


def prepare4out_beforeForLoop_SpaltenZeilenBestimmen(
    state: PrepareAdapterState,
    table: CsvTable,
    positive_conditions: List[String],
    negative_conditions: List[String],
) raises -> DisplaySelection:
    var config = state.row_filter.copy()
    config.rows_were_set = state.rows_were_set
    return select_display_lines(
        config, table, positive_conditions, negative_conditions
    )


def prepare4out(
    row_indexes: List[Int],
    rows: List[List[String]],
    context: ParallelRowPreparationContext,
) -> PreparedRowsSerialResult:
    """Typed orchestration alias for the independently prepared data rows.

    Header/tag mutation remains serial at the caller, matching the Python
    architecture owner and the Stage-11j thread boundary.
    """
    return prepare_rows_serial(row_indexes, rows, context)


def prepare4out_LoopBody(
    row_index: Int,
    line: List[String],
    context: ParallelRowPreparationContext,
) -> PreparedIndexedRow:
    return prepare_indexed_row(row_index, line, context)


def prepare4out_Tagging(
    schema: TagSchemaBundle,
    source_column: Int,
    kombi_csv_number: Int = -1,
) -> List[Int]:
    """Return the tags that Python glues onto one selected source column.

    ``-1`` selects the primary table, ``0`` the first combination table and
    ``1`` the second combination table.
    """
    return tags_for_column(schema, source_column, kombi_csv_number)


def cellWork(
    state: PrepareAdapterState,
    cell: String,
    width: Int,
) -> List[String]:
    return prepare_cell_fragments(cell, width, state.wrapping_runtime)
