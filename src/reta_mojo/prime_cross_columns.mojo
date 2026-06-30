"""Native port of Reta's generated prime-cross pro/contra columns."""

from std.collections import List
from .csv_table import CsvTable
from .types import IntPair
from .number_theory import (
    primCreativity,
    primMultiple,
    couldBePrimeNumberPrimzahlkreuz,
    couldBePrimeNumberPrimzahlkreuz_fuer_innen,
    couldBePrimeNumberPrimzahlkreuz_fuer_aussen,
)


@fieldwise_init
struct PrimeCrossColumns(Copyable):
    var forward: List[String]
    var reverse: List[String]


def _pc_cell(table: CsvTable, row: Int, column: Int) -> String:
    if row < 0 or row >= len(table.rows):
        return ""
    if column < 0 or column >= len(table.rows[row]):
        return ""
    return table.rows[row][column]


def _pc_english(language: String) -> Bool:
    return language == "english" or language == "en" or language == "englisch"


def _pc_headline() -> String:
    # The historical English catalog deliberately leaves this heading German.
    return "Gegen / pro: Nach Rechenregeln auf Primzahlkreuz und Vielfachern von Primzahlen"


def _pc_against(language: String) -> String:
    return "against " if _pc_english(language) else "gegen "


def _pc_for(language: String) -> String:
    return "per " if _pc_english(language) else "pro "


def _pc_perspective(number: Int, language: String) -> String:
    if _pc_english(language):
        return " In this " + String(number) + " is able to mentally understand the mind inside."
    return " Darin kann sich die " + String(number) + " am Besten hineinversetzen."


def _pc_reverse_sentence() -> String:
    # This sentence is also intentionally untranslated in the Python catalog.
    return " - Die Zahlen, die für oder gegen diese Zahlen hier sind, können sich in diese am Besten gedanklich hineinversetzen."


def _pc_pro_label(amount: Int, language: String) -> String:
    if _pc_english(language):
        return "per this number are: " if amount > 1 else "per this number is "
    return "pro dieser Zahl sind: " if amount > 1 else "pro dieser Zahl ist "


def _pc_contra_label(amount: Int, language: String) -> String:
    if _pc_english(language):
        return " contra this number are: " if amount > 1 else " contra this number is "
    return " contra dieser Zahl sind: " if amount > 1 else " contra dieser Zahl ist "


def _pc_contains_int(values: List[Int], value: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _pc_append_unique_int(mut values: List[Int], value: Int):
    if not _pc_contains_int(values, value):
        values.append(value)


def _pc_contains_string(values: List[String], value: String) -> Bool:
    for index in range(len(values)):
        if values[index] == value:
            return True
    return False


def _pc_append_unique_string(mut values: List[String], value: String):
    # Keep attempts; CPython set conversion and its pre-merge resizing are
    # reproduced immediately before rendering.
    values.append(value)


def _pc_join_strings(values: List[String], separator: String) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += separator
        result += values[index]
    return result^


def _pc_join_ints(values: List[Int], separator: String) -> String:
    var result = String()
    for index in range(len(values)):
        if index > 0:
            result += separator
        result += String(values[index])
    return result^


def _pc_empty_set_slots(size: Int) -> List[Int]:
    var slots = List[Int]()
    for _ in range(size):
        slots.append(-1)
    return slots^


def _pc_set_slot(slots: List[Int], value: Int) -> Int:
    # CPython 3.13 setobject.c probing for non-negative integer hashes.  The
    # Python reference falls back from orderedset.OrderedSet to builtin set,
    # so byte parity requires the same iteration order.
    var mask = len(slots) - 1
    var index = value & mask
    var perturb = value
    while True:
        if slots[index] == -1 or slots[index] == value:
            return index
        var probes = 9 if index + 9 <= mask else 0
        for offset in range(1, probes + 1):
            if slots[index + offset] == -1 or slots[index + offset] == value:
                return index + offset
        perturb >>= 5
        index = (index * 5 + 1 + perturb) & mask


def _pc_set_resize(slots: List[Int], minimum_used: Int) -> List[Int]:
    var new_size = 8
    while new_size <= minimum_used:
        new_size <<= 1
    var resized = _pc_empty_set_slots(new_size)
    for index in range(len(slots)):
        var value = slots[index]
        if value >= 0:
            var target = _pc_set_slot(resized, value)
            resized[target] = value
    return resized^


def _pc_python_set_order(values: List[Int]) -> List[Int]:
    # The source code repeatedly executes ``target |= {value}``.  set_merge()
    # can resize before discovering a duplicate, so preserve every insertion
    # attempt rather than deduplicating the input list first.
    var slots = _pc_empty_set_slots(8)
    var fill = 0
    var used = 0
    for value_index in range(len(values)):
        var value = values[value_index]
        var mask = len(slots) - 1
        if (fill + 1) * 5 >= mask * 3:
            slots = _pc_set_resize(slots, (used + 1) * 2)
            fill = used
        var target = _pc_set_slot(slots, value)
        if slots[target] == value:
            continue
        slots[target] = value
        fill += 1
        used += 1

    var result = List[Int]()
    for index in range(len(slots)):
        if slots[index] >= 0:
            result.append(slots[index])
    return result^


def python_int_set_order(values: List[Int]) -> List[Int]:
    """Public CPython-3.13 non-negative integer-set iteration order."""
    return _pc_python_set_order(values)


@fieldwise_init
struct _PcPairSetState(Copyable):
    var slots: List[Int]
    var values: List[IntPair]
    var hashes: List[UInt64]
    var fill: Int
    var used: Int


@fieldwise_init
struct _PcIntMergeSetState(Copyable):
    var slots: List[Int]
    var fill: Int
    var used: Int


def _pc_empty_pair_set() -> _PcPairSetState:
    return _PcPairSetState(
        _pc_empty_set_slots(8),
        List[IntPair](),
        List[UInt64](),
        0,
        0,
    )


def _pc_empty_int_merge_set() -> _PcIntMergeSetState:
    return _PcIntMergeSetState(_pc_empty_set_slots(8), 0, 0)


def _pc_copy_ints(values: List[Int]) -> List[Int]:
    var result = List[Int]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _pc_copy_pairs(values: List[IntPair]) -> List[IntPair]:
    var result = List[IntPair]()
    for index in range(len(values)):
        result.append(values[index].copy())
    return result^


def _pc_copy_hashes(values: List[UInt64]) -> List[UInt64]:
    var result = List[UInt64]()
    for index in range(len(values)):
        result.append(values[index])
    return result^


def _pc_tuple_pair_hash(value: IntPair) -> UInt64:
    # CPython 3.13 tuplehash(): the XXHash-derived two-lane tuple hash.  The
    # factor-pair inputs are positive integers, so their integer hashes equal
    # their values.
    var prime1 = UInt64(11400714785074694791)
    var prime2 = UInt64(14029467366897019727)
    var prime5 = UInt64(2870177450012600261)
    var accumulator = prime5

    accumulator += UInt64(value.first) * prime2
    accumulator = (accumulator << UInt64(31)) | (
        accumulator >> UInt64(33)
    )
    accumulator *= prime1

    accumulator += UInt64(value.second) * prime2
    accumulator = (accumulator << UInt64(31)) | (
        accumulator >> UInt64(33)
    )
    accumulator *= prime1

    accumulator += UInt64(2) ^ (prime5 ^ UInt64(3527539))
    return accumulator


def _pc_pair_set_slot(
    state: _PcPairSetState,
    value: IntPair,
    hash_value: UInt64,
) -> Int:
    var mask = len(state.slots) - 1
    var mask_u = UInt64(mask)
    var index = Int(hash_value & mask_u)
    var perturb = hash_value
    while True:
        var stored_index = state.slots[index]
        if stored_index == -1 or state.values[stored_index] == value:
            return index
        var probes = 9 if index + 9 <= mask else 0
        for offset in range(1, probes + 1):
            stored_index = state.slots[index + offset]
            if stored_index == -1 or state.values[stored_index] == value:
                return index + offset
        perturb >>= UInt64(5)
        index = Int(
            (UInt64(index * 5 + 1) + perturb) & mask_u
        )


def _pc_pair_set_resize(
    mut state: _PcPairSetState, minimum_used: Int
) -> None:
    var new_size = 8
    while new_size <= minimum_used:
        new_size <<= 1
    var old_slots = _pc_copy_ints(state.slots)
    state.slots = _pc_empty_set_slots(new_size)
    for index in range(len(old_slots)):
        var stored_index = old_slots[index]
        if stored_index >= 0:
            var target = _pc_pair_set_slot(
                state,
                state.values[stored_index],
                state.hashes[stored_index],
            )
            state.slots[target] = stored_index
    state.fill = state.used


def _pc_pair_set_add(
    mut state: _PcPairSetState, value: IntPair
) -> None:
    var hash_value = _pc_tuple_pair_hash(value)
    var target = _pc_pair_set_slot(state, value, hash_value)
    if state.slots[target] >= 0:
        return
    var stored_index = len(state.values)
    state.values.append(value.copy())
    state.hashes.append(hash_value)
    state.slots[target] = stored_index
    state.fill += 1
    state.used += 1
    if state.fill * 5 >= (len(state.slots) - 1) * 3:
        _pc_pair_set_resize(state, state.used * 4)


def _pc_pair_set_merge(
    mut target: _PcPairSetState, source: _PcPairSetState
) -> None:
    if (
        (target.fill + source.used) * 5
        >= (len(target.slots) - 1) * 3
    ):
        _pc_pair_set_resize(
            target, (target.used + source.used) * 2
        )
    if (
        target.fill == 0
        and len(target.slots) == len(source.slots)
        and source.fill == source.used
    ):
        target.slots = _pc_copy_ints(source.slots)
        target.values = _pc_copy_pairs(source.values)
        target.hashes = _pc_copy_hashes(source.hashes)
        target.fill = source.fill
        target.used = source.used
        return
    for index in range(len(source.slots)):
        var source_index = source.slots[index]
        if source_index < 0:
            continue
        var value = source.values[source_index].copy()
        var hash_value = source.hashes[source_index]
        var slot = _pc_pair_set_slot(target, value, hash_value)
        if target.slots[slot] >= 0:
            continue
        var target_index = len(target.values)
        target.values.append(value.copy())
        target.hashes.append(hash_value)
        target.slots[slot] = target_index
        target.fill += 1
        target.used += 1


def _pc_pair_set_order(state: _PcPairSetState) -> List[IntPair]:
    var result = List[IntPair]()
    for index in range(len(state.slots)):
        var stored_index = state.slots[index]
        if stored_index >= 0:
            result.append(state.values[stored_index].copy())
    return result^


def _pc_int_merge_set_slot(
    slots: List[Int], value: Int
) -> Int:
    return _pc_set_slot(slots, value)


def _pc_int_merge_set_resize(
    mut state: _PcIntMergeSetState, minimum_used: Int
) -> None:
    state.slots = _pc_set_resize(state.slots, minimum_used)
    state.fill = state.used


def _pc_int_merge_set_add(
    mut state: _PcIntMergeSetState, value: Int
) -> None:
    var target = _pc_int_merge_set_slot(state.slots, value)
    if state.slots[target] == value:
        return
    state.slots[target] = value
    state.fill += 1
    state.used += 1
    if state.fill * 5 >= (len(state.slots) - 1) * 3:
        _pc_int_merge_set_resize(state, state.used * 4)


def _pc_int_merge_set_from_pair(value: IntPair) -> _PcIntMergeSetState:
    var result = _pc_empty_int_merge_set()
    _pc_int_merge_set_add(result, value.first)
    _pc_int_merge_set_add(result, value.second)
    return result^


def _pc_int_merge_set_merge(
    mut target: _PcIntMergeSetState,
    source: _PcIntMergeSetState,
) -> None:
    if (
        (target.fill + source.used) * 5
        >= (len(target.slots) - 1) * 3
    ):
        _pc_int_merge_set_resize(
            target, (target.used + source.used) * 2
        )
    if (
        target.fill == 0
        and len(target.slots) == len(source.slots)
        and source.fill == source.used
    ):
        target.slots = _pc_copy_ints(source.slots)
        target.fill = source.fill
        target.used = source.used
        return
    for index in range(len(source.slots)):
        var value = source.slots[index]
        if value < 0:
            continue
        var slot = _pc_int_merge_set_slot(target.slots, value)
        if target.slots[slot] == value:
            continue
        target.slots[slot] = value
        target.fill += 1
        target.used += 1


def _pc_factor_pair_order(number: Int) -> List[IntPair]:
    # arithmetic.factor_pairs() first builds a tuple set through repeated
    # singleton unions, converts it to a list, appends (n, 1), and then the
    # caller constructs a fresh tuple set from that iterable.
    var first = _pc_empty_pair_set()
    var divisor = 2
    while divisor * divisor <= number:
        if number % divisor == 0:
            var singleton = _pc_empty_pair_set()
            _pc_pair_set_add(
                singleton, IntPair(number // divisor, divisor)
            )
            _pc_pair_set_merge(first, singleton)
        divisor += 1

    var first_order = _pc_pair_set_order(first)
    var second = _pc_empty_pair_set()
    for index in range(len(first_order)):
        _pc_pair_set_add(second, first_order[index])
    _pc_pair_set_add(second, IntPair(number, 1))
    return _pc_pair_set_order(second)


def python_divisor_set_order(numbers: List[Int]) -> List[Int]:
    """Reproduce arithmetic.divisor_range's CPython-3.13 set order.

    The reference nests tuple sets, two-element integer sets and ``set |=``.
    This is observably different from sorting divisors or from inserting each
    divisor directly (for example 24 serializes ``...,8,24,12``).
    """
    var target = _pc_empty_int_merge_set()
    for number_index in range(len(numbers)):
        var number = numbers[number_index]
        if number <= 0:
            continue
        var pairs = _pc_factor_pair_order(number)
        for pair_index in range(len(pairs)):
            var source = _pc_int_merge_set_from_pair(pairs[pair_index])
            _pc_int_merge_set_merge(target, source)

    var raw = List[Int]()
    for index in range(len(target.slots)):
        if target.slots[index] >= 0:
            raw.append(target.slots[index])
    var keep_one = len(raw) == 1 and raw[0] == 1
    var result = List[Int]()
    for index in range(len(raw)):
        if raw[index] != 1 or keep_one:
            result.append(raw[index])
    return result^


def _pc_signed_int_hash(value: Int) -> UInt64:
    # Python hashes integers as themselves, except -1 which is reserved as the
    # C-API error sentinel and therefore hashes to -2.  Conversion to UInt64
    # reproduces setobject.c's size_t perturbation for negative hashes.
    return UInt64(-2 if value == -1 else value)


def _pc_signed_int_set_slot(
    slots: List[Int], stored: List[Int], value: Int
) -> Int:
    var mask = len(slots) - 1
    var hash_value = _pc_signed_int_hash(value)
    var index = Int(hash_value & UInt64(mask))
    var perturb = hash_value
    while True:
        var stored_index = slots[index]
        if stored_index == -1 or stored[stored_index] == value:
            return index
        var probes = 9 if index + 9 <= mask else 0
        for offset in range(1, probes + 1):
            stored_index = slots[index + offset]
            if stored_index == -1 or stored[stored_index] == value:
                return index + offset
        perturb >>= UInt64(5)
        index = Int(
            (UInt64(index * 5 + 1) + perturb) & UInt64(mask)
        )


def _pc_signed_int_set_resize(
    slots: List[Int], stored: List[Int], minimum_used: Int
) -> List[Int]:
    var new_size = 8
    while new_size <= minimum_used:
        new_size <<= 1
    var resized = _pc_empty_set_slots(new_size)
    for index in range(len(slots)):
        var stored_index = slots[index]
        if stored_index >= 0:
            var target = _pc_signed_int_set_slot(
                resized, stored, stored[stored_index]
            )
            resized[target] = stored_index
    return resized^


def python_signed_int_set_order(values: List[Int]) -> List[Int]:
    """CPython-3.13 set iteration order for signed prompt row values."""
    var slots = _pc_empty_set_slots(8)
    var stored = List[Int]()
    var fill = 0
    var used = 0
    for value_index in range(len(values)):
        var value = values[value_index]
        var mask = len(slots) - 1
        if (fill + 1) * 5 >= mask * 3:
            slots = _pc_signed_int_set_resize(
                slots, stored, (used + 1) * 2
            )
            fill = used
        var target = _pc_signed_int_set_slot(slots, stored, value)
        if slots[target] >= 0:
            continue
        stored.append(value)
        slots[target] = len(stored) - 1
        fill += 1
        used += 1

    var result = List[Int]()
    for index in range(len(slots)):
        if slots[index] >= 0:
            result.append(stored[slots[index]])
    return result^


@fieldwise_init
struct _PcSipState(Copyable):
    var v0: UInt64
    var v1: UInt64
    var v2: UInt64
    var v3: UInt64


def _pc_rotl64(value: UInt64, amount: Int) -> UInt64:
    return (value << UInt64(amount)) | (value >> UInt64(64 - amount))


def _pc_sip_round(state: _PcSipState) -> _PcSipState:
    var v0 = state.v0 + state.v1
    var v1 = _pc_rotl64(state.v1, 13) ^ v0
    v0 = _pc_rotl64(v0, 32)
    var v2 = state.v2 + state.v3
    var v3 = _pc_rotl64(state.v3, 16) ^ v2
    v0 += v3
    v3 = _pc_rotl64(v3, 21) ^ v0
    v2 += v1
    v1 = _pc_rotl64(v1, 17) ^ v2
    v2 = _pc_rotl64(v2, 32)
    return _PcSipState(v0, v1, v2, v3)


def _pc_siphash13_seed_zero(text: String) -> UInt64:
    # CPython's deterministic PYTHONHASHSEED=0 string hash (SipHash-1-3,
    # zero 128-bit secret).  Prime-cross forward labels pass through builtin
    # set in the Python fallback, so this makes the native contract stable.
    var state = _PcSipState(
        UInt64(0x736f6d6570736575),
        UInt64(0x646f72616e646f6d),
        UInt64(0x6c7967656e657261),
        UInt64(0x7465646279746573),
    )
    var cursor = 0
    while cursor + 8 <= text.byte_length():
        var word = UInt64(0)
        for offset in range(8):
            word |= UInt64(ord(text[byte=cursor + offset])) << UInt64(offset * 8)
        state.v3 ^= word
        state = _pc_sip_round(state)
        state.v0 ^= word
        cursor += 8

    var tail = UInt64(text.byte_length()) << UInt64(56)
    var offset = 0
    while cursor + offset < text.byte_length():
        tail |= UInt64(ord(text[byte=cursor + offset])) << UInt64(offset * 8)
        offset += 1
    state.v3 ^= tail
    state = _pc_sip_round(state)
    state.v0 ^= tail
    state.v2 ^= UInt64(0xff)
    state = _pc_sip_round(state)
    state = _pc_sip_round(state)
    state = _pc_sip_round(state)
    return state.v0 ^ state.v1 ^ state.v2 ^ state.v3


def _pc_string_set_slot(
    slots: List[Int], values: List[String], value: String
) -> Int:
    var hash_value = _pc_siphash13_seed_zero(value)
    var mask = len(slots) - 1
    var index = Int(hash_value & UInt64(mask))
    var perturb = hash_value
    while True:
        if slots[index] == -1 or values[slots[index]] == value:
            return index
        var probes = 9 if index + 9 <= mask else 0
        for offset in range(1, probes + 1):
            if (
                slots[index + offset] == -1
                or values[slots[index + offset]] == value
            ):
                return index + offset
        perturb >>= UInt64(5)
        index = Int((UInt64(index * 5 + 1) + perturb) & UInt64(mask))


def _pc_string_set_resize(
    slots: List[Int], values: List[String], minimum_used: Int
) -> List[Int]:
    var new_size = 8
    while new_size <= minimum_used:
        new_size <<= 1
    var resized = _pc_empty_set_slots(new_size)
    for index in range(len(slots)):
        var value_index = slots[index]
        if value_index >= 0:
            var target = _pc_string_set_slot(
                resized, values, values[value_index]
            )
            resized[target] = value_index
    return resized^


def _pc_python_string_set_order(values: List[String]) -> List[String]:
    var slots = _pc_empty_set_slots(8)
    var fill = 0
    var used = 0
    for value_index in range(len(values)):
        var mask = len(slots) - 1
        if (fill + 1) * 5 >= mask * 3:
            slots = _pc_string_set_resize(slots, values, (used + 1) * 2)
            fill = used
        var target = _pc_string_set_slot(slots, values, values[value_index])
        if slots[target] >= 0:
            continue
        slots[target] = value_index
        fill += 1
        used += 1

    var result = List[String]()
    for index in range(len(slots)):
        if slots[index] >= 0:
            result.append(values[slots[index]])
    return result^


def _pc_column_206_text(table: CsvTable, row: Int) -> String:
    var pieces = _pc_cell(table, row, 206).split("|")
    if len(pieces) > 1:
        return String(pieces[1])
    return ""


def _pc_reverse_annotation(table: CsvTable, source: Int, target: Int) -> String:
    var pieces = _pc_cell(table, source, 206).split("|")
    if len(pieces) != 2:
        return ""
    if String(String(pieces[0]).strip()) != String(target):
        return ""
    return String(pieces[1])


def _pc_contains_pair(values: List[IntPair], first: Int, second: Int) -> Bool:
    for index in range(len(values)):
        if values[index].first == first and values[index].second == second:
            return True
    return False


def _pc_factor_pairs(number: Int) -> List[IntPair]:
    var result = List[IntPair]()
    var raw = primMultiple(number)
    for index in range(len(raw)):
        var first = min(raw[index].first, raw[index].second)
        var second = max(raw[index].first, raw[index].second)
        if not _pc_contains_pair(result, first, second):
            result.append(IntPair(first, second))
    return result^


def _pc_forward_value(
    number: Int,
    against_values: List[String],
    for_values: List[String],
    annotation: String,
    output_mode: String,
    language: String,
) -> String:
    if number == 0:
        return _pc_headline()
    var perspective = _pc_perspective(number, language)
    if output_mode == "html":
        var result = String("<ul>")
        if len(against_values) > 0:
            result += "<li>" + _pc_join_strings(against_values, ", ") + perspective + "</li>"
        if len(for_values) > 0:
            result += "<li>" + _pc_join_strings(for_values, ", ") + perspective + "</li>"
        if annotation.byte_length() > 0:
            result += "<li>" + annotation + "</li>"
        result += "</ul>"
        return result^
    if output_mode == "bbcode":
        var result = String("[list]")
        if len(against_values) > 0:
            result += "[*]" + _pc_join_strings(against_values, ", ") + perspective
        if len(for_values) > 0:
            result += "[*]" + _pc_join_strings(for_values, ", ") + perspective
        if annotation.byte_length() > 0:
            result += "[*]" + annotation
        result += "[/list]"
        return result^

    var parts = List[String]()
    if len(against_values) > 0:
        parts.append(_pc_join_strings(against_values, ", "))
        parts.append(perspective)
    if len(for_values) > 0:
        parts.append(_pc_join_strings(for_values, ", "))
        parts.append(perspective)
    if annotation.byte_length() > 0:
        parts.append(annotation)
    return _pc_join_strings(parts, " | ")


def _pc_reverse_value(
    number: Int,
    pro_sources: List[Int],
    contra_sources: List[Int],
    pro_annotation: String,
    contra_annotation: String,
    output_mode: String,
    language: String,
) -> String:
    if number == 0:
        return _pc_headline()
    if len(pro_sources) == 0 and len(contra_sources) == 0:
        return "-"

    if output_mode == "html":
        var result = String("<ul>")
        if len(pro_sources) > 0:
            result += "<li>" + _pc_pro_label(len(pro_sources), language) + _pc_join_ints(pro_sources, ", ") + "</li>"
        if pro_annotation.byte_length() > 0:
            result += "<li>" + pro_annotation + "</li>"
        if len(contra_sources) > 0:
            result += "<li>" + _pc_contra_label(len(contra_sources), language) + _pc_join_ints(contra_sources, ", ") + "</li>"
        if contra_annotation.byte_length() > 0:
            result += "<li>" + contra_annotation + "</li>"
        result += "</ul>" + _pc_reverse_sentence()
        return result^

    if output_mode == "bbcode":
        var result = String("[list]")
        if len(pro_sources) > 0:
            result += "[*]" + _pc_pro_label(len(pro_sources), language) + _pc_join_ints(pro_sources, ", ")
        if pro_annotation.byte_length() > 0:
            result += "[*]" + pro_annotation
        if len(contra_sources) > 0:
            result += "[*]" + _pc_contra_label(len(contra_sources), language) + _pc_join_ints(contra_sources, ", ")
        if contra_annotation.byte_length() > 0:
            result += "[*]" + contra_annotation
        result += "[/list]" + _pc_reverse_sentence()
        return result^

    var result = String()
    if len(pro_sources) > 0:
        result += _pc_pro_label(len(pro_sources), language)
        result += _pc_join_ints(pro_sources, ", ")
    if pro_annotation.byte_length() > 0:
        result += " (" + pro_annotation + ")"
    if len(pro_sources) > 0 and len(contra_sources) > 0:
        result += " | "
    if len(contra_sources) > 0:
        result += _pc_contra_label(len(contra_sources), language)
        result += _pc_join_ints(contra_sources, ", ")
    if contra_annotation.byte_length() > 0:
        result += " (" + contra_annotation + ")"
    result += _pc_reverse_sentence()
    return result^


def generate_prime_cross_columns(
    table: CsvTable,
    last_row: Int,
    output_mode: String,
    language: String,
) -> PrimeCrossColumns:
    var visible_stop = min(last_row, len(table.rows) - 1)
    var relation_stop = min(1024, len(table.rows) - 1)
    var contra_last = List[Int]()
    var pro_last = List[Int]()
    var contra_values = List[List[Int]]()
    var pro_values = List[List[Int]]()
    for _ in range(relation_stop + 1):
        contra_last.append(-1)
        pro_last.append(-1)
        contra_values.append(List[Int]())
        pro_values.append(List[Int]())

    var inner_primes = List[Int]()
    var outer_primes = List[Int]()
    var no_inner_prime = True
    var no_outer_prime = True
    var next_inner_same = 0
    var next_inner_other = 0
    var next_outer_same = 0
    var next_outer_other = 0
    var forward = List[String]()

    for number in range(relation_stop + 1):
        var against_texts = List[String]()
        var for_texts = List[String]()

        if primCreativity(number) == 1 or number == 1:
            if couldBePrimeNumberPrimzahlkreuz_fuer_innen(number):
                inner_primes.append(number)
                var against = -1
                if number > 16:
                    if no_inner_prime:
                        var index = next_inner_other + 1
                        if index < len(outer_primes):
                            against = outer_primes[index]
                        next_inner_other += 1
                    else:
                        if next_inner_same < len(inner_primes):
                            against = inner_primes[next_inner_same]
                        next_inner_same += 1
                elif number == 5 or number == 11:
                    against = 2
                if against >= 0:
                    contra_last[number] = against
                    contra_values[number].append(against)
                    _pc_append_unique_string(against_texts, _pc_against(language) + String(against))
                no_inner_prime = False

            if number == 2:
                contra_last[number] = 1
                contra_values[number].append(1)
                _pc_append_unique_string(against_texts, _pc_against(language) + "1")
            elif number == 3:
                pro_last[number] = 1
                pro_values[number].append(1)
                _pc_append_unique_string(for_texts, _pc_for(language) + "1")

            if couldBePrimeNumberPrimzahlkreuz_fuer_aussen(number):
                outer_primes.append(number)
                var pro = -1
                if number > 16:
                    if no_outer_prime:
                        var index = next_outer_other + 1
                        if index < len(inner_primes):
                            pro = inner_primes[index]
                        next_outer_other += 1
                    else:
                        if next_outer_same < len(outer_primes):
                            pro = outer_primes[next_outer_same]
                        next_outer_same += 1
                elif number == 7 or number == 13:
                    pro = 3
                if pro >= 0:
                    pro_last[number] = pro
                    pro_values[number].append(pro)
                    _pc_append_unique_string(for_texts, _pc_for(language) + String(pro))
                no_outer_prime = False
        else:
            if couldBePrimeNumberPrimzahlkreuz_fuer_innen(number):
                no_inner_prime = True
            elif couldBePrimeNumberPrimzahlkreuz_fuer_aussen(number):
                no_outer_prime = True

            var pairs = _pc_factor_pairs(number)
            for pair_index in range(len(pairs)):
                var pair = pairs[pair_index].copy()
                if pair.first == 1 or pair.second == 1:
                    continue
                var orientation_count = 1 if pair.first == pair.second else 2
                for orientation in range(orientation_count):
                    var first = pair.first if orientation == 0 else pair.second
                    var second = pair.second if orientation == 0 else pair.first
                    var selector_count = 1 if first == second else 2
                    for selector_index in range(selector_count):
                        var selector = 1 if selector_index == 0 else 0
                        var chosen = second if selector == 1 else first
                        var other = first if selector == 1 else second
                        if (
                            couldBePrimeNumberPrimzahlkreuz_fuer_innen(chosen)
                            or first % 2 == 0
                            or second % 2 == 0
                        ) and chosen >= 0 and chosen <= relation_stop and contra_last[chosen] >= 0:
                            var against = other * contra_last[chosen]
                            contra_last[number] = against
                            contra_values[number].append(against)
                            _pc_append_unique_string(against_texts, _pc_against(language) + String(against))
                        if (
                            couldBePrimeNumberPrimzahlkreuz_fuer_aussen(second)
                            or second % 3 == 0
                            or first % 3 == 0
                        ) and chosen >= 0 and chosen <= relation_stop and pro_last[chosen] >= 0:
                            var pro = other * pro_last[chosen]
                            pro_last[number] = pro
                            pro_values[number].append(pro)
                            _pc_append_unique_string(for_texts, _pc_for(language) + String(pro))

        against_texts = _pc_python_string_set_order(against_texts)
        for_texts = _pc_python_string_set_order(for_texts)
        forward.append(
            _pc_forward_value(
                number,
                against_texts,
                for_texts,
                _pc_column_206_text(table, number),
                output_mode,
                language,
            )
        )

    # Keep the physical table rectangular after the configured generated range.
    for _ in range(relation_stop + 1, len(table.rows)):
        forward.append("")

    var reverse_pro_attempts = List[List[Int]]()
    var reverse_contra_attempts = List[List[Int]]()
    for _ in range(relation_stop + 1):
        reverse_pro_attempts.append(List[Int]())
        reverse_contra_attempts.append(List[Int]())
    for source in range(relation_stop + 1):
        var ordered_pro = _pc_python_set_order(pro_values[source])
        for value_index in range(len(ordered_pro)):
            var target = ordered_pro[value_index]
            if target >= 0 and target <= relation_stop:
                reverse_pro_attempts[target].append(source)
        var ordered_contra = _pc_python_set_order(contra_values[source])
        for value_index in range(len(ordered_contra)):
            var target = ordered_contra[value_index]
            if target >= 0 and target <= relation_stop:
                reverse_contra_attempts[target].append(source)

    var reverse_pro = List[List[Int]]()
    var reverse_contra = List[List[Int]]()
    for number in range(relation_stop + 1):
        reverse_pro.append(_pc_python_set_order(reverse_pro_attempts[number]))
        reverse_contra.append(_pc_python_set_order(reverse_contra_attempts[number]))

    var reverse = List[String]()
    for number in range(visible_stop + 1):
        var pro_annotations = List[String]()
        for index in range(len(reverse_pro[number])):
            var source = reverse_pro[number][index]
            if source <= visible_stop:
                var annotation = _pc_reverse_annotation(table, source, number)
                if annotation.byte_length() > 0:
                    pro_annotations.append(annotation)
        var contra_annotations = List[String]()
        for index in range(len(reverse_contra[number])):
            var source = reverse_contra[number][index]
            if source <= visible_stop:
                var annotation = _pc_reverse_annotation(table, source, number)
                if annotation.byte_length() > 0:
                    contra_annotations.append(annotation)
        reverse.append(
            _pc_reverse_value(
                number,
                reverse_pro[number],
                reverse_contra[number],
                _pc_join_strings(pro_annotations, " , "),
                _pc_join_strings(contra_annotations, ", "),
                output_mode,
                language,
            )
        )
    for _ in range(visible_stop + 1, len(table.rows)):
        reverse.append("")
    return PrimeCrossColumns(forward^, reverse^)
