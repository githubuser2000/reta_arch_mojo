"""Incremental Mojo front end for reta.arch.

Commands beginning with --mojo- are native. Historical reta arguments are handled by ``compat_main.mojo`` until their
subsystem is ported.
"""

from std.sys import argv
from std.collections import List
from std.collections.string import atol
from reta_mojo.number_theory import prime_factors, prime_creativity, divisors
from reta_mojo.row_ranges import range_to_numbers
from reta_mojo.output_modes import colored_row_begin, output_mode_spec


def _print_int_list(values: List[Int]) -> None:
    print("[", end="")
    for index in range(len(values)):
        if index > 0:
            print(", ", end="")
        print(values[index], end="")
    print("]")


def _print_native_help() -> None:
    print("reta-mojo: inkrementeller nativer Port von reta.arch")
    print("  --mojo-prime N            Primfaktoren, Teiler und Kreativitätsklasse")
    print("  --mojo-range AUSDRUCK [MAX]  Zeilenbereich nativ expandieren")
    print("  --mojo-architecture       Anzahl der Kategorien/Funktoren/Transformationen")
    print("  --mojo-output MODUS ZEILE Renderer-Zeilenanfang erzeugen")
    print("  --mojo-help               Diese Hilfe")
    print("Die historische CLI steht über bin/reta-mojo-compat bereit.")


def _run_native(args: Span[StaticString, StaticConstantOrigin]) raises -> Bool:
    if len(args) < 2:
        return False
    var command = String(args[1])
    if command == "--mojo-help":
        _print_native_help()
        return True
    if command == "--mojo-prime":
        if len(args) < 3:
            raise Error("--mojo-prime benötigt eine ganze Zahl")
        var value = atol(String(args[2]))
        print("Zahl:", value)
        print("Primfaktoren: ", end="")
        _print_int_list(prime_factors(value))
        print("Teiler: ", end="")
        _print_int_list(divisors(value))
        print("Prime-Creativity-Klasse:", prime_creativity(value))
        return True
    if command == "--mojo-range":
        if len(args) < 3:
            raise Error("--mojo-range benötigt einen Bereichsausdruck")
        var maximum = 1028
        if len(args) >= 4:
            maximum = atol(String(args[3]))
        var values = range_to_numbers(String(args[2]), False, maximum)
        var ordered = List[Int]()
        for value in values:
            ordered.append(value)
        for i in range(1, len(ordered)):
            var key = ordered[i]
            var j = i - 1
            while j >= 0 and ordered[j] > key:
                ordered[j + 1] = ordered[j]
                j -= 1
            ordered[j + 1] = key
        print("Zeilen: ", end="")
        _print_int_list(ordered)
        return True
    if command == "--mojo-output":
        if len(args) < 4:
            raise Error("--mojo-output benötigt MODUS und ZEILE")
        var mode = String(args[2])
        var line = atol(String(args[3]))
        var spec = output_mode_spec(mode)
        if spec.canonical_name.byte_length() == 0:
            raise Error("unbekannter Ausgabemodus: " + mode)
        print(colored_row_begin(mode, line), end="")
        return True
    return False


def main() raises:
    var args = argv()
    if _run_native(args):
        return
    _print_native_help()
