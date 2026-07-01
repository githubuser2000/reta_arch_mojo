"""Native selection plan for the historical ``-spalten --alles`` flag.

The source TSV is generated from Python's already-folded synthetic ``alles``
parameter.  Runtime execution is pure Mojo: the asset only freezes the twelve
legacy bucket values and their deterministic order.
"""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file
from .resource_paths import asset_resource
from .generated_aliases import (
    FractionColumnRequest,
    MetaColumnRequest,
    ModalConcept,
    append_unique_fraction_request,
    append_unique_meta_request,
    append_unique_modal_concept,
)
from .kombi_join_columns import KombiColumnRequest, append_unique_kombi_request


@fieldwise_init
struct AllColumnSelection(Copyable):
    var columns: List[Int]
    var modal_concepts: List[ModalConcept]
    var fraction_requests: List[FractionColumnRequest]
    var kombi_requests: List[KombiColumnRequest]
    var generated_commands: List[String]
    var meta_requests: List[MetaColumnRequest]
    var source_entries: Int


def _contains_int_all(values: List[Int], wanted: Int) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique_int_all(mut values: List[Int], value: Int):
    if not _contains_int_all(values, value):
        values.append(value)


def _contains_string_all(values: List[String], wanted: String) -> Bool:
    for index in range(len(values)):
        if values[index] == wanted:
            return True
    return False


def _append_unique_string_all(mut values: List[String], value: String):
    if not _contains_string_all(values, value):
        values.append(value)


def _pair_all(payload: String) raises -> Tuple[Int, Int]:
    var fields = payload.split(",")
    if len(fields) < 2:
        return -1, -1
    return atol(String(fields[0])), atol(String(fields[1]))


def load_all_column_selection(
    path: String = "",
) raises -> AllColumnSelection:
    var columns = List[Int]()
    var modal_concepts = List[ModalConcept]()
    var fraction_requests = List[FractionColumnRequest]()
    var kombi_requests = List[KombiColumnRequest]()
    var generated_commands = List[String]()
    var meta_requests = List[MetaColumnRequest]()
    var source_entries = 0

    var source_path = path if path.byte_length() > 0 else asset_resource("all_columns_plan.tsv")
    var lines = read_text_file(source_path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0 or line.startswith("#"):
            continue
        var fields = line.split("\t")
        if len(fields) != 2:
            continue
        var bucket = String(fields[0])
        var payload = String(fields[1])
        source_entries += 1
        if bucket == "ordinary":
            _append_unique_int_all(columns, atol(payload))
        elif bucket == "modal":
            var pair = _pair_all(payload)
            append_unique_modal_concept(
                modal_concepts, ModalConcept(pair[0], pair[1])
            )
        elif bucket == "concat":
            # Any non-empty bucket-2 selection attaches the one described-prime
            # CSV column.  The concrete prime values only acted as a non-empty
            # trigger in Python's readConcatCsv(concatTable == 1).
            _append_unique_string_all(generated_commands, "PrimCSV")
        elif bucket == "kombi":
            append_unique_kombi_request(
                kombi_requests, KombiColumnRequest("galaxy", atol(payload))
            )
        elif bucket == "prime_effect":
            _append_unique_string_all(
                generated_commands,
                "prime_effect:none" if payload.byte_length()
                == 0 else "prime_effect:" + payload,
            )
        elif bucket == "fraction_universe":
            append_unique_fraction_request(
                fraction_requests,
                FractionColumnRequest("universe", atol(payload)),
            )
        elif bucket == "fraction_galaxy":
            append_unique_fraction_request(
                fraction_requests,
                FractionColumnRequest("galaxy", atol(payload)),
            )
        elif bucket == "generated_command":
            _append_unique_string_all(generated_commands, payload)
        elif bucket == "kombi2":
            append_unique_kombi_request(
                kombi_requests, KombiColumnRequest("universe", atol(payload))
            )
        elif bucket == "fraction_emotion":
            append_unique_fraction_request(
                fraction_requests,
                FractionColumnRequest("emotion", atol(payload)),
            )
        elif bucket == "fraction_size":
            append_unique_fraction_request(
                fraction_requests,
                FractionColumnRequest("size", atol(payload)),
            )
        elif bucket == "meta":
            var pair = _pair_all(payload)
            append_unique_meta_request(
                meta_requests, MetaColumnRequest(pair[0], pair[1])
            )

    return AllColumnSelection(
        columns^,
        modal_concepts^,
        fraction_requests^,
        kombi_requests^,
        generated_commands^,
        meta_requests^,
        source_entries,
    )
