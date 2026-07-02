"""Generated immutable parameter/value domains for prompt preparation."""

from std.collections import List
from .csv_table import read_text_file


@fieldwise_init
struct PromptPreparationDomain(Copyable):
    var language: String
    var main_parameter: String
    var parameter: String
    var values: List[String]


@fieldwise_init
struct PromptPreparationCatalog(Copyable):
    var domains: List[PromptPreparationDomain]


def _split_encoded_values(encoded: String) -> List[String]:
    var result = List[String]()
    # An empty fourth TSV field represents the historical singleton {""}.
    if encoded.byte_length() == 0:
        result.append("")
        return result^
    var pieces = encoded.split("\x1f")
    for index in range(len(pieces)):
        result.append(String(pieces[index]))
    return result^


def load_prompt_preparation_catalog(path: String) raises -> PromptPreparationCatalog:
    var domains = List[PromptPreparationDomain]()
    var lines = read_text_file(path).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 4:
            continue
        domains.append(
            PromptPreparationDomain(
                String(fields[0]),
                String(fields[1]),
                String(fields[2]),
                _split_encoded_values(String(fields[3])),
            )
        )
    return PromptPreparationCatalog(domains^)
