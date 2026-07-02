from std.collections import Dict, List
from std.sys import argv
from reta_mojo.legacy_center import (
    BereichToNumbers2,
    alxp,
    chunks,
    cliout,
    einsPn,
    emo,
    gal,
    groe,
    invert_dict_B,
    isZeilenAngabe,
    isZeilenAngabe_betweenKommas,
    isZeilenBruchAngabe,
    isZeilenBruchAngabe_betweenKommas,
    isZeilenBruchOrGanzZahlAngabe,
    moduloA,
    multiples,
    n,
    primRepeat as center_primRepeat,
    primRepeat2,
    primfaktoren,
    retaHilfe,
    retaPromptHilfe,
    textHatZiffer,
    teiler,
    uni,
    unique_everseen,
    x,
)
from reta_mojo.legacy_lib4tables import (
    NichtsSyntax,
    OutputSyntax,
    bbCodeSyntax,
    couldBePrimeNumberPrimzahlkreuz,
    couldBePrimeNumberPrimzahlkreuz_fuer_aussen,
    couldBePrimeNumberPrimzahlkreuz_fuer_innen,
    csvSyntax,
    divisorGenerator,
    emacsSyntax,
    htmlSyntax,
    isPrimMultiple,
    isPrimMultipleMatches,
    legacy_lib4tables_snapshot,
    markdownSyntax,
    moonNumber,
    primCreativity,
    primFak,
    primMultiple,
    primRepeat as lib_primRepeat,
)


def _bool(value: Bool) -> String:
    return "1" if value else "0"


def _int_list(values: List[Int]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += String(values[index])
    return result^


def _string_list(values: List[String]) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += ","
        result += values[index]
    return result^


def main() raises:
    var args = argv()
    if len(args) > 1:
        var command = String(args[1])
        if command == "reta-help-de":
            print(retaHilfe("german"), end="")
            return
        if command == "reta-help-en":
            print(retaHilfe("english"), end="")
            return
        if command == "prompt-help-de":
            print(retaPromptHilfe("german"), end="")
            return
        if command == "prompt-help-en":
            print(retaPromptHilfe("english"), end="")
            return

    print("npm=" + _int_list(gal()) + "|" + _int_list(uni()) + "|" + _int_list(emo()) + "|" + _int_list(groe()) + "|" + _int_list(n()) + "|" + _int_list(einsPn()))
    print("rowchecks=" + _bool(isZeilenBruchAngabe_betweenKommas("1/2-3/4")) + _bool(isZeilenBruchOrGanzZahlAngabe("1-3,4/5")) + _bool(isZeilenBruchAngabe("1/2,3/4")) + _bool(isZeilenAngabe("1-4,-2")) + _bool(isZeilenAngabe_betweenKommas("{1,3,5}")))
    var rows = BereichToNumbers2("1-4,-2")
    print("range=" + _bool(1 in rows) + _bool(2 in rows) + _bool(3 in rows) + _bool(4 in rows) + ":" + String(len(rows)))
    var unique = unique_everseen(["a", "b", "a", "c", "b"])
    print("unique=" + _string_list(unique))
    var chunked = chunks(["a", "b", "c", "d", "e"], 2)
    print("chunks=" + String(len(chunked)) + ":" + chunked[0][0] + chunked[0][1] + ":" + chunked[2][0])
    print("console=" + cliout("  a\n  b  ", True) + "|" + x("value", "42", True) + "|" + alxp("42", True))
    print("digits=" + _bool(textHatZiffer("abc2")) + _bool(textHatZiffer("abc٢")) + _bool(textHatZiffer("abc²")) + _bool(textHatZiffer("abc⑵")) + _bool(textHatZiffer("abc四")))
    var factors = primfaktoren(72)
    var labels = center_primRepeat(factors)
    var grouped = primRepeat2(factors)
    print("center-prime=" + _int_list(factors) + "|" + _string_list(labels) + "|" + String(grouped[0].first) + "^" + String(grouped[0].second) + "," + String(grouped[1].first) + "^" + String(grouped[1].second))
    var pairs = multiples(12)
    print("pairs=" + String(len(pairs)) + ":" + String(pairs[0].first) + "x" + String(pairs[0].second) + ":" + String(pairs[len(pairs)-1].first) + "x" + String(pairs[len(pairs)-1].second))
    var divs = teiler("12")
    print("teiler=" + _bool(1 in divs[1]) + _bool(2 in divs[1]) + _bool(3 in divs[1]) + _bool(4 in divs[1]) + _bool(6 in divs[1]) + _bool(12 in divs[1]) + ":" + String(len(divs[1])))
    var source = Dict[String, List[String]]()
    source["a"] = ["2", "3"]
    source["b"] = ["3"]
    var inverted = invert_dict_B(source)
    print("invert=" + String(len(inverted[2])) + ":" + String(len(inverted[3])))
    print("modulo=" + String(len(moduloA([5]))) + ":" + moduloA([5])[0])

    var exports = legacy_lib4tables_snapshot().exported_names.copy()
    print("libexports=" + _string_list(exports))
    print("syntax=" + OutputSyntax().syntax_class_name + "," + NichtsSyntax().syntax_class_name + "," + csvSyntax().canonical_name + "," + emacsSyntax().canonical_name + "," + markdownSyntax().canonical_name + "," + bbCodeSyntax().canonical_name + "," + htmlSyntax().canonical_name)
    var lib_factors = primFak(360)
    var lib_grouped = lib_primRepeat(primFak(72))
    var divisors = divisorGenerator(36)
    var prime_multiples = primMultiple(12)
    print("libnumber=" + String(len(lib_factors)) + ":" + String(len(divisors)) + ":" + String(lib_grouped[0].first) + "^" + String(lib_grouped[0].second) + ":" + String(primCreativity(36)) + ":" + String(prime_multiples[0].first) + "x" + String(prime_multiples[0].second) + ":" + _bool(isPrimMultiple(12, [6])) + _bool(isPrimMultiple(12, [7])))
    var match_vector = isPrimMultipleMatches(12, [6, 7])
    var match_bits = String()
    for index in range(len(match_vector)):
        match_bits += _bool(match_vector[index])
    print("libmatches=" + match_bits + ":" + String(len(match_vector)))
    print("cross=" + _bool(couldBePrimeNumberPrimzahlkreuz(29)) + _bool(couldBePrimeNumberPrimzahlkreuz_fuer_innen(29)) + _bool(couldBePrimeNumberPrimzahlkreuz_fuer_aussen(29)))
    var moon = moonNumber(64)
    print("moon=" + _int_list(moon[0]) + "|" + _int_list(moon[1]))
