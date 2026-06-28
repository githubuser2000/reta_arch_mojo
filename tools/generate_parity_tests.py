#!/usr/bin/env python3
"""Generate fixed Mojo parity vectors from the bundled Python reference."""
from __future__ import annotations

import argparse
import json
import pathlib
import sys


def mojo_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--reference-root", type=pathlib.Path, required=True)
    parser.add_argument("--output", type=pathlib.Path, required=True)
    args = parser.parse_args()
    sys.path.insert(0, str(args.reference_root))

    from reta_architecture.number_theory import (
        primCreativity,
        primFak,
        divisorGenerator,
        couldBePrimeNumberPrimzahlkreuz,
        couldBePrimeNumberPrimzahlkreuz_fuer_innen,
        couldBePrimeNumberPrimzahlkreuz_fuer_aussen,
    )
    from reta_architecture.row_ranges import BereichToNumbers2

    creativity = [primCreativity(n) for n in range(257)]
    factor_numbers = list(range(2, 81)) + [97, 100, 127, 128, 255, 256, 1024]
    factors = [",".join(map(str, primFak(n))) for n in factor_numbers]
    divisor_numbers = list(range(1, 41)) + [64, 81, 97, 100]
    divisors = [",".join(str(int(v)) for v in divisorGenerator(n)) for n in divisor_numbers]
    cross = [couldBePrimeNumberPrimzahlkreuz(n) for n in range(96)]
    inner = [couldBePrimeNumberPrimzahlkreuz_fuer_innen(n) for n in range(96)]
    outer = [couldBePrimeNumberPrimzahlkreuz_fuer_aussen(n) for n in range(96)]

    range_cases = [
        ("1-9", False, 30),
        ("1-9,-3", False, 30),
        ("2-4+1", False, 30),
        ("v2-3", False, 25),
        ("2-3", True, 25),
        ("{1,2,5,8}", False, 30),
        ("{1,2,5,8},-{2,8}", False, 30),
        ("1,3,5-7", False, 30),
        ("4+1+2", False, 30),
        ("v5", False, 40),
    ]
    ranges = [(text, multiples, maximum, sorted(BereichToNumbers2(text, multiples, maximum))) for text, multiples, maximum in range_cases]

    lines: list[str] = []
    lines += [
        '"""Generated against the Python reference; do not edit by hand."""\n',
        'from std.collections import List, Set\n',
        'from std.testing import assert_equal, assert_true, TestSuite\n',
        'from reta_mojo.number_theory import *\n',
        'from reta_mojo.row_ranges import range_to_numbers\n\n',
        'def _csv(values: List[Int]) -> String:\n',
        '    var result = String()\n',
        '    for index in range(len(values)):\n',
        '        if index > 0:\n',
        '            result += ","\n',
        '        result += String(values[index])\n',
        '    return result^\n\n',
        'def _assert_set(actual: Set[Int], expected: List[Int]) raises:\n',
        '    assert_equal(len(actual), len(expected))\n',
        '    for index in range(len(expected)):\n',
        '        assert_true(expected[index] in actual)\n\n',
        'def test_prime_creativity_reference_vector() raises:\n',
        f'    var expected = {creativity!r}\n',
        '    for value in range(len(expected)):\n',
        '        assert_equal(prime_creativity(value), expected[value])\n\n',
        'def test_prime_factor_reference_vectors() raises:\n',
        f'    var numbers = {factor_numbers!r}\n',
        '    var expected = [' + ', '.join(mojo_string(v) for v in factors) + ']\n',
        '    for index in range(len(numbers)):\n',
        '        assert_equal(_csv(prime_factors(numbers[index])), expected[index])\n\n',
        'def test_divisor_reference_vectors() raises:\n',
        f'    var numbers = {divisor_numbers!r}\n',
        '    var expected = [' + ', '.join(mojo_string(v) for v in divisors) + ']\n',
        '    for index in range(len(numbers)):\n',
        '        assert_equal(_csv(divisors(numbers[index])), expected[index])\n\n',
        'def test_prime_cross_reference_vectors() raises:\n',
        f'    var cross = {cross!r}\n'.replace('True','True').replace('False','False'),
        f'    var inner = {inner!r}\n'.replace('True','True').replace('False','False'),
        f'    var outer = {outer!r}\n'.replace('True','True').replace('False','False'),
        '    for value in range(len(cross)):\n',
        '        assert_equal(prime_cross_candidate(value), cross[value])\n',
        '        assert_equal(prime_cross_inner_candidate(value), inner[value])\n',
        '        assert_equal(prime_cross_outer_candidate(value), outer[value])\n\n',
        'def test_row_range_reference_vectors() raises:\n',
    ]
    for text, multiples, maximum, expected in ranges:
        lines.append(f'    _assert_set(range_to_numbers({mojo_string(text)}, {str(multiples)}, {maximum}), {expected!r})\n')
    lines += ['\n\ndef main() raises:\n', '    TestSuite.discover_tests[__functions_in_module()]().run()\n']
    args.output.write_text(''.join(lines), encoding='utf-8')


if __name__ == '__main__':
    main()
