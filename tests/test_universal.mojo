from std.collections import Dict, List
from std.testing import assert_equal, assert_true, assert_false, TestSuite
from reta_mojo.universal import *
from reta_mojo.semantics_builder import (
    ParameterPair,
    ParameterDataEntry,
    ParameterReferenceGroup,
    append_data_binding_group,
    empty_data_slots,
    semantic_int,
)


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
