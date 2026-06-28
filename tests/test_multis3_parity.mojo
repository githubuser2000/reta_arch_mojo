from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.arithmetic import factor_triples
from multis3_parity_constants import *


def test_multis3_full_reference_fingerprint() raises:
    var count = 0
    var fingerprint = 0
    var count_fingerprint = 0
    for value in range(MULTIS3_PARITY_START, MULTIS3_PARITY_STOP + 1):
        var triples = factor_triples(value)
        count_fingerprint = (
            count_fingerprint * MULTIS3_PARITY_MULTIPLIER
            + value * 257
            + len(triples)
        ) % MULTIS3_PARITY_MOD
        for index in range(len(triples)):
            var triple = triples[index].copy()
            assert_true(triple.first > 1)
            assert_true(triple.first <= triple.second)
            assert_true(triple.second <= triple.third)
            assert_equal(triple.first * triple.second * triple.third, value)
            var token = (
                ((value * 1009 + triple.first) * 1009 + triple.second) * 1009
                + triple.third
            ) % MULTIS3_PARITY_MOD
            fingerprint = (
                fingerprint * MULTIS3_PARITY_MULTIPLIER + token
            ) % MULTIS3_PARITY_MOD
            count += 1
    assert_equal(count, MULTIS3_PARITY_TRIPLE_COUNT)
    assert_equal(fingerprint, MULTIS3_PARITY_FINGERPRINT)
    assert_equal(count_fingerprint, MULTIS3_PARITY_COUNT_FINGERPRINT)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
