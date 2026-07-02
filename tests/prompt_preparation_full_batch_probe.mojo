from std.collections import List
from std.collections.string import atol
from std.sys import argv
from reta_mojo.csv_table import read_text_file
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_preparation import bootstrap_prompt_preparation


def _extra(text: String) -> List[String]:
    var result = List[String]()
    if text.byte_length() == 0:
        return result^
    for piece in text.split("\x1f"):
        result.append(String(piece))
    return result^


def main() raises:
    var args = argv()
    if len(args) != 3:
        raise Error(
            "usage: prompt_preparation_full_batch_probe LANGUAGE CASES.tsv"
        )
    var language = String(args[1])
    var catalog = load_prompt_language_catalog("assets")
    var bundle = bootstrap_prompt_preparation(
        catalog,
        "assets",
        language,
        ["q", ":q", "exit", "quit", "ende"],
    )
    for raw in read_text_file(String(args[2])).split("\n"):
        var line = String(raw)
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 8:
            continue
        var result = bundle.prepare_large_output(
            String(fields[1]),
            atol(String(fields[2])),
            atol(String(fields[3])),
            atol(String(fields[4])),
            String(fields[5]),
            _extra(String(fields[6])),
            String(fields[7]) == "1",
        )
        print("@@@" + String(fields[0]))
        print(
            "pure="
            + ("1" if result.is_pure_reta_command else "0")
        )
        print("max=" + String(result.max_number))
        print("compact=" + ("1" if result.compact else "0"))
        for token in result.tokens:
            print(token)
