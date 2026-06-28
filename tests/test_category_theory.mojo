from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.category_theory import *


def test_snapshot_counts() raises:
    var bundle = bootstrap_category_theory()
    assert_equal(len(bundle.categories), 26)
    assert_equal(len(bundle.functors), 77)
    assert_equal(len(bundle.natural_transformations), 42)
    assert_equal(len(bundle.paradigm_terms), 8)


def test_named_category() raises:
    var bundle = bootstrap_category_theory()
    var index = category_index(bundle, "OpenRetaContextCategory")
    assert_true(index >= 0)
    assert_equal(bundle.categories[index].objects[0].name, "ContextSelection")
    assert_equal(bundle.categories[index].morphisms[0].name, "refine")


def test_named_functor_and_transformation() raises:
    var bundle = bootstrap_category_theory()
    assert_true(functor_index(bundle, "ArchitectureRuntimeFunctor") >= 0)
    assert_true(natural_transformation_index(bundle, "LegacyToArchitectureTransformation") >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
