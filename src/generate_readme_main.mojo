"""Native command-line replacement for ``libs/generate4readme.py``."""

from std.collections import List
from std.sys import argv

from reta_mojo.readme_generator import *


def _usage() -> None:
    print("generate4readme [-language=english|-language=englisch]")
    print("generate4readme --summary [german|english]")


def _arguments() -> List[String]:
    var result = List[String]()
    var values = argv()
    for index in range(1, len(values)):
        result.append(String(values[index]))
    return result^


def main() raises:
    var arguments = _arguments()
    if len(arguments) > 0 and arguments[0] == "--help":
        _usage()
        return
    if len(arguments) > 0 and arguments[0] == "--summary":
        var language = "german"
        if len(arguments) > 1:
            language = normalize_readme_language(arguments[1])
        var document = generate_readme(language)
        var bundle = bootstrap_readme_generator()
        print("language=" + document.language)
        print("asset=" + document.asset_name)
        print("bytes=" + String(document.byte_count))
        print("lines=" + String(document.line_count))
        print("canonical_python_hash_seed=" + String(bundle.canonical_python_hash_seed))
        print("valid=" + ("true" if readme_generator_valid(bundle) else "false"))
        return
    var language = readme_language_from_arguments(arguments)
    var document = generate_readme(language)
    print(document.text, end="")
