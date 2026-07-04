"""Pure native helpers extracted from ``prompt_execution.py``.

The historical prompt execution owner mixes terminal effects, subprocess
execution and small deterministic transformations.  This module owns the
pure transformations so the remaining large command runner can be migrated
without keeping duplicate Python helper semantics.
"""

from std.collections import List, Set
from .prompt_language import PromptLanguageCatalog, prompt_is_reta_parameter
from .row_ranges import range_to_numbers


@fieldwise_init
struct OrderedStringEntry(Copyable):
    var key: String
    var value: String


@fieldwise_init
struct PromptIntPartition(Copyable):
    var greater: Set[Int]
    var lesser: Set[Int]


@fieldwise_init
struct PromptExecutionHelpersSnapshot(Copyable):
    var class_name: String
    var functions: List[String]
    var pure_helpers: Int


@fieldwise_init
struct PromptExecutionHelpersBundle(Copyable):
    var source_owner: String

    def snapshot(self) -> PromptExecutionHelpersSnapshot:
        return prompt_execution_helpers_snapshot()


def _copy_int_set(values: Set[Int]) -> Set[Int]:
    var result = Set[Int]()
    for value in values:
        result.add(value)
    return result^


def _entry_index(entries: List[OrderedStringEntry], key: String) -> Int:
    for index in range(len(entries)):
        if entries[index].key == key:
            return index
    return -1


def another_upper_maximum(
    range_expression: String,
    maximum: Int,
    highest_row_1024: Int,
    option_name: String = "oberesmaximum",
) raises -> String:
    """Typed form of ``anotherOberesMaximum`` without a global ``Txt`` object."""
    var selected = range_to_numbers(range_expression, False, 0)
    var result_maximum = max(maximum, highest_row_1024)
    for value in selected:
        result_maximum = max(result_maximum, value)
    return "--" + option_name + "=" + String(result_maximum + 1)


def return_only_reta_parameters(
    catalog: PromptLanguageCatalog,
    language: String,
    tokens: List[String],
) raises -> List[String]:
    """Preserve order while retaining only native Reta option tokens."""
    var result = List[String]()
    for index in range(len(tokens)):
        if prompt_is_reta_parameter(catalog, language, tokens[index]):
            result.append(tokens[index])
    return result^


def partition_outside_bounds(
    values: Set[Int], bounds: Set[Int]
) -> PromptIntPartition:
    """Port of ``grKl``: values above max(bounds) and below min(bounds)."""
    if len(bounds) == 0:
        return PromptIntPartition(
            _copy_int_set(values), _copy_int_set(values)
        )

    var first = True
    var lower = 0
    var upper = 0
    for value in bounds:
        if first:
            lower = value
            upper = value
            first = False
        else:
            lower = min(lower, value)
            upper = max(upper, value)

    var greater = Set[Int]()
    var lesser = Set[Int]()
    for value in values:
        if value > upper:
            greater.add(value)
        elif value < lower:
            lesser.add(value)
    return PromptIntPartition(greater^, lesser^)


def limit_entries_by_keys(
    entries: List[OrderedStringEntry], keys: List[String]
) -> List[OrderedStringEntry]:
    """Ordered typed equivalent of ``getDictLimtedByKeyList``."""
    var result = List[OrderedStringEntry]()
    for key_index in range(len(keys)):
        var index = _entry_index(entries, keys[key_index])
        if index >= 0:
            result.append(entries[index].copy())
    return result^


def ordered_entry_values(
    entries: List[OrderedStringEntry]
) -> List[String]:
    """Port of ``dictToList`` for an explicit insertion-ordered map."""
    var result = List[String]()
    for index in range(len(entries)):
        result.append(entries[index].value)
    return result^


def range_selection_option(
    counting: Bool,
    range_expression: String,
    counting_name: String = "zaehlung",
    previous_slice_name: String = "vorhervonausschnitt",
) -> String:
    """Port of ``vorherVonAusschnittOderZaehlung`` without prompt globals."""
    var option_name = previous_slice_name
    if counting:
        option_name = counting_name
    return "--" + option_name + "=" + range_expression


# Historical public spellings retained for direct source migration.
def anotherOberesMaximum(
    zahlenBereichC: String,
    maxNum: Int,
    highestRow1024: Int,
    upperMaximumName: String = "oberesmaximum",
) raises -> String:
    return another_upper_maximum(
        zahlenBereichC, maxNum, highestRow1024, upperMaximumName
    )


def returnOnlyParasAsList(
    catalog: PromptLanguageCatalog,
    language: String,
    textList: List[String],
) raises -> List[String]:
    return return_only_reta_parameters(catalog, language, textList)


def grKl(A: Set[Int], B: Set[Int]) -> PromptIntPartition:
    return partition_outside_bounds(A, B)


def getDictLimtedByKeyList(
    entries: List[OrderedStringEntry], keys: List[String]
) -> List[OrderedStringEntry]:
    return limit_entries_by_keys(entries, keys)


def dictToList(entries: List[OrderedStringEntry]) -> List[String]:
    return ordered_entry_values(entries)


def vorherVonAusschnittOderZaehlung(
    counting: Bool,
    bereichsAngabe: String,
    countingName: String = "zaehlung",
    previousSliceName: String = "vorhervonausschnitt",
) -> String:
    return range_selection_option(
        counting, bereichsAngabe, countingName, previousSliceName
    )


def prompt_execution_helpers_snapshot() -> PromptExecutionHelpersSnapshot:
    return PromptExecutionHelpersSnapshot(
        "PromptExecutionHelpersBundle",
        [
            "anotherOberesMaximum",
            "returnOnlyParasAsList",
            "grKl",
            "getDictLimtedByKeyList",
            "dictToList",
            "vorherVonAusschnittOderZaehlung",
        ],
        6,
    )


def bootstrap_prompt_execution_helpers() -> PromptExecutionHelpersBundle:
    return PromptExecutionHelpersBundle(
        "reta_architecture.prompt_execution"
    )
