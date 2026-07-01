"""Interactive PTY probe for the fully native prompt input boundary."""

from std.sys import argv
from reta_mojo.native_prompt_input import read_native_prompt_line
from reta_mojo.prompt_language import load_prompt_language_catalog


def _result_text(line: String) -> String:
    if line == "\x03":
        return "INTERRUPT"
    if line == "\x04":
        return "EOF"
    return line


def main() raises:
    var args = argv()
    var history_path = String(args[1]) if len(args) > 1 else "/tmp/reta-prompt-history"
    var vi_mode = len(args) > 2 and String(args[2]) == "vi"
    var logging = len(args) > 3 and String(args[3]) == "log"
    var language = String(args[4]) if len(args) > 4 else "deutsch"
    var repeat = len(args) > 5 and String(args[5]) == "twice"
    var catalog = load_prompt_language_catalog("assets")
    var line = read_native_prompt_line(
        "probe> ", catalog, language, vi_mode, logging, history_path
    )
    if not repeat:
        print("@@RESULT@@" + _result_text(line))
        return

    print("@@FIRST@@" + _result_text(line))
    var second = read_native_prompt_line(
        "probe2> ", catalog, language, vi_mode, logging, history_path
    )
    print("@@RESULT@@" + _result_text(second))
