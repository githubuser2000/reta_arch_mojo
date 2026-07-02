"""Native universal constructions used by reta's architecture."""
from std.collections import Dict, List, Set
from .semantics_builder import DataSlot, ParameterDataEntry, merge_data_slots, merge_parameter_entries
from .table_state import GeneratedColumnSection


@fieldwise_init
struct ColumnBucket(Copyable):
    var polarity: Int
    var bucket_type: Int
    var values: Set[Int]


def make_bucket(polarity: Int, bucket_type: Int, values: List[Int]) -> ColumnBucket:
    var result = Set[Int]()
    for index in range(len(values)):
        result.add(values[index])
    return ColumnBucket(polarity, bucket_type, result^)


def _bucket_index(buckets: List[ColumnBucket], polarity: Int, bucket_type: Int) -> Int:
    for index in range(len(buckets)):
        if buckets[index].polarity == polarity and buckets[index].bucket_type == bucket_type:
            return index
    return -1


def normalize_column_buckets(source: List[ColumnBucket]) -> List[ColumnBucket]:
    """Deterministically subtract negative selections from positive buckets.

    This is the typed equivalent of
    ``spalten_removeDoublesNthenRemoveOneFromAnother``. Negative buckets are
    consumed by the construction and do not occur in the result.
    """
    var buckets = List[ColumnBucket]()
    for index in range(len(source)):
        buckets.append(source[index].copy())

    var max_type = len(buckets) // 2
    for bucket_type in range(max_type):
        var positive_index = _bucket_index(buckets, 0, bucket_type)
        var negative_index = _bucket_index(buckets, 1, bucket_type)
        if positive_index >= 0 and negative_index >= 0:
            var retained = Set[Int]()
            for value in buckets[positive_index].values:
                if value not in buckets[negative_index].values:
                    retained.add(value)
            buckets[positive_index].values = retained^

    var result = List[ColumnBucket]()
    for index in range(len(buckets)):
        if buckets[index].polarity == 0:
            result.append(buckets[index].copy())
    return result^



@fieldwise_init
struct MergedParameterDictionaries(Copyable):
    var parameter_entries: List[ParameterDataEntry]
    var data_slots: List[DataSlot]


def merge_parameter_dicts(
    first_parameters: List[ParameterDataEntry],
    first_data_slots: List[DataSlot],
    second_parameters: List[ParameterDataEntry],
    second_data_slots: List[DataSlot],
) -> MergedParameterDictionaries:
    """Typed pushout-like merge used by the native semantics builder.

    Later parameter-pair mappings overwrite earlier mappings, while incoming
    data reference groups are appended.  This is the deterministic native
    equivalent of Python's heterogeneous dictionary merge.
    """

    var parameters = first_parameters.copy()
    var slots = first_data_slots.copy()
    merge_parameter_entries(parameters, second_parameters)
    merge_data_slots(slots, second_data_slots)
    return MergedParameterDictionaries(parameters^, slots^)


@fieldwise_init
struct TableOutputSection(Copyable):
    var output_mode: String
    var resulting_table: List[List[String]]
    var finally_display_lines: List[Int]
    var has_finally_display_lines: Bool
    var rows_range: List[Int]
    var has_rows_range: Bool


@fieldwise_init
struct UniversalSyncState(Copyable):
    var generated_columns: GeneratedColumnSection
    var output_sections: List[TableOutputSection]


def empty_universal_sync_state() -> UniversalSyncState:
    return UniversalSyncState(
        GeneratedColumnSection(Dict[Int, String](), Dict[Int, String]()),
        List[TableOutputSection](),
    )


def _copy_int_string_dict(source: Dict[Int, String]) -> Dict[Int, String]:
    var result = Dict[Int, String]()
    for item in source.items():
        result[item.key] = item.value
    return result^


def _copy_int_list(source: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(source)):
        result.append(source[index])
    return result^


def _copy_string_table(source: List[List[String]]) -> List[List[String]]:
    var result = List[List[String]]()
    for row_index in range(len(source)):
        var row = List[String]()
        for column_index in range(len(source[row_index])):
            row.append(source[row_index][column_index])
        result.append(row^)
    return result^


def sync_generated_columns_from_tables(
    mut state: UniversalSyncState,
    generated_parameters: Dict[Int, String],
    generated_tags: Dict[Int, String],
) -> None:
    state.generated_columns = GeneratedColumnSection(
        _copy_int_string_dict(generated_parameters),
        _copy_int_string_dict(generated_tags),
    )


def _output_section_index(state: UniversalSyncState, output_mode: String) -> Int:
    for index in range(len(state.output_sections)):
        if state.output_sections[index].output_mode == output_mode:
            return index
    return -1


def sync_output_section_from_tables(
    mut state: UniversalSyncState,
    output_mode: String,
    resulting_table: List[List[String]],
    finally_display_lines: List[Int] = List[Int](),
    has_finally_display_lines: Bool = False,
    rows_range: List[Int] = List[Int](),
    has_rows_range: Bool = False,
) -> None:
    var section = TableOutputSection(
        output_mode,
        _copy_string_table(resulting_table),
        _copy_int_list(finally_display_lines),
        has_finally_display_lines,
        _copy_int_list(rows_range),
        has_rows_range,
    )
    var index = _output_section_index(state, output_mode)
    if index < 0:
        state.output_sections.append(section^)
    else:
        state.output_sections[index] = section^


def sync_tables(
    mut state: UniversalSyncState,
    generated_parameters: Dict[Int, String],
    generated_tags: Dict[Int, String],
    output_mode: String = "",
    resulting_table: List[List[String]] = List[List[String]](),
    finally_display_lines: List[Int] = List[Int](),
    has_finally_display_lines: Bool = False,
    rows_range: List[Int] = List[Int](),
    has_rows_range: Bool = False,
) -> None:
    sync_generated_columns_from_tables(state, generated_parameters, generated_tags)
    if output_mode.byte_length() > 0:
        sync_output_section_from_tables(
            state,
            output_mode,
            resulting_table,
            finally_display_lines,
            has_finally_display_lines,
            rows_range,
            has_rows_range,
        )


def universal_operation_names() -> List[String]:
    return ["merge_parameter_dicts", "normalize_column_buckets", "sync_tables"]
