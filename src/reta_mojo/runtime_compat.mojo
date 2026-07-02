"""Typed native compatibility surface for ``reta_architecture.runtime_compat``.

The Python module is a dependency-inversion facade over row ranges, arithmetic,
console formatting, help assets and a handful of historical constants.  This
Mojo owner preserves that complete callable surface without importing Python or
embedding a dynamic interpreter.
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
from .row_ranges import is_row_range, range_to_numbers
from .terminal_geometry import terminal_columns
from .types import IntPair


comptime NPM_GAL_N = 2
comptime NPM_GAL_1_PLUS_N = 3
comptime NPM_UNI_N = 4
comptime NPM_UNI_1_PLUS_N = 5
comptime NPM_EMO_N = 6
comptime NPM_EMO_1_PLUS_N = 7
comptime NPM_GROE_N = 8
comptime NPM_GROE_1_PLUS_N = 9

comptime RUNTIME_COMPAT_COMMA_PATTERN = ",(?![^\\[\\]\\{\\}\\(\\)]*[\\]\\}\\)])"
comptime RUNTIME_COMPAT_PRIME_CROSS_NAME = "Primzahlkreuz_pro_contra"
comptime RUNTIME_COMPAT_PRIME_CROSS_DESCRIPTION = "nachvollziehen_emotional_oder_geistig_durch_Primzahl-Kreuz-Algorithmus_(15)"


@fieldwise_init
struct RuntimeCompatTextWrapRuntime(Copyable, Equatable):
    var shell_rows_amount: Int
    var has_hyphenator: Bool
    var has_dictionary: Bool
    var has_fill: Bool


@fieldwise_init
struct RuntimeCompatSnapshot(Copyable):
    var callable_names: List[String]
    var global_names: List[String]
    var npm_values: List[Int]
    var multiplication_pairs: List[List[String]]
    var comma_split_pattern: String
    var prime_cross_strings: List[String]
    var native_owners: List[String]


def npm_galaxy() -> List[Int]:
    return [NPM_GAL_N, NPM_GAL_1_PLUS_N]


def npm_universe() -> List[Int]:
    return [NPM_UNI_N, NPM_UNI_1_PLUS_N]


def npm_emotion() -> List[Int]:
    return [NPM_EMO_N, NPM_EMO_1_PLUS_N]


def npm_size() -> List[Int]:
    return [NPM_GROE_N, NPM_GROE_1_PLUS_N]


def npm_n_values() -> List[Int]:
    return [NPM_GAL_N, NPM_UNI_N, NPM_EMO_N, NPM_GROE_N]


def npm_one_plus_n_values() -> List[Int]:
    return [
        NPM_GAL_1_PLUS_N,
        NPM_UNI_1_PLUS_N,
        NPM_EMO_1_PLUS_N,
        NPM_GROE_1_PLUS_N,
    ]


def runtime_compat_multiplications() -> List[List[String]]:
    return [["Multiplikationen", ""]]


def runtime_compat_prime_cross_strings() -> List[String]:
    return [
        RUNTIME_COMPAT_PRIME_CROSS_NAME,
        RUNTIME_COMPAT_PRIME_CROSS_DESCRIPTION,
    ]


def runtime_compat_snapshot() -> RuntimeCompatSnapshot:
    return RuntimeCompatSnapshot(
        [
            "BereichToNumbers2",
            "isZeilenAngabe",
            "retaPromptHilfe",
            "retaHilfe",
            "getTextWrapThings",
            "x",
            "alxp",
            "chunks",
            "cliout",
            "unique_everseen",
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
            "REPO_ROOT",
            "i18n",
            "ROW_RANGE_SYNTAX",
            "ROW_RANGE_MORPHISMS",
            "ARITHMETIC_MORPHISMS",
            "CONSOLE_IO_MORPHISMS",
            "infoLog",
            "output",
            "pp",
            "Multiplikationen",
            "kpattern",
            "Primzahlkreuz_pro_contra_strs",
            "isZeilenAngabe",
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
        runtime_compat_multiplications(),
        RUNTIME_COMPAT_COMMA_PATTERN,
        runtime_compat_prime_cross_strings(),
        [
            "row_ranges.mojo",
            "arithmetic.mojo",
            "console_io.mojo",
            "native_cli_startup.mojo",
            "resource_paths.mojo",
            "terminal_geometry.mojo",
        ],
    )


def fill_both(mut first: List[String], mut second: List[String]) -> None:
    while len(first) < len(second):
        first.append("")
    while len(second) < len(first):
        second.append("")


# Historical architecture-local spellings.
def BereichToNumbers2(
    mehrere_bereiche: String,
    vielfache: Bool = False,
    max_zahl: Int = 1028,
    allow_less_equal_zero: Bool = False,
) raises -> Set[Int]:
    return range_to_numbers(
        mehrere_bereiche,
        vielfache,
        max_zahl,
        allow_less_equal_zero,
    )


def isZeilenAngabe(text: String) raises -> Bool:
    return is_row_range(text)


def _read_runtime_asset(filename: String) raises -> String:
    var file = open(asset_resource(filename), "r")
    var payload = file.read()
    file.close()
    return payload^


def retaPromptHilfe(language: String = "german") raises -> String:
    return _read_runtime_asset(
        "reta_prompt_help_en.txt"
        if language == "english"
        else "reta_prompt_help_de.txt"
    )


def retaHilfe(language: String = "german") raises -> String:
    var tokens: List[String] = [
        "-language=english" if language == "english" else "-language=german",
        "-h",
    ]
    return native_cli_startup(tokens).output


def getTextWrapThings(max_len: Int = 0) -> RuntimeCompatTextWrapRuntime:
    var width = max_len if max_len > 0 else terminal_columns()
    # Native hard wrapping is always present. Python callable objects are
    # represented as explicit capability flags rather than dynamic values.
    return RuntimeCompatTextWrapRuntime(width, False, False, True)


def x(
    text1: String,
    text: String,
    info_log: Bool = False,
    output_enabled: Bool = True,
) -> String:
    if info_log and output_enabled:
        return debug_pair_text(text1, text)
    return ""


def alxp(
    text: String,
    info_log: Bool = False,
    output_enabled: Bool = True,
) -> String:
    return text if info_log and output_enabled else ""


def chunks(values: List[String], size: Int) raises -> List[List[String]]:
    return chunks_strings(values, size)


def cliout(
    text: String,
    color: Bool = False,
    stype: String = "",
    output_enabled: Bool = True,
) -> String:
    _ = stype
    if not output_enabled:
        return ""
    return normalize_colored_cli_text(text) if color else text


def unique_everseen(values: List[String]) -> List[String]:
    return unique_everseen_strings(values)


def multiples(value: Int, mul1: Bool = True) -> List[IntPair]:
    return factor_pairs(value, mul1)


def teiler(range_expression: String) raises -> Tuple[List[String], Set[Int]]:
    return divisor_range(range_expression)


def invert_dict_B(
    source: Dict[String, List[String]],
) raises -> Dict[Int, List[String]]:
    return invert_int_value_dict(source)


def textHatZiffer(text: String) -> Bool:
    return has_digit(text)


def primfaktoren(value: Int, modulo: Bool = False) -> List[Int]:
    return prime_factors(value, modulo)


def primRepeat(values: List[Int]) -> List[String]:
    return prime_repeat_labels(values)


def primRepeat2(values: List[Int]) -> List[IntPair]:
    return prime_repeat_pairs(values)


def moduloA(values: List[Int]) -> List[String]:
    return modulo_table_lines(values)
