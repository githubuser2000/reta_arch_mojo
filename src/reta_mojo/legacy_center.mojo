"""Typed native compatibility facade for historical ``libs/center.py``.

The Python module is now almost entirely a set of wrappers over architecture
owners.  This module preserves those public compatibility names while keeping
row-range parsing, arithmetic, console formatting, help text and terminal
geometry in native Mojo.
"""

from std.collections import Dict, List, Set
from .arithmetic import (
    divisor_range,
    factor_pairs,
    has_digit,
    invert_int_value_dict,
    modulo_table_lines,
    prime_factors,
    prime_repeat_labels,
    prime_repeat_pairs,
)
from .console_io import (
    chunks_strings,
    debug_pair_text,
    normalize_colored_cli_text,
    unique_everseen_strings,
)
from .native_cli_startup import native_cli_startup
from .resource_paths import asset_resource
from .row_ranges import (
    add_non_multiple_values,
    add_multiple_values,
    add_range_couple_values,
    add_single_range_segment,
    is_fraction_or_integer_range,
    is_fraction_range,
    is_fraction_range_token,
    is_row_range,
    is_row_range_token,
    parse_explicit_int_set,
    range_to_numbers,
)
from .runtime_compat import (
    NPM_EMO_1_PLUS_N,
    NPM_EMO_N,
    NPM_GAL_1_PLUS_N,
    NPM_GAL_N,
    NPM_GROE_1_PLUS_N,
    NPM_GROE_N,
    NPM_UNI_1_PLUS_N,
    NPM_UNI_N,
    npm_emotion,
    npm_galaxy,
    npm_n_values,
    npm_one_plus_n_values,
    npm_size,
    npm_universe,
)
from .terminal_geometry import terminal_columns
from .unicode_digits import has_unicode_digit
from .types import IntPair


@fieldwise_init
struct CenterTextWrapRuntime(Copyable, Equatable):
    var shell_width: Int
    var has_hyphenator: Bool
    var has_dictionary: Bool
    var has_fill: Bool


@fieldwise_init
struct LegacyCenterSnapshot(Copyable):
    var compatibility_names: List[String]
    var npm_values: List[Int]
    var native_owners: List[String]


def legacy_center_snapshot() -> LegacyCenterSnapshot:
    return LegacyCenterSnapshot(
        [
            "isZeilenBruchAngabe_betweenKommas",
            "isZeilenBruchOrGanzZahlAngabe",
            "isZeilenBruchAngabe",
            "isZeilenAngabe",
            "isZeilenAngabe_betweenKommas",
            "retaPromptHilfe",
            "retaHilfe",
            "getTextWrapThings",
            "x",
            "alxp",
            "chunks",
            "cliout",
            "strAsGeneratorToListOfNumStrs",
            "unique_everseen",
            "BereichToNumbers2",
            "BereichToNumbers2_EinBereich",
            "BereichToNumbers2_EinBereich_Menge",
            "BereichToNumbers2_EinBereich_Menge_nichtVielfache",
            "BereichToNumbers2_EinBereich_Menge_vielfache",
            "multiples",
            "teiler",
            "invert_dict_B",
            "textHatZiffer",
            "primfaktoren",
            "primRepeat",
            "primRepeat2",
            "moduloA",
        ],
        [
            NPM_GAL_N,
            NPM_GAL_1_PLUS_N,
            NPM_UNI_N,
            NPM_UNI_1_PLUS_N,
            NPM_EMO_N,
            NPM_EMO_1_PLUS_N,
            NPM_GROE_N,
            NPM_GROE_1_PLUS_N,
        ],
        [
            "row_ranges.mojo",
            "arithmetic.mojo",
            "console_io.mojo",
            "native_cli_startup.mojo",
            "terminal_geometry.mojo",
            "runtime_compat.mojo",
        ],
    )


# nPmEnum compatibility groups.
def gal() -> List[Int]:
    return npm_galaxy()


def uni() -> List[Int]:
    return npm_universe()


def emo() -> List[Int]:
    return npm_emotion()


def groe() -> List[Int]:
    return npm_size()


def n() -> List[Int]:
    return npm_n_values()


def einsPn() -> List[Int]:
    return npm_one_plus_n_values()


# Historical row-range spellings.
def isZeilenBruchAngabe_betweenKommas(text: String) -> Bool:
    return is_fraction_range_token(text)


def isZeilenBruchOrGanzZahlAngabe(text: String) raises -> Bool:
    return is_fraction_or_integer_range(text)


def isZeilenBruchAngabe(text: String) -> Bool:
    return is_fraction_range(text)


def isZeilenAngabe(text: String) raises -> Bool:
    return is_row_range(text)


def isZeilenAngabe_betweenKommas(text: String) raises -> Bool:
    return is_row_range_token(text)


def strAsGeneratorToListOfNumStrs(text: String) raises -> Set[Int]:
    var parsed = parse_explicit_int_set(text)
    if parsed.valid:
        return parsed.values.copy()
    return Set[Int]()


def BereichToNumbers2(
    text: String,
    vielfache: Bool = False,
    maxZahl: Int = 1028,
    allowLessEqZero: Bool = False,
) raises -> Set[Int]:
    return range_to_numbers(text, vielfache, maxZahl, allowLessEqZero)


def BereichToNumbers2_EinBereich(
    segment: String,
    mut dazu: Set[Int],
    mut hinfort: Set[Int],
    maxZahl: Int,
    vielfache: Bool,
) raises:
    add_single_range_segment(segment, dazu, hinfort, maxZahl, vielfache)


def BereichToNumbers2_EinBereich_Menge(
    range_couple: List[String],
    around: List[Int],
    maxZahl: Int,
    mut menge: Set[Int],
    vielfache: Bool,
) raises:
    # ``around`` is retained for signature parity. The historical owner also
    # recomputes it from the right-hand side of ``range_couple``.
    _ = around
    add_range_couple_values(range_couple, maxZahl, menge, vielfache)


def BereichToNumbers2_EinBereich_Menge_nichtVielfache(
    range_couple: List[String],
    around: List[Int],
    maxZahl: Int,
    mut menge: Set[Int],
) raises:
    if len(range_couple) != 2:
        return
    add_non_multiple_values(
        atol(range_couple[0]), atol(range_couple[1]), around, maxZahl, menge
    )


def BereichToNumbers2_EinBereich_Menge_vielfache(
    range_couple: List[String],
    around: List[Int],
    maxZahl: Int,
    mut menge: Set[Int],
) raises:
    if len(range_couple) != 2:
        return
    add_multiple_values(
        atol(range_couple[0]), atol(range_couple[1]), around, maxZahl, menge
    )


# Historical console/help compatibility surface.
def _read_asset(filename: String) raises -> String:
    var file = open(asset_resource(filename), "r")
    var payload = file.read()
    file.close()
    return payload^


def retaPromptHilfe(language: String = "german") raises -> String:
    return _read_asset(
        "reta_prompt_help_en.txt" if language == "english" else "reta_prompt_help_de.txt"
    )


def retaHilfe(language: String = "german") raises -> String:
    var tokens: List[String] = [
        "-language=english" if language == "english" else "-language=german",
        "-h",
    ]
    return native_cli_startup(tokens).output


def getTextWrapThings(maxLen: Int = 0) -> CenterTextWrapRuntime:
    # Native hard wrapping is always available. Optional Python dictionary and
    # fill callables are deliberately represented as typed capability flags.
    var width = maxLen if maxLen > 0 else terminal_columns()
    return CenterTextWrapRuntime(width, False, False, True)


def x(text1: String, text: String, infoLog: Bool = False, output: Bool = True) -> String:
    if infoLog and output:
        return debug_pair_text(text1, text)
    return String()


def alxp(text: String, infoLog: Bool = False, output: Bool = True) -> String:
    if infoLog and output:
        return text
    return String()


def chunks(values: List[String], size: Int) raises -> List[List[String]]:
    return chunks_strings(values, size)


def cliout(text: String, color: Bool = False, output: Bool = True) -> String:
    if not output:
        return String()
    if color and text.byte_length() > 0:
        return normalize_colored_cli_text(text)
    return text


def unique_everseen(values: List[String]) -> List[String]:
    return unique_everseen_strings(values)


# Historical arithmetic spellings.
def multiples(value: Int, mul1: Bool = True) -> List[IntPair]:
    return factor_pairs(value, mul1)


def teiler(range_expression: String) raises -> Tuple[List[String], Set[Int]]:
    return divisor_range(range_expression)


def invert_dict_B(source: Dict[String, List[String]]) raises -> Dict[Int, List[String]]:
    return invert_int_value_dict(source)


def textHatZiffer(text: String) -> Bool:
    return has_unicode_digit(text)


def primfaktoren(value: Int, modulo: Bool = False) -> List[Int]:
    return prime_factors(value, modulo)


def primRepeat(values: List[Int]) -> List[String]:
    return prime_repeat_labels(values)


def primRepeat2(values: List[Int]) -> List[IntPair]:
    return prime_repeat_pairs(values)


def moduloA(values: List[Int]) -> List[String]:
    return modulo_table_lines(values)
