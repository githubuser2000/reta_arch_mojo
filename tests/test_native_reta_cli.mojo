from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.native_reta_cli import *


def test_plan_resolves_rows_columns_and_output() raises:
    var plan = build_native_reta_plan(
        ["-zeilen", "--vorhervonausschnitt=1-3", "-spalten", "--religionen=sternpolygon", "-ausgabe", "--art=csv"],
        746,
        1024,
    )
    assert_equal(plan.output_mode, "csv")
    assert_equal(plan.positive_rows, ["_a_1-3"])
    assert_equal(plan.columns, [0, 6, 36])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
