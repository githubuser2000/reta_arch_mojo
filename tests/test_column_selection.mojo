from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.column_selection import *
from reta_mojo.universal import normalize_column_buckets


def test_legacy_bucket_coordinates_are_exact() raises:
    var bundle = bootstrap_column_selection()
    assert_equal(bundle.bucket_count(), 24)
    assert_equal(bundle.positive_bucket_count(), 12)
    assert_equal(bundle.negative_bucket_count(), 12)
    var ordinary = bundle.resolve("ordinary")
    assert_true(ordinary.valid)
    assert_equal(ordinary.coordinate.polarity, 0)
    assert_equal(ordinary.coordinate.bucket_type, 0)
    var meta_not = bundle.resolve("metakonkretNot")
    assert_true(meta_not.valid)
    assert_equal(meta_not.coordinate.polarity, 1)
    assert_equal(meta_not.coordinate.bucket_type, 11)
    assert_false(bundle.resolve("not-a-bucket").valid)


def test_new_bucket_map_integrates_with_universal_normalization() raises:
    var bundle = bootstrap_column_selection()
    var buckets = bundle.new_bucket_map()
    assert_equal(len(buckets), 24)
    var positive = bundle.resolve("ordinary").coordinate.copy()
    var negative = bundle.resolve("ordinaryNot").coordinate.copy()
    var positive_index = bucket_index_for_coordinate(buckets, positive)
    var negative_index = bucket_index_for_coordinate(buckets, negative)
    buckets[positive_index].values.add(1)
    buckets[positive_index].values.add(2)
    buckets[negative_index].values.add(2)
    var normalized = normalize_column_buckets(buckets)
    assert_equal(len(normalized), 12)
    assert_true(1 in normalized[0].values)
    assert_false(2 in normalized[0].values)


def test_bucket_names_preserve_python_order() raises:
    var names = column_bucket_names(bootstrap_column_selection())
    assert_equal(names[0], "ordinary")
    assert_equal(names[11], "metakonkret")
    assert_equal(names[12], "ordinaryNot")
    assert_equal(names[23], "metakonkretNot")


def test_bind_column_sections_replaces_program_side_effects() raises:
    var bundle = bootstrap_column_selection()
    var buckets = bundle.new_bucket_map()
    var ordinary = bucket_index_for_coordinate(buckets, bundle.resolve("ordinary").coordinate)
    var generated = bucket_index_for_coordinate(buckets, bundle.resolve("generated1").coordinate)
    var concat = bucket_index_for_coordinate(buckets, bundle.resolve("concat1").coordinate)
    var kombi1 = bucket_index_for_coordinate(buckets, bundle.resolve("kombi1").coordinate)
    var kombi2 = bucket_index_for_coordinate(buckets, bundle.resolve("kombi2").coordinate)
    buckets[ordinary].values.add(3)
    buckets[ordinary].values.add(5)
    buckets[generated].values.add(17)
    buckets[concat].values.add(23)
    buckets[kombi1].values.add(2)
    buckets[kombi2].values.add(7)
    var bound = bind_column_sections(bundle, buckets, [[11], [12, 13], [19]])
    assert_true(3 in bound.rows_as_numbers)
    assert_true(5 in bound.rows_as_numbers)
    assert_true(17 in bound.generated_rows)
    assert_true(23 in bound.prime_universe_rows)
    assert_true(2 in bound.combination_rows)
    assert_true(7 in bound.combination_rows2)
    assert_equal(bound.ones, [11, 19])
    assert_equal(bound.parameter_sections_to_add, ["ka", "ka2"])
    assert_equal(bound.vanilla_column_count, 2)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
