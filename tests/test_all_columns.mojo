from std.testing import assert_equal, TestSuite
from reta_mojo.all_columns import load_all_column_selection


def test_generated_all_selection_shape() raises:
    var selection = load_all_column_selection()
    assert_equal(selection.source_entries, 756)
    assert_equal(len(selection.columns), 556)
    assert_equal(len(selection.modal_concepts), 46)
    assert_equal(len(selection.fraction_requests), 88)
    assert_equal(len(selection.kombi_requests), 26)
    assert_equal(len(selection.generated_commands), 17)
    assert_equal(len(selection.meta_requests), 12)
    assert_equal(selection.columns[0], 0)
    assert_equal(selection.columns[len(selection.columns) - 1], 745)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
