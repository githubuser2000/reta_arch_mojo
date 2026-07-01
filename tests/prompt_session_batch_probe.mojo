from std.sys import argv
from std.collections import List
from std.collections.string import atol
from reta_mojo.csv_table import read_text_file
from reta_mojo.prompt_language import load_prompt_language_catalog
from reta_mojo.prompt_session import *


def _print_words(label: String, values: List[String]) -> None:
    print(label + "=" + String(len(values)))
    for index in range(len(values)):
        print("[" + values[index] + "]")


def main() raises:
    var args = argv()
    if len(args) != 3:
        raise Error("usage: prompt_session_batch_probe LANGUAGE CASES.tsv")
    var language = String(args[1])
    var catalog = load_prompt_language_catalog("assets")
    var lines = read_text_file(String(args[2])).split("\n")
    for line_index in range(len(lines)):
        var line = String(lines[line_index])
        if line.byte_length() == 0:
            continue
        var fields = line.split("\t")
        if len(fields) < 3:
            continue
        var operation = String(fields[0])
        print("@@@" + String(fields[1]))
        if operation == "state":
            var state = new_prompt_text_state(String(fields[2]))
            print("text=[" + state.text + "]")
            _print_words("tokens", state.tokens)
            _print_words("command_words", state.command_words)
        elif operation == "delete":
            var session = new_prompt_session(False)
            store_prompt_text(session, String(fields[2]))
            var result = delete_stored_selection_result(session, String(fields[3]))
            print("stored=[" + result.stored_text + "]")
            print("remaining=[" + result.remaining_selection + "]")
        elif operation == "apply":
            var mode = atol(String(fields[2]))
            var result = apply_storage_output(
                String(fields[5]), mode, String(fields[3]), String(fields[4])
            )
            print("text=[" + result + "]")
        elif operation == "history":
            print(
                "append="
                + (
                    "1"
                    if history_should_append(String(fields[2]), catalog, language)
                    else "0"
                )
            )
        elif operation == "combine":
            var combined = combine_stored_prompt_localized(
                catalog, language, String(fields[2]), String(fields[3])
            )
            print("stored=[" + combined + "]")
            print("mode=" + String(PROMPT_MODE_SELECTIVE_OUTPUT))
