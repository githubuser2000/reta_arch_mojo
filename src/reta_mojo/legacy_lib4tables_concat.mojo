"""Typed compatibility facade for ``libs/lib4tables_concat.py``.

The Python class contains almost no algorithms of its own: after constructing
legacy mutable sets it forwards all 34 non-constructor methods into generated-column,
meta-column, and concat-CSV architecture owners.  This module preserves that
public surface as an explicit mapping and provides typed convenience aliases
for the callable operations that remain useful to native clients.
"""

from std.collections import Dict, List
from .concat_csv import (
    ConcatCsvResult,
    RationalPair,
    RationalValue,
    append_concat_csv,
    combine_pair_groups,
    concat_csv_path,
    group_pairs_by_division,
    group_pairs_by_multiplication,
    expand_fraction_pairs,
)
from .csv_table import CsvTable
from .fraction_concat_columns import FractionConcatColumns, generate_fraction_concat_columns
from .generated_aliases import FractionColumnRequest, MetaColumnRequest, ModalConcept
from .generated_columns import (
    equality_freedom_value,
    mind_energy_topology_value,
    prime_creativity_value,
)
from .generated_table_columns import (
    GeneratedTableResult,
    apply_native_generated_columns,
    love_polygon_value,
    modal_logic_column,
    moon_relation_value,
    propagate_multiples_column,
)
from .meta_columns import MetaColumnsResult, generate_meta_columns
from .prime_cross_columns import PrimeCrossColumns, generate_prime_cross_columns
from .prime_universe_columns import (
    FractionPrimeUniverseColumns,
    PrimeUniverseColumns,
    generate_fractional_prime_universe_columns,
    generate_integer_prime_universe_columns,
)


@fieldwise_init
struct LegacyConcatMethod(Copyable):
    var legacy_name: String
    var owner_module: String
    var native_entry: String


@fieldwise_init
struct LegacyConcatSnapshot(Copyable):
    var method_mappings: List[LegacyConcatMethod]
    var csv_same_keys: List[Int]
    var csv_same_values: List[List[Int]]
    var state_sections: List[String]


@fieldwise_init
struct LegacyConcatState(Copyable):
    var ones: List[Int]
    var csvs_already_read: List[Int]
    var csv_same_keys: List[Int]
    var csv_same_values: List[List[Int]]
    var fractions_universe: List[RationalValue]
    var fractions_galaxy: List[RationalValue]
    var mul_star_universe: List[RationalPair]
    var div_star_universe: List[RationalPair]
    var mul_uniform_universe: List[RationalPair]
    var div_uniform_universe: List[RationalPair]
    var mul_star_galaxy: List[RationalPair]
    var div_star_galaxy: List[RationalPair]
    var mul_uniform_galaxy: List[RationalPair]
    var div_uniform_galaxy: List[RationalPair]


@fieldwise_init
struct LegacyPrimeUniverseResult(Copyable):
    var integer_columns: PrimeUniverseColumns
    var fractional_columns: FractionPrimeUniverseColumns


def _method(name: String, owner: String, entry: String) -> LegacyConcatMethod:
    return LegacyConcatMethod(name, owner, entry)


def legacy_concat_snapshot() -> LegacyConcatSnapshot:
    return LegacyConcatSnapshot(
        [
            _method("concatLovePolygon", "generated_table_columns.mojo", "love_polygon_value"),
            _method("gleichheitFreiheitVergleich", "generated_columns.mojo", "equality_freedom_value"),
            _method("geistEmotionEnergieMaterieTopologie", "generated_columns.mojo", "mind_energy_topology_value"),
            _method("concatGleichheitFreiheitDominieren", "generated_table_columns.mojo", "apply_native_generated_columns"),
            _method("concatGeistEmotionEnergieMaterieTopologie", "generated_table_columns.mojo", "apply_native_generated_columns"),
            _method("concatPrimCreativityType", "generated_columns.mojo", "prime_creativity_value"),
            _method("concatMondExponzierenLogarithmusTyp", "generated_table_columns.mojo", "moon_relation_value"),
            _method("concatVervielfacheZeile", "generated_table_columns.mojo", "propagate_multiples_column"),
            _method("concatModallogik", "generated_table_columns.mojo", "modal_logic_column"),
            _method("convertSetOfPaarenToDictOfNumToPaareDiv", "concat_csv.mojo", "group_pairs_by_division"),
            _method("convertSetOfPaarenToDictOfNumToPaareMul", "concat_csv.mojo", "group_pairs_by_multiplication"),
            _method("convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction", "concat_csv.mojo", "expand_fraction_pairs"),
            _method("combineDicts", "concat_csv.mojo", "combine_pair_groups"),
            _method("concat1PrimzahlkreuzProContra", "prime_cross_columns.mojo", "generate_prime_cross_columns"),
            _method("concat1RowPrimUniverse2", "prime_universe_columns.mojo", "generate_integer_prime_universe_columns + generate_fractional_prime_universe_columns"),
            _method("spalteMetaKontretTheorieAbstrakt_etc_1", "meta_columns.mojo", "generate_meta_columns"),
            _method("spalteMetaKonkretAbstrakt_isGanzZahlig", "meta_columns.mojo", "typed rational integrality"),
            _method("spalteMetaKontretTheorieAbstrakt_etc", "meta_columns.mojo", "generate_meta_columns"),
            _method("spalteMetaKonkretTheorieAbstrakt_SetHtmlParameters", "meta_columns.mojo", "MetaColumnsResult requests/inversions"),
            _method("spalteMetaKonkretTheorieAbstrakt_mainPart", "meta_columns.mojo", "generate_meta_columns"),
            _method("spalteMetaKonkretTheorieAbstrakt_VorwortBehandlungWieVorwortMeta", "meta_columns.mojo", "meta_column_value"),
            _method("spalteMetaKonkretTheorieAbstrakt_mainPart_InsertingText", "meta_columns.mojo", "meta_column_value"),
            _method("getAllBrueche", "meta_columns.mojo", "typed MetaFraction traversal"),
            _method("readOneCSVAndReturn", "csv_table.mojo", "read_semicolon_csv"),
            _method("findAllBruecheAndTheirCombinations", "concat_csv.mojo", "expand_fraction_pairs"),
            _method("spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie", "fraction_concat_columns.mojo", "fraction_domain_value"),
            _method("spalteMetaKonkretAbstrakt_UeberschriftenUndTags", "meta_columns.mojo", "generate_meta_columns"),
            _method("spalteFuerGegenInnenAussenSeitlichPrim", "prime_cross_columns.mojo", "generate_prime_cross_columns"),
            _method("readConcatCsv_tabelleDazuColchange", "concat_csv.mojo", "transform_fraction_concat_row"),
            _method("readConcatCsv", "concat_csv.mojo", "append_concat_csv"),
            _method("readConcatCSV_choseCsvFile", "concat_csv.mojo", "concat_csv_path"),
            _method("readConcatCsv_ChangeTableToAddToTable", "concat_csv.mojo", "prepare_concat_source"),
            _method("readConcatCsv_LoopBody", "concat_csv.mojo", "append_concat_csv selection plan"),
            _method("readConcatCsv_SetHtmlParamaters", "concat_csv.mojo", "ConcatColumnMetadata"),
        ],
        [1, 2, 3, 4, 5],
        [[1], [2, 4], [3, 5], [2, 4], [3, 5]],
        [
            "ones",
            "CSVsAlreadRead",
            "CSVsSame",
            "BruecheUni",
            "BruecheGal",
            "gebrRatMulSternUni",
            "gebrRatDivSternUni",
            "gebrRatMulGleichfUni",
            "gebrRatDivGleichfUni",
            "gebrRatMulSternGal",
            "gebrRatDivSternGal",
            "gebrRatMulGleichfGal",
            "gebrRatDivGleichfGal",
        ],
    )


def create_legacy_concat_state() -> LegacyConcatState:
    return LegacyConcatState(
        List[Int](),
        List[Int](),
        [1, 2, 3, 4, 5],
        [[1], [2, 4], [3, 5], [2, 4], [3, 5]],
        List[RationalValue](),
        List[RationalValue](),
        List[RationalPair](),
        List[RationalPair](),
        List[RationalPair](),
        List[RationalPair](),
        List[RationalPair](),
        List[RationalPair](),
        List[RationalPair](),
        List[RationalPair](),
    )


# Typed historical aliases.
def concatLovePolygon(
    table: CsvTable, row: Int, language: String = "german"
) -> String:
    return love_polygon_value(table, row, language)


def gleichheitFreiheitVergleich(
    number: Int, language: String = "german"
) -> String:
    return equality_freedom_value(number, language)


def geistEmotionEnergieMaterieTopologie(
    number: Int, language: String = "german"
) -> String:
    return mind_energy_topology_value(number, language)


def concatPrimCreativityType(
    number: Int, language: String = "german"
) -> String:
    return prime_creativity_value(number, language)


def concatMondExponzierenLogarithmusTyp(
    table: CsvTable,
    number: Int,
    source_column: Int,
    output_mode: String,
    language: String = "german",
) -> String:
    return moon_relation_value(
        table, number, source_column, output_mode, language
    )


def concatVervielfacheZeile(
    table: CsvTable,
    source_column: Int,
    last_row: Int,
    output_mode: String,
) -> CsvTable:
    return propagate_multiples_column(
        table, source_column, last_row, output_mode
    )


def concatModallogik(
    table: CsvTable,
    concept: ModalConcept,
    last_row: Int,
    output_mode: String,
    language: String = "german",
) -> List[String]:
    return modal_logic_column(
        table, concept, last_row, output_mode, language
    )


def convertSetOfPaarenToDictOfNumToPaareDiv(
    pairs: List[RationalPair], reversed: Bool = False
) raises -> Dict[Int, List[RationalPair]]:
    return group_pairs_by_division(pairs, reversed)


def convertSetOfPaarenToDictOfNumToPaareMul(
    pairs: List[RationalPair], reciprocal: Bool = False
) raises -> Dict[Int, List[RationalPair]]:
    return group_pairs_by_multiplication(pairs, reciprocal)


def convertFractionsToDictOfNumToPaareOfMulOfIntAndFraction(
    fractions: List[RationalValue],
    secondary: List[RationalValue],
    highest_row: Int,
    reciprocal: Bool = False,
) raises -> Dict[Int, List[RationalPair]]:
    return expand_fraction_pairs(
        fractions, secondary, highest_row, reciprocal
    )


def combineDicts(
    first: Dict[Int, List[RationalPair]],
    second: Dict[Int, List[RationalPair]],
) raises -> Dict[Int, List[RationalPair]]:
    return combine_pair_groups(first, second)


def concat1PrimzahlkreuzProContra(
    table: CsvTable,
    last_row: Int,
    output_mode: String,
    language: String = "german",
) -> PrimeCrossColumns:
    return generate_prime_cross_columns(
        table, last_row, output_mode, language
    )


def concat1RowPrimUniverse2(
    table: CsvTable,
    commands: List[String],
    last_row: Int,
    output_mode: String,
    language: String = "german",
) raises -> LegacyPrimeUniverseResult:
    return LegacyPrimeUniverseResult(
        generate_integer_prime_universe_columns(
            table, commands, last_row, output_mode, language
        ),
        generate_fractional_prime_universe_columns(
            table, commands, last_row, output_mode, language
        ),
    )


def spalteMetaKontretTheorieAbstrakt_etc_1(
    table: CsvTable,
    requests: List[MetaColumnRequest],
    last_row: Int,
    output_mode: String,
    language: String = "german",
) raises -> MetaColumnsResult:
    return generate_meta_columns(
        table, requests, last_row, output_mode, language
    )


def readConcatCsv(
    table: CsvTable,
    source: CsvTable,
    selected_table_columns: List[Int],
    table_kind: Int = 1,
    output_mode: String = "csv",
    language: String = "german",
) -> ConcatCsvResult:
    return append_concat_csv(
        table,
        source,
        selected_table_columns,
        table_kind,
        output_mode,
        language,
    )


def readConcatCSV_choseCsvFile(table_kind: Int) -> String:
    return concat_csv_path(table_kind)


def applyConcatGeneratedColumns(
    table: CsvTable,
    selected_columns: List[Int],
    modal_concepts: List[ModalConcept],
    meta_requests: List[MetaColumnRequest],
    fraction_requests: List[FractionColumnRequest],
    generated_commands: List[String],
    language: String,
    output_mode: String,
    last_row: Int,
) raises -> GeneratedTableResult:
    return apply_native_generated_columns(
        table,
        selected_columns,
        modal_concepts,
        meta_requests,
        fraction_requests,
        generated_commands,
        language,
        output_mode,
        last_row,
    )


def fractionConcatColumns(
    table: CsvTable,
    requests: List[FractionColumnRequest],
    last_row: Int,
    output_mode: String,
    language: String,
) raises -> FractionConcatColumns:
    return generate_fraction_concat_columns(
        table, requests, last_row, output_mode, language
    )
