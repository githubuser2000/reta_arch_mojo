from std.collections import List
from std.sys import argv
from reta_mojo.integer_expressions import parse_integer_collection


def _sort_ints(mut values: List[Int]):
    for index in range(1, len(values)):
        var key = values[index]
        var position = index - 1
        while position >= 0 and values[position] > key:
            values[position + 1] = values[position]
            position -= 1
        values[position + 1] = key


def main():
    var args = argv()
    for index in range(1, len(args)):
        var parsed = parse_integer_collection(String(args[index]))
        if not parsed.valid:
            print("invalid")
            continue
        var values = List[Int]()
        for value in parsed.values:
            values.append(value)
        _sort_ints(values)
        print("valid", end="")
        for value in values:
            print("\t", value, sep="", end="")
        print()
