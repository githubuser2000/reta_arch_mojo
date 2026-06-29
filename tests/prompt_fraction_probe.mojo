from std.sys import argv
from reta_mojo.prompt_fraction_execution import *


def main() raises:
    var args = argv()
    for index in range(1, len(args)):
        var parsed = parse_prompt_fraction(String(args[index]))
        var range_result = PromptFractionRange(False, [], "")
        if parsed.valid:
            range_result = create_prompt_fraction_range(parsed.groups)
        print(serialize_prompt_fraction(parsed), "\t", serialize_prompt_fraction_range(range_result), sep="")
