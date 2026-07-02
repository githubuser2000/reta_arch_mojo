from std.collections import List
from std.testing import assert_equal, assert_true, TestSuite

from reta_mojo.csv_table import read_semicolon_csv
from reta_mojo.generated_aliases import MetaColumnRequest
from reta_mojo.meta_columns import (
    MetaFraction,
    bootstrap_meta_columns,
    discover_meta_fractions,
    findAllBruecheAndTheirCombinations,
    getAllBrueche,
    meta_catalog_combinations,
    meta_catalog_fractions,
    meta_column_metadata,
    meta_columns_snapshot,
    meta_columns_surface,
    meta_fraction_is_integral,
    readOneCSVAndReturn,
    spalteFuerGegenInnenAussenSeitlichPrim,
    spalteMetaKonkretAbstrakt_UeberschriftenUndTags,
    spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie,
)
from reta_mojo.tag_schema import (
    TAG_GEBROCHEN_RATIONAL,
    TAG_GLEICHFOERMIGES_POLYGON,
    TAG_STERN_POLYGON,
    TAG_UNIVERSUM,
)


def test_meta_bundle_and_surface_cover_python_owner():
    var bundle = bootstrap_meta_columns()
    assert_equal(len(bundle.specs), 3)
    var snapshot = meta_columns_snapshot(bundle)
    assert_equal(snapshot.class_name, "MetaColumnsBundle")
    assert_equal(snapshot.count, 3)
    assert_equal(
        bundle.specs[0].method_name,
        "spalteMetaKontretTheorieAbstrakt_etc_1",
    )
    assert_equal(bundle.specs[2].method_name, "readOneCSVAndReturn")
    var surface = meta_columns_surface()
    assert_equal(len(surface), 14)
    assert_equal(surface[0].python_name, "bootstrap_meta_columns")
    assert_equal(
        surface[13].python_name,
        "spalteFuerGegenInnenAussenSeitlichPrim",
    )
    assert_equal(surface[13].owner_module, "prime_effect_columns.mojo")


def test_meta_fraction_catalog_freezes_exact_reference_order() raises:
    var catalog = findAllBruecheAndTheirCombinations()
    assert_equal(len(catalog.sources), 2)
    assert_equal(len(catalog.fractions), 87)
    assert_equal(len(catalog.combinations), 884)
    assert_equal(len(meta_catalog_fractions(catalog, "universe")), 47)
    assert_equal(len(meta_catalog_fractions(catalog, "galaxy")), 40)
    assert_equal(
        len(meta_catalog_combinations(catalog, "UniUni", "stern", "mul")),
        80,
    )
    assert_equal(
        len(meta_catalog_combinations(catalog, "UniUni", "stern", "div")),
        0,
    )
    assert_equal(
        len(meta_catalog_combinations(catalog, "GalGal", "gleichf", "div")),
        50,
    )


def test_fraction_discovery_and_integrality_are_typed() raises:
    var universe = readOneCSVAndReturn("universe")
    var galaxy = read_semicolon_csv(
        "python_reference/csv/gebrochen-rational-galaxie.csv"
    )
    assert_equal(len(discover_meta_fractions(universe)), 47)
    assert_equal(len(getAllBrueche(galaxy)), 40)
    assert_true(meta_fraction_is_integral(MetaFraction(6, 3)))
    assert_true(meta_fraction_is_integral(MetaFraction(2, 6), True))
    assert_true(not meta_fraction_is_integral(MetaFraction(2, 3)))


def test_heading_tags_and_fraction_domain_value_are_explicit() raises:
    var upper = meta_column_metadata(MetaColumnRequest(2, 0), 0, "german")
    assert_equal(upper.heading, "Meta für n")
    assert_equal(upper.tags, [TAG_STERN_POLYGON, TAG_UNIVERSUM])
    var lower = spalteMetaKonkretAbstrakt_UeberschriftenUndTags(
        MetaColumnRequest(3, 1), 1, "german"
    )
    assert_equal(lower.heading, "Praxis für 1/n statt n")
    assert_equal(
        lower.tags,
        [
            TAG_GLEICHFOERMIGES_POLYGON,
            TAG_UNIVERSUM,
            TAG_GEBROCHEN_RATIONAL,
        ],
    )

    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var fractions = readOneCSVAndReturn("universe")
    var domain_only = spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie(
        table,
        fractions,
        MetaFraction(1, 2),
        5,
        131,
        "plain",
        True,
    )
    var universe_value = spalteMetaKonkretTheorieAbstrakt_getGebrRatUnivStrukturalie(
        table,
        fractions,
        MetaFraction(1, 2),
        5,
        131,
        "plain",
        False,
    )
    assert_true(domain_only.byte_length() > 3)
    assert_true(universe_value.startswith(domain_only))
    assert_true(universe_value.find("(1/2)") >= 0)


def test_prime_effect_historical_alias_uses_native_owner() raises:
    var table = read_semicolon_csv("python_reference/csv/religion.csv")
    var commands = List[String]()
    commands.append("prime_effect:10")
    var result = spalteFuerGegenInnenAussenSeitlichPrim(
        table, commands, 8, "german"
    )
    assert_equal(result.source_columns, [10])
    assert_equal(len(result.columns), 1)
    assert_true(result.columns[0][0].find("Galaxie n") >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
