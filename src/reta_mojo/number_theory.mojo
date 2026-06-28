"""Native Mojo implementation of reta_architecture.number_theory.

The public snake_case names are the canonical Mojo API. Historical Python names
are preserved as thin aliases where Mojo overloading permits it.
"""

from std.collections import List, Set
from .types import IntPair


def _int_pow(base: Int, exponent: Int) -> Int:
    var result = 1
    for _ in range(exponent):
        result *= base
    return result


def moon_number(num: Int) -> Tuple[List[Int], List[Int]]:
    """Return integer bases and historical exponent markers for moon numbers."""
    var results = List[Int]()
    var exponents = List[Int]()
    if num <= 2:
        return (results^, exponents^)

    for exponent in range(2, num):
        # Find an exact integer root. This replaces Python's floating five-decimal
        # test with an exact test and therefore avoids false positives.
        var base = 2
        while base <= num:
            var value = _int_pow(base, exponent)
            if value == num:
                results.append(base)
                exponents.append(exponent - 2)
                break
            if value > num:
                break
            base += 1
    return (results^, exponents^)


def prime_factors(n: Int) -> List[Int]:
    """Return prime factors with repetitions, preserving legacy order."""
    var factors = List[Int]()
    var remaining = n
    while remaining > 1:
        var candidate = 2
        var found = False
        var prime = remaining
        while candidate * candidate <= n and not found:
            if remaining % candidate == 0:
                found = True
                prime = candidate
            else:
                candidate += 1
        factors.append(prime)
        remaining //= prime
    return factors^


def divisors(n: Int) -> List[Int]:
    """Return all positive divisors in ascending order."""
    var small = List[Int]()
    var large = List[Int]()
    var i = 1
    while i * i <= n:
        if n % i == 0:
            small.append(i)
            if i * i != n:
                large.append(n // i)
        i += 1
    var index = len(large)
    while index > 0:
        index -= 1
        small.append(large[index])
    return small^


def prime_repeat(factors: List[Int]) -> List[IntPair]:
    """Group repeated adjacent prime factors as (prime, amount)."""
    var grouped = List[IntPair]()
    if len(factors) == 0:
        return grouped^

    var current = factors[0]
    var amount = 1
    for index in range(1, len(factors)):
        if factors[index] == current:
            amount += 1
        else:
            grouped.append(IntPair(current, amount))
            current = factors[index]
            amount = 1
    grouped.append(IntPair(current, amount))
    return grouped^


def _nontrivial_divisor_set(n: Int) -> Set[Int]:
    var result = Set[Int]()
    var values = divisors(n)
    for index in range(len(values)):
        if values[index] != 1:
            result.add(values[index])
    return result^


def prime_creativity(num: Int) -> Int:
    """Classify a number using Reta's historical prime-creativity classes."""
    if num == 0:
        return 0

    var grouped = prime_repeat(prime_factors(num))
    if len(grouped) == 1 and grouped[0].second == 1:
        return 1
    if len(grouped) == 1:
        return 3
    if len(grouped) < 1:
        return 0

    var intersection = Set[Int]()
    var has_intersection = False
    for index in range(len(grouped)):
        var exponent_divisors = _nontrivial_divisor_set(grouped[index].second)
        if len(exponent_divisors) == 0:
            return 2
        if not has_intersection:
            for value in exponent_divisors:
                intersection.add(value)
            has_intersection = True
        else:
            var narrowed = Set[Int]()
            for value in intersection:
                if value in exponent_divisors:
                    narrowed.add(value)
            intersection = narrowed^

    if has_intersection and len(intersection) != 0:
        return 3
    return 2


def prime_multiples(n: Int) -> List[IntPair]:
    """Return (prime, quotient) pairs, including the legacy (1, n) pair."""
    var result = List[IntPair]()
    result.append(IntPair(1, n))
    var grouped = prime_repeat(prime_factors(n))
    for index in range(len(grouped)):
        result.append(IntPair(grouped[index].first, n // grouped[index].first))
    return result^


def prime_multiple_matches(value: Int, requested_multiples: List[Int]) -> List[Bool]:
    var matches = List[Bool]()
    var candidates = prime_multiples(value)
    for requested_index in range(len(requested_multiples)):
        for candidate_index in range(len(candidates)):
            matches.append(requested_multiples[requested_index] == candidates[candidate_index].second)
    return matches^


def is_prime_multiple(value: Int, requested_multiples: List[Int]) -> Bool:
    var candidates = prime_multiples(value)
    for requested_index in range(len(requested_multiples)):
        for candidate_index in range(len(candidates)):
            if requested_multiples[requested_index] == candidates[candidate_index].second:
                return True
    return False


def prime_cross_candidate(num: Int) -> Bool:
    var residue = num % 24
    return residue == 1 or residue == 5 or residue == 7 or residue == 11 or residue == 13 or residue == 17 or residue == 19 or residue == 23


def prime_cross_inner_candidate(num: Int) -> Bool:
    var residue = num % 24
    return residue == 5 or residue == 11 or residue == 17 or residue == 23


def prime_cross_outer_candidate(num: Int) -> Bool:
    var residue = num % 24
    return residue == 1 or residue == 7 or residue == 13 or residue == 19


# Historical compatibility aliases.
def moonNumber(num: Int) -> Tuple[List[Int], List[Int]]:
    return moon_number(num)


def primFak(n: Int) -> List[Int]:
    return prime_factors(n)


def primCreativity(num: Int) -> Int:
    return prime_creativity(num)


def primMultiple(n: Int) -> List[IntPair]:
    return prime_multiples(n)


def couldBePrimeNumberPrimzahlkreuz(num: Int) -> Bool:
    return prime_cross_candidate(num)


def couldBePrimeNumberPrimzahlkreuz_fuer_innen(num: Int) -> Bool:
    return prime_cross_inner_candidate(num)


def couldBePrimeNumberPrimzahlkreuz_fuer_aussen(num: Int) -> Bool:
    return prime_cross_outer_candidate(num)
