"""Native construction of reta's canonical parameter semantics.

This module ports ``reta_architecture.semantics_builder`` into explicit typed
records.  Python used heterogeneous dictionaries and tuple/list values.  Mojo
keeps the same information in tagged values, ordered mapping records and
reference groups, which makes ownership and merge behaviour deterministic.
"""

from std.collections import Dict, List
from std.collections.string import ord
from .number_theory import prime_creativity


comptime SEMANTIC_INT = 0
comptime SEMANTIC_TEXT = 1
comptime SEMANTIC_INT_TUPLE = 2
comptime SEMANTIC_BOOL = 3
comptime SEMANTIC_BOOL_TUPLE = 4
comptime SEMANTIC_CALLABLE = 5
comptime SEMANTIC_NULL = 6
comptime SEMANTIC_SENTINEL = 7
comptime SEMANTIC_NULL_TUPLE = 8


@fieldwise_init
struct SemanticValue(Copyable, Equatable, Writable):
    var kind: Int
    var text: String
    var first: Int
    var second: Int
    var tuple_length: Int
    var bool_value: Bool
    var first_is_bool: Bool

    def __eq__(self, other: Self) -> Bool:
        return (
            self.kind == other.kind
            and self.text == other.text
            and self.first == other.first
            and self.second == other.second
            and self.tuple_length == other.tuple_length
            and self.bool_value == other.bool_value
            and self.first_is_bool == other.first_is_bool
        )

    def write_to[W: Writer](self, mut writer: W):
        writer.write(self.canonical())

    def canonical(self) -> String:
        if self.kind == SEMANTIC_INT:
            return "int:" + String(self.first)
        if self.kind == SEMANTIC_TEXT:
            return "text:" + self.text
        if self.kind == SEMANTIC_INT_TUPLE:
            if self.tuple_length == 1:
                return "tuple:(" + String(self.first) + ",)"
            return "tuple:(" + String(self.first) + "," + String(self.second) + ")"
        if self.kind == SEMANTIC_BOOL:
            return "bool:" + ("true" if self.bool_value else "false")
        if self.kind == SEMANTIC_BOOL_TUPLE:
            return (
                "booltuple:("
                + ("true" if self.bool_value else "false")
                + ","
                + String(self.second)
                + ")"
            )
        if self.kind == SEMANTIC_CALLABLE:
            return "callable:" + self.text
        if self.kind == SEMANTIC_SENTINEL:
            return "sentinel:" + self.text + ":" + String(self.first)
        if self.kind == SEMANTIC_NULL_TUPLE:
            return "tuple:(none,)"
        return "null"


def semantic_int(value: Int) -> SemanticValue:
    return SemanticValue(SEMANTIC_INT, "", value, 0, 0, False, False)


def semantic_text(value: String) -> SemanticValue:
    return SemanticValue(SEMANTIC_TEXT, value, 0, 0, 0, False, False)


def semantic_int_tuple(first: Int, second: Int) -> SemanticValue:
    return SemanticValue(SEMANTIC_INT_TUPLE, "", first, second, 2, False, False)


def semantic_single_int_tuple(first: Int) -> SemanticValue:
    return SemanticValue(SEMANTIC_INT_TUPLE, "", first, 0, 1, False, False)


def semantic_null_tuple() -> SemanticValue:
    return SemanticValue(SEMANTIC_NULL_TUPLE, "", 0, 0, 1, False, False)


def semantic_bool(value: Bool) -> SemanticValue:
    return SemanticValue(SEMANTIC_BOOL, "", 0, 0, 0, value, True)


def semantic_bool_tuple(value: Bool, second: Int) -> SemanticValue:
    return SemanticValue(SEMANTIC_BOOL_TUPLE, "", 0, second, 2, value, True)


def semantic_callable(name: String) -> SemanticValue:
    return SemanticValue(SEMANTIC_CALLABLE, name, 0, 0, 0, False, False)


def semantic_null() -> SemanticValue:
    return SemanticValue(SEMANTIC_NULL, "", 0, 0, 0, False, False)


def semantic_sentinel(name: String, number: Int) -> SemanticValue:
    return SemanticValue(SEMANTIC_SENTINEL, name, number, 0, 2, False, False)


@fieldwise_init
struct SemanticDataSet(Copyable):
    var values: List[SemanticValue]


@fieldwise_init
struct ParameterMatrixEntry(Copyable):
    var main_names: List[String]
    var parameter_names: List[String]
    var datasets: List[SemanticDataSet]


@fieldwise_init
struct CombinationEntry(Copyable):
    var key: Int
    var values: List[String]


@fieldwise_init
struct ParameterSemanticsSchema(Copyable):
    var entries: List[ParameterMatrixEntry]
    var combinations1: List[CombinationEntry]
    var combinations2: List[CombinationEntry]


@fieldwise_init
struct ParameterPair(Copyable, Equatable, Writable):
    var main_name: String
    var parameter_name: String

    def __eq__(self, other: Self) -> Bool:
        return self.main_name == other.main_name and self.parameter_name == other.parameter_name

    def write_to[W: Writer](self, mut writer: W):
        writer.write("(", self.main_name, ",", self.parameter_name, ")")


@fieldwise_init
struct MainParameterEntry(Copyable):
    var main_name: String
    var parameter_names: List[String]


@fieldwise_init
struct ParameterDataEntry(Copyable):
    var pair: ParameterPair
    var matrix_entry_index: Int


@fieldwise_init
struct ParameterReferenceGroup(Copyable, Equatable):
    var pairs: List[ParameterPair]

    def __eq__(self, other: Self) -> Bool:
        if len(self.pairs) != len(other.pairs):
            return False
        for index in range(len(self.pairs)):
            if self.pairs[index] != other.pairs[index]:
                return False
        return True


@fieldwise_init
struct DataBinding(Copyable):
    var key: SemanticValue
    var groups: List[ParameterReferenceGroup]


@fieldwise_init
struct DataSlot(Copyable):
    var bindings: List[DataBinding]
    var combinations: List[CombinationEntry]
    var is_combination: Bool


@fieldwise_init
struct ReverseLookupEntry(Copyable, Equatable, Writable):
    var value: String
    var key: Int

    def __eq__(self, other: Self) -> Bool:
        return self.value == other.value and self.key == other.key

    def write_to[W: Writer](self, mut writer: W):
        writer.write(self.value, "=", self.key)


@fieldwise_init
struct IntoParameterDatatypeResult(Copyable):
    var main_entries: List[MainParameterEntry]
    var parameter_entries: List[ParameterDataEntry]
    var data_slots: List[DataSlot]


@fieldwise_init
struct AllValuesResult(Copyable):
    var all_values: List[SemanticDataSet]
    var all_simple_command_columns: List[Int]


@fieldwise_init
struct ParameterSemanticsBuildResult(Copyable):
    var para_main_dict: List[MainParameterEntry]
    var para_dict: List[ParameterDataEntry]
    var data_dict: List[DataSlot]
    var para_n_data_matrix: List[ParameterMatrixEntry]
    var kombi_para_n_data_matrix: List[CombinationEntry]
    var kombi_para_n_data_matrix2: List[CombinationEntry]
    var kombi_reverse_dict: List[ReverseLookupEntry]
    var kombi_reverse_dict2: List[ReverseLookupEntry]
    var all_simple_command_columns: List[Int]
    var all_values: List[SemanticDataSet]


def empty_data_slots(amount: Int = 14) -> List[DataSlot]:
    var result = List[DataSlot]()
    for _ in range(amount):
        result.append(DataSlot(List[DataBinding](), List[CombinationEntry](), False))
    return result^


def _contains_semantic(values: List[SemanticValue], candidate: SemanticValue) -> Bool:
    for index in range(len(values)):
        if values[index] == candidate:
            return True
    return False


def _contains_int(values: List[Int], candidate: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == candidate:
            return True
    return False


def _contains_string(values: List[String], candidate: String) -> Bool:
    for index in range(len(values)):
        if values[index] == candidate:
            return True
    return False


def _contains_group(values: List[ParameterReferenceGroup], candidate: ParameterReferenceGroup) -> Bool:
    for index in range(len(values)):
        if values[index] == candidate:
            return True
    return False


def _semantic_less(left: SemanticValue, right: SemanticValue) -> Bool:
    return left.canonical() < right.canonical()


def _sort_semantic_values(mut values: List[SemanticValue]) -> None:
    for index in range(1, len(values)):
        var key = values[index].copy()
        var previous = index - 1
        while previous >= 0 and _semantic_less(key, values[previous]):
            values[previous + 1] = values[previous].copy()
            previous -= 1
        values[previous + 1] = key^


def _sort_ints(mut values: List[Int]) -> None:
    for index in range(1, len(values)):
        var key = values[index]
        var previous = index - 1
        while previous >= 0 and values[previous] > key:
            values[previous + 1] = values[previous]
            previous -= 1
        values[previous + 1] = key


def _decimal_string(value: String) -> Bool:
    if value.byte_length() == 0:
        return False
    for index in range(value.byte_length()):
        var byte = ord(value[byte=index])
        if byte < 48 or byte > 57:
            return False
    return True


def _parse_decimal(value: String) -> Int:
    var result = 0
    for index in range(value.byte_length()):
        result = result * 10 + ord(value[byte=index]) - 48
    return result


def allowed_prim_numbers_for_command() -> List[String]:
    var result = List[String]()
    for number in range(2, 32):
        if prime_creativity(number) == 1:
            result.append(String(number))
    return result^


def build_reverse_lookup(mapping: List[CombinationEntry]) -> List[ReverseLookupEntry]:
    var result = List[ReverseLookupEntry]()
    for mapping_index in range(len(mapping)):
        var entry = mapping[mapping_index].copy()
        for value_index in range(len(entry.values)):
            var found = -1
            for result_index in range(len(result)):
                if result[result_index].value == entry.values[value_index]:
                    found = result_index
                    break
            if found >= 0:
                result[found].key = entry.key
            else:
                result.append(ReverseLookupEntry(entry.values[value_index], entry.key))
    return result^


def _copy_semantic_values(values: List[SemanticValue]) -> List[SemanticValue]:
    var result = List[SemanticValue]()
    for index in range(len(values)):
        result.append(values[index].copy())
    return result^



def _copy_int_list(values: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _copy_string_list(values: List[String]) -> List[String]:
    var result = List[String]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _copy_combination_entries(values: List[CombinationEntry]) -> List[CombinationEntry]:
    var result = List[CombinationEntry]()
    for index in range(len(values)):
        result.append(CombinationEntry(values[index].key, _copy_string_list(values[index].values)))
    return result^


def collect_all_values(
    schema: ParameterSemanticsSchema,
    gebrochen_spalten_maximum_plus1: Int,
    invert_alles: Bool,
) -> AllValuesResult:
    var all_values = List[SemanticDataSet]()
    for _ in range(12):
        all_values.append(SemanticDataSet(List[SemanticValue]()))

    for entry_index in range(len(schema.entries)):
        var entry = schema.entries[entry_index].copy()
        var limit = len(entry.datasets)
        if limit > 12:
            limit = 12
        for dataset_index in range(limit):
            for value_index in range(len(entry.datasets[dataset_index].values)):
                var candidate = entry.datasets[dataset_index].values[value_index].copy()
                if not _contains_semantic(all_values[dataset_index].values, candidate):
                    all_values[dataset_index].values.append(candidate^)

    var simple_columns = List[Int]()
    for index in range(len(all_values[0].values)):
        if all_values[0].values[index].kind == SEMANTIC_INT:
            var value = all_values[0].values[index].first
            if not _contains_int(simple_columns, value):
                simple_columns.append(value)
    _sort_ints(simple_columns)

    if invert_alles and len(all_values[0].values) > 0:
        var maximum = 0
        for index in range(len(all_values[0].values)):
            if all_values[0].values[index].kind == SEMANTIC_INT:
                if all_values[0].values[index].first > maximum:
                    maximum = all_values[0].values[index].first
        var inverted = List[SemanticValue]()
        for value in range(maximum):
            var excluded = _contains_semantic(all_values[0].values, semantic_int(value))
            if not excluded:
                for pair_index in range(len(all_values[1].values)):
                    var pair = all_values[1].values[pair_index].copy()
                    if pair.kind == SEMANTIC_INT_TUPLE and (
                        pair.first == value or (pair.tuple_length > 1 and pair.second == value)
                    ):
                        excluded = True
                        break
            if not excluded:
                inverted.append(semantic_int(value))
        all_values[0].values = inverted^

    var primes = List[SemanticValue]()
    var prime_strings = allowed_prim_numbers_for_command()
    for index in range(len(prime_strings)):
        primes.append(semantic_int(_parse_decimal(prime_strings[index])))
    all_values[2].values = primes^

    var kombi1 = List[SemanticValue]()
    for index in range(len(schema.combinations1)):
        kombi1.append(semantic_int(schema.combinations1[index].key))
    all_values[3].values = kombi1^

    var fractions1 = List[SemanticValue]()
    for value in range(2, gebrochen_spalten_maximum_plus1):
        fractions1.append(semantic_int(value))
    all_values[5].values = _copy_semantic_values(fractions1)
    all_values[6].values = _copy_semantic_values(fractions1)

    var kombi2 = List[SemanticValue]()
    for index in range(len(schema.combinations2)):
        kombi2.append(semantic_int(schema.combinations2[index].key))
    all_values[8].values = kombi2^
    all_values[9].values = _copy_semantic_values(fractions1)
    all_values[10].values = _copy_semantic_values(fractions1)

    if invert_alles:
        for index in range(1, 11):
            all_values[index].values = List[SemanticValue]()

    for index in range(len(all_values)):
        _sort_semantic_values(all_values[index].values)
    return AllValuesResult(all_values^, simple_columns^)


def _cross_product_pairs(
    parameter_main_names: List[String], parameter_names: List[String]
) -> List[ParameterPair]:
    var result = List[ParameterPair]()
    if len(parameter_names) == 0:
        for main_index in range(len(parameter_main_names)):
            result.append(ParameterPair(parameter_main_names[main_index], ""))
        return result^
    for main_index in range(len(parameter_main_names)):
        for parameter_index in range(len(parameter_names)):
            result.append(
                ParameterPair(
                    parameter_main_names[main_index], parameter_names[parameter_index]
                )
            )
    return result^


def _binding_index(bindings: List[DataBinding], key: SemanticValue) -> Int:
    for index in range(len(bindings)):
        if bindings[index].key == key:
            return index
    return -1


def _append_binding_group(
    mut slot: DataSlot,
    key: SemanticValue,
    group: ParameterReferenceGroup,
    deduplicate: Bool = True,
) -> None:
    var index = _binding_index(slot.bindings, key)
    if index < 0:
        var groups = List[ParameterReferenceGroup]()
        groups.append(group.copy())
        slot.bindings.append(DataBinding(key.copy(), groups^))
        return
    if not deduplicate or not _contains_group(slot.bindings[index].groups, group):
        slot.bindings[index].groups.append(group.copy())


def append_data_binding_group(
    mut slot: DataSlot,
    key: SemanticValue,
    group: ParameterReferenceGroup,
    deduplicate: Bool = True,
) -> None:
    _append_binding_group(slot, key, group, deduplicate)


def into_parameter_datatype(
    parameter_main_names: List[String],
    parameter_names: List[String],
    datas: List[SemanticDataSet],
    matrix_entry_index: Int = 0,
) -> IntoParameterDatatypeResult:
    var main_entries = List[MainParameterEntry]()
    for main_index in range(len(parameter_main_names)):
        main_entries.append(
            MainParameterEntry(
                parameter_main_names[main_index], _copy_string_list(parameter_names)
            )
        )

    var parameter_entries = List[ParameterDataEntry]()
    var all_pairs = _cross_product_pairs(parameter_main_names, parameter_names)
    for pair_index in range(len(all_pairs)):
        parameter_entries.append(
            ParameterDataEntry(all_pairs[pair_index].copy(), matrix_entry_index)
        )

    var data_slots = empty_data_slots(12)
    for dataset_index in range(len(datas)):
        if dataset_index >= 12:
            break
        for value_index in range(len(datas[dataset_index].values)):
            var value = datas[dataset_index].values[value_index].copy()
            var target_index = dataset_index
            var case_two = (
                dataset_index == 5
                or dataset_index == 6
                or dataset_index == 9
                or dataset_index == 10
                or (dataset_index == 2 and value.kind == SEMANTIC_CALLABLE)
            )
            var case_one = dataset_index == 4 and (
                value.kind == SEMANTIC_BOOL
                or value.kind == SEMANTIC_BOOL_TUPLE
                or value.first_is_bool
            )
            if case_one:
                target_index = 3
                _append_binding_group(
                    data_slots[target_index],
                    semantic_sentinel("bool", 0),
                    ParameterReferenceGroup(_copy_pairs(all_pairs)),
                )
            elif case_two:
                var pair_index = 0
                for main_index in range(len(parameter_main_names)):
                    if len(parameter_names) == 0:
                        _append_binding_group(
                            data_slots[target_index],
                            semantic_null(),
                            ParameterReferenceGroup([
                                ParameterPair(parameter_main_names[main_index], "")
                            ]),
                        )
                    else:
                        for parameter_index in range(len(parameter_names)):
                            var parameter_name = parameter_names[parameter_index]
                            var key = semantic_text(parameter_name)
                            if _decimal_string(parameter_name):
                                key = semantic_int(_parse_decimal(parameter_name))
                            _append_binding_group(
                                data_slots[target_index],
                                key^,
                                ParameterReferenceGroup([
                                    ParameterPair(
                                        parameter_main_names[main_index], parameter_name
                                    )
                                ]),
                            )
                            pair_index += 1
            else:
                _append_binding_group(
                    data_slots[target_index],
                    value^,
                    ParameterReferenceGroup(_copy_pairs(all_pairs)),
                )
    return IntoParameterDatatypeResult(main_entries^, parameter_entries^, data_slots^)


def _copy_pairs(values: List[ParameterPair]) -> List[ParameterPair]:
    var result = List[ParameterPair]()
    for index in range(len(values)):
        result.append(values[index].copy())
    return result^


def _main_entry_index(values: List[MainParameterEntry], main_name: String) -> Int:
    for index in range(len(values)):
        if values[index].main_name == main_name:
            return index
    return -1


def _parameter_entry_index(values: List[ParameterDataEntry], pair: ParameterPair) -> Int:
    for index in range(len(values)):
        if values[index].pair == pair:
            return index
    return -1


def merge_main_entries(
    mut target: List[MainParameterEntry], incoming: List[MainParameterEntry]
) -> None:
    for index in range(len(incoming)):
        var existing = _main_entry_index(target, incoming[index].main_name)
        if existing >= 0:
            target[existing].parameter_names = _copy_string_list(incoming[index].parameter_names)
        else:
            target.append(
                MainParameterEntry(
                    incoming[index].main_name,
                    _copy_string_list(incoming[index].parameter_names),
                )
            )


def merge_parameter_entries(
    mut target: List[ParameterDataEntry], incoming: List[ParameterDataEntry]
) -> None:
    for index in range(len(incoming)):
        var existing = _parameter_entry_index(target, incoming[index].pair)
        if existing >= 0:
            target[existing].matrix_entry_index = incoming[index].matrix_entry_index
        else:
            target.append(incoming[index].copy())


def merge_data_slots(mut target: List[DataSlot], incoming: List[DataSlot]) -> None:
    while len(target) < len(incoming):
        target.append(DataSlot(List[DataBinding](), List[CombinationEntry](), False))
    for slot_index in range(len(incoming)):
        if incoming[slot_index].is_combination:
            target[slot_index] = incoming[slot_index].copy()
            continue
        for binding_index in range(len(incoming[slot_index].bindings)):
            var binding = incoming[slot_index].bindings[binding_index].copy()
            for group_index in range(len(binding.groups)):
                _append_binding_group(
                    target[slot_index],
                    binding.key.copy(),
                    binding.groups[group_index].copy(),
                    False,
                )


def _copy_datasets(values: List[SemanticDataSet]) -> List[SemanticDataSet]:
    var result = List[SemanticDataSet]()
    for index in range(len(values)):
        result.append(SemanticDataSet(_copy_semantic_values(values[index].values)))
    return result^


def _copy_matrix_entry(value: ParameterMatrixEntry) -> ParameterMatrixEntry:
    return ParameterMatrixEntry(
        _copy_string_list(value.main_names),
        _copy_string_list(value.parameter_names),
        _copy_datasets(value.datasets),
    )


def _parameter_pair_index_key(pair: ParameterPair) -> String:
    return (
        String(pair.main_name.byte_length())
        + ":"
        + pair.main_name
        + String(pair.parameter_name.byte_length())
        + ":"
        + pair.parameter_name
    )


def _slot_binding_index_key(slot_index: Int, key: SemanticValue) -> String:
    var canonical = key.canonical()
    return String(slot_index) + ":" + String(canonical.byte_length()) + ":" + canonical


def build_parameter_semantics(
    schema: ParameterSemanticsSchema,
    gebrochen_spalten_maximum_plus1: Int,
    invert_alles: Bool,
    alles_parameter_names: List[String],
) raises -> ParameterSemanticsBuildResult:
    var matrix = List[ParameterMatrixEntry]()
    for index in range(len(schema.entries)):
        matrix.append(_copy_matrix_entry(schema.entries[index]))

    var collected = collect_all_values(
        schema, gebrochen_spalten_maximum_plus1, invert_alles
    )
    matrix.append(
        ParameterMatrixEntry(
            _copy_string_list(alles_parameter_names),
            List[String](),
            _copy_datasets(collected.all_values),
        )
    )

    var main_entries = List[MainParameterEntry]()
    var main_indexes = Dict[String, Int]()
    var parameter_entries = List[ParameterDataEntry]()
    var parameter_indexes = Dict[String, Int]()
    var data_slots = empty_data_slots(14)
    var binding_indexes = Dict[String, Int]()

    for entry_index in range(len(matrix)):
        var local = into_parameter_datatype(
            matrix[entry_index].main_names,
            matrix[entry_index].parameter_names,
            matrix[entry_index].datasets,
            entry_index,
        )

        for local_index in range(len(local.main_entries)):
            var incoming_main = local.main_entries[local_index].copy()
            if incoming_main.main_name in main_indexes:
                var target_index = main_indexes[incoming_main.main_name]
                main_entries[target_index].parameter_names = _copy_string_list(
                    incoming_main.parameter_names
                )
            else:
                main_indexes[incoming_main.main_name] = len(main_entries)
                main_entries.append(incoming_main^)

        for local_index in range(len(local.parameter_entries)):
            var incoming_parameter = local.parameter_entries[local_index].copy()
            var pair_key = _parameter_pair_index_key(incoming_parameter.pair)
            if pair_key in parameter_indexes:
                parameter_entries[parameter_indexes[pair_key]].matrix_entry_index = (
                    incoming_parameter.matrix_entry_index
                )
            else:
                parameter_indexes[pair_key] = len(parameter_entries)
                parameter_entries.append(incoming_parameter^)

        for slot_index in range(len(local.data_slots)):
            for binding_index in range(len(local.data_slots[slot_index].bindings)):
                var incoming_binding = local.data_slots[slot_index].bindings[
                    binding_index
                ].copy()
                var binding_key = _slot_binding_index_key(
                    slot_index, incoming_binding.key
                )
                if binding_key in binding_indexes:
                    var target_binding = binding_indexes[binding_key]
                    for group_index in range(len(incoming_binding.groups)):
                        data_slots[slot_index].bindings[target_binding].groups.append(
                            incoming_binding.groups[group_index].copy()
                        )
                else:
                    binding_indexes[binding_key] = len(data_slots[slot_index].bindings)
                    data_slots[slot_index].bindings.append(incoming_binding^)

    data_slots[3] = DataSlot(
        List[DataBinding](), _copy_combination_entries(schema.combinations1), True
    )
    data_slots[8] = DataSlot(
        List[DataBinding](), _copy_combination_entries(schema.combinations2), True
    )

    return ParameterSemanticsBuildResult(
        main_entries^,
        parameter_entries^,
        data_slots^,
        matrix^,
        _copy_combination_entries(schema.combinations1),
        _copy_combination_entries(schema.combinations2),
        build_reverse_lookup(schema.combinations1),
        build_reverse_lookup(schema.combinations2),
        _copy_int_list(collected.all_simple_command_columns),
        _copy_datasets(collected.all_values),
    )


def bootstrap_parameter_semantics_builder(
    schema: ParameterSemanticsSchema,
    gebrochen_spalten_maximum_plus1: Int,
    invert_alles: Bool,
    alles_parameter_names: List[String],
) raises -> ParameterSemanticsBuildResult:
    return build_parameter_semantics(
        schema,
        gebrochen_spalten_maximum_plus1,
        invert_alles,
        alles_parameter_names,
    )


comptime SEMANTICS_FINGERPRINT_MOD1 = 1000000007
comptime SEMANTICS_FINGERPRINT_MOD2 = 1000000009


@fieldwise_init
struct SemanticFingerprint(Copyable, Equatable, Writable):
    """Order-independent content fingerprint for the heterogeneous Python contract."""

    var records: Int
    var sum1: Int
    var sum2: Int
    var square1: Int
    var square2: Int

    def __eq__(self, other: Self) -> Bool:
        return (
            self.records == other.records
            and self.sum1 == other.sum1
            and self.sum2 == other.sum2
            and self.square1 == other.square1
            and self.square2 == other.square2
        )

    def canonical(self) -> String:
        return (
            String(self.records)
            + ":"
            + String(self.sum1)
            + ":"
            + String(self.sum2)
            + ":"
            + String(self.square1)
            + ":"
            + String(self.square2)
        )

    def write_to[W: Writer](self, mut writer: W):
        writer.write(self.canonical())


def empty_semantic_fingerprint() -> SemanticFingerprint:
    return SemanticFingerprint(0, 0, 0, 0, 0)


def _fingerprint_field(value: String) -> String:
    return String(value.byte_length()) + ":" + value


def _fingerprint_record(
    tag: String,
    first: String = "",
    second: String = "",
    third: String = "",
    fourth: String = "",
    fifth: String = "",
) -> String:
    return (
        _fingerprint_field(tag)
        + _fingerprint_field(first)
        + _fingerprint_field(second)
        + _fingerprint_field(third)
        + _fingerprint_field(fourth)
        + _fingerprint_field(fifth)
    )


def _record_hash(value: String, modulus: Int, base: Int) -> Int:
    var result = 0
    var bytes = value.as_bytes()
    for index in range(len(bytes)):
        result = (result * base + Int(bytes[index]) + 1) % modulus
    return result


def _fingerprint_add(mut result: SemanticFingerprint, record: String) -> None:
    var first = _record_hash(record, SEMANTICS_FINGERPRINT_MOD1, 257)
    var second = _record_hash(record, SEMANTICS_FINGERPRINT_MOD2, 263)
    result.records += 1
    result.sum1 = (result.sum1 + first) % SEMANTICS_FINGERPRINT_MOD1
    result.sum2 = (result.sum2 + second) % SEMANTICS_FINGERPRINT_MOD2
    result.square1 = (
        result.square1 + (first * first) % SEMANTICS_FINGERPRINT_MOD1
    ) % SEMANTICS_FINGERPRINT_MOD1
    result.square2 = (
        result.square2 + (second * second) % SEMANTICS_FINGERPRINT_MOD2
    ) % SEMANTICS_FINGERPRINT_MOD2


def _group_fingerprint(group: ParameterReferenceGroup) -> SemanticFingerprint:
    var result = empty_semantic_fingerprint()
    for index in range(len(group.pairs)):
        _fingerprint_add(
            result,
            _fingerprint_record(
                "pair", group.pairs[index].main_name, group.pairs[index].parameter_name
            ),
        )
    return result^


def parameter_semantics_fingerprint(
    result: ParameterSemanticsBuildResult,
) -> SemanticFingerprint:
    """Fingerprint every semantic leaf without depending on dictionary/set order.

    Matrix and sequence coordinates are recorded where Python exposes ordering.
    Dictionary-like bindings and reference groups are aggregated as multisets.
    The Python parity generator uses the same UTF-8 polynomial hashes and
    modular moments, so equal fingerprints cover substantially more than the
    traditional regression counts.
    """

    var fingerprint = empty_semantic_fingerprint()

    for entry_index in range(len(result.para_n_data_matrix)):
        var entry = result.para_n_data_matrix[entry_index].copy()
        _fingerprint_add(
            fingerprint,
            _fingerprint_record(
                "matrix-shape",
                String(entry_index),
                String(len(entry.main_names)),
                String(len(entry.parameter_names)),
                String(len(entry.datasets)),
            ),
        )
        for main_index in range(len(entry.main_names)):
            _fingerprint_add(
                fingerprint,
                _fingerprint_record(
                    "matrix-main",
                    String(entry_index),
                    String(main_index),
                    entry.main_names[main_index],
                ),
            )
        for parameter_index in range(len(entry.parameter_names)):
            _fingerprint_add(
                fingerprint,
                _fingerprint_record(
                    "matrix-parameter",
                    String(entry_index),
                    String(parameter_index),
                    entry.parameter_names[parameter_index],
                ),
            )
        for dataset_index in range(len(entry.datasets)):
            _fingerprint_add(
                fingerprint,
                _fingerprint_record(
                    "matrix-dataset-size",
                    String(entry_index),
                    String(dataset_index),
                    String(len(entry.datasets[dataset_index].values)),
                ),
            )
            for value_index in range(len(entry.datasets[dataset_index].values)):
                _fingerprint_add(
                    fingerprint,
                    _fingerprint_record(
                        "matrix-value",
                        String(entry_index),
                        String(dataset_index),
                        entry.datasets[dataset_index].values[value_index].canonical(),
                    ),
                )

    for index in range(len(result.para_main_dict)):
        var entry = result.para_main_dict[index].copy()
        _fingerprint_add(
            fingerprint,
            _fingerprint_record(
                "main-size", entry.main_name, String(len(entry.parameter_names))
            ),
        )
        for parameter_index in range(len(entry.parameter_names)):
            _fingerprint_add(
                fingerprint,
                _fingerprint_record(
                    "main-parameter",
                    entry.main_name,
                    String(parameter_index),
                    entry.parameter_names[parameter_index],
                ),
            )

    for index in range(len(result.para_dict)):
        var entry = result.para_dict[index].copy()
        _fingerprint_add(
            fingerprint,
            _fingerprint_record(
                "parameter-pair",
                entry.pair.main_name,
                entry.pair.parameter_name,
                String(entry.matrix_entry_index),
            ),
        )

    for slot_index in range(len(result.data_dict)):
        var slot = result.data_dict[slot_index].copy()
        _fingerprint_add(
            fingerprint,
            _fingerprint_record(
                "data-slot",
                String(slot_index),
                "combination" if slot.is_combination else "binding",
                String(len(slot.combinations) if slot.is_combination else len(slot.bindings)),
            ),
        )
        if slot.is_combination:
            for combination_index in range(len(slot.combinations)):
                var combination = slot.combinations[combination_index].copy()
                _fingerprint_add(
                    fingerprint,
                    _fingerprint_record(
                        "combination-size",
                        String(slot_index),
                        String(combination.key),
                        String(len(combination.values)),
                    ),
                )
                for value_index in range(len(combination.values)):
                    _fingerprint_add(
                        fingerprint,
                        _fingerprint_record(
                            "combination-value",
                            String(slot_index),
                            String(combination.key),
                            String(value_index),
                            combination.values[value_index],
                        ),
                    )
            continue
        for binding_index in range(len(slot.bindings)):
            var binding = slot.bindings[binding_index].copy()
            var key = binding.key.canonical()
            _fingerprint_add(
                fingerprint,
                _fingerprint_record(
                    "binding-size",
                    String(slot_index),
                    key,
                    String(len(binding.groups)),
                ),
            )
            for group_index in range(len(binding.groups)):
                var group_hash = _group_fingerprint(binding.groups[group_index])
                _fingerprint_add(
                    fingerprint,
                    _fingerprint_record(
                        "binding-group",
                        String(slot_index),
                        key,
                        group_hash.canonical(),
                    ),
                )

    for index in range(len(result.kombi_reverse_dict)):
        _fingerprint_add(
            fingerprint,
            _fingerprint_record(
                "reverse-1",
                result.kombi_reverse_dict[index].value,
                String(result.kombi_reverse_dict[index].key),
            ),
        )
    for index in range(len(result.kombi_reverse_dict2)):
        _fingerprint_add(
            fingerprint,
            _fingerprint_record(
                "reverse-2",
                result.kombi_reverse_dict2[index].value,
                String(result.kombi_reverse_dict2[index].key),
            ),
        )
    for index in range(len(result.all_simple_command_columns)):
        _fingerprint_add(
            fingerprint,
            _fingerprint_record(
                "simple-column", String(result.all_simple_command_columns[index])
            ),
        )
    for dataset_index in range(len(result.all_values)):
        _fingerprint_add(
            fingerprint,
            _fingerprint_record(
                "all-values-size",
                String(dataset_index),
                String(len(result.all_values[dataset_index].values)),
            ),
        )
        for value_index in range(len(result.all_values[dataset_index].values)):
            _fingerprint_add(
                fingerprint,
                _fingerprint_record(
                    "all-value",
                    String(dataset_index),
                    result.all_values[dataset_index].values[value_index].canonical(),
                ),
            )
    return fingerprint^


def semantic_record_fingerprint(record: String) -> SemanticFingerprint:
    """Expose the stable record hash for generator/parity tests."""
    var result = empty_semantic_fingerprint()
    _fingerprint_add(result, record)
    return result^


def semantic_fingerprint_record_for_test(
    tag: String,
    first: String = "",
    second: String = "",
    third: String = "",
    fourth: String = "",
    fifth: String = "",
) -> String:
    return _fingerprint_record(tag, first, second, third, fourth, fifth)
