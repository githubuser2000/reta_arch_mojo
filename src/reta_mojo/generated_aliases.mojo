"""Runtime catalog for generated, relational, fractional, and meta aliases.

The source catalog is generated from the non-ordinary buckets of Python's
``paraNdataMatrix``.  Keeping it data-driven avoids duplicating thousands of
German/English command aliases in compiled source code.
"""

from std.collections import List
from std.collections.string import atol
from .csv_table import read_text_file


@fieldwise_init
struct GeneratedAliasEntry(Copyable):
    var language: String
    var main_alias: String
    var parameter_alias: String
    var bucket: String
    var payload: String


@fieldwise_init
struct GeneratedAliasCatalog(Copyable):
    var entries: List[GeneratedAliasEntry]


@fieldwise_init
struct ModalConcept(Copyable):
    var first: Int
    var second: Int


@fieldwise_init
struct FractionColumnRequest(Copyable):
    """One selected denominator from a fractional CSV presheaf bucket."""

    var domain: String
    var denominator: Int


@fieldwise_init
struct MetaColumnRequest(Copyable):
    """One historical ``(metavariable, side)`` request from bucket 11.

    ``metavariable`` is 2..7. ``side`` is 0 for the upper/meta/theory
    branch and 1 for the lower/concrete/practice branch.
    """

    var metavariable: Int
    var side: Int


def load_generated_alias_catalog(path: String) raises -> GeneratedAliasCatalog:
    var text = read_text_file(path)
    var lines = text.split("\n")
    var entries = List[GeneratedAliasEntry]()
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var pieces = line.split("\t")
        if len(pieces) != 5:
            continue
        entries.append(
            GeneratedAliasEntry(
                String(pieces[0]),
                String(pieces[1]),
                String(pieces[2]),
                String(pieces[3]),
                String(pieces[4]),
            )
        )
    return GeneratedAliasCatalog(entries^)


def resolve_generated_aliases(
    catalog: GeneratedAliasCatalog,
    language: String,
    main_alias: String,
    parameter_alias: String,
) -> List[GeneratedAliasEntry]:
    var result = List[GeneratedAliasEntry]()
    for index in range(len(catalog.entries)):
        var entry = catalog.entries[index].copy()
        if (
            entry.language == language
            and entry.main_alias == main_alias
            and entry.parameter_alias == parameter_alias
        ):
            result.append(entry.copy())
    return result^


def modal_concept_from_entry(entry: GeneratedAliasEntry) raises -> ModalConcept:
    var pieces = entry.payload.split(",")
    if len(pieces) < 2:
        return ModalConcept(-1, -1)
    return ModalConcept(atol(String(pieces[0])), atol(String(pieces[1])))


def contains_modal_concept(values: List[ModalConcept], wanted: ModalConcept) -> Bool:
    for index in range(len(values)):
        if values[index].first == wanted.first and values[index].second == wanted.second:
            return True
    return False


def append_unique_modal_concept(mut values: List[ModalConcept], value: ModalConcept):
    if value.first >= 0 and value.second >= 0 and not contains_modal_concept(values, value):
        values.append(value.copy())


def remove_modal_concepts(
    values: List[ModalConcept], excluded: List[ModalConcept]
) -> List[ModalConcept]:
    var result = List[ModalConcept]()
    for index in range(len(values)):
        if not contains_modal_concept(excluded, values[index]):
            result.append(values[index].copy())
    return result^


def sort_modal_concepts(mut values: List[ModalConcept]):
    for index in range(1, len(values)):
        var key = values[index].copy()
        var position = index - 1
        while position >= 0 and (
            values[position].first > key.first
            or (
                values[position].first == key.first
                and values[position].second > key.second
            )
        ):
            values[position + 1] = values[position].copy()
            position -= 1
        values[position + 1] = key.copy()


def meta_request_from_entry(entry: GeneratedAliasEntry) raises -> MetaColumnRequest:
    var pieces = entry.payload.split(",")
    if len(pieces) < 2:
        return MetaColumnRequest(-1, -1)
    return MetaColumnRequest(atol(String(pieces[0])), atol(String(pieces[1])))


def contains_meta_request(values: List[MetaColumnRequest], wanted: MetaColumnRequest) -> Bool:
    for index in range(len(values)):
        if (
            values[index].metavariable == wanted.metavariable
            and values[index].side == wanted.side
        ):
            return True
    return False


def append_unique_meta_request(
    mut values: List[MetaColumnRequest], value: MetaColumnRequest
):
    if (
        value.metavariable >= 2
        and value.metavariable <= 7
        and (value.side == 0 or value.side == 1)
        and not contains_meta_request(values, value)
    ):
        values.append(value.copy())


def remove_meta_requests(
    values: List[MetaColumnRequest], excluded: List[MetaColumnRequest]
) -> List[MetaColumnRequest]:
    var result = List[MetaColumnRequest]()
    for index in range(len(values)):
        if not contains_meta_request(excluded, values[index]):
            result.append(values[index].copy())
    return result^


def _meta_request_bit(value: MetaColumnRequest) -> Int:
    if (
        value.metavariable < 2
        or value.metavariable > 7
        or (value.side != 0 and value.side != 1)
    ):
        return -1
    return (value.metavariable - 2) * 2 + value.side


def sort_meta_requests_by_python_set(
    mut values: List[MetaColumnRequest],
    path: String = "assets/meta_request_order.tsv",
) raises:
    """Reproduce legacy CPython ``set`` iteration for the final subset.

    A single rank table is insufficient because CPython's slot order changes
    when the set grows from 8 to 32 slots.  The generated asset contains the
    exact order for all 4095 non-empty subsets of the twelve valid requests.
    """
    if len(values) < 2:
        return
    var mask = 0
    for index in range(len(values)):
        var bit = _meta_request_bit(values[index])
        if bit >= 0:
            mask |= 1 << bit
    if mask == 0:
        return
    var wanted = String(mask) + "\t"
    var text = read_text_file(path)
    var lines = text.split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if not line.startswith(wanted):
            continue
        var fields = line.split("\t")
        if len(fields) != 2:
            return
        var ordered = List[MetaColumnRequest]()
        var pairs = String(fields[1]).split(";")
        for pair_index in range(len(pairs)):
            var parts = String(pairs[pair_index]).split(",")
            if len(parts) != 2:
                continue
            var request = MetaColumnRequest(
                atol(String(parts[0])), atol(String(parts[1]))
            )
            if contains_meta_request(values, request):
                ordered.append(request.copy())
        if len(ordered) == len(values):
            for index in range(len(values)):
                values[index] = ordered[index].copy()
        return


def fraction_request_from_entry(entry: GeneratedAliasEntry) raises -> FractionColumnRequest:
    var domain = String()
    if entry.bucket == "fraction_universe":
        domain = "universe"
    elif entry.bucket == "fraction_galaxy":
        domain = "galaxy"
    elif entry.bucket == "fraction_emotion":
        domain = "emotion"
    elif entry.bucket == "fraction_size":
        domain = "size"
    return FractionColumnRequest(domain^, atol(entry.parameter_alias))


def contains_fraction_request(
    values: List[FractionColumnRequest], wanted: FractionColumnRequest
) -> Bool:
    for index in range(len(values)):
        if (
            values[index].domain == wanted.domain
            and values[index].denominator == wanted.denominator
        ):
            return True
    return False


def append_unique_fraction_request(
    mut values: List[FractionColumnRequest], value: FractionColumnRequest
):
    if (
        value.domain.byte_length() > 0
        and value.denominator >= 2
        and value.denominator <= 23
        and not contains_fraction_request(values, value)
    ):
        values.append(value.copy())


def remove_fraction_requests(
    values: List[FractionColumnRequest], excluded: List[FractionColumnRequest]
) -> List[FractionColumnRequest]:
    var result = List[FractionColumnRequest]()
    for index in range(len(values)):
        if not contains_fraction_request(excluded, values[index]):
            result.append(values[index].copy())
    return result^
