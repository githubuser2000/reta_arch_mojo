from std.sys import argv
from reta_mojo.parameter_runtime import upper_limit_values_for_argument


def main() raises:
    for index in range(1, len(argv())):
        var token = argv()[index]
        var result = upper_limit_values_for_argument(token)
        var values = String("")
        for value_index in range(len(result.values)):
            if value_index > 0:
                values += ","
            values += String(result.values[value_index])
        print(token + "\t" + values + "|" + ("1" if result.applies else "0"))
