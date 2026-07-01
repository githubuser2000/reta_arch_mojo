from std.sys import argv
from std.collections import List
from reta_mojo.native_reta_cli import run_native_reta
from reta_mojo.resource_paths import csv_resource


def main() raises:
    var args = argv()
    var tokens = List[String]()
    for index in range(1, len(args)):
        tokens.append(String(args[index]))
    print(run_native_reta(tokens, csv_resource("religion.csv")), end="")
