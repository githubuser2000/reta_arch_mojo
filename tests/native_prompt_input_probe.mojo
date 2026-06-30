from std.sys import argv
from reta_mojo.native_prompt_input import PROMPT_EOF, read_plain_prompt_line


def main() raises:
    var args = argv()
    var history_enabled = len(args) > 1 and String(args[1]) == "1"
    var history_path = "/tmp/reta-native-prompt-input-probe.history"
    if len(args) > 2:
        history_path = String(args[2])
    var line = read_plain_prompt_line("native> ", history_enabled, history_path)
    if line == PROMPT_EOF:
        print("<EOF>")
    else:
        print("<LINE>" + line)
