"""Persistent native nested-completion worker for GNU readline.

The Python bridge owns only the terminal callback and pipe.  Every context
transition, fuzzy match and candidate order is resolved in Mojo.
"""

from std.sys import argv
from std.python import Python
from reta_mojo.prompt_language import (
    load_prompt_language_catalog,
    normalize_prompt_language,
    prompt_completion_candidates,
)


def _without_line_ending(text: String) -> String:
    var end = text.byte_length()
    if end > 0 and Int(text.as_bytes()[end - 1]) == 10:
        end -= 1
    if end > 0 and Int(text.as_bytes()[end - 1]) == 13:
        end -= 1
    return String(StringSlice(text)[byte=0:end])


def main() raises:
    var args = argv()
    if len(args) < 2:
        raise Error("usage: reta-prompt-complete LANGUAGE [ASSET_ROOT]")
    var language = normalize_prompt_language(String(args[1]))
    var asset_root = "assets"
    if len(args) > 2:
        asset_root = String(args[2])
    var catalog = load_prompt_language_catalog(asset_root)
    var sys = Python.import_module("sys")

    while True:
        var raw = String(py=sys.stdin.readline())
        if raw.byte_length() == 0:
            break
        var text = _without_line_ending(raw)
        var values = prompt_completion_candidates(catalog, language, text)
        var response = String(len(values)) + "\n"
        for index in range(len(values)):
            response += values[index] + "\n"
        _ = sys.stdout.write(response)
        _ = sys.stdout.flush()
