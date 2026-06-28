from std.sys import argv
from std.collections import List
from reta_mojo.native_reta_cli import run_native_reta


def main() raises:
    var args = argv()
    var tokens = List[String]()
    for index in range(1, len(args)):
        tokens.append(String(args[index]))
    print(run_native_reta(tokens, "python_reference/csv/religion.csv"), end="")
