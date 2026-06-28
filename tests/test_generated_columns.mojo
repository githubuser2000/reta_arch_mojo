from std.testing import assert_equal, TestSuite
from reta_mojo.generated_columns import *


def test_reference_fingerprints() raises:
    assert_equal(generated_values_fingerprint(0, "german", 512), 587079226)
    assert_equal(generated_values_fingerprint(1, "german", 512), 856678104)
    assert_equal(generated_values_fingerprint(2, "german", 512), 228507251)
    assert_equal(generated_values_fingerprint(3, "german", 512), 426773764)
    assert_equal(generated_values_fingerprint(0, "english", 512), 375819533)
    assert_equal(generated_values_fingerprint(1, "english", 512), 103877742)
    assert_equal(generated_values_fingerprint(2, "english", 512), 811761661)
    assert_equal(generated_values_fingerprint(3, "english", 512), 948793905)


def test_representative_values() raises:
    assert_equal(equality_freedom_value(6, "german"), "den anderen überbieten wollen")
    assert_equal(equality_freedom_value(14, "english"), "wanting to be among or under the other")
    assert_equal(prime_creativity_value(4, "german"), "3. Mondzahl")
    assert_equal(celestial_value(6, "english"), "suns (no math powers), and as well planets (2*n), and as well would be a black sun, if inverted into its negative by a type 13")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
