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
