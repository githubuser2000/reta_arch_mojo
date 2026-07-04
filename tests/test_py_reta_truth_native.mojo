from std.collections import List
from std.testing import assert_equal, TestSuite
from reta_mojo.py_reta_truth import *


def test_matrix_matches_py_reta_truth() raises:
    var snapshot = py_reta_truth_matrix_snapshot()
    assert_equal(
        snapshot.grundstrukturen_structure_size,
        [4, 21, 54, 197, 425, 745],
    )
    assert_equal(
        snapshot.size_order_structure_size,
        [4, 21, 54, 197, 425, 745],
    )
    assert_equal(
        snapshot.size_order_organisations,
        [30, 82, 425, 745],
    )


def test_all_religion_csv_aliases_have_truth_tail() raises:
    var filenames: List[String] = [
        "religion.csv",
        "cn-religion.csv",
        "en-religion.csv",
        "kr-religion.csv",
        "vn-religion.csv",
    ]
    for index in range(len(filenames)):
        var snapshot = py_reta_truth_header_snapshot(filenames[index])
        assert_equal(snapshot.columns, 746)
        assert_equal(snapshot.column_744, "Neues M (13) Kontinuum")
        assert_equal(snapshot.column_745, "alternative Größenordnungen")


def test_tag_schema_knows_truth_tail_columns() raises:
    var snapshot = py_reta_truth_tag_snapshot()
    assert_equal(snapshot.column_744_tags, [0, 5])
    assert_equal(snapshot.column_745_tags, [0, 4])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
