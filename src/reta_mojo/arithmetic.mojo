"""Native Mojo implementation of reta_architecture.arithmetic."""

from std.collections import Dict, List, Set
from std.collections.string import atol, ord
from .types import IntPair
from .number_theory import prime_factors as number_theory_prime_factors
from .row_ranges import range_to_numbers


def factor_pairs(value: Int, include_one: Bool = True) -> List[IntPair]:
    """Return exact integer factor pairs in ascending divisor order."""
    var pairs = List[IntPair]()
    var divisor = 2
    while divisor * divisor <= value:
        if value % divisor == 0:
            pairs.append(IntPair(value // divisor, divisor))
        divisor += 1
    if include_one:
        pairs.append(IntPair(value, 1))
    return pairs^


def prime_factors(value: Int, modulo: Bool = False) -> List[Int]:
    var factors = number_theory_prime_factors(value)
    if modulo:
        for index in range(len(factors)):
            factors[index] %= 24
    return factors^


def prime_repeat_pairs(values: List[Int]) -> List[IntPair]:
    """Group adjacent factors without Python's input-list mutation."""
    var result = List[IntPair]()
    if len(values) == 0:
        return result^
    var previous = values[0]
    var amount = 1
    for index in range(1, len(values)):
        if values[index] == previous:
            amount += 1
        else:
            result.append(IntPair(previous, amount))
            previous = values[index]
            amount = 1
    result.append(IntPair(previous, amount))
    return result^


def prime_repeat_labels(values: List[Int]) -> List[String]:
    """Return a homogeneous string representation of legacy primeRepeat output."""
    var grouped = prime_repeat_pairs(values)
    var result = List[String]()
    for index in range(len(grouped)):
        if grouped[index].second == 1:
            result.append(String(grouped[index].first))
        else:
            result.append(String(grouped[index].first) + "^" + String(grouped[index].second))
    return result^


def has_digit(text: String) -> Bool:
    for index in range(text.byte_length()):
        var code = ord(text[byte=index])
        if code >= 48 and code <= 57:
            return True
    return False


def divisor_range(range_expression: String) raises -> Tuple[List[String], Set[Int]]:
    """Expand rows and collect all non-trivial factor values sequentially."""
    var numbers = range_to_numbers(range_expression, False, 0)
    var divisor_values = Set[Int]()
    for number in numbers:
        var pairs = factor_pairs(number)
        for index in range(len(pairs)):
            divisor_values.add(pairs[index].first)
            divisor_values.add(pairs[index].second)
    if len(divisor_values) != 1 or 1 not in divisor_values:
        if 1 in divisor_values:
            divisor_values.remove(1)

    var string_values = List[String]()
    for value in divisor_values:
        string_values.append(String(value))
    return (string_values^, divisor_values^)


def modulo_table_lines(values: List[Int]) -> List[String]:
    """Return the arithmetic portion of the historical modulo table."""
    var lines = List[String]()
    for value_index in range(len(values)):
        var raw = values[value_index]
        for divisor in range(2, 26):
            var remainder = raw % divisor
            var complement = divisor - remainder
            lines.append(
                String(raw) + " % " + String(divisor) + " = " + String(remainder) + ", " + String(complement)
            )
    return lines^


def invert_int_value_dict(source: Dict[String, List[String]]) raises -> Dict[Int, List[String]]:
    """Invert stringified integer values into a typed integer-key dictionary.

    Unlike the Python implementation's accidental str-vs-int membership test,
    this version keeps all distinct source keys for each integer value.
    """
    var inverted = Dict[Int, List[String]]()
    for item in source.items():
        var source_key = item.key
        var values = item.value.copy()
        for value_index in range(len(values)):
            var int_value = atol(values[value_index])
            if int_value not in inverted:
                inverted[int_value] = List[String]()
            var known = False
            for key_index in range(len(inverted[int_value])):
                if inverted[int_value][key_index] == source_key:
                    known = True
                    break
            if not known:
                inverted[int_value].append(source_key)
    return inverted^


# Historical spellings retained where the return type is unambiguous.
def multiples(value: Int, include_one: Bool = True) -> List[IntPair]:
    return factor_pairs(value, include_one)


def primfaktoren(value: Int, modulo: Bool = False) -> List[Int]:
    return prime_factors(value, modulo)


def textHatZiffer(text: String) -> Bool:
    return has_digit(text)
