"""Native CLI for reta's complete canonical parameter-semantics dictionaries."""

from std.collections import List
from std.sys import argv
from reta_mojo.semantics_builder import DataSlot, parameter_semantics_fingerprint
from reta_mojo.semantics_builder_catalog import bootstrap_full_parameter_semantics


def _slot_size(slot: DataSlot) -> Int:
    if slot.is_combination:
        return len(slot.combinations)
    return len(slot.bindings)


def _print_sizes(prefix: String, values: List[Int]) -> None:
    print(prefix, end="")
    for index in range(len(values)):
        if index > 0:
            print(",", end="")
        print(values[index], end="")
    print()


def _usage() -> None:
    print("reta-mojo-semantics [--normal|--invert]")


def main() raises:
    var args = argv()
    var invert_alles = False
    var name = "normal"
    if len(args) > 1:
        var command = String(args[1])
        if command == "--invert":
            invert_alles = True
            name = "inverted"
        elif command != "--normal":
            _usage()
            raise Error("invalid parameter-semantics arguments")

    var result = bootstrap_full_parameter_semantics(invert_alles)
    print("mode=" + name)
    print("matrix_entries=" + String(len(result.para_n_data_matrix)))
    print("main_parameters=" + String(len(result.para_main_dict)))
    print("parameter_pairs=" + String(len(result.para_dict)))
    print("combination_reverse_1=" + String(len(result.kombi_reverse_dict)))
    print("combination_reverse_2=" + String(len(result.kombi_reverse_dict2)))
    print("simple_columns=" + String(len(result.all_simple_command_columns)))
    var data_sizes = List[Int]()
    for index in range(len(result.data_dict)):
        data_sizes.append(_slot_size(result.data_dict[index]))
    _print_sizes("data_dict_sizes=", data_sizes)
    var all_sizes = List[Int]()
    for index in range(len(result.all_values)):
        all_sizes.append(len(result.all_values[index].values))
    _print_sizes("all_values_sizes=", all_sizes)
    print("fingerprint=" + parameter_semantics_fingerprint(result).canonical())
