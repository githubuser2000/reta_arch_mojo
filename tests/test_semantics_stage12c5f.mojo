"""Combined Stage 12c5f suite to keep the Mojo compiler invocation bounded."""

from std.collections import Dict, List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.semantics_builder import *
from reta_mojo.column_selection import *
from reta_mojo.universal import *


def _slot_size(slot: DataSlot) -> Int:
    if slot.is_combination:
        return len(slot.combinations)
    return len(slot.bindings)


def test_allowed_primes_and_reverse_lookup() raises:
    var primes = allowed_prim_numbers_for_command()
    assert_equal(primes, ["2", "3", "5", "7", "11", "13", "17", "19", "23", "29", "31"])
    var mapping = [
        CombinationEntry(2, ["alpha", "shared"]),
        CombinationEntry(7, ["beta", "shared"]),
    ]
    var reverse = build_reverse_lookup(mapping)
    assert_equal(len(reverse), 3)
    assert_equal(reverse[0], ReverseLookupEntry("alpha", 2))
    assert_equal(reverse[1], ReverseLookupEntry("shared", 7))
    assert_equal(reverse[2], ReverseLookupEntry("beta", 7))


def test_collect_all_values_normal_and_inverted() raises:
    var entries = [
        ParameterMatrixEntry(
            ["main"],
            ["sub"],
            [
                SemanticDataSet([semantic_int(1), semantic_int(4), semantic_int(6)]),
                SemanticDataSet([semantic_int_tuple(2, 3)]),
            ],
        )
    ]
    var schema = ParameterSemanticsSchema(
        entries^,
        [CombinationEntry(9, ["nine"])],
        [CombinationEntry(12, ["twelve"])],
    )
    var normal = collect_all_values(schema, 6, False)
    assert_equal(normal.all_simple_command_columns, [1, 4, 6])
    assert_equal(len(normal.all_values[0].values), 3)
    assert_equal(len(normal.all_values[2].values), 11)
    assert_equal(normal.all_values[3].values[0], semantic_int(9))
    assert_equal(len(normal.all_values[5].values), 4)
    assert_equal(normal.all_values[8].values[0], semantic_int(12))

    var inverted = collect_all_values(schema, 6, True)
    assert_equal(len(inverted.all_values[0].values), 2)
    assert_equal(inverted.all_values[0].values[0], semantic_int(0))
    assert_equal(inverted.all_values[0].values[1], semantic_int(5))
    for index in range(1, 11):
        assert_equal(len(inverted.all_values[index].values), 0)


def test_into_parameter_datatype_special_cases() raises:
    var datasets = List[SemanticDataSet]()
    datasets.append(SemanticDataSet([semantic_int(3)]))
    datasets.append(SemanticDataSet(List[SemanticValue]()))
    datasets.append(SemanticDataSet([semantic_callable("predicate")]))
    datasets.append(SemanticDataSet(List[SemanticValue]()))
    datasets.append(
        SemanticDataSet([
            semantic_bool(True),
            semantic_single_int_tuple(10),
            semantic_null_tuple(),
        ])
    )
    datasets.append(SemanticDataSet([semantic_text("ignored")]))
    var result = into_parameter_datatype(["main", "alias"], ["15", "name"], datasets, 4)
    assert_equal(len(result.main_entries), 2)
    assert_equal(len(result.parameter_entries), 4)
    assert_equal(len(result.data_slots[0].bindings), 1)
    assert_equal(len(result.data_slots[0].bindings[0].groups[0].pairs), 4)
    assert_equal(len(result.data_slots[2].bindings), 2)
    assert_equal(result.data_slots[2].bindings[0].key, semantic_int(15))
    assert_equal(result.data_slots[2].bindings[1].key, semantic_text("name"))
    assert_equal(len(result.data_slots[3].bindings), 1)
    assert_equal(result.data_slots[3].bindings[0].key, semantic_sentinel("bool", 0))
    assert_equal(len(result.data_slots[4].bindings), 2)
    assert_equal(len(result.data_slots[5].bindings), 2)


def test_merge_overwrite_and_group_append_contract() raises:
    var target_main = [MainParameterEntry("main", ["old"])]
    merge_main_entries(target_main, [MainParameterEntry("main", ["new"]), MainParameterEntry("other", [])])
    assert_equal(target_main[0].parameter_names, ["new"])
    assert_equal(len(target_main), 2)

    var target_parameters = [ParameterDataEntry(ParameterPair("main", "sub"), 1)]
    merge_parameter_entries(
        target_parameters,
        [ParameterDataEntry(ParameterPair("main", "sub"), 9)],
    )
    assert_equal(target_parameters[0].matrix_entry_index, 9)

    var first = empty_data_slots(2)
    var second = empty_data_slots(2)
    var group = ParameterReferenceGroup([ParameterPair("main", "sub")])
    append_data_binding_group(first[0], semantic_int(1), group.copy())
    append_data_binding_group(second[0], semantic_int(1), group.copy())
    merge_data_slots(first, second)
    assert_equal(len(first[0].bindings), 1)
    assert_equal(len(first[0].bindings[0].groups), 2)


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


def test_normalize_column_buckets() raises:
    var source = [
        make_bucket(0, 0, [1, 2, 3, 4]),
        make_bucket(0, 1, [10, 11]),
        make_bucket(1, 0, [2, 4, 9]),
        make_bucket(1, 1, [11]),
    ]
    var result = normalize_column_buckets(source)
    assert_equal(len(result), 2)
    assert_true(1 in result[0].values)
    assert_true(3 in result[0].values)
    assert_false(2 in result[0].values)
    assert_false(4 in result[0].values)
    assert_true(10 in result[1].values)
    assert_false(11 in result[1].values)


def test_input_is_not_mutated() raises:
    var source = [make_bucket(0, 0, [1, 2]), make_bucket(1, 0, [2])]
    var _ = normalize_column_buckets(source)
    assert_true(2 in source[0].values)



def test_parameter_dictionary_merge_contract() raises:
    var first_parameters = [ParameterDataEntry(ParameterPair("main", "sub"), 1)]
    var second_parameters = [
        ParameterDataEntry(ParameterPair("main", "sub"), 9),
        ParameterDataEntry(ParameterPair("other", "value"), 10),
    ]
    var first_slots = empty_data_slots(2)
    var second_slots = empty_data_slots(2)
    append_data_binding_group(
        first_slots[0],
        semantic_int(3),
        ParameterReferenceGroup([ParameterPair("main", "sub")]),
    )
    append_data_binding_group(
        second_slots[0],
        semantic_int(3),
        ParameterReferenceGroup([ParameterPair("other", "value")]),
    )
    var merged = merge_parameter_dicts(
        first_parameters, first_slots, second_parameters, second_slots
    )
    assert_equal(len(merged.parameter_entries), 2)
    assert_equal(merged.parameter_entries[0].matrix_entry_index, 9)
    assert_equal(len(merged.data_slots[0].bindings), 1)
    assert_equal(len(merged.data_slots[0].bindings[0].groups), 2)


def test_typed_table_sync_contract() raises:
    var state = empty_universal_sync_state()
    var parameters = Dict[Int, String]()
    parameters[5] = "parameter"
    var tags = Dict[Int, String]()
    tags[5] = "tag"
    sync_tables(
        state,
        parameters,
        tags,
        "html",
        [["head"], ["cell"]],
        [0, 1],
        True,
        [1],
        True,
    )
    assert_equal(len(state.generated_columns.parameters), 1)
    assert_equal(state.generated_columns.parameters[5], "parameter")
    assert_equal(state.generated_columns.tags[5], "tag")
    assert_equal(len(state.output_sections), 1)
    assert_equal(state.output_sections[0].output_mode, "html")
    assert_equal(state.output_sections[0].resulting_table[1][0], "cell")
    assert_equal(state.output_sections[0].finally_display_lines, [0, 1])
    assert_true(state.output_sections[0].has_rows_range)
    sync_output_section_from_tables(state, "html", [["replacement"]])
    assert_equal(len(state.output_sections), 1)
    assert_equal(state.output_sections[0].resulting_table[0][0], "replacement")
    assert_equal(universal_operation_names(), ["merge_parameter_dicts", "normalize_column_buckets", "sync_tables"])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
