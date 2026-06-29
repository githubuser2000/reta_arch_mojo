from std.sys import argv
from reta_mojo.csv_table import read_text_file
from reta_mojo.prompt_language import load_prompt_language_catalog, prompt_completion_candidates


def main() raises:
    var args = argv()
    if len(args) < 3:
        raise Error("usage: prompt_completion_batch_probe LANGUAGE CONTEXTS.tsv")
    var language = String(args[1])
    var catalog = load_prompt_language_catalog("assets")
    var lines = read_text_file(String(args[2])).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) != 2:
            continue
        print("@@@" + String(fields[0]))
        var values = prompt_completion_candidates(catalog, language, String(fields[1]))
        for index in range(len(values)):
            print(values[index])
