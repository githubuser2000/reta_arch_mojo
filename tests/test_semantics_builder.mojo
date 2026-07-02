from std.collections import List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.semantics_builder import *


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



def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
