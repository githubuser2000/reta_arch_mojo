from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite
from reta_mojo.generated_columns import *


def _contains_surface(
    entries: List[GeneratedColumnsSurfaceEntry], name: String
) -> Bool:
    for index in range(len(entries)):
        if entries[index].python_name == name:
            return True
    return False


def test_registry_matches_python_order_and_metadata() raises:
    var bundle = bootstrap_generated_columns()
    var names = bundle.registry.names()
    assert_equal(len(names), 10)
    assert_equal(names[0], "concatVervielfacheZeile")
    assert_equal(names[1], "concatModallogik")
    assert_equal(names[8], "concatLovePolygon")
    assert_equal(names[9], "createSpalteGestirn")
    assert_equal(bundle.registry.specs[0].trigger_columns, [19, 90])
    assert_equal(bundle.registry.specs[8].trigger_columns, [9])
    assert_equal(bundle.registry.specs[9].tags[2], "galaxie")


def test_bundle_snapshot_preserves_registry_shape() raises:
    var snapshot = bootstrap_generated_columns().snapshot()
    assert_equal(snapshot.class_name, "GeneratedColumnsBundle")
    assert_equal(snapshot.count, 10)
    assert_equal(snapshot.morphisms[4].method_name, "concatPrimCreativityType")
    assert_equal(snapshot.morphisms[5].trigger_columns, [132])


def test_surface_maps_every_python_owner_entry() raises:
    var surface = generated_columns_surface()
    assert_equal(len(surface), 16)
    assert_true(_contains_surface(surface, "GeneratedColumnSpec"))
    assert_true(_contains_surface(surface, "GeneratedColumnRegistry"))
    assert_true(_contains_surface(surface, "GeneratedColumnsBundle"))
    assert_true(_contains_surface(surface, "concat_prim_universe_row"))
    assert_true(_contains_surface(surface, "create_spalte_gestirn"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
