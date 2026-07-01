from std.sys import argv
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.completion_nested import nested_completion_candidates_from_catalog


def main() raises:
    var args = argv()
    if len(args) < 3:
        raise Error("usage: prompt_completion_probe LANGUAGE TEXT")
    var catalog = load_prompt_language_catalog("assets")
    var values = nested_completion_candidates_from_catalog(catalog, String(args[1]), String(args[2]))
    for index in range(len(values)):
        print(values[index])
