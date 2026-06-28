from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.tag_schema import *
from reta_mojo.tag_schema_catalog import bootstrap_tag_schema
from tag_schema_parity_constants import *


def _hash_field(value: Int, text: String) -> Int:
    var result = value
    for byte in text.bytes():
        result = (result * 257 + Int(byte) + 1) % TAG_FINGERPRINT_MODULUS
    return (result * 257 + 257) % TAG_FINGERPRINT_MODULUS


def _add_fingerprint(mut total: Int, mut squares: Int, value: Int) -> None:
    total = (total + value) % TAG_FINGERPRINT_MODULUS
    squares = (
        squares + (value * value) % TAG_FINGERPRINT_MODULUS
    ) % TAG_FINGERPRINT_MODULUS


def _group_fingerprint(groups: List[TagGroup]) -> Tuple[Int, Int, Int]:
    var total = 0
    var squares = 0
    for group_index in range(len(groups)):
        var group = groups[group_index].copy()
        var value = 17
        for tag_index in range(len(group.tags)):
            value = _hash_field(value, String(group.tags[tag_index]))
        value = _hash_field(value, "|")
        for column_index in range(len(group.columns)):
            value = _hash_field(value, String(group.columns[column_index]))
        _add_fingerprint(total, squares, value)
    return (len(groups), total, squares)


def _contains(values: List[Int], value: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _reverse_fingerprint(
    reverse: List[TagColumnEntry],
) -> Tuple[Int, Int, Int]:
    var total = 0
    var squares = 0
    for index in range(len(reverse)):
        var entry = reverse[index].copy()
        var value = _hash_field(17, String(entry.column))
        for tag_index in range(len(entry.tags)):
            value = _hash_field(value, String(entry.tags[tag_index]))
        _add_fingerprint(total, squares, value)
    return (len(reverse), total, squares)

def test_tag_schema_counts_and_names() raises:
    var schema = bootstrap_tag_schema()
    assert_equal(len(schema.tag_names), 7)
    assert_equal(tag_name(schema, TAG_STERN_POLYGON), "sternPolygon")
    assert_equal(tag_name(schema, TAG_GEBROCHEN_RATIONAL), "gebrRat")
    assert_equal(len(schema.primary), EXPECTED_PRIMARY_GROUP_COUNT)
    assert_equal(reverse_entry_count(schema), EXPECTED_PRIMARY_REVERSE_COUNT)
    assert_equal(len(schema.combination), EXPECTED_KOMBI_GROUP_COUNT)
    assert_equal(reverse_entry_count(schema, 0), EXPECTED_KOMBI_REVERSE_COUNT)
    assert_equal(len(schema.combination_two), EXPECTED_KOMBI2_GROUP_COUNT)
    assert_equal(reverse_entry_count(schema, 1), EXPECTED_KOMBI2_REVERSE_COUNT)


def test_complete_group_fingerprints_match_python() raises:
    var schema = bootstrap_tag_schema()
    var primary = _group_fingerprint(schema.primary)
    assert_equal(primary[0], EXPECTED_PRIMARY_GROUP_COUNT)
    assert_equal(primary[1], EXPECTED_PRIMARY_GROUP_SUM)
    assert_equal(primary[2], EXPECTED_PRIMARY_GROUP_SQUARE_SUM)

    var kombi = _group_fingerprint(schema.combination)
    assert_equal(kombi[0], EXPECTED_KOMBI_GROUP_COUNT)
    assert_equal(kombi[1], EXPECTED_KOMBI_GROUP_SUM)
    assert_equal(kombi[2], EXPECTED_KOMBI_GROUP_SQUARE_SUM)

    var kombi2 = _group_fingerprint(schema.combination_two)
    assert_equal(kombi2[0], EXPECTED_KOMBI2_GROUP_COUNT)
    assert_equal(kombi2[1], EXPECTED_KOMBI2_GROUP_SUM)
    assert_equal(kombi2[2], EXPECTED_KOMBI2_GROUP_SQUARE_SUM)


def test_complete_reverse_fingerprints_match_python() raises:
    var schema = bootstrap_tag_schema()
    var primary = _reverse_fingerprint(schema.primary_reverse)
    assert_equal(primary[0], EXPECTED_PRIMARY_REVERSE_COUNT)
    assert_equal(primary[1], EXPECTED_PRIMARY_REVERSE_SUM)
    assert_equal(primary[2], EXPECTED_PRIMARY_REVERSE_SQUARE_SUM)

    var kombi = _reverse_fingerprint(schema.combination_reverse)
    assert_equal(kombi[0], EXPECTED_KOMBI_REVERSE_COUNT)
    assert_equal(kombi[1], EXPECTED_KOMBI_REVERSE_SUM)
    assert_equal(kombi[2], EXPECTED_KOMBI_REVERSE_SQUARE_SUM)

    var kombi2 = _reverse_fingerprint(schema.combination_two_reverse)
    assert_equal(kombi2[0], EXPECTED_KOMBI2_REVERSE_COUNT)
    assert_equal(kombi2[1], EXPECTED_KOMBI2_REVERSE_SUM)
    assert_equal(kombi2[2], EXPECTED_KOMBI2_REVERSE_SQUARE_SUM)


def test_known_primary_and_combination_lookups() raises:
    var schema = bootstrap_tag_schema()
    var column_216 = tags_for_column(schema, 216)
    assert_equal(len(column_216), 4)
    assert_true(_contains(column_216, TAG_STERN_POLYGON))
    assert_true(_contains(column_216, TAG_GLEICHFOERMIGES_POLYGON))
    assert_true(_contains(column_216, TAG_GALAXIE))
    assert_true(_contains(column_216, TAG_UNIVERSUM))

    var primary_5 = tags_for_column(schema, 5)
    assert_equal(len(primary_5), 2)
    assert_true(_contains(primary_5, TAG_STERN_POLYGON))
    assert_true(_contains(primary_5, TAG_UNIVERSUM))

    var kombi_5 = tags_for_column(schema, 5, 0)
    assert_equal(len(kombi_5), 4)
    var kombi2_5 = tags_for_column(schema, 5, 1)
    assert_equal(len(kombi2_5), 4)


def test_columns_for_exact_tag_set() raises:
    var schema = bootstrap_tag_schema()
    var tags: List[Int] = [TAG_STERN_POLYGON, TAG_UNIVERSUM]
    var columns = columns_for_tags(schema, tags)
    assert_true(_contains(columns, 5))
    assert_true(_contains(columns, 745))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
