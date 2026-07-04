from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.parameter_runtime import *


def test_complete_legacy_surface_is_explicit() raises:
    var snapshot = parameter_runtime_legacy_snapshot()
    assert_equal(snapshot.module_functions, 8)
    assert_equal(snapshot.nested_helpers, 3)
    assert_equal(snapshot.historical_globals, 6)
    assert_false(snapshot.dynamic_program_object)
    assert_false(snapshot.lazy_python_imports)
    assert_true(snapshot.diagnostics_are_values)
    assert_equal(len(parameter_runtime_owner_contract()), 10)


def test_column_and_parse_adapters_share_one_plan() raises:
    var tokens = [
        "-spalten",
        "--religionen=sternpolygon",
        "-ausgabe",
        "--art=markdown",
    ]
    var columns = produce_all_spalten_numbers(tokens, 746, 1024)
    var plan = parameters_to_commands_and_numbers(tokens, 746, 1024)
    assert_equal(columns, [0, 6, 36])
    assert_equal(plan.columns, columns)
    assert_equal(plan.output_mode, "markdown")


def test_width_adapter_preserves_zero_lock_and_explicit_widths() raises:
    var zero = apply_width_parameter("breite=0")
    assert_true(zero.handled)
    assert_true(zero.zero_locked)
    assert_equal(zero.width, 0)

    var widths = apply_width_parameter("breiten=9,11")
    assert_true(widths.handled)
    assert_equal(widths.widths, [9, 11])

    var negative = apply_width_parameter("breite=40", "-")
    assert_false(negative.handled)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
