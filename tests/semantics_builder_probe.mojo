"""Stable full-catalog probe for Python↔Mojo parameter-semantics parity."""

from std.collections import List
from std.sys import argv
from reta_mojo.semantics_builder import DataSlot, parameter_semantics_fingerprint
from reta_mojo.semantics_builder_catalog import bootstrap_full_parameter_semantics


def _slot_size(slot: DataSlot) -> Int:
    if slot.is_combination:
        return len(slot.combinations)
    return len(slot.bindings)


def _print_int_list(values: List[Int]) -> None:
    for index in range(len(values)):
        if index > 0:
            print(",", end="")
        print(values[index], end="")
    print()


def main() raises:
    var args = argv()
    var invert_alles = len(args) > 1 and String(args[1]) == "--invert"
    var name = "inverted" if invert_alles else "normal"
    var result = bootstrap_full_parameter_semantics(invert_alles)
    print("mode=" + name)
    print("matrix_entries=" + String(len(result.para_n_data_matrix)))
    print("para_main=" + String(len(result.para_main_dict)))
    print("para_dict=" + String(len(result.para_dict)))
    print("reverse1=" + String(len(result.kombi_reverse_dict)))
    print("reverse2=" + String(len(result.kombi_reverse_dict2)))
    print("simple_columns=" + String(len(result.all_simple_command_columns)))
    print("data_dict_sizes=", end="")
    var data_sizes = List[Int]()
    for index in range(len(result.data_dict)):
        data_sizes.append(_slot_size(result.data_dict[index]))
    _print_int_list(data_sizes)
    print("all_values_sizes=", end="")
    var all_value_sizes = List[Int]()
    for index in range(len(result.all_values)):
        all_value_sizes.append(len(result.all_values[index].values))
    _print_int_list(all_value_sizes)
    print("fingerprint=" + parameter_semantics_fingerprint(result).canonical())
