"""Persistent native nested-completion worker for GNU readline.

The Python adapter owns only the terminal callback and worker process lifecycle.
Every context transition, fuzzy match, candidate order and pipe byte is handled
in Mojo; the worker no longer embeds CPython merely to access stdin/stdout.
"""

from std.io import FileHandle
from std.sys import argv
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
    var stdin_file = FileHandle()
    stdin_file.handle = 0
    var stdout_file = FileHandle()
    stdout_file.handle = 1
    var raw = String()

    while True:
        var byte_text = stdin_file.read(1)
        var at_eof = byte_text.byte_length() == 0
        if not at_eof and byte_text != "\n":
            raw += byte_text
            continue
        if at_eof and raw.byte_length() == 0:
            break

        var text = _without_line_ending(raw)
        var values = prompt_completion_candidates(catalog, language, text)
        var response = String(len(values)) + "\n"
        for index in range(len(values)):
            response += values[index] + "\n"
        stdout_file.write_all(response.as_bytes())
        raw = String()
        if at_eof:
            break
