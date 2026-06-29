from std.sys import argv
from reta_mojo.csv_table import read_text_file
from reta_mojo.prompt_language import (
    balanced_prompt_split,
    expand_compact_prompt_tokens,
    load_prompt_language_catalog,
)


def main() raises:
    var args = argv()
    if len(args) != 3:
        raise Error("usage: prompt_compact_batch_probe LANGUAGE CASES.tsv")
    var language = String(args[1])
    var catalog = load_prompt_language_catalog("assets")
    var lines = read_text_file(String(args[2])).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 4:
            continue
        var selective = String(fields[1]) == "1"
        var force_e = String(fields[2]) == "1"
        var tokens = balanced_prompt_split(String(fields[3]))
        var result = expand_compact_prompt_tokens(
            catalog, language, tokens, selective, force_e
        )
        print("@@@" + String(fields[0]))
        print("1" if result.compact else "0")
        for index in range(len(result.tokens)):
            print(result.tokens[index])
