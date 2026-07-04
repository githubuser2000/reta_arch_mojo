from std.collections import List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.schema import *
from reta_mojo.parameter_semantics import *


def _fixture_schema() -> RetaContextSchema:
    var schema = empty_schema()
    schema.parameters_main.append(AliasGroup("Religionen", ["Religionen", "religionen", "religion"]))
    schema.parameters_main.append(AliasGroup("Menschliches", ["Menschliches", "menschliches"]))
    schema.parameter_entries.append(ParameterEntry(
        ["Religionen", "religionen"],
        ["Sternpolygon", "sternpolygon", "stern"],
        [8, 4, 8],
    ))
    schema.parameter_entries.append(ParameterEntry(
        ["religionen"],
        ["Sternpolygon", "star"],
        [10, 4],
    ))
    schema.parameter_entries.append(ParameterEntry(
        ["Menschliches", "menschliches"],
        ["Motive", "motive"],
        [314],
    ))
    return schema^


def test_schema_alias_resolution() raises:
    var schema = _fixture_schema()
    assert_equal(resolve_schema_main_alias(schema, "religion"), "Religionen")
    assert_equal(resolve_schema_main_alias(schema, "unknown"), "")
    assert_equal(schema_direct_column_count(schema), 6)


def test_parameter_semantics_merges_aliases_and_columns() raises:
    var sheaf = build_parameter_semantics(_fixture_schema())
    assert_equal(resolve_main_alias(sheaf, "religionen"), "Religionen")
    assert_equal(resolve_parameter_alias(sheaf, "religion", "star"), "Sternpolygon")
    var pair = canonicalize_pair(sheaf, "religionen", "stern")
    assert_true(pair.valid)
    assert_equal(pair.main_name, "Religionen")
    assert_equal(pair.parameter_name, "Sternpolygon")
    var columns = column_numbers_for_pair(sheaf, "religion", "star")
    assert_equal(len(columns), 3)
    assert_equal(columns[0], 4)
    assert_equal(columns[1], 8)
    assert_equal(columns[2], 10)


def test_invalid_pair_and_reverse_map() raises:
    var sheaf = build_parameter_semantics(_fixture_schema())
    assert_false(canonicalize_pair(sheaf, "unknown", "star").valid)
    assert_equal(len(column_numbers_for_pair(sheaf, "religion", "unknown")), 0)
    var reverse = reverse_map_canonical_pairs(sheaf)
    assert_equal(len(reverse), 4)
    assert_equal(reverse[0].column, 4)
    assert_equal(reverse[0].pairs[0].main_name, "Religionen")
    assert_equal(reverse[3].column, 314)


def test_parameter_groups_and_pair_storage_match_python_order() raises:
    var schema = empty_schema()
    schema.parameters_main.append(
        AliasGroup("Religionen", ["Religionen", "religionen"])
    )
    schema.parameter_entries.append(
        ParameterEntry(["Religionen"], ["Zeta", "zeta"], [9])
    )
    schema.parameter_entries.append(
        ParameterEntry(
            ["Religionen", "religionen"],
            ["Alpha", "zeta", "alpha", "Mitte"],
            [1],
        )
    )
    schema.parameter_entries.append(
        ParameterEntry(["Religionen"], ["Mitte", "mitte"], [5])
    )

    var sheaf = build_parameter_semantics(schema)
    var groups = parameter_alias_groups_for_main(sheaf, "religionen")
    assert_equal(len(groups), 3)
    assert_equal(groups[0].parameter_canonical, "Alpha")
    assert_equal(groups[0].aliases, ["Alpha", "Mitte", "alpha", "zeta"])
    var metadata = exact_meta_for_column(sheaf, 1)
    assert_equal(len(metadata), 1)
    assert_equal(metadata[0].parameter_main_aliases, ["Religionen", "religionen"])
    assert_equal(metadata[0].parameter_aliases, ["Alpha", "zeta", "alpha", "Mitte"])
    assert_equal(groups[1].parameter_canonical, "Mitte")
    assert_equal(groups[2].parameter_canonical, "Zeta")
    assert_equal(len(sheaf.pair_to_columns), 3)
    assert_equal(sheaf.pair_to_columns[0].parameter_canonical, "Alpha")
    assert_equal(sheaf.pair_to_columns[1].parameter_canonical, "Mitte")
    assert_equal(sheaf.pair_to_columns[2].parameter_canonical, "Zeta")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
