from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.parameter_runtime import *


def test_bundle_matches_python_owner_surface() raises:
    var bundle = bootstrap_parameter_runtime()
    assert_equal(bundle.column_function, "produce_all_spalten_numbers")
    assert_equal(bundle.width_function, "apply_width_parameter")
    assert_equal(bundle.parse_function, "parameters_to_commands_and_numbers")
    assert_equal(bundle.upper_limit_argument_function, "upper_limit_values_for_argument")
    assert_equal(bundle.upper_limit_aggregate_function, "upper_limit_from_arguments")
    assert_equal(bundle.upper_limit_apply_function, "apply_upper_limit_argument")


def test_upper_limit_argument_exact_maximum() raises:
    var result = upper_limit_values_for_argument("--oberesmaximum=17")
    assert_true(result.applies)
    assert_equal(result.values, [17])

    var english = upper_limit_values_for_argument("--uppermaximum=23")
    assert_true(english.applies)
    assert_equal(english.values, [23])

    var invalid = upper_limit_values_for_argument("--maximum=x")
    assert_false(invalid.applies)
    assert_equal(len(invalid.values), 0)


def test_upper_limit_argument_range_uses_historical_1024_floor() raises:
    var result = upper_limit_values_for_argument("--vorhervonausschnitt=1-3")
    assert_false(result.applies)
    assert_equal(result.values, [1024, 1024, 1024])

    var extended = upper_limit_values_for_argument("--range=1024-1025")
    assert_equal(extended.values, [1025, 1026])


def test_upper_limit_aggregate_and_apply() raises:
    assert_equal(
        upper_limit_from_arguments(
            ["--vorhervonausschnitt=1-3", "--oberesmaximum=2048"], 1024
        ),
        2048,
    )
    var applied = apply_upper_limit_argument(1024, "--maximum=4096")
    assert_equal(applied.maximum, 4096)
    assert_true(applied.applied)

    var ignored = apply_upper_limit_argument(1024, "--range=1-2")
    assert_equal(ignored.maximum, 1024)
    assert_false(ignored.applied)


def test_effective_highest_keeps_generated_absolute_range_semantics() raises:
    assert_equal(
        parameter_runtime_effective_highest(
            ["-zeilen", "--vorhervonausschnitt=2,v6,v10"], 1024
        ),
        1027,
    )
    assert_equal(
        parameter_runtime_effective_highest(
            ["-lines", "--range=2-4,v2-4"], 1024
        ),
        1029,
    )


def test_width_zero_lock_and_replacement_semantics() raises:
    var plan = build_parameter_runtime_plan(
        [
            "-ausgabe", "--breite=40", "--breite=0", "--breite=80",
            "--breiten=5,x,-2,7", "--breiten=9,11",
        ],
        746,
        1024,
    )
    assert_equal(plan.width, 0)
    assert_equal(plan.widths, [9, 11])


def test_rows_columns_output_and_language_are_one_typed_plan() raises:
    var plan = build_parameter_runtime_plan(
        [
            "-language=english",
            "-lines", "--range=1-3", "--time=today,-tomorrow",
            "-columns", "--religions=starpolygon",
            "-output", "--type=markdown", "--nonumbering", "--noheadings",
        ],
        746,
        1024,
    )
    assert_equal(plan.language, "english")
    assert_equal(plan.output_mode, "markdown")
    assert_false(plan.number_rows)
    assert_false(plan.include_headings)
    assert_equal(plan.positive_rows, ["_a_1-3", "="])
    assert_equal(plan.negative_rows, [">"])
    assert_equal(plan.columns, [0, 6, 36])


def test_explicit_order_and_semantic_selection_are_separate() raises:
    var plan = build_parameter_runtime_plan(
        [
            "-spalten", "--religionen=sternpolygon",
            "-ausgabe", "--spaltenreihenfolgeundnurdiese=37,1,7",
        ],
        746,
        1024,
    )
    assert_true(plan.explicit_order_requested)
    assert_equal(plan.columns, [0, 6, 36])
    assert_equal(plan.explicit_positions, [36, 0, 6])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
