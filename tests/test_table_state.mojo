from std.testing import assert_equal, assert_false, assert_true, TestSuite
from reta_mojo.table_state import *


def test_default_and_explicit_highest_rows() raises:
    var default_state = create_table_state()
    assert_equal(default_state.highest_rows[1024], 1024)
    assert_equal(default_state.highest_rows[114], 163)

    var explicit = create_table_state(42)
    assert_equal(explicit.highest_rows[1024], 42)
    assert_equal(explicit.highest_rows[114], 42)
    set_highest_row(explicit, 99)
    assert_equal(explicit.highest_rows[1024], 99)
    assert_equal(explicit.highest_rows[114], 99)


def test_mutable_sections_are_owned_together() raises:
    var state = create_table_state()
    assert_false(state.display.no_headings)
    state.display.no_headings = True
    state.display.religion_numbers.append(7)
    state.generated_columns.parameters[12] = "generated"
    state.generated_columns.tags[12] = "sternPolygon"
    state.row_display_to_original[3] = 17
    state.generated_rows.add(12)

    assert_true(state.display.no_headings)
    assert_equal(state.display.religion_numbers[0], 7)
    assert_equal(generated_parameter_count(state), 1)
    assert_equal(generated_tag_count(state), 1)
    assert_equal(state.row_display_to_original[3], 17)
    assert_true(12 in state.generated_rows)


def test_state_section_names_match_python_bundle() raises:
    var names = state_section_names()
    assert_equal(len(names), 5)
    assert_equal(names[0], "highest_rows")
    assert_equal(names[4], "generated_rows")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
