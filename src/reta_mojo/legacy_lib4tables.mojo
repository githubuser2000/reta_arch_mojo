"""Native compatibility facade for historical ``libs/lib4tables.py``.

The Python file is a pure re-export surface over output syntax and number
-theory owners.  Mojo exposes the same named operations through typed wrappers
and describes syntax classes with ``OutputModeSpec`` values.
"""

from std.collections import List
from .number_theory import (
    divisors,
    is_prime_multiple,
    moon_number,
    prime_creativity,
    prime_cross_candidate,
    prime_cross_inner_candidate,
    prime_cross_outer_candidate,
    prime_factors,
    prime_multiples,
    prime_multiple_matches,
    prime_repeat,
)
from .output_modes import OutputModeSpec, output_mode_spec
from .types import IntPair


@fieldwise_init
struct LegacyLib4TablesSnapshot(Copyable):
    var exported_names: List[String]
    var native_owners: List[String]


def legacy_lib4tables_snapshot() -> LegacyLib4TablesSnapshot:
    return LegacyLib4TablesSnapshot(
        [
            "math",
            "NichtsSyntax",
            "OutputSyntax",
            "csvSyntax",
            "emacsSyntax",
            "markdownSyntax",
            "bbCodeSyntax",
            "htmlSyntax",
            "moonNumber",
            "primFak",
            "divisorGenerator",
            "primRepeat",
            "primCreativity",
            "primMultiple",
            "isPrimMultiple",
            "couldBePrimeNumberPrimzahlkreuz",
            "couldBePrimeNumberPrimzahlkreuz_fuer_innen",
            "couldBePrimeNumberPrimzahlkreuz_fuer_aussen",
        ],
        ["output_modes.mojo", "number_theory.mojo"],
    )


def NichtsSyntax() -> OutputModeSpec:
    return output_mode_spec("nichts")


def OutputSyntax() -> OutputModeSpec:
    return output_mode_spec("shell")


def csvSyntax() -> OutputModeSpec:
    return output_mode_spec("csv")


def emacsSyntax() -> OutputModeSpec:
    return output_mode_spec("emacs")


def markdownSyntax() -> OutputModeSpec:
    return output_mode_spec("markdown")


def bbCodeSyntax() -> OutputModeSpec:
    return output_mode_spec("bbcode")


def htmlSyntax() -> OutputModeSpec:
    return output_mode_spec("html")


def moonNumber(num: Int) -> Tuple[List[Int], List[Int]]:
    return moon_number(num)


def primFak(num: Int) -> List[Int]:
    return prime_factors(num)


def divisorGenerator(num: Int) -> List[Int]:
    return divisors(num)


def primRepeat(values: List[Int]) -> List[IntPair]:
    return prime_repeat(values)


def primCreativity(num: Int) -> Int:
    return prime_creativity(num)


def primMultiple(num: Int) -> List[IntPair]:
    return prime_multiples(num)


def isPrimMultiple(
    value: Int,
    requested_multiples: List[Int],
    dontReturnList: Bool = True,
) -> Bool:
    # Python changes the return type when ``dontReturnList`` is false. Mojo
    # keeps this compatibility spelling for the historical/default Bool path
    # and exposes the typed list path as ``isPrimMultipleMatches`` below.
    return is_prime_multiple(value, requested_multiples)


def isPrimMultipleMatches(
    value: Int,
    requested_multiples: List[Int],
) -> List[Bool]:
    return prime_multiple_matches(value, requested_multiples)


def couldBePrimeNumberPrimzahlkreuz(num: Int) -> Bool:
    return prime_cross_candidate(num)


def couldBePrimeNumberPrimzahlkreuz_fuer_innen(num: Int) -> Bool:
    return prime_cross_inner_candidate(num)


def couldBePrimeNumberPrimzahlkreuz_fuer_aussen(num: Int) -> Bool:
    return prime_cross_outer_candidate(num)
